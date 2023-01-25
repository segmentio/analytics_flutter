import 'package:analytics_flutter/event.dart';
import 'package:analytics_flutter/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

class PwnTracks extends EventPlugin {
  @override
  PluginType type = PluginType.before;

  @override
  Future<TrackEvent?> track(TrackEvent event) {
    event.name = 'PWNED!';
    // return Future<TrackEvent>.value(event);
    return Future<TrackEvent>.delayed(
        const Duration(milliseconds: 5), () => event);
  }
}

class ShortCircuitPlugin extends EventPlugin {
  @override
  PluginType type = PluginType.before;

  @override
  Future<TrackEvent?> track(TrackEvent event) {
    return Future<TrackEvent?>.value(null);
  }
}

void main() {
  test('timeline supports plugins', () async {
    final timeline = Timeline();

    timeline.add(PwnTracks());

    final event = await timeline.process(TrackEvent(name: 'Track whatever'));

    expect((event as TrackEvent).name, 'PWNED!');
  });

  test('plugins can shortcircuit timeline', () async {
    final timeline = Timeline();

    timeline.add(PwnTracks());
    timeline.add(ShortCircuitPlugin());

    final event = await timeline.process(TrackEvent(name: 'Track whatever'));

    expect(event, null);
  });
}
