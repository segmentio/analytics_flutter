import 'dart:async';

import 'package:analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

class LifeCycleImpl extends LifeCycle {
  final _stream = FGBGEvents.stream;

  @override
  StreamSubscription<AppStatus> listen(void Function(AppStatus event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final subscription = _stream.listen((event) => event == FGBGType.foreground
        ? AppStatus.foreground
        : AppStatus.background);

    return _LifeCycleSuscription(subscription);
  }
}

class _LifeCycleSuscription extends StreamSubscription<AppStatus> {
  final StreamSubscription<FGBGType> _subscription;

  _LifeCycleSuscription(this._subscription);

  @override
  Future<E> asFuture<E>([E? futureValue]) {
    return _subscription.asFuture(futureValue);
  }

  @override
  Future<void> cancel() {
    return _subscription.cancel();
  }

  @override
  bool get isPaused => _subscription.isPaused;

  @override
  void onData(void Function(AppStatus data)? handleData) {
    _subscription.onData(handleData == null
        ? null
        : (data) {
            handleData(data == FGBGType.foreground
                ? AppStatus.foreground
                : AppStatus.background);
          });
  }

  @override
  void onDone(void Function()? handleDone) {
    _subscription.onData(handleDone == null
        ? null
        : (data) {
            handleDone();
          });
  }

  @override
  void onError(Function? handleError) {
    _subscription.onData(handleError == null
        ? null
        : (error) {
            handleError(error);
          });
  }

  @override
  void pause([Future<void>? resumeSignal]) {
    _subscription.pause(resumeSignal);
  }

  @override
  void resume() {
    _subscription.resume();
  }
}
