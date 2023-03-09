import 'dart:async';

import 'package:analytics/utils/lifecycle/lifecycle.dart';

class LifeCycleImpl extends LifeCycle {
  @override
  StreamSubscription<AppStatus> listen(void Function(AppStatus event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (onData != null) {
      onData(AppStatus.foreground);
    }
    return LifeCycleSubsription();
  }
}

class LifeCycleSubsription extends StreamSubscription<AppStatus> {
  @override
  Future<E> asFuture<E>([E? futureValue]) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancel() async {}

  @override
  bool get isPaused => throw UnimplementedError();

  @override
  void onData(void Function(AppStatus data)? handleData) {
    if (handleData != null) {
      handleData(AppStatus.foreground);
    }
  }

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}
}
