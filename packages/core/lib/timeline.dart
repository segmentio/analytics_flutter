import 'dart:async';

import 'package:analytics/errors.dart';
import 'package:analytics/event.dart';
import 'package:analytics/plugin.dart';
import 'package:analytics/logger.dart';

typedef TimelinePlugins = Map<PluginType, List<Plugin>>;
typedef PluginClosure = void Function(Plugin);

class Timeline {
  final TimelinePlugins _plugins = {};
  Future<List<RawEvent?>>? _beforeFuture;
  List<Future<RawEvent?>> _beforeQueue = [];

  List<Plugin> getPlugins(PluginType? ofType) {
    if (ofType != null) {
      return [...(_plugins[ofType] ?? [])];
    }
    return ([
      ...getPlugins(PluginType.before),
      ...getPlugins(PluginType.enrichment),
      ...getPlugins(PluginType.utility),
      ...getPlugins(PluginType.destination),
      ...getPlugins(PluginType.after),
    ]);
  }

  void add(Plugin plugin) {
    final type = plugin.type;
    if (_plugins.containsKey(type)) {
      _plugins[type]?.add(plugin);
    } else {
      _plugins[type] = [plugin];
    }
    final integrations = plugin.analytics?.state.integrations.state;
    var hasInitialSettings = false;
    if (integrations != null) {
      plugin.update(integrations, ContextUpdateType.initial);
      hasInitialSettings = true;
    }

    plugin.analytics?.state.integrations.addListener((newIntegrations) {
      plugin.update(
          newIntegrations,
          hasInitialSettings
              ? ContextUpdateType.refresh
              : ContextUpdateType.initial);
      hasInitialSettings = true;
    });
  }

  void remove(Plugin plugin) {
    final plugins = _plugins[plugin.type];
    if (plugins != null) {
      plugins.remove(plugin);
    }
  }

  void apply(PluginClosure closure) {
    _plugins.forEach((type, plugins) {
      for (var plugin in plugins) {
        closure(plugin);
      }
    });
  }

  Future<RawEvent?> process(RawEvent incomingEvent) async {
    // apply .before first, ensuring all .before phases for all events triggered
    // in a synchronous block are finished before moving onto the enrichment phase

    final index = _beforeQueue.length;
    _beforeQueue.add(applyPlugins(PluginType.before, incomingEvent));

    _beforeFuture ??= Future.delayed(const Duration(microseconds: 1), () async {
      final thisBeforeFutures = _beforeQueue;
      _beforeQueue = [];
      _beforeFuture = null;
      return await Future.wait(thisBeforeFutures);
    });

    final beforeResults = await _beforeFuture!;
    final beforeResult = beforeResults[index];

    if (beforeResult == null) {
      return null;
    }

    // .enrichment here is akin to source middleware in the old analytics-ios.
    final enrichmentResult =
        await applyPlugins(PluginType.enrichment, beforeResult);

    if (enrichmentResult == null) {
      return null;
    }

    // once the event enters a destination, we don't want
    // to know about changes that happen there. those changes
    // are to only be received by the destination.
    await applyPlugins(PluginType.destination, enrichmentResult);

    // apply .after plugins ...
    final afterResult = await applyPlugins(PluginType.after, enrichmentResult);

    return afterResult;
  }

  Future<RawEvent?> applyPlugins(PluginType type, RawEvent event) async {
    RawEvent? result = event;

    final plugins = _plugins[type];
    if (plugins != null) {
      for (var plugin in plugins) {
        if (result != null) {
          try {
            final pluginResult = plugin.execute(result);
            // Each destination is independent from each other, so we don't roll over changes caused internally in each one of their processing
            if (type != PluginType.destination) {
              result = await pluginResult;
            }
          } catch (error) {
            reportInternalError(PluginError(error));
            if (plugin.type == PluginType.destination) {
              log("Destination ${(plugin as DestinationPlugin).key} failed to execute: $error",
                  kind: LogFilterKind.warning);
            }
          }
        }
      }
    }
    return result;
  }
}

List<Flushable> getPluginsWithFlush(Timeline timeline) {
  List<Flushable> flushablePlugins = [];
  timeline._plugins.forEach((key, plugins) {
    for (var plugin in plugins) {
      if (plugin is Flushable) {
        flushablePlugins.add(plugin as Flushable);
      }
    }
  });

  return flushablePlugins;
}

List<Resetable> getPluginsWithReset(Timeline timeline) {
  List<Resetable> flushablePlugins = [];
  timeline._plugins.forEach((key, plugins) {
    for (var plugin in plugins) {
      if (plugin is Resetable) {
        flushablePlugins.add(plugin as Resetable);
      }
    }
  });

  return flushablePlugins;
}
