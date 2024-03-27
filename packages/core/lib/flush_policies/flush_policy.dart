import 'package:segment_analytics/event.dart';
import 'package:state_notifier/state_notifier.dart';

abstract class FlushPolicy extends StateNotifier<bool> {
  FlushPolicy() : super(false);

  bool get shouldFlush => state;
  set shouldFlush(bool shouldFlush) => state = shouldFlush;

  /// Start gets executed when the FlushPolicy is added to the client.
  ///
  /// This is a good place to initialize configuration or timers as it will only
  /// execute when this policy is enabled
  void start() {}

  /// Executed every time an event is tracked by the client
  /// @param event triggered event
  void onEvent(RawEvent event) {}

  /// Resets the values of this policy.
  ///
  /// Called when the flush has been completed.
  void reset() {
    state = false;
  }
}
