import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/state.dart';

typedef OnFlush = Future Function(List<RawEvent> events);

class QueueFlushingPlugin extends UtilityPlugin {
  QueueState<RawEvent>? _state;

  bool _isPendingUpload = false;
  final OnFlush _onFlush;

  // Gets executed last to keep the queue after all timeline processing is done
  /// @param onFlush callback to execute when the queue is flushed (either by reaching the limit or manually) e.g. code to upload events to your destination
  QueueFlushingPlugin(this._onFlush) : super(PluginType.after);

  @override
  configure(Analytics analytics) {
    super.configure(analytics);

    _state = QueueState("queue_flushing_plugin", analytics.store,
        (json) => eventFromJson(json));

    _state!.init(analytics.error, true);
  }

  @override
  Future<RawEvent> execute(RawEvent event) async {
    await _state!.ready;
    await _state!.add(event);
    return event;
  }

  /// Calls the onFlush callback with the events in the queue
  @override
  flush() async {
    if (_state != null) {
      await _state!.ready;
      final events = await _state!.state;
      try {
        if (!_isPendingUpload) {
          _isPendingUpload = true;
          await _onFlush(events);
          _state!.flush();
        }
      } finally {
        _isPendingUpload = false;
      }
    }
  }

  /// Removes one or multiple events from the queue
  /// @param events events to remove
  Future dequeue(List<RawEvent> eventsToRemove) async {
    await _state!.ready;
    final events = await _state!.events;
    for (var event in eventsToRemove) {
      events.remove(event);
    }
    _state!.setEvents(events);
  }
}
