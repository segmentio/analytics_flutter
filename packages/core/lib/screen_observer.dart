import 'dart:async';

import 'package:flutter/widgets.dart';

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
    final name = route.settings.name;
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
