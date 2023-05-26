import 'package:analytics/analytics.dart';
import 'package:analytics/event.dart';
import 'package:analytics/timeline.dart';
import 'package:flutter/foundation.dart';

abstract class Plugin {
  final PluginType type;

  @protected
  Analytics? pAnalytics;
  Analytics? get analytics => pAnalytics;

  Plugin(this.type);

  void clear() {
    pAnalytics = null;
  }

  void configure(Analytics analytics) {
    pAnalytics = analytics;
  }

  void update(Map<String, dynamic> settings, ContextUpdateType type) {
    // do nothing by default, user can override.
  }

  Future<RawEvent?> execute(RawEvent event) async {
    // do nothing by default, user can override.
    return event;
  }

  @mustCallSuper
  void shutdown() {
    pAnalytics = null;
  }
}

mixin Flushable {
  Future flush();
}
mixin Resetable {
  void reset();
}

abstract class EventPlugin extends Plugin with Flushable, Resetable {
  EventPlugin(super.type);

  @override
  Future<RawEvent?> execute(RawEvent event) {
    switch (event.type) {
      case EventType.identify:
        return identify(event as IdentifyEvent);
      case EventType.track:
        return track(event as TrackEvent);
      case EventType.screen:
        return screen(event as ScreenEvent);
      case EventType.alias:
        return alias(event as AliasEvent);
      case EventType.group:
        return group(event as GroupEvent);
    }
  }

  // Default implementations that forward the event. This gives plugin
  // implementors the chance to interject on an event.
  Future<RawEvent?> identify(IdentifyEvent event) async {
    return event;
  }

  Future<RawEvent?> track(TrackEvent event) async {
    return event;
  }

  Future<RawEvent?> screen(ScreenEvent event) async {
    return event;
  }

  Future<RawEvent?> alias(AliasEvent event) async {
    return event;
  }

  Future<RawEvent?> group(GroupEvent event) async {
    return event;
  }

  @override
  Future flush() async {}

  @override
  reset() {}
}

enum DestinationKey { none, firebase, adjust, amplitude }

abstract class DestinationPlugin extends EventPlugin {
  DestinationPlugin(this.key) : super(PluginType.destination);

  final String key;

  @protected
  Timeline timeline = Timeline();

  bool _hasSettings() {
    return analytics?.state.integrations != null;
  }

  bool _isEnabled(RawEvent event) {
    var customerDisabled = false;
    final settings = event.integrations?[key];
    if (settings == false) {
      customerDisabled = true;
    }

    return _hasSettings() && !customerDisabled;
  }

  /// Adds a new plugin to the currently loaded set.
  /// - Parameter plugin: The plugin to be added.
  /// - Returns: Returns the name of the supplied plugin.
  Plugin add(Plugin plugin) {
    final analytics = this.analytics;
    if (analytics != null) {
      plugin.configure(analytics);
    }
    timeline.add(plugin);
    return plugin;
  }

  /// Applies the supplied closure to the currently loaded set of plugins.
  /// - Parameter closure: A closure that takes an plugin to be operated on as a parameter.
  void apply(PluginClosure closure) {
    timeline.apply(closure);
  }

  @override
  void configure(Analytics analytics) {
    pAnalytics = analytics;
    apply((plugin) => plugin.configure(analytics));
  }

  /// Removes and unloads plugins with a matching name from the system.
  /// Parameter pluginName: An plugin name.
  void remove(Plugin plugin) {
    timeline.remove(plugin);
  }

  Future<RawEvent?> process(RawEvent event) async {
    if (!_isEnabled(event)) {
      return null;
    }

    final beforeResult = await timeline.applyPlugins(PluginType.before, event);
    if (beforeResult == null) {
      return null;
    }

    final enrichmentResult =
        await timeline.applyPlugins(PluginType.enrichment, event);
    if (enrichmentResult == null) {
      return null;
    }

    await super.execute(enrichmentResult);

    final afterResult = await timeline.applyPlugins(PluginType.after, event);
    return afterResult;
  }

  @override
  Future<RawEvent?> execute(RawEvent event) async {
    return process(event);
  }
}

abstract class UtilityPlugin extends EventPlugin {
  UtilityPlugin(super.type);
}

// For internal platform-specific bits
abstract class PlatformPlugin extends Plugin {
  PlatformPlugin(super.type);
}

/// PluginType specifies where in the chain a given plugin is to be executed.
enum PluginType {
  /// Executed before event processing begins.
  before,

  /// Executed as the first level of event processing.
  enrichment,

  /// Executed as events begin to pass off to destinations.
  destination,

  /// Executed after all event processing is completed.  This can be used to perform cleanup operations, etc.
  after,

  /// Executed only when called manually, such as Logging.
  utility
}

enum ContextUpdateType { initial, refresh }
