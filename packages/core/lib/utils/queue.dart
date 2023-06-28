import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Reducer<T> {
  final Future<T> Function() operation;
  final Completer<T> completer = Completer<T>();

  Reducer({required this.operation});
}

class ConcurrencyQueue<T> {
  final List<Reducer<T>> _queue = [];
  bool _lock = false;

  bool get _isLocked => (_lock == true);

  bool _tryUnlock(Reducer<T> op) {
    // We process and lock right away if the file is unlocked
    if (!_isLocked) {
      _lock = true;
      _process(op);
      return true;
    }
    return false;
  }

  Future<T> _process(Reducer<T> op) async {
    final result = await op.operation();
    // The actual operation future is resolved here so the caller doesn't await for the full queue
    op.completer.complete(result);
    _lock = false;

    // When the process completes we trigger the next one right away if there's already a queue
    if (_queue.isNotEmpty) {
      final nextOp = _queue.first;
      if (_tryUnlock(nextOp)) {
        _queue.removeAt(0);
      }
    }
    return result;
  }

  Future<T> enqueue(Future<T> Function() fun) async {
    final op = Reducer<T>(operation: fun);

    if (!_tryUnlock(op)) {
      _queue.add(op);
    }

    return op.completer.future;
  }
}
