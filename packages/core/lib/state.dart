import 'dart:async';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:segment_analytics/utils/http_client.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:uuid/uuid.dart';
part 'state.g.dart';

class StateManager {
  bool get isReady => _isReady;
  Future get ready => _ready;
  bool _isReady = false;
  late Future _ready;

  final ConfigurationState configuration;
  final IntegrationsState integrations;
  final ContextState context;
  final SystemState system;
  final FiltersState filters;
  final DeepLinkDataState deepLinkData;
  final UserInfoState userInfo;

  void init(ErrorHandler errorHandler, bool storageJson) {
    filters.init(errorHandler, storageJson);
    deepLinkData.init(errorHandler, storageJson);
    userInfo.init(errorHandler, storageJson);
    context.init(errorHandler, storageJson);
  }

  StateManager(Store store, System system, Configuration configuration)
      : system = SystemState(system),
        configuration = ConfigurationState(configuration),
        integrations = IntegrationsState({}),
        filters = FiltersState(store),
        deepLinkData = DeepLinkDataState(store),
        userInfo = UserInfoState(store),
        context = ContextState(store, configuration) {
    _ready = Future.wait<void>(
            [filters.ready, deepLinkData.ready, userInfo.ready, context.ready])
        .then((_) => _isReady = true);
  }
}

mixin AsyncStateNotifier<T> {
  void setState(T value);
  Future<T> get state;
  bool get hasListeners;
  RemoveListener addListener(
    Listener<T> listener, {
    bool fireImmediately = true,
  });
  void dispose();
}

class NullableStateNotifier<T> extends StateNotifier<T?> {
  NullableStateNotifier() : super(null);
  @override
  get state => super.state;

  set nonNullState(T state) => super.state = state;
}

abstract class PersistedState<T> implements AsyncStateNotifier<T> {
  final Store _store;
  final NullableStateNotifier _notifier = NullableStateNotifier<T>();
  ErrorHandler? _errorHandler;
  Future? _persistance;
  bool _hasUpdated = false;
  final String _key;
  Completer<T>? _getCompleter;

  @protected
  Future modifyState(Future Function(T state) modifier) async {
    if (_notifier.state == null) {
      await state;
    }
    modifier(_notifier.state);
  }

  final Future<T> Function() _initialiser;
  final Completer<void> _readyCompleter = Completer<void>();
  late Future<void> _ready;
  bool _isReady = false;
  bool get isReady => _isReady;
  Future<void> get ready => _ready;
  Object? _error;

  @protected
  Map<String, dynamic> toJson(T t);

  @protected
  T fromJson(Map<String, dynamic> json);

  _whenPersistenceComplete() {
    if (_hasUpdated) {
      _hasUpdated = false;
      final state = _notifier.state;
      if (state == null) {
        if (_errorHandler != null) {
          _errorHandler!(InconsistentStateError(_key));
        } else {
          reportInternalError(InconsistentStateError(_key));
        }
      } else {}
      _persistance = _store
          .setPersisted(_key, toJson(state as T))
          .whenComplete(_whenPersistenceComplete);
    } else {
      _persistance = null;
    }
  }

  @override
  void setState(T value) {
    if (!isReady) {
      log("Setting state when not ready can lead to unexpected results. Await the ready future for safety.",
          kind: LogFilterKind.warning);
    }
    _notifier.nonNullState = value;
  }

  @override
  RemoveListener addListener(Listener<T> listener,
      {bool fireImmediately = true}) {
    return _notifier.addListener((v) {
      if (v != null) {
        listener(v);
      }
    }, fireImmediately: fireImmediately);
  }

  @override
  bool get hasListeners => _notifier.hasListeners;

  @override
  Future<T> get state async {
    if (_error != null) {
      return Future.error(_error as Object);
    }
    final s = _notifier.state;
    if (s == null) {
      if (_getCompleter == null) {
        final completer = Completer<T>();
        _getCompleter = completer;
        return completer.future;
      } else {
        return _getCompleter!.future;
      }
    } else {
      return s;
    }
  }

  void init(ErrorHandler errorHandler, bool storageJson) {
    this._errorHandler = errorHandler;
    addListener((state) {
      if (_persistance != null) {
        _hasUpdated = true;
      } else {
        _persistance = storageJson 
            ? _store
              .setPersisted(_key, toJson(state))
              .whenComplete(_whenPersistenceComplete) 
            : null;
      }
    });
    _store.ready.then<void>((_) async {
      final rawV = await _store.getPersisted(_key);
      T v;

      if (rawV == null) {
        final init = await _initialiser();
        _persistance = storageJson 
            ? _store
              .setPersisted(_key, toJson(init))
              .whenComplete(_whenPersistenceComplete) 
            : null;
        _notifier.nonNullState = init;
        v = init;
      } else {
        v = fromJson(rawV);
        _notifier.nonNullState = v;
      }

      _isReady = true;

      if (_getCompleter != null) {
        _getCompleter!.complete(v);
      }

      _readyCompleter.complete();

      return;
    }).catchError((e) {
      _error = e;
      // Clean file if exist a format error
      if(_error.toString().contains("FormatException")) {
        _store.setPersisted(_key, {});
        log("Clean file $_key with format error",
          kind: LogFilterKind.warning);
      } else {
        final wrappedError = ErrorLoadingStorage(e);
        errorHandler(wrappedError);
        throw wrappedError;
      }
    });
  }

