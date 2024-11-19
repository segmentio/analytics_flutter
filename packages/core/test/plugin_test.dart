import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/state.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';

void main() {
   TestWidgetsFlutterBinding.ensureInitialized();
  // Define arguments
  String writeKey = '123';
  List<RawEvent> batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];
  group('Plugin Tests', () {
    late Plugin plugin;
    late Analytics mockAnalytics;
    late MockHTTPClient httpClient;
    
    setUp(() async {
      plugin = MockPlugin(PluginType.after); // Ejemplo con un tipo arbitrario
      AnalyticsPlatform.instance = MockPlatform();
      
      httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      mockAnalytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              token: "abcdef12345"),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await mockAnalytics.init();
    });

    test('Plugin clear should set analytics to null', () {
      plugin.configure(mockAnalytics);
      plugin.clear();
      expect(plugin.analytics, isNull);
    });

    test('Plugin configure should set analytics', () {
      plugin.configure(mockAnalytics);
      expect(plugin.analytics, equals(mockAnalytics));
    });

    test('Plugin execute should return the same event by default', () async {
      final mockEvent = TrackEvent("track test event");
      final result = await plugin.execute(mockEvent);
      expect(result, equals(mockEvent));
    });

    test('Plugin shutdown should set analytics to null', () {
      plugin.configure(mockAnalytics);
      plugin.shutdown();
      expect(plugin.analytics, isNull);
    });
  });

  group('EventPlugin Tests', () {
    late EventPlugin eventPlugin;
    late Analytics mockAnalytics;
    late MockHTTPClient httpClient;
    
    setUp(() async {
      eventPlugin = MockEventPlugin(PluginType.after);
      AnalyticsPlatform.instance = MockPlatform();
      
      httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      mockAnalytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              token: "abcdef12345"),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await mockAnalytics.init();
    });

    test('EventPlugin execute should call the correct method based on event type', () async {
      final mockIdentifyEvent = eventFromJson({"type":"identify"});
      final result = await eventPlugin.execute(mockIdentifyEvent);
      expect(result, equals(mockIdentifyEvent));

      final mockTrackEvent = eventFromJson({"type":"track", "event": "Test track json event"});
      final resultTrack = await eventPlugin.execute(mockTrackEvent);
      expect(resultTrack, equals(mockTrackEvent));

      final mockAliasEvent = eventFromJson({"type":"alias", "previousId": "Test track json event"});
      final resultAlias = await eventPlugin.execute(mockAliasEvent);
      expect(resultAlias, equals(mockAliasEvent));

      final mockGroupEvent = eventFromJson({"type":"group", "groupId": "Test track json event"});
      final resultGroup = await eventPlugin.execute(mockGroupEvent);
      expect(resultGroup, equals(mockGroupEvent));

      final mockScreenEvent = eventFromJson({"type":"screen", "name": "Test track json event"});
      final resultScreen = await eventPlugin.execute(mockScreenEvent);
      expect(resultScreen, equals(mockScreenEvent));

    });

    test('EventPlugin flush should be callable', () async {
      await eventPlugin.flush();
    });

    test('EventPlugin reset should be callable', () {
      eventPlugin.reset();
    });

  });

  group('DestinationPlugin Tests', () {
    late DestinationPlugin destinationPlugin;
    late Analytics mockAnalytics;
    late MockHTTPClient httpClient;
    
    setUp(() async {
      destinationPlugin = MockDestinationPlugin("1234567890");
      AnalyticsPlatform.instance = MockPlatform();
      
      httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      mockAnalytics = Analytics(
          Configuration("123",
              trackApplicationLifecycleEvents: false,
              token: "abcdef12345"),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await mockAnalytics.init();
    });

    test('DestinationPlugin execute should call the correct method based on event type', () async {
      final mockScreenEvent = eventFromJson({"type":"screen", "name": "Test track json event"});
      final resultScreen = await destinationPlugin.execute(mockScreenEvent);
      expect(resultScreen, isNull);

    });

    test('DestinationPlugin flush should be callable', () async {
      await destinationPlugin.flush();
    });

    test('DestinationPlugin reset should be callable', () {
      destinationPlugin.reset();
    });

  });
}

class MockPlugin extends Plugin {
  MockPlugin(super.type);
}
class MockEventPlugin extends EventPlugin {
  MockEventPlugin(super.type);
}
class MockDestinationPlugin extends DestinationPlugin {
  MockDestinationPlugin(super.type);
}
