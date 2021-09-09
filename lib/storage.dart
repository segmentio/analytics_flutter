import 'package:analytics_flutter/state.dart';
import 'package:sovran/store.dart';
import 'package:sovran/subscriber.dart' as Subscribe;
import 'package:shared_preferences/shared_preferences.dart';

class Storage implements Subscribe.Subscriber {
  late final Store _store;
  late final String _writeKey;
  static const int MAX_FILE_SIZE = 475000;

  Storage(this._store, this._writeKey) {
    _store.subscribe(this, handler: (T) { });
    // _store.subscribe(true, this, (T) { });
    // _store.subscribe(true, subscriber, (T) { })
  }

  userInfoUpdate(UserInfo state) {

  }

  systemUpdate(System state) {

  }
}

extension on Storage {
  void userInfoUpdate() {

  }
}