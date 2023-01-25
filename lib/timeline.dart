import 'analytics_flutter.dart';
import 'event.dart';
import 'types.dart';

enum PluginType {
  before,
  enrichment,
  destination,
  after,
  utility,
}

enum UpdateType { initial, refresh }

// Plugins

abstract class Plugin {
  abstract final PluginType type;
  late final SegmentClient analytics;

  /// Links the plugin to a particular instance of analytics
  configure(SegmentClient analytics) {
    this.analytics = analytics;
  }

  /// Called by the Timeline for each new event tracked
  /// The Plugin can process and transformt the event
  /// Return null to drop an event and stop the rest of the timeline processing
  Future<T?> execute<T extends SegmentEvent>(T? event) async {
    return event;
  }

  /// Called when new settings are available from Segment Cloud
  update(SegmentAPISettings settings, UpdateType type) {
    // Don't do anything by default
  }

  /// Cleanup
  shutdown() {
    // Nothing by default
  }
}

abstract class EventPlugin extends Plugin {
  @override
  Future<T?> execute<T extends SegmentEvent>(T? event) async {
    if (event == null) {
      return null;
    }

    switch (event.type) {
      case EventType.identify:
        return identify(event as IdentifyEvent) as Future<T?>;
      case EventType.alias:
        return alias(event as AliasEvent) as Future<T?>;
      case EventType.group:
        return group(event as GroupEvent) as Future<T?>;
      case EventType.screen:
        return screen(event as ScreenEvent) as Future<T?>;
      case EventType.track:
        return track(event as TrackEvent) as Future<T?>;
    }
  }

  Future<SegmentEvent?> identify(IdentifyEvent event) async {
    return event;
  }

  Future<SegmentEvent?> alias(AliasEvent event) async {
    return event;
  }

  Future<SegmentEvent?> group(GroupEvent event) async {
    return event;
  }

  Future<SegmentEvent?> screen(ScreenEvent event) async {
    return event;
  }

  Future<SegmentEvent?> track(TrackEvent event) async {
    return event;
  }

  flush() async {}

  reset() {}
}

class DestinationPlugin extends Plugin {
  @override
  PluginType type = PluginType.destination;
}

class Timeline {
  final Map<PluginType, List<Plugin>> _plugins = {};
  static final _pluginOrder = [
    PluginType.before,
    PluginType.enrichment,
    PluginType.destination,
    PluginType.after
  ];

  List<Plugin> get allPlugins {
    List<Plugin> allPlugins = [];

    for (final val in _plugins.values) {
      allPlugins.addAll(val);
    }
    return allPlugins;
  }

  add(Plugin plugin) {
    final type = plugin.type;

    if (!_plugins.containsKey(type)) {
      _plugins[type] = [];
    }
    _plugins[type]!.add(plugin);

    // TODO: Check if there's settings to send to the plugin
    // plugin.analytics.settings.get()
  }

  void remove(Plugin plugin) {
    final type = plugin.type;

    if (_plugins.containsKey(type)) {
      _plugins[type]!.remove(plugin);
    }
  }

  void apply(void Function(Plugin) applyToPlugins) {
    allPlugins.map(applyToPlugins);
  }

  Future<SegmentEvent?> process(SegmentEvent event) async {
    SegmentEvent? result = event;

    for (final type in _pluginOrder) {
      result = await _applyPlugins(event, type);

      if (type != PluginType.destination && result == null) {
        break;
      }
    }

    return result;
  }

  Future<SegmentEvent?> _applyPlugins(
      SegmentEvent event, PluginType type) async {
    SegmentEvent? result = event;

    final plugins = _plugins[type] ?? [];
    for (final plugin in plugins) {
      if (result != null) {
        // TODO: Do not await destinations
        try {
          result = await plugin.execute(event);
          if (result == null) {
            break;
          }
        } catch (error) {
          // TODO: analytics.reportInternalError
          // TODO: analycis.logger.warn
          print(error);
        }
      }
    }
    return result;
  }
}
