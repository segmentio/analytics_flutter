import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/count_flush_policy.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/plugins/event_logger.dart';
import 'package:segment_analytics/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Define arguments
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];

  group("analytics", () {
    late Analytics analytics;
    late MockHTTPClient httpClient;
    setUp(() async {
      AnalyticsPlatform.instance = MockPlatform();
      // Prevents spamming the test console. Eventually logging info will be behind a debug flag so this won't be needed
      LogFactory.logger = Mocks.logTarget();
      SharedPreferences.setMockInitialValues({});

      httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));

      analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              token: "abcdef12345"),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();
    });

    test(
        "it fetches settings but does not fire track event when not tracking lifecycle events",
        () async {
      
      verify(httpClient.settingsFor(writeKey));
      verifyNever(httpClient.startBatchUpload(writeKey, batch));
    });
    test(
        "it fetches settings and fires track event when tracking lifecycle events",
        () async {

      verify(httpClient.settingsFor(writeKey));
      verifyNever(httpClient.startBatchUpload(writeKey, batch));
    });

    test('it analytics track should be callable', () {
      analytics.track("test track");
    });
    test('it analytics screen should be callable', () {
      analytics.screen("test screem");
    });
    test('it analytics identify should be callable', () {
      analytics.identify();
    });
    test('it analytics group should be callable', () {
      analytics.group("test group");
    });
    test('it analytics alias should be callable', () {
      analytics.alias("test alias");
    });
    test('it analytics cleanup should be callable', () {
      analytics.cleanup();
    });
    test('it analytics reset should be callable', () {
      analytics.reset();
    });
    test('it analytics addFlushPolicy should be callable', () {
      List<FlushPolicy> policies = [];
      policies.add(CountFlushPolicy(5));
      analytics.addFlushPolicy(policies);
    });
    test('it analytics getFlushPolicies should be callable', () {
      analytics.getFlushPolicies();
    });
    test('it analytics removeFlushPolicy should be callable', () {
      List<FlushPolicy> policies = [];
      policies.add(CountFlushPolicy(5));
      analytics.removeFlushPolicy(policies);
    });
    test('it analytics removePlugin should be callable', () {
      analytics.addPlugin(EventLogger(), settings: {"event":"Track Event"});
    });
    test('it analytics removePlugin should be callable', () {
      analytics.removePlugin(EventLogger());
    });
    test('it analytics onContextLoaded should be callable', () {
      analytics.onContextLoaded((p0) { });
    });
    test('it analytics onPluginLoaded should be callable', () {
      analytics.onPluginLoaded((p0) { });
    });
    
    test("Test analytics platform getContext", () {
      AnalyticsPlatform analyticsPlatform = MockAnalyticsPlatform();

      expect(
        () async => await analyticsPlatform.getContext(),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test("Test analytics platform linkStream", () {
      AnalyticsPlatform analyticsPlatform = MockAnalyticsPlatform();

      expect(
        () async => analyticsPlatform.linkStream,
        throwsA(isA<UnimplementedError>()),
      );
    });

    test("it createClient", () async {
      Analytics analytics = createClient(Configuration("123",
              debug: false,
              trackApplicationLifecycleEvents: true,
              trackDeeplinks: true,
              token: "abcdef12345")
              );
      expect(analytics, isA<Analytics>());
    });
  });
}

class MockAnalyticsPlatform extends AnalyticsPlatform { }