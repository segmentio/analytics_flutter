import 'dart:async';

import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/count_flush_policy.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';
import 'package:segment_analytics/flush_policies/startup_flush_policy.dart';
import 'package:segment_analytics/flush_policies/timer_flush_policy.dart';
import 'package:segment_analytics/plugins/event_logger.dart';
import 'package:segment_analytics/state.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:flutter/widgets.dart';

Analytics createClient(Configuration configuration) {
  if (configuration.debug) {
    Analytics.debug = true;
  }
  if (configuration.flushPolicies == null) {
    configuration = setFlushPolicies(configuration, defaultFlushPolicies);
  }

  final analytics = Analytics(configuration, storeFactory());

  if (configuration.debug) {
    analytics.addPlugin(EventLogger());
  }

  analytics.init();
  ScreenObserver().screenStream.listen((name) {
    analytics.screen(name);
  });

  return analytics;
}

mixin ClientMethods {
  Future track(String event, {Map<String, dynamic>? properties});
  Future screen(String name, {Map<String, dynamic>? properties});
  Future identify({String? userId, UserTraits? userTraits});
  Future group(String groupId, {GroupTraits? groupTraits});
  Future alias(String newUserId);
  Future flush();
  Future reset({bool? resetAnonymousId});
}

List<FlushPolicy> defaultFlushPolicies = [
  StartupFlushPolicy(),
  TimerFlushPolicy(20000),
  CountFlushPolicy(30),
];

class ScreenObserver extends NavigatorObserver {
  final StreamController<String> screenStreamController =
      StreamController.broadcast();

  Stream<String> get screenStream => screenStreamController.stream;

  static final ScreenObserver _singleton = ScreenObserver._internal();
  ScreenObserver._internal();
  factory ScreenObserver() {
    return _singleton;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = previousRoute?.settings.name;
    if (name != null) {
      screenStreamController.add(name);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      screenStreamController.add(name);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name != null) {
      screenStreamController.add(name);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name;
    if (name != null) {
      screenStreamController.add(name);
    }
  }
}
