import 'dart:async';
import 'package:analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter/widgets.dart';

abstract class LifeCycle extends Stream<AppStatus> {}

class LifeCycleImpl extends LifeCycle with WidgetsBindingObserver {
  final StreamController<AppLifecycleState> _streamController = StreamController<AppLifecycleState>.broadcast();

  LifeCycleImpl() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
      _streamController.add(state);
  }

  @override
  StreamSubscription<AppStatus> listen(void Function(AppStatus event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final subscription = _streamController.stream.listen((event) => event == AppLifecycleState.resumed ? AppStatus.foreground : AppStatus.background);
    return _LifeCycleSuscription(subscription);
  }
}

class _LifeCycleSuscription extends StreamSubscription<AppStatus> {
  final StreamSubscription<AppLifecycleState> _subscription;

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
            if (data == AppLifecycleState.resumed) {
              handleData(AppStatus.foreground);
            } else if (data == AppLifecycleState.paused || data == AppLifecycleState.inactive) {
              handleData(AppStatus.background);
            }
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

