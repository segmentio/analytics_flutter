import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/timer_flush_policy.dart';


void main() {
  group('TimerFlushPolicy Tests', () {
    test('start method starts the timer and sets shouldFlush to true after interval', () {
      fakeAsync((async) {
        final policy = TimerFlushPolicy(1000); // 1000 milliseconds = 1 second
        policy.start();

        expect(policy.shouldFlush, isFalse); // Initially shouldFlush is false

        async.elapse(const Duration(milliseconds: 1000)); // Advance time by 1 second
        expect(policy.shouldFlush, isTrue); // After 1 second, shouldFlush should be true
      });
    });

    test('onEvent method resets the timer', () {
      fakeAsync((async) {
        final policy = TimerFlushPolicy(1000); // 1000 milliseconds = 1 second
        final event = TrackEvent("Test"); // Asegúrate de definir RawEvent o usa un mock si es una clase compleja
        policy.start();

        async.elapse(const Duration(milliseconds: 500)); // Advance time by 0.5 second
        expect(policy.shouldFlush, isFalse); // shouldFlush is still false

        policy.onEvent(event); // Reset the timer
        async.elapse(const Duration(milliseconds: 500)); // Advance time by another 0.5 second
        expect(policy.shouldFlush, isFalse); // shouldFlush is still false because the timer was reset

        async.elapse(const Duration(milliseconds: 500)); // Advance time by another 0.5 second
        expect(policy.shouldFlush, isTrue); // After 1 second from the reset, shouldFlush should be true
      });
    });

    test('reset method resets the timer', () {
      fakeAsync((async) {
        final policy = TimerFlushPolicy(1000); // 1000 milliseconds = 1 second
        policy.start();

        async.elapse(const Duration(milliseconds: 500)); // Advance time by 0.5 second
        expect(policy.shouldFlush, isFalse); // shouldFlush is still false

        policy.reset(); // Reset the timer
        async.elapse(const Duration(milliseconds: 500)); // Advance time by another 0.5 second
        expect(policy.shouldFlush, isFalse); // shouldFlush is still false because the timer was reset

        async.elapse(const Duration(milliseconds: 500)); // Advance time by another 0.5 second
        expect(policy.shouldFlush, isTrue); // After 1 second from the reset, shouldFlush should be true
      });
    });
  });
}
