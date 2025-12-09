import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/logger.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/mock_store.dart';

// Test that verifies the priority order of settings:
// 1. Network settings
// 2. Cached settings
// 3. Default settings
// 4. Empty map
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group("Integration Settings Priority Test", () {
    test("Settings priority order: network > cache > default > empty", () async {
      // Setup
      final networkSettings = {"network_integration": {"setting1": "network_value"}};
      final cachedSettings = {"cached_integration": {"setting1": "cached_value"}};
      final defaultSettings = {"default_integration": {"setting1": "default_value"}};

      AnalyticsPlatform.instance = MockPlatform();
      LogFactory.logger = Mocks.logTarget();
      SharedPreferences.setMockInitialValues({});

      // Test Case 1: First Initialization with Network Success
      // ---------------------------------------------------------------
      // Create an in-memory store with no cached settings
      final mockStore1 = InMemoryStore(storageJson: true);

      // Note: settings will be stored directly in the InMemoryStore

      // Create HTTP client that returns network settings
      final httpClient1 = Mocks.httpClient();
      when(httpClient1.settingsFor(any))
          .thenAnswer((_) => Future.value(SegmentAPISettings(networkSettings)));

      // Initialize analytics
      final analytics1 = Analytics(
        Configuration("test_key",
          defaultIntegrationSettings: defaultSettings
        ),
        mockStore1,
        httpClient: (_) => httpClient1,
      );
      await analytics1.init();

      // Verify network settings are used in this session
      final stateSettings1 = analytics1.state.integrations.state;
      expect(stateSettings1, equals(networkSettings),
          reason: "Should use settings from network on first run");

      // Verify settings were persisted to storage
      final storedSettings = await mockStore1.getPersisted("integrations");
      expect(storedSettings, equals(networkSettings),
          reason: "Network settings should be stored to cache");

      // Test Case 2: Network Failure with Cached Settings
      // ---------------------------------------------------------------
      // Create an in-memory store with cached settings
      final mockStore2 = InMemoryStore(storageJson: true);

      // Seed the store with cached settings
      await mockStore2.setPersisted("integrations", networkSettings);

      // Create HTTP client that fails
      final failingHttpClient = Mocks.httpClient();
      when(failingHttpClient.settingsFor(any))
          .thenAnswer((_) => Future.value(null));

      // Initialize analytics
      final analytics2 = Analytics(
        Configuration("test_key",
          defaultIntegrationSettings: defaultSettings
        ),
        mockStore2,
        httpClient: (_) => failingHttpClient,
      );
      await analytics2.init();

      // Verify cached settings are used when network fails
      final stateSettings2 = analytics2.state.integrations.state;
      expect(stateSettings2, equals(networkSettings),
          reason: "Should use cached settings when network fails");

      // Test Case 3: No Network, No Cache - Uses Default Settings
      // ---------------------------------------------------------------
      final mockStore3 = InMemoryStore(storageJson: true);

      // No need to add any cached settings as the store starts empty

      final failingHttpClient2 = Mocks.httpClient();
      when(failingHttpClient2.settingsFor(any))
          .thenAnswer((_) => Future.value(null));

      final analytics3 = Analytics(
        Configuration("test_key",
          defaultIntegrationSettings: defaultSettings
        ),
        mockStore3,
        httpClient: (_) => failingHttpClient2,
      );
      await analytics3.init();

      // Verify default settings are used when no network and no cache
      final stateSettings3 = analytics3.state.integrations.state;
      expect(stateSettings3, equals(defaultSettings),
          reason: "Should use default settings when network fails and no cache");

      // Test Case 4: No Network, No Cache, No Default - Uses Empty Map
      // ---------------------------------------------------------------
      final mockStore4 = InMemoryStore(storageJson: true);

      // No need to add any cached settings as the store starts empty

      final failingHttpClient3 = Mocks.httpClient();
      when(failingHttpClient3.settingsFor(any))
          .thenAnswer((_) => Future.value(null));

      final analytics4 = Analytics(
        Configuration("test_key"), // No default settings
        mockStore4,
        httpClient: (_) => failingHttpClient3,
      );
      await analytics4.init();

      // Verify empty map is used as last resort
      final stateSettings4 = analytics4.state.integrations.state;
      expect(stateSettings4, equals({}),
          reason: "Should use empty map when all else fails");
    });
  });
}