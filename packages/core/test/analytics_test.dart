import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mocks/mocks.dart';

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

    setUp(() {
      AnalyticsPlatform.instance = MockPlatform();

      // Prevents spamming the test console. Eventually logging info will be behind a debug flag so this won't be needed
      LogFactory.logger = Mocks.logTarget();

      SharedPreferences.setMockInitialValues({});
    });

    test(
        "it fetches settings but does not fire track event when not tracking lifecycle events",
        () async {
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));

      Analytics analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();

      verify(httpClient.settingsFor(writeKey));
      verifyNever(httpClient.startBatchUpload(writeKey, batch));
    });
    test(
        "it fetches settings and fires track event when tracking lifecycle events",
        () async {
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));

      Analytics analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: true,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();

      verify(httpClient.settingsFor(writeKey));
      verifyNever(httpClient.startBatchUpload(writeKey, batch));
    });
  });
}
