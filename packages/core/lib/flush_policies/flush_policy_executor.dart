import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';

typedef OnFlush = void Function();

class FlushPolicyExecuter {
  List<FlushPolicy> get policies => [..._policies];
  final List<FlushPolicy> _policies;
  final List<Function> _observers = [];
  final OnFlush _onFlush;

  FlushPolicyExecuter(this._policies, this._onFlush);

  void start() {
    for (var policy in _policies) {
      startPolicy(policy);
    }
  }

  void add(FlushPolicy policy) {
    startPolicy(policy);
    _policies.add(policy);
  }

  bool remove(FlushPolicy policy) {
    final i = _policies.indexOf(policy);
    return removeIndex(i);
  }

  bool removeIndex(int index) {
    if (index < 0 || index >= _policies.length) return false;

    final policy = _policies[index];

    policy.reset();
    _policies.removeAt(index);
    return true;
  }

  /// Checks if any flush policy is requesting a flush
  /// This is only intended for startup/initialization, all policy shouldFlush
  /// changes are already observed and reacted to.
  ///
  /// This is for policies that might startup with a shouldFlush = true value
  void manualFlush() {
    for (var policy in _policies) {
      if (policy.shouldFlush) {
        _onFlush();
        break;
      }
    }
  }

  /// Notifies each flush policy that an event is being processed
  void notify(RawEvent event) {
    for (var policy in _policies) {
      policy.onEvent(event);
    }
  }

  /// Resets all flush policies
  void reset() {
    for (var policy in _policies) {
      policy.reset();
    }
  }

  void cleanup() {
    for (var unsubscribe in _observers) {
      unsubscribe();
    }
  }

  void startPolicy(FlushPolicy policy) {
    policy.start();
    final observer = policy.addListener((shouldFlush) {
      if (shouldFlush) {
        _onFlush();
      }
    });

    _observers.add(observer);
  }
}
