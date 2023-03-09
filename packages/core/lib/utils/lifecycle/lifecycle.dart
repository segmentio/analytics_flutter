import 'dart:async';

import 'package:analytics/utils/lifecycle/impl.dart';

enum AppStatus { foreground, background }

abstract class LifeCycle extends Stream<AppStatus> {}

final LifeCycleImpl lifecycle = LifeCycleImpl();
