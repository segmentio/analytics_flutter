import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'timeline.dart';
import 'types.dart';

class UserInfo {
  String anonymousId;
  String? userId;
  JSONMap? traits;

  UserInfo({required this.anonymousId, this.userId, this.traits});
}

class QueueNotifier<T> extends ChangeNotifier with ListMixin<T> {
  final List<T> _list = [];

  @override
  void add(T element) {
    super.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    super.addAll(iterable);
    notifyListeners();
  }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
  }

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
  }
}

class Reducer<T> {
  final Future<T> Function(T current) operation;
  final Completer<T> completer = Completer<T>();

  Reducer({required this.operation});
}

// TODO: We can use StreamController<T> instead to make a subscription, this does have the advantage of being able to handle async reducers slightly better though
class ConcurrencySafeState<T extends Object?> {
  final List<Reducer<T>> _queue = [];
  bool _lock = false;
  final ValueNotifier<T> _value;
  ConcurrencySafeState(T value) : _value = ValueNotifier(value);

  bool get _isLocked => (_lock == true);

  bool _tryUnlock(Reducer<T> op) {
    // If the file is unlo
    if (!_isLocked) {
      _lock = true;
      _process(op);
      return true;
    }
    return false;
  }

  Future<T> _process(Reducer<T> op) async {
    final currentValue = _value.value;
    final newValue = await op.operation(currentValue);
    _value.value = newValue;
    // Complete the Future so that it releases the current caller
    op.completer.complete(newValue);
    _lock = false;
    // Check if there's anything waiting, then execute those

    // TODO: If we check if the op is Read vs Write we can iterate over all the reads at once
    if (_queue.isNotEmpty) {
      final nextOp = _queue.first;
      if (_tryUnlock(nextOp)) {
        _queue.removeAt(0);
      }
    }

    return _value.value;
  }

  Future<T> setValue(Future<T> Function(T currentValue) operation) {
    final op = Reducer<T>(operation: operation);

    if (_queue.isNotEmpty || !_tryUnlock(op)) {
      _queue.add(op);
    }

    return op.completer.future;
  }

  Future<T> getValue() {
    final op = Reducer<T>(operation: (current) => Future.value(current));

    if (_queue.isNotEmpty || !_tryUnlock(op)) {
      _queue.add(op);
    }

    return op.completer.future;
  }

  void addListener(void Function() listener) {
    _value.addListener(listener);
  }

  void removeListener(void Function() listener) {
    _value.removeListener(listener);
  }
}

abstract class Store {
  ValueNotifier<bool> get isReady;
  ConcurrencySafeState<UserInfo> get userInfo;
  ConcurrencySafeState<SegmentAPISettings> get settings;
  ConcurrencySafeState<JSONMap> get context; // TODO: Better typing

  // TODO: Possibly define only the methods for storing, people might want to
  // store data differently as we have learned from RN
}

// TODO: Default values

class InstanceStore extends Store {
  final _isReady = ValueNotifier(true); // This Store is always ready
  final _userInfo =
      ConcurrencySafeState(UserInfo(anonymousId: const Uuid().toString()));
  final _settings = ConcurrencySafeState(SegmentAPISettings(integrations: {}));
  final _context = ConcurrencySafeState<JSONMap>({});

  @override
  ConcurrencySafeState<JSONMap> get context => _context;

  @override
  ConcurrencySafeState<SegmentAPISettings> get settings => _settings;

  @override
  ConcurrencySafeState<UserInfo> get userInfo => _userInfo;

  @override
  ValueNotifier<bool> get isReady => _isReady;
}
