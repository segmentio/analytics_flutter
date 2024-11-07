library analytics;

import 'dart:async';

import 'package:segment_analytics/client.dart';
import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';
import 'package:segment_analytics/flush_policies/flush_policy_executor.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/native_context.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/plugins/segment_destination.dart';
import 'package:segment_analytics/state.dart';
import 'package:segment_analytics/timeline.dart';
import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:uuid/uuid.dart';
import 'analytics_platform_interface.dart';
import 'package:segment_analytics/version.dart';
import 'package:segment_analytics/utils/http_client.dart';
import 'package:segment_analytics/plugins/inject_user_info.dart';
import 'package:segment_analytics/plugins/inject_context.dart';
import 'package:segment_analytics/plugins/inject_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Analytics with ClientMethods {
  static String version() => segmentVersion;
  static bool debug = false;

  StateManager get state => _state;
  final StateManager _state;
  Store get store => _store;
  final Store _store;
  late final HTTPClient httpClient;
  AppStatus? _appState;
  StreamSubscription<AppStatus>? _appStateSubscription;
  bool _destroyed = false;
  bool _isInitialized = false;
  late FlushPolicyExecuter _flushPolicyExecuter;
  final List<RawEvent> _pendingEvents = [];
  final _onContextLoaded = NotifierImpl<ContextUpdateType>();
  final _onPluginLoaded = NotifierImpl<Plugin>();
  final Timeline _timeline;
  final List<Plugin> _pluginsToAdd = [];
  Function? _deepLinkDataListener;

  final List<PlatformPlugin> _platformPlugins = [
    InjectUserInfo(),
    InjectContext(),
  ];

  void error(Exception exception) {
    reportInternalError(exception, analytics: this);
  }

  Analytics(Configuration config, this._store,
      {HTTPClient Function(Analytics)? httpClient})
      : _state = StateManager(_store, System(true, false), config),
        _timeline = Timeline() {
    _state.init(error, config.storageJson!);

    this.httpClient = httpClient == null ? HTTPClient(this) : httpClient(this);

    state.ready.then((_) => _onStateReady());

    if (config.autoAddSegmentDestination) {
      final segmentDestination = SegmentDestination();
      addPlugin(segmentDestination);
    }

    if(config.token != null) {
      _platformPlugins.add(InjectToken(config.token!));
    }

    // Setup platform specific plugins
    _platformPlugins.forEach(addPlugin);

    // Start flush policies
    final flushPolicies = state.configuration.state.flushPolicies ?? [];
    _flushPolicyExecuter = FlushPolicyExecuter(flushPolicies, () => flush());
    _flushPolicyExecuter.start();
  }

  /// Executes when the state store is initialized.
  /// @param isReady
  void _onStateReady() {
    if (state.configuration.state.trackDeeplinks) {
      AnalyticsPlatform.instance.linkStream.listen((event) {
        if (state.configuration.state.trackDeeplinks) {
          _trackDeepLinkEvent(DeepLinkData.fromJson(event));
        }
      });
    }

    for (var plugin in _pluginsToAdd) {
      _addPlugin(plugin);
    }

    // Send all events in the queue
    for (var e in _pendingEvents) {
      _timeline.process(e);
    }
    _pendingEvents.clear();
  }

  /// Registers a callback for when the client has loaded the device context. This happens at the startup of the app, but
  /// it is handy for plugins that require context data during configure as it guarantees the context data is available.
  ///
  /// If the context is already loaded it will call the callback immediately.
  ///
  /// @param callback Function to call when context is ready.
  void Function() onContextLoaded(void Function(ContextUpdateType) callback) =>
      _onContextLoaded
          .addListener((context) => context != null ? callback(context) : null);

  /// Registers a callback for each plugin that gets added to the analytics client.
  /// @param callback Function to call
  void Function() onPluginLoaded(void Function(Plugin) callback) =>
      _onPluginLoaded
          .addListener((plugin) => plugin != null ? callback(plugin) : null);

  List<Plugin> getPlugins(PluginType? ofType) {
    return _timeline.getPlugins(ofType);
  }

  /// Adds a new plugin to the currently loaded set.
  /// @param {{ plugin: Plugin, settings?: IntegrationSettings }} Plugin to be added. Settings are optional if you want to force a configuration instead of the Segment Cloud received one
  void addPlugin(Plugin plugin, {Map<String, dynamic>? settings}) {
    // plugins can either be added immediately or
    // can be cached and added later during the next state update
    // this is to avoid adding plugins before network requests made as part of setup have resolved
    if (settings != null && plugin.type == PluginType.destination) {
      state.integrations
          .addIntegration((plugin as DestinationPlugin).key, settings);
    }

    if (!state.isReady) {
      _pluginsToAdd.add(plugin);
    } else {
      _addPlugin(plugin);
    }
  }

  void _addPlugin(Plugin plugin) {
    plugin.configure(this);
    _timeline.add(plugin);
    _onPluginLoaded.set(plugin);
  }

  /// Removes and unloads plugins with a matching name from the system.
  /// - Parameter pluginName: An plugin name.
  void removePlugin(Plugin plugin) {
    _timeline.remove(plugin);
  }

  /// Adds a FlushPolicy to the list
  /// @param policies policies to add
  void addFlushPolicy(List<FlushPolicy> policies) {
    for (var policy in policies) {
      _flushPolicyExecuter.add(policy);
    }
  }

  /// Removes a FlushPolicy from the execution
  ///
  /// @param policies policies to remove
  /// @returns true if the value was removed, false if not found
  void removeFlushPolicy(List<FlushPolicy> policies) {
    for (var policy in policies) {
      _flushPolicyExecuter.remove(policy);
    }
  }

  /// Returns the current enabled flush policies
  List<FlushPolicy> getFlushPolicies() {
    return _flushPolicyExecuter.policies;
  }

  @override
  Future reset({bool? resetAnonymousId = true}) async {
    final anonymousId = resetAnonymousId == true
        ? const Uuid().v4()
        : (await state.userInfo.state).anonymousId;

    state.userInfo.setState(UserInfo(anonymousId));

    getPluginsWithReset(_timeline).forEach((plugin) => plugin.reset());

    log("Client has been reset", kind: LogFilterKind.debug);
  }

  @override
  Future flush() async {
    if (_destroyed) {
      return;
    }

    _flushPolicyExecuter.reset();

    await Future.wait(
        getPluginsWithFlush(_timeline).map((plugin) => plugin.flush()));
  }

  void _trackDeepLinkEvent(DeepLinkData deepLinkProperties) {
    if (deepLinkProperties.url != '') {
      track("Deep Link Opened", properties: deepLinkProperties.toJson());
    }
  }

  @override
  Future track(String event, {Map<String, dynamic>? properties}) async {
    await _process(TrackEvent(event, properties: properties ?? {}));
  }

  @override
  Future screen(String name, {Map<String, dynamic>? properties}) async {
    final event = ScreenEvent(name, properties: properties ?? {});

    await _process(event);
  }

  @override
  Future identify({String? userId, UserTraits? userTraits}) async {
    final event = IdentifyEvent(userId: userId, traits: userTraits);

    await _process(event);
  }

  @override
  Future group(String groupId, {GroupTraits? groupTraits}) async {
    final event = GroupEvent(groupId, traits: groupTraits);

    await _process(event);
  }

  @override
  Future alias(String newUserId) async {
    final userInfo = await state.userInfo.state;
    final event =
        AliasEvent(userInfo.userId ?? userInfo.anonymousId, userId: newUserId);

    await _process(event);
  }

  Future init() async {
    if (_isInitialized) {
      log("SegmentClient already initialized", kind: LogFilterKind.warning);
      return;
    }

    await _fetchSettings();

    // flush any stored events
    _flushPolicyExecuter.manualFlush();

    // set up tracking for lifecycle events
    _setupLifecycleEvents();

    // save the current installed version
    await _checkInstalledVersion();

    _isInitialized = true;
  }

  Future<void> cleanup() {
    _flushPolicyExecuter.cleanup();
    Future<void>? future = _appStateSubscription?.cancel();
    if (_deepLinkDataListener != null) {
      _deepLinkDataListener!();
    }
    _appState = null;
    if (_appStateSubscription != null) {
      final f = _appStateSubscription!.cancel();
      if (future != null) {
        future = Future.wait([future, f]);
      } else {
        future = f;
      }
      _appStateSubscription = null;
    }
    if (_deepLinkDataListener != null) {
      _deepLinkDataListener!();
      _deepLinkDataListener = null;
    }
    _pendingEvents.clear();
    _pluginsToAdd.clear();

    _timeline.apply((plugin) {
      plugin.clear();
    });

    _destroyed = true;
    _isInitialized = false;
    return future ?? Future.value();
  }

  Future _checkInstalledVersion() async {
    final contextFuture = AnalyticsPlatform.instance
        .getContext(collectDeviceId: state.configuration.state.collectDeviceId);
    final previousContextFuture = state.context.state;
    final userInfo = state.userInfo.state;

    final contexts =
        await Future.wait([contextFuture, previousContextFuture, userInfo]);
    final context = Context.fromNative(contexts[0] as NativeContext,
        (contexts[2] as UserInfo).userTraits ?? UserTraits());
    final previousContext = contexts[1] as Context?;

    state.context.setState(previousContext == null
        ? context
        : mergeContext(context, previousContext));

    // Only callback during the intial context load
    if (previousContext == null) {
      _onContextLoaded.set(ContextUpdateType.initial);
    } else {
      _onContextLoaded.set(ContextUpdateType.refresh);
    }

    if (!state.configuration.state.trackApplicationLifecycleEvents) {
      return;
    }

    // Set a flag on the first launch to track installations/updates
    // We ignore this on web
    if (!kIsWeb) {
      const appInstalledFlag = "segment_app_installed";
      final prefs = await SharedPreferences.getInstance();
      final isAppInstalled = prefs.getBool(appInstalledFlag);

      if (isAppInstalled != true) {
        prefs.setBool(appInstalledFlag, true);
        track("Application Installed", properties: {
          "version": context.app.version,
          "build": context.app.build,
        });
      } else if (context.app.version != previousContext?.app.version) {
        track("Application Updated", properties: {
          "version": context.app.version,
          "build": context.app.build,
          "previous_version": previousContext?.app.version,
          "previous_build": previousContext?.app.build,
        });
      }
    }

    track("Application Opened", properties: {
      "from_background": false,
      "version": context.app.version,
      "build": context.app.build,
    });
  }

  Future _fetchSettings() async {
    final settings =
        await httpClient.settingsFor(state.configuration.state.writeKey);
    if (settings == null) {
      log("""Could not receive settings from Segment. ${state.configuration.state.defaultIntegrationSettings != null ? 'Will use the default settings.' : 'Device mode destinations will be ignored unless you specify default settings in the client config.'}""",
          kind: LogFilterKind.warning);

      state.integrations.state =
          state.configuration.state.defaultIntegrationSettings ?? {};
    } else {
      final integrations = settings.integrations;
      log("Received settings from Segment succesfully.");
      state.integrations.state = integrations;
    }
  }

  void _setupLifecycleEvents() {
    _appStateSubscription?.cancel();
    _appStateSubscription = state.configuration.state.appStateStream == null
        ? lifecycle.listen((nextAppState) {
            _handleAppStateChange(nextAppState);
          })
        : state.configuration.state.appStateStream!();
  }

  Future _process(RawEvent event) async {
    applyRawEventData(event);
    if (state.isReady) {
      final processedEvent = await _timeline.process(event);
      _flushPolicyExecuter.notify(event);
      return processedEvent;
    } else {
      _pendingEvents.add(event);
      return event;
    }
  }

  /// AppState event listener. Called whenever the app state changes.
  ///
  /// Send application lifecycle events if trackAppLifecycleEvents is enabled.
  ///
  /// Application Opened - only when the app state changes from 'inactive' or 'background' to 'active'
  ///   The initial event from 'unknown' to 'active' is handled on launch in checkInstalledVersion
  /// Application Backgrounded - when the app state changes from 'inactive' or 'background' to 'active
  ///
  /// @param nextAppState 'active', 'inactive', 'background' or 'unknown'
  Future _handleAppStateChange(AppStatus nextAppState) async {
    final priorAppState = _appState;
    _appState = nextAppState;

    if (state.configuration.state.trackApplicationLifecycleEvents) {
      if ((priorAppState == AppStatus.background) &&
          nextAppState == AppStatus.foreground) {
        final context = await state.context.state;
        track("Application Opened",
            properties: priorAppState == AppStatus.background
                ? {}
                : {
                    "from_background": true,
                    "version": context?.app.version,
                    "build": context?.app.build
                  });
        await _fetchSettings();
      } else if ((priorAppState == null ||
              priorAppState == AppStatus.foreground) &&
          nextAppState == AppStatus.background) {
        track("Application Backgrounded");
      }
    }
  }
}

mixin Notifier<T> {
  RemoveListener add(Listener<T> listener);
}

class NotifierImpl<T> extends StateNotifier<T?> with Notifier {
  NotifierImpl() : super(null);
  void set(T updateType) {
    state = updateType;
  }

  @override
  RemoveListener add(Listener<T> listener) {
    return addListener((state) {
      if (state != null) {
        listener(state);
      }
    });
  }
}
