import 'package:analytics/flush_policies/flush_policy.dart';

class StartupFlushPolicy extends FlushPolicy {
  @override
  start() {
    shouldFlush = true;
  }
}
