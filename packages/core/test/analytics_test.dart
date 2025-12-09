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
import 'mocks/mock_store.dart';

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

    group("Integration Settings Persistence", () {
      test("settings loading and fallback behavior", () async {
        // Setup
        final testSettings = {"test_integration": {"setting1": "value1"}};
        final defaultSettings = {"default_integration": {"enabled": true}};
        AnalyticsPlatform.instance = MockPlatform();
        LogFactory.logger = Mocks.logTarget();
        SharedPreferences.setMockInitialValues({});

        // Test Case 1: First initialization with successful network fetch
        // ---------------------------------------------------------------
        // Create an in-memory store for testing
        final mockStore1 = InMemoryStore(storageJson: true);

        final httpClient1 = Mocks.httpClient();
        when(httpClient1.settingsFor(any))
            .thenAnswer((_) => Future.value(SegmentAPISettings(testSettings)));

        // Initialize analytics
        final analytics1 = Analytics(
          Configuration("test_key"),
          mockStore1,
          httpClient: (_) => httpClient1,
        );
        await analytics1.init();

        // Verify network settings are used
        final stateSettings1 = await analytics1.state.integrations.state;
        expect(stateSettings1, equals(testSettings),
            reason: "Should use settings from network");

        // Test Case 2: Network failure with default settings
        // --------------------------------------------------
        // Create an in-memory store for testing
        final mockStore2 = InMemoryStore(storageJson: true);

        final failingHttpClient = Mocks.httpClient();
        when(failingHttpClient.settingsFor(any))
            .thenAnswer((_) => Future.value(null));

        // Initialize analytics with default settings
        final analytics2 = Analytics(
          Configuration("test_key",
            defaultIntegrationSettings: defaultSettings
          ),
          mockStore2,
          httpClient: (_) => failingHttpClient,
        );
        await analytics2.init();

        // Verify default settings are used
        final stateSettings2 = await analytics2.state.integrations.state;
        expect(stateSettings2, equals(defaultSettings),
            reason: "Should fall back to default settings when network fails");

        // Test Case 3: Loading cached settings and refreshing from network
        // ---------------------------------------------------------------
        // Create an in-memory store with cached settings
        final cachedSettings = {"cached_integration": {"setting1": "cached"}};
        final mockStore3 = InMemoryStore(storageJson: true);

        // Seed the store with cached settings
        await mockStore3.setPersisted("integrations", cachedSettings);

        // Create HTTP client that returns new settings
        final newNetworkSettings = {"network_integration": {"setting1": "new"}};
        final httpClient3 = Mocks.httpClient();
        when(httpClient3.settingsFor(any))
            .thenAnswer((_) => Future.value(SegmentAPISettings(newNetworkSettings)));

        // Initialize analytics
        final analytics3 = Analytics(
          Configuration("test_key"),
          mockStore3,
          httpClient: (_) => httpClient3,
        );

        // Before initialization, state would be empty
        expect(analytics3.state.integrations.hasListeners, isFalse);

        // Initialize analytics
        await analytics3.init();

        // After initialization with cached settings + network fetch, we should have the network settings
        final stateSettings3 = await analytics3.state.integrations.state;
        expect(stateSettings3, equals(newNetworkSettings),
            reason: "Should update cached settings with network settings");

        // Test Case 4: Network failure with cached settings
        // ------------------------------------------------
        // Create an in-memory store with cached settings
        final cachedSettings2 = {"cached_integration2": {"setting1": "cached2"}};
        final mockStore4 = InMemoryStore(storageJson: true);

        // Seed the store with cached settings
        await mockStore4.setPersisted("integrations", cachedSettings2);

        // Create failing HTTP client
        final httpClient4 = Mocks.httpClient();
        when(httpClient4.settingsFor(any))
            .thenAnswer((_) => Future.value(null));

        // Initialize analytics with default settings
        final analytics4 = Analytics(
          Configuration("test_key",
            defaultIntegrationSettings: defaultSettings
          ),
          mockStore4,
          httpClient: (_) => httpClient4,
        );
        await analytics4.init();

        // After initialization with network failure, we should have cached settings
        final stateSettings4 = await analytics4.state.integrations.state;
        expect(stateSettings4, equals(cachedSettings2),
            reason: "Should use cached settings when network fails, even with default settings");
      });
    });
  });
}

class MockAnalyticsPlatform extends AnalyticsPlatform { }