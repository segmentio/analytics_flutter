import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/flush_policies/startup_flush_policy.dart';

void main() {
  group('StartupFlushPolicy Tests', () {
    test('start method sets shouldFlush to true', () {
      final policy = StartupFlushPolicy();
      expect(policy.shouldFlush, isFalse);

      policy.start();
      expect(policy.shouldFlush, isTrue);
    });
  });
}