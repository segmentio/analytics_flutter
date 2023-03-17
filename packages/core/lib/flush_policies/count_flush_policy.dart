import 'package:analytics/event.dart';
import 'package:analytics/flush_policies/flush_policy.dart';

class CountFlushPolicy extends FlushPolicy {
  int _count = 0;
  final int _flushAt;

  CountFlushPolicy(this._flushAt, {int? count}) : _count = count ?? 0;

  @override
  void start() {
    _count = 0;
  }

  @override
  onEvent(RawEvent event) {
    _count += 1;
    if (_count >= _flushAt) {
      shouldFlush = true;
    }
  }

  @override
  reset() {
    super.reset();
    _count = 0;
  }
}
