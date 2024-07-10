import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:segment_analytics/client.dart';


void main() {
  late ScreenObserver screenObserver;
  late Stream<String> screenStream;
  late List<String> events;

  setUp(() {
    screenObserver = ScreenObserver();
    screenStream = screenObserver.screenStream;
    events = [];
    screenStream.listen((event) {
      events.add(event);
    });
  });  

  test('didPop adds previous route name to stream', () {
    final route = MaterialPageRoute(settings: const RouteSettings(name: '/new'), builder: (_) => Container());
    final previousRoute = MaterialPageRoute(settings: const RouteSettings(name: '/old'), builder: (_) => Container());
    screenObserver.didPop(route, previousRoute);
  });

  test('didPush adds new route name to stream', () {
    final route = MaterialPageRoute(settings: const RouteSettings(name: '/new'), builder: (_) => Container());
    screenObserver.didPush(route, null);   
  });

  test('didRemove adds route name to stream', () {
    final route = MaterialPageRoute(settings: const RouteSettings(name: '/remove'), builder: (_) => Container());
    screenObserver.didRemove(route, null);   
  });

  test('didReplace adds new route name to stream', () {
    final oldRoute = MaterialPageRoute(settings: const RouteSettings(name: '/old'), builder: (_) => Container());
    final newRoute = MaterialPageRoute(settings: const RouteSettings(name: '/new'), builder: (_) => Container());
    screenObserver.didReplace(newRoute: newRoute, oldRoute: oldRoute);   
  });
}
