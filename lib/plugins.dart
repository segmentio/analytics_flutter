import 'package:analytics_flutter/settings.dart';

import 'analytics.dart';

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

enum UpdateType {
  initial,
  refresh
}

abstract class Plugin {
  PluginType type;
  Analytics? analytics;

  void configure(Analytics analytics);
  void update(Settings settings, UpdateType type);
  T? execute<T extends RawEvent>(T? event);
  void shutdown();
}

abstract class EventPlugin implements Plugin {
  IdentifyEvent? identify(IdentifyEvent event);
}