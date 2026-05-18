import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/state.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';

/// Simulates the BUGGY PluginIdfa behavior (before PR #198): fires off async
/// IDFA fetch in constructor without overriding execute() to await it.
class BuggyIdfaPlugin extends Plugin {
  final Completer<void> _fetchCompleter;

  BuggyIdfaPlugin(this._fetchCompleter) : super(PluginType.enrichment) {
    _simulateIdfaFetch();
  }

  Future<void> _simulateIdfaFetch() async {
    await _fetchCompleter.future;
    final context = await analytics?.state.context.state;
    if (context != null) {
      context.device.advertisingId = 'test-advertising-id';
      context.device.adTrackingEnabled = true;
      analytics?.state.context.setState(context);
    }
  }
}

/// Simulates the FIXED PluginIdfa behavior (PR #198): stores the future and
/// awaits it in execute(), blocking events until IDFA data is available.
class FixedIdfaPlugin extends Plugin {
  final Completer<void> _fetchCompleter;
  late final Future<void> _idfaFuture;

  FixedIdfaPlugin(this._fetchCompleter) : super(PluginType.enrichment) {
    _idfaFuture = _simulateIdfaFetch();
  }

  Future<void> _simulateIdfaFetch() async {
    await _fetchCompleter.future;
    final context = await analytics?.state.context.state;
    if (context != null) {
      context.device.advertisingId = 'test-advertising-id';
      context.device.adTrackingEnabled = true;
      analytics?.state.context.setState(context);
    }
  }

  @override
  Future<RawEvent?> execute(RawEvent event) async {
    await _idfaFuture;
    return event;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const writeKey = '123';
  final batch = [
    TrackEvent("Event 1"),
    TrackEvent("Event 2"),
    TrackEvent("Event 3"),
  ];

  group('IDFA plugin - advertisingId on initial events', () {
    late Analytics analytics;
    late MockHTTPClient httpClient;

    setUp(() async {
      AnalyticsPlatform.instance = MockPlatform();
      httpClient = Mocks.httpClient();
      when(httpClient.settingsFor(writeKey))
          .thenAnswer((_) => Future.value(SegmentAPISettings({})));
      when(httpClient.startBatchUpload(writeKey, batch))
          .thenAnswer((_) => Future.value(true));
      analytics = Analytics(
          Configuration(writeKey,
              trackApplicationLifecycleEvents: false,
              token: "test-token"),
          Mocks.store(),
          httpClient: (_) => httpClient);
      await analytics.init();
    });

    test('regression: without execute() override, events pass through before '
        'IDFA is ready', () async {
      // Demonstrates the bug from before PR #198: an enrichment plugin that
      // does async work in constructor but doesn't override execute() lets
      // events through immediately. This causes context.device.advertisingId
      // to be null when events are serialized to the queue.
      final fetchCompleter = Completer<void>();
      final plugin = BuggyIdfaPlugin(fetchCompleter);
      analytics.addPlugin(plugin);

      bool executeReturned = false;
      plugin.execute(TrackEvent("Application Opened")).then((_) {
        executeReturned = true;
      });

      await Future<void>.delayed(Duration.zero);

      // Confirms the buggy behavior: execute() returned without waiting
      expect(executeReturned, isTrue,
          reason: 'Without execute() override, events pass through immediately');

      fetchCompleter.complete();
    });

    test('fix: with execute() override, events are blocked until IDFA resolves',
        () async {
      // Validates the fix from PR #198: by overriding execute() to await the
      // IDFA future, no event can pass through the enrichment phase until
      // advertisingId is populated in context.
      final fetchCompleter = Completer<void>();
      final plugin = FixedIdfaPlugin(fetchCompleter);
      analytics.addPlugin(plugin);

      bool executeReturned = false;
      final executeFuture =
          plugin.execute(TrackEvent("Application Opened")).then((result) {
        executeReturned = true;
        return result;
      });

      await Future<void>.delayed(Duration.zero);

      // execute() is still blocked — waiting for IDFA
      expect(executeReturned, isFalse,
          reason: 'execute() must block until IDFA data is available');

      // Simulate native ATTrackingManager callback
      fetchCompleter.complete();
      await executeFuture;

      // advertisingId is now set before event passes through
      expect(executeReturned, isTrue);
      final context = await analytics.state.context.state;
      expect(context!.device.advertisingId, equals('test-advertising-id'));
    });
  });
}
