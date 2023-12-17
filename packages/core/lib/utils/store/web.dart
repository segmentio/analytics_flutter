import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:analytics/utils/store/store.dart';

class StoreImpl implements Store {
  html.Storage get localStorage => html.window.localStorage;

  @override
  Future<Map<String, dynamic>?> getPersisted(String key) {
    return _readFromStorage(key);
  }

  @override
  Future get ready => Future.value();

  @override
  Future setPersisted(String key, Map<String, dynamic> value) {
    return _writeToStorage(key, value);
  }

  String _getFileName(String fileKey) {
    return "analytics-flutter-$fileKey.json";
  }

  Future<void> _writeToStorage(
      String fileKey, Map<String, dynamic> data) async {
    localStorage.update(
      _getFileName(fileKey),
      (val) => json.encode(data),
      ifAbsent: () => json.encode(data),
    );
  }

  Future<Map<String, dynamic>?> _readFromStorage(String fileKey) async {
    final fileName = _getFileName(fileKey);

    String? anonymousId;
    if (fileKey == "userInfo") {
      final cookies = html.document.cookie?.split(";");
      if (cookies != null && cookies.isNotEmpty) {
        for (var cookie in cookies) {
          final cookieParts = cookie.split("=");
          if (cookieParts[0].trim() == "ajs_anonymous_id") {
            anonymousId = cookieParts[1];
          }
        }
      }
    }

    MapEntry<String, String>? data;
    try {
      data = localStorage.entries.firstWhere((i) => i.key == fileName);
    } on StateError {
      data = null;
    }
    if (data != null) {
      if (data.value == "{}") {
        if (anonymousId != null) {
          return {
            "anonymousId": anonymousId,
          };
        }

        return null; // Prefer null to empty map, because we'll want to initialise a valid empty value.
      }

      final jsonMap = json.decode(data.value) as Map<String, dynamic>;
      if (anonymousId != null) {
        jsonMap["anonymousId"] = anonymousId;
      }

      return jsonMap;
    } else {
      if (anonymousId != null) {
        return {
          "anonymousId": anonymousId,
        };
      }

      return null;
    }
  }

  @override
  void dispose() {}
}
