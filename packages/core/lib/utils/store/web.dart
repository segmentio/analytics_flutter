import 'dart:async';
import 'dart:convert';

import 'package:segment_analytics/utils/store/store.dart';
import 'package:web/web.dart' as web;

class StoreImpl implements Store {
  web.Storage get localStorage => web.window.localStorage;

  @override
  Future<Map<String, dynamic>?> getPersisted(String key) {
    return _readFromStorage(key);
  }

  @override
  Future get ready => Future.value();

  @override
  Future setPersisted(String key, Map<String, dynamic> value) {
    _writeToStorage(key, value);
    return Future.value();
  }

  String _getFileName(String fileKey) {
    return "analytics-flutter-$fileKey.json";
  }

  void _writeToStorage(String fileKey, Map<String, dynamic> data) {
    localStorage.setItem(
      _getFileName(fileKey),
      json.encode(data),
    );
  }

  Future<Map<String, dynamic>?> _readFromStorage(String fileKey) async {
    final fileName = _getFileName(fileKey);
    final data = localStorage.getItem(fileName);
    String anonymousId;

    if (fileKey == "userInfo") {
      anonymousId = getExistingAnonymousId();
      if (data != null) {
        final jsonDecoded = json.decode(data);
        if (anonymousId.isNotEmpty) {
          jsonDecoded["anonymousId"] = anonymousId;
          return jsonDecoded as Map<String, dynamic>;
        }
      } else if (anonymousId.isNotEmpty) {
        final json = {"anonymousId": anonymousId};
        return json;
      }
    }

    if (data != null) {
      if (data == "{}") {
        return null; // Prefer null to empty map, because we'll want to initialise a valid empty value.
      }
      return json.decode(data) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  @override
  void dispose() {}

  String getExistingAnonymousId() {
    var anonymousId = localStorage.getItem("ajs_anonymous_id");

    if (anonymousId?.isEmpty ?? true) {
      final cookies = web.document.cookie.split(";");
      if (cookies.isNotEmpty) {
        for (var cookie in cookies) {
          final cookieParts = cookie.split("=");
          if (cookieParts[0].trim() == "ajs_anonymous_id") {
            anonymousId = cookieParts[1];
          }
        }
      }
    }
    return anonymousId ?? '';
  }
}
