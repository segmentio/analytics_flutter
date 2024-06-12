import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy_executor.dart';

import '../mocks/mocks.mocks.dart'; 

void main() {
  group('FlushPolicyExecuter Tests', () {
    test('start method starts all policies', () {
      final policy1 = MockFlushPolicy();
      final policy2 = MockFlushPolicy();
      final policies = [policy1, policy2];
      onFlush() {}
      final executer = FlushPolicyExecuter(policies, onFlush);

      executer.start();

      expect(executer.policies, containsAll(policies));
    });

    test('add method adds and starts a new policy', () {
      final policy1 = MockFlushPolicy();
      onFlush() {}
      final executer = FlushPolicyExecuter([], onFlush);

      executer.add(policy1);

      expect(executer.policies, contains(policy1));
    });

    test('remove method removes a policy', () {
      final policy1 = MockFlushPolicy();
      final policies = [policy1];
      onFlush() {}
      final executer = FlushPolicyExecuter(policies, onFlush);

      final result = executer.remove(policy1);

      expect(result, isTrue);
      expect(executer.policies, isNot(contains(policy1)));
    });

    test('manualFlush method triggers onFlush if any policy should flush', () {
      final policy1 = MockFlushPolicy();
      final onFlushCalled = <bool>[];
      onFlush() {
        onFlushCalled.add(true);
      }
      final executer = FlushPolicyExecuter([policy1], onFlush);

      when(policy1.shouldFlush).thenReturn(true);
      executer.manualFlush();
      expect(onFlushCalled, [true]);
    });

    test('notify method notifies all policies of an event', () {
      final policy1 = MockFlushPolicy();
      final policy2 = MockFlushPolicy();
      final policies = [policy1, policy2];
      onFlush() {}
      final executer = FlushPolicyExecuter(policies, onFlush);
      final event = TrackEvent("Test");

      executer.notify(event);
    });

    test('reset method resets all policies', () {
      final policy1 = MockFlushPolicy();
      final policy2 = MockFlushPolicy();
      final policies = [policy1, policy2];
      onFlush() {}
      final executer = FlushPolicyExecuter(policies, onFlush);

      executer.reset();
    });

    test('cleanup method unsubscribes all observers', () {
      final policy1 = MockFlushPolicy();
      onFlush() {}
      final executer = FlushPolicyExecuter([policy1], onFlush);

      executer.start();
      expect(executer.policies, contains(policy1));

      executer.cleanup();
    });
  });
}
