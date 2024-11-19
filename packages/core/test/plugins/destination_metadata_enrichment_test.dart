import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/plugins/destination_metadata_enrichment.dart';
import 'package:segment_analytics/state.dart';

import '../mocks/mocks.dart';

void main() {
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];
  final Map<String, dynamic> settings = {
      'integrations': "12345abcdef"
    };
  group('DestinationMetadataEnrichment', () {
    late DestinationMetadataEnrichment plugin;
    late RawEvent event;
    late Analytics mockAnalytics;
    setUp(() async{
      AnalyticsPlatform.instance = MockPlatform();
      plugin = DestinationMetadataEnrichment('destinationKey');
      final httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      mockAnalytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              appStateStream: () => Mocks.streamSubscription()),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await mockAnalytics.init();
      mockAnalytics.state.integrations.state = settings;
      mockAnalytics.addPlugin(plugin);
      // ignore: invalid_use_of_protected_member
      plugin.pAnalytics = mockAnalytics;
      event = TrackEvent('test_event');
    });

    test('bundled keys are correctly added excluding the destinationKey', () async {
      final resultEvent = await plugin.execute(event);
      expect(resultEvent.metadata?.bundled, isNot(contains('unbundledIntegrations')));
    });
  });
}
