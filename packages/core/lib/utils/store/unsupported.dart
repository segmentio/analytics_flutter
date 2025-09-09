import 'dart:async';
import 'package:segment_analytics/errors.dart';

import 'store.dart';

class StoreImpl with Store {
  final bool storageJson;
  StoreImpl({this.storageJson = true});
  @override
  Future<Map<String, dynamic>?> getPersisted(String key) {
    throw PlatformNotSupportedError();
  }

  @override
  Future get ready => throw PlatformNotSupportedError();

  @override
  Future setPersisted(String key, Map<String, dynamic> value) {
    throw PlatformNotSupportedError();
  }
  
  @override
  Future deletePersisted(String key) {
    throw PlatformNotSupportedError();
  }

  @override
  void dispose() {
    throw PlatformNotSupportedError();
  }
}