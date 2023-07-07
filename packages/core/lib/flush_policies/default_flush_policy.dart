import 'package:analytics/flush_policies/count_flush_policy.dart';
import 'package:analytics/flush_policies/flush_policy.dart';
import 'package:analytics/flush_policies/startup_flush_policy.dart';
import 'package:analytics/flush_policies/timer_flush_policy.dart';

List<FlushPolicy> defaultFlushPolicies = [
  StartupFlushPolicy(),
  TimerFlushPolicy(20000),
  CountFlushPolicy(30),
];
