import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/count_flush_policy.dart';


void main() {
  group('CountFlushPolicy Tests', () {
    test('Initial count is set correctly', () {
      final policy = CountFlushPolicy(5);
      expect(policy.count, 0);
    });

    test('Start method resets count to 0', () {
      final policy = CountFlushPolicy(5, count: 3);
      policy.start();
      expect(policy.count, 0);
    });

    test('onEvent increments count and sets shouldFlush to true when _flushAt is reached', () {
      final policy = CountFlushPolicy(2);
      final event = TrackEvent("Test");

      policy.onEvent(event);
      expect(policy.count, 1);
      expect(policy.shouldFlush, false);

      policy.onEvent(event);
      expect(policy.count, 2);
      expect(policy.shouldFlush, true);
    });

    test('reset method calls super.reset and resets count to 0', () {
      final policy = CountFlushPolicy(5, count: 3);
      policy.reset();
      expect(policy.count, 0);
    });
  });
}
