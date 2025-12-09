import 'dart:async';

import 'package:segment_analytics/utils/store/store.dart';

/// An in-memory implementation of Store that doesn't access the file system
/// This is used for testing to avoid platform-specific file operations
class InMemoryStore implements Store {
  final Map<String, dynamic> _storage = {};
  final bool storageJson;

  InMemoryStore({this.storageJson = false});

  @override
  Future<Map<String, dynamic>?> getPersisted(String key) async {
    return _storage[key];
  }

  @override
  Future<void> setPersisted(String key, Map<String, dynamic> value) async {
    _storage[key] = value;
  }

  @override
  Future<void> removePersisted(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deletePersisted(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> dispose() async {
    _storage.clear();
  }

  @override
  Future<void> purge() async {
    _storage.clear();
  }

  @override
  Future<void> get ready => Future.value();
}