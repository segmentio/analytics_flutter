library analytics_flutter;

import 'dart:convert' as convert;

import 'package:analytics_flutter/store.dart';
import 'package:analytics_flutter/timeline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'event.dart';
import 'types.dart';

class Config {
  final String writeKey;
  bool debug = false;
  // logger?: DeactivableLoggerType; // TODO Logger support

  int flushAt = 20;
  int flushInterval = 30;
  // flushPolicies?: FlushPolicy[]; // TODO Flush Policies support
  bool trackAppLifecycleEvents = false;
  int maxBatchSize = 1000;
  bool trackDeepLinks = false;
  bool autoAddSegmentDestination = true;
  bool collectDeviceId = false;
  String? proxy;

  SegmentAPISettings? defaultSettings;
  // errorHandler?: (error: SegmentError) => void; // TODO ErrorHandler support

  Config(this.writeKey);
}

class SegmentClient {
  final Config _config;
  final _timeline = Timeline();
  final _isReady = ValueNotifier(false);
  final _storage = InstanceStore(); // TODO: Composition, let users set this one

  SegmentClient(this._config) {
    // TODO: Initialize storage
    // TODO: Add Segment Destination
    // TODO: Add all our fancy plugins
    initialize();
  }

  void initialize() async {
    // TODO: Fetch Settings
    // TODO: Manual Flush
    // TODO: LifecycleEvents, Deeplinks and gather device data
    _isReady.value = true;
  }

  List<Plugin> get plugins => _timeline.allPlugins;

  Config get config => _config;

  void apply(void Function(Plugin) applyToPlugins) {
    _timeline.apply(applyToPlugins);
  }

  void add(Plugin plugin, {JSONMap? settings}) {
    if (plugin.type == PluginType.destination && settings != null) {
      // TODO: Add to Settings store if settings is not null
    }
    _addPlugin(plugin);
  }

  void _addPlugin(Plugin plugin) {
    plugin.configure(this);
    _timeline.add(plugin);
    // TODO: onPluginLoaded for stuff that is listening for plugins
  }

  void remove(Plugin plugin) {
    _timeline.remove(plugin);
  }

  Future<SegmentEvent?> process(SegmentEvent event) async {
    event = _applyRawEventData(event);
    // TODO: Queue events if storage isn't ready
    return _timeline.process(event);
  }

  SegmentEvent _applyRawEventData(SegmentEvent event) {
    event.messageId = const Uuid().toString();
    event.timestamp = DateTime.now().toIso8601String();
    event.integrations = {};
    return event;
  }

  Future<void> flush() async {
    // TODO: Reset flushpolicies
    List<Future<void>> futures = [];
    for (final plugin in _timeline.allPlugins) {
      if (plugin is EventPlugin) {
        futures.add(plugin.flush());
      }
    }
    await Future.wait(futures);
  }

  Future<SegmentEvent?> screen(String name, {JSONMap? options}) async {
    final event = ScreenEvent(name: name, properties: options);
    final result = await process(event);
    // TODO: Log
    return result;
  }

  Future<SegmentEvent?> identify(String userId, {JSONMap? traits}) async {
    final event = IdentifyEvent(userId: userId, traits: traits);
    final result = await process(event);
    // TODO: Log
    return result;
  }

  Future<SegmentEvent?> group(String groupId, {JSONMap? traits}) async {
    final event = GroupEvent(groupId: groupId, traits: traits);
    final result = await process(event);
    // TODO: Log
    return result;
  }

  Future<SegmentEvent?> track(String name, {JSONMap? properties}) async {
    final event = TrackEvent(name: name, properties: properties);
    final result = await process(event);
    // TODO: Log
    return result;
  }

  Future<SegmentEvent?> alias(String newUserId) async {
    final userInfo = await _storage.userInfo.getValue();
    final event = AliasEvent(
        previousId: userInfo.userId ?? userInfo.anonymousId, userId: newUserId);
    final result = await process(event);
    return result;
  }

  fetchSettings() async {
    final url = Uri.https(
        'cdn-settings.segment.com', "v1/projects/${config.writeKey}/settings");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as SegmentAPISettings;
      _storage.settings.setValue((currentValue) => Future.value(jsonResponse));
    } else {
      // TODO: Log errors properly
      print('Request failed with status ${response.statusCode}');
    }
  }
}
