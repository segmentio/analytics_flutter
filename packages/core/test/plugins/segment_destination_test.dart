import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugins/segment_destination.dart';
import 'package:segment_analytics/state.dart';
import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];
   final Map<String, dynamic> settings = {
      'key': "12345abcdef"
    };
  late SegmentDestination segmentDestination;
  late MockHTTPClient httpClient;
  setUp(() async {
    AnalyticsPlatform.instance = MockPlatform();
    segmentDestination = SegmentDestination();
     httpClient = Mocks.httpClient();
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
          analytics.state.integrations.state = settings;
      await analytics.init();
    segmentDestination.configure(analytics);
  });

  test('Test _sendEvents with empty events list', () async {
    await segmentDestination.sendEvents([]);
    // No assertions needed since it should just return
  });

  test('Test _sendEvents with non-empty events list', () async {
    final List<TrackEvent> events = [
      TrackEvent('test_event', properties: {}),
    ];

    when(httpClient.startBatchUpload(any, any, host: anyNamed('host')))
        .thenAnswer((_) async => true);

    await segmentDestination.sendEvents(events);

    verify(httpClient.startBatchUpload(any, any, host: anyNamed('host')))
        .called(1);
  });

  test('Test flush method', () async {
    await segmentDestination.flush();
    // Assert the flush method calls the flush of the queue plugin
  });
}
