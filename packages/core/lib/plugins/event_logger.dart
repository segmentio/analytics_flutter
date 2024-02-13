import 'dart:convert';

import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/logger.dart';

class EventLogger extends DestinationPlugin {
  var logKind = LogFilterKind.debug;

  EventLogger() : super("event_logger");

  @override
  void configure(Analytics analytics) {
    pAnalytics = analytics;
  }

  @override
  Future<RawEvent?> execute(RawEvent event) async {
    log("${event.type.toString().toUpperCase()} event${event is TrackEvent ? " (${event.event})" : ''} saved: \n${jsonEncode(event.toJson())}",
        kind: logKind);
    return event;
  }
}
