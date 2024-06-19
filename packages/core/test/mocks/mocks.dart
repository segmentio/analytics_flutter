import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/native_context.dart';
import 'package:segment_analytics/utils/http_client.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<LogTarget>(),
  MockSpec<Request>(),
  MockSpec<StreamSubscription>(),
  MockSpec<HTTPClient>(),
  MockSpec<Store>(),
  MockSpec<FlushPolicy>(),
  MockSpec<Logger>(),
  MockSpec<NativeContextApi>(),
  MockSpec<WidgetsBinding>()
])
import 'mocks.mocks.dart';

class MockPlatform extends AnalyticsPlatform {
  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) {
    return Future.value(NativeContext(
        app: NativeContextApp(),
        device: NativeContextDevice(),
        library: NativeContextLibrary(),
        network: NativeContextNetwork(),
        os: NativeContextOS(),
        screen: NativeContextScreen()));
  }
}

class Mocks {
  static MockLogTarget logTarget() => MockLogTarget();
  static MockRequest request() => MockRequest();
  static MockStreamSubscription<T> streamSubscription<T>() =>
      MockStreamSubscription<T>();
  static MockHTTPClient httpClient() => MockHTTPClient();
  static MockStore store() => MockStore();
  static MockFlushPolicy flushPolicy() => MockFlushPolicy();
}
