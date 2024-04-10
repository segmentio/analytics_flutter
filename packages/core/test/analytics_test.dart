import 'package:analytics/analytics.dart';
import 'package:analytics/analytics_platform_interface.dart';
import 'package:analytics/logger.dart';
import 'package:analytics/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group("analytics", () {
    setUp(() {
      AnalyticsPlatform.instance = MockPlatform();

      // Prevents spamming the test console. Eventually logging info will be behind a debug flag so this won't be needed
      LogFactory.logger = Mocks.logTarget();
    });

    test(
        "it fetches settings but does not fire track event when not tracking lifecycle events",
        () async {
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(any))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(any, any))
          .thenAnswer((_) => Future.value(true));

      Analytics analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();

      verify(httpClient.settingsFor(any));
      verifyNever(httpClient.startBatchUpload(any, any));
    });
    test(
        "it fetches settings and fires track event when tracking lifecycle events",
        () async {
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(any))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(any, any))
          .thenAnswer((_) => Future.value(true));

      Analytics analytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: true,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();

      verify(httpClient.settingsFor(any));
      verify(httpClient.startBatchUpload(any, any));
    });
  });
}