  PersistedState(this._key, this._store, this._initialiser) {
    _ready = _readyCompleter.future;
  }

  @override
  void dispose() {
    _store.dispose();
    _notifier.dispose();
  }
}

class QueueState<T extends JSONSerialisable> extends PersistedState<List<T>> {
  QueueState(String key, Store store, this._elementFromJson)
      : super(key, store, () async {
          return [];
        });

  final T Function(Map<String, dynamic> json) _elementFromJson;

  Future<List<T>> get events => state;
  void setEvents(List<T> events) => setState([...events]);

  Future add(T t) async {
    await modifyState((state) async => setState([...state, t]));
  }

  void flush({int? number}) {
    setState([]);
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    final rawList = json['queue'] as List<dynamic>;
    return rawList.map((e) => _elementFromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson(List<T> t) {
    return {"queue": t.map((e) => e.toJson()).toList()};
  }
}

class SystemState extends StateNotifier<System> {
  SystemState(System system) : super(system);

  set isRunning(bool isRunning) {
    state = System(state.isEnabled, isRunning);
  }

  set isEnabled(bool isEnabled) {
    state = System(isEnabled, state.isRunning);
  }
}

class System {
  final bool isRunning;
  final bool isEnabled;

  System(this.isEnabled, this.isRunning);
}

class FiltersState extends PersistedState<DestinationFilters> {
  FiltersState(Store store)
      : super("filters", store, () async {
          return {};
        });

  @override
  DestinationFilters fromJson(Map<String, dynamic> json) {
    DestinationFilters filters = {};
    json.forEach((key, value) {
      filters[key] = RoutingRule.fromJson(value);
    });
    return filters;
  }

  @override
  Map<String, dynamic> toJson(DestinationFilters t) {
    Map<String, dynamic> json = {};
    t.forEach((key, value) {
      json[key] = value.toJson();
    });
    return json;
  }
}

class UserInfoState extends PersistedState<UserInfo> {
  UserInfoState(Store store)
      : super("userInfo", store, () async {
          return UserInfo(const Uuid().v4());
        });

  @override
  UserInfo fromJson(Map<String, dynamic> json) {
    return UserInfo.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(UserInfo t) {
    return t.toJson();
  }
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserInfo {
  final String anonymousId;
  final String? userId;
  final UserTraits? userTraits;
  final GroupTraits? groupTraits;

  UserInfo(this.anonymousId, {this.userId, this.groupTraits, this.userTraits});

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

class DeepLinkDataState extends PersistedState<DeepLinkData> {
  DeepLinkDataState(Store store)
      : super("deepLinkData", store, () async {
          return DeepLinkData("", "");
        });

  @override
  DeepLinkData fromJson(Map<String, dynamic> json) {
    return DeepLinkData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DeepLinkData t) {
    return t.toJson();
  }
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DeepLinkData {
  final String referringApplication;
  final String url;

  DeepLinkData(this.referringApplication, this.url);

  factory DeepLinkData.fromJson(Map<String, dynamic> json) =>
      _$DeepLinkDataFromJson(json);
  Map<String, dynamic> toJson() => _$DeepLinkDataToJson(this);
}

class ContextState extends PersistedState<Context?> {
  ContextState(Store store, Configuration config)
      : super("context", store, () async {
          return Context.fromNative(
              await AnalyticsPlatform.instance
                  .getContext(collectDeviceId: config.collectDeviceId),
              UserTraits());
        });

  @override
  Context fromJson(Map<String, dynamic> json) {
    return Context.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Context? t) {
    return t == null ? {} : t.toJson();
  }
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SegmentAPISettings {
  final Map<String, dynamic> integrations;
  final MiddlewareSettings? middlewareSettings;

  SegmentAPISettings(this.integrations, {this.middlewareSettings});

  factory SegmentAPISettings.fromJson(Map<String, dynamic> json) =>
      _$SegmentAPISettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentAPISettingsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class MiddlewareSettings {
  final List<RoutingRule> routingRules;

  MiddlewareSettings({this.routingRules = const []});

  factory MiddlewareSettings.fromJson(Map<String, dynamic> json) =>
      _$MiddlewareSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$MiddlewareSettingsToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RoutingRule {
  final String scope;
  @JsonKey(name: "target_type")
  final String targetType;
  final List<Matcher> matchers;
  final List<List<Transformer>> transformers;
  final String? destinationName;

  RoutingRule(this.scope, this.targetType,
      {this.destinationName,
      this.matchers = const [],
      this.transformers = const []});

  factory RoutingRule.fromJson(Map<String, dynamic> json) =>
      _$RoutingRuleFromJson(json);
  Map<String, dynamic> toJson() => _$RoutingRuleToJson(this);
}

typedef DestinationFilters = Map<String, RoutingRule>;

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Matcher {
  final String type;
  final String ir;

  Matcher(this.type, this.ir);

  factory Matcher.fromJson(Map<String, dynamic> json) =>
      _$MatcherFromJson(json);
  Map<String, dynamic> toJson() => _$MatcherToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Transformer {
  final String type;
  final TransformerConfig? config;

  Transformer(this.type, {this.config});

  factory Transformer.fromJson(Map<String, dynamic> json) =>
      _$TransformerFromJson(json);
  Map<String, dynamic> toJson() => _$TransformerToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TransformerConfig {
  final Map<String, List<String>>? allow;
  final Map<String, List<String>>? drop;
  final TransformerConfigSample? sample;
  final Map<String, TransformerConfigMap>? map;

  TransformerConfig({this.allow, this.drop, this.map, this.sample});

  factory TransformerConfig.fromJson(Map<String, dynamic> json) =>
      _$TransformerConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TransformerConfigToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TransformerConfigSample {
  final int percent;
  final String path;

  TransformerConfigSample(this.percent, this.path);

  factory TransformerConfigSample.fromJson(Map<String, dynamic> json) =>
      _$TransformerConfigSampleFromJson(json);
  Map<String, dynamic> toJson() => _$TransformerConfigSampleToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TransformerConfigMap {
  final dynamic set;
  final String? copy;
  final String? move;
  @JsonKey(name: "to_string")
  final bool? enableToString;

  TransformerConfigMap({this.copy, this.move, this.set, this.enableToString});

  factory TransformerConfigMap.fromJson(Map<String, dynamic> json) =>
      _$TransformerConfigMapFromJson(json);
  Map<String, dynamic> toJson() => _$TransformerConfigMapToJson(this);
}

class IntegrationsState extends StateNotifier<Map<String, dynamic>> {
  IntegrationsState(Map<String, dynamic> integrations) : super(integrations);

  @override
  Map<String, dynamic> get state => super.state;

  @override
  set state(Map<String, dynamic> state) => super.state = state;

  void addIntegration(String key, Map<String, dynamic> settings) {
    final integrations = state;
    integrations[key] = settings;
    state = integrations;
  }
}

class ConfigurationState extends StateNotifier<Configuration> {
  ConfigurationState(Configuration configuration) : super(configuration);

  @override
  Configuration get state => super.state;

  @override
  set state(Configuration state) => super.state = state;
}

class Configuration {
  final String writeKey;
  final bool debug;

  final bool collectDeviceId;
  final bool trackApplicationLifecycleEvents;
  final bool trackDeeplinks;
  final List<FlushPolicy>? flushPolicies;

  final int? maxBatchSize;
  final Map<String, dynamic>? defaultIntegrationSettings;
  final bool autoAddSegmentDestination;
  final String? apiHost;
  final String cdnHost;

  final RequestFactory? requestFactory;
  final StreamSubscription<AppStatus> Function()? appStateStream;
  final ErrorHandler? errorHandler;
  final bool? storageJson;

  final String? token;

  Configuration(this.writeKey,
      {this.apiHost,
      this.autoAddSegmentDestination = true,
      this.collectDeviceId = false,
      this.cdnHost = HTTPClient.defaultCDNHost,
      this.defaultIntegrationSettings,
      this.errorHandler,
      this.flushPolicies,
      this.appStateStream,
      this.requestFactory,
      this.trackApplicationLifecycleEvents = false,
      this.trackDeeplinks = false,
      this.debug = false,
      this.maxBatchSize,
      this.storageJson = true,
      this.token
      });
}

typedef ErrorHandler = void Function(Exception);
typedef RequestFactory = Request Function(Request);

Configuration setFlushPolicies(
    Configuration a, List<FlushPolicy> flushPolicies) {
  return Configuration(a.writeKey,
      apiHost: a.apiHost,
      autoAddSegmentDestination: a.autoAddSegmentDestination,
      cdnHost: a.cdnHost,
      debug: a.debug,
      defaultIntegrationSettings: a.defaultIntegrationSettings,
      errorHandler: a.errorHandler,
      flushPolicies: flushPolicies,
      maxBatchSize: a.maxBatchSize,
      requestFactory: a.requestFactory,
      trackApplicationLifecycleEvents: a.trackApplicationLifecycleEvents,
      trackDeeplinks: a.trackDeeplinks,
      storageJson: a.storageJson,
      token: a.token);
}
