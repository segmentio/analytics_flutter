// test/inject_token_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugins/inject_token.dart';
import 'package:segment_analytics/state.dart';

import '../mocks/mocks.dart';


void main() {
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];
  group('InjectToken Tests', () {
    late InjectToken injectToken;

    setUp(() async {
      AnalyticsPlatform.instance = MockPlatform();
    });
 
    test('should inject token into event context', () async {
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

      injectToken = InjectToken('test-token');
      // ignore: invalid_use_of_protected_member
      injectToken.pAnalytics = analytics;

      final resultEvent = await injectToken.execute(TrackEvent("Test"));

      expect(resultEvent.context!.device.token, 'test-token');
    });
  });
}
