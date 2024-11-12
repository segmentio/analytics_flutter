import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/event.dart';

import '../mocks/mocks.mocks.dart'; 

void main() {
  group('FlushPolicy Tests', () {
    test('Initial state is false', () {
      final policy = MockFlushPolicy();
      expect(policy.shouldFlush, isFalse);
    });

    test('shouldFlush can be set and retrieved', () {
      final policy = MockFlushPolicy();
      expect(policy.shouldFlush, isFalse);

      when(policy.shouldFlush).thenReturn(true);
      expect(policy.shouldFlush, isTrue);
    });

    test('start method sets startCalled to true', () {
      final policy = MockFlushPolicy();
      policy.start();
      verify(policy.start()).called(1);
    });

    test('onEvent method sets onEventCalled to true', () {
      final policy = MockFlushPolicy();
      final event = TrackEvent("Test");
      policy.onEvent(event);
      verify(policy.onEvent(event)).called(1);
    });

    test('reset method sets shouldFlush to false', () {
      final policy = MockFlushPolicy();
      policy.shouldFlush = true;
      policy.reset();
      expect(policy.shouldFlush, isFalse);
    });
  });
}
