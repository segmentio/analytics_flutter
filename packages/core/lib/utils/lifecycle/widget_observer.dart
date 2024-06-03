import 'dart:async';

import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter/widgets.dart';

class WidgetObserverLifecycle extends LifeCycle with WidgetsBindingObserver {
  final StreamController<AppLifecycleState> _streamController =
      StreamController<AppLifecycleState>.broadcast();

  lifeCycleImpl() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _streamController.add(state);
  }

  @override
  StreamSubscription<AppStatus> listen(void Function(AppStatus event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _streamController.stream
        .map((event) => (event == AppLifecycleState.resumed)
            ? AppStatus.foreground
            : AppStatus.background)
        .listen(onData, onDone: onDone, onError: onError);
  }
}
