import 'dart:convert';

import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/state.dart';
import 'package:http/http.dart' as http;

class HTTPClient {
  static const defaultAPIHost = "api.segment.io/v1";
  static const defaultCDNHost = "cdn-settings.segment.com/v1";

  final WeakReference<Analytics> _analytics;

  HTTPClient(Analytics analytics) : _analytics = WeakReference(analytics);

  Uri _url(String host, String path) {
    String s = "https://$host$path";
    Uri result = Uri.parse(s);
    return result;
  }

  /// Starts an upload of events. Responds appropriately if successful or not. If not, lets the respondant
  /// know if the task should be retried or not based on the response.
  /// - Parameters:
  ///   - key: The write key the events are assocaited with.
  ///   - batch: The array of the events, considered a batch of events.
  ///   - completion: The closure executed when done. Passes if the task should be retried or not if failed.
  Future<bool> startBatchUpload(String writeKey, List<RawEvent> batch,
      {String? host}) async {
    final apihost = _analytics.target!.state.configuration.state.apiHost ??
        host ??
        defaultAPIHost;
    Uri uploadURL = _url(apihost, "/b");

    try {
      var urlRequest = _configuredRequest(uploadURL, "POST",
          body: jsonEncode({
            "batch": batch.map((e) => e.toJson()).toList(),
            "sentAt": DateTime.now().toUtc().toIso8601String(),
            "writeKey": _analytics.target!.state.configuration.state.writeKey,
          }));
      var f = urlRequest.send().then(http.Response.fromStream);

      var response = await f;

      if (response.statusCode < 300) {
        return true;
      } else if (response.statusCode < 400) {
        reportInternalError(NetworkUnexpectedHTTPCode(response.statusCode),
            analytics: _analytics.target);
        return false;
      } else if (response.statusCode == 429) {
        reportInternalError(NetworkServerLimited(response.statusCode),
            analytics: _analytics.target);
        return false;
      } else {
        reportInternalError(NetworkServerRejected(response.statusCode),
            analytics: _analytics.target);
        return false;
      }
    } catch (error) {
      log("Error uploading request ${error.toString()}",
          kind: LogFilterKind.error);
      return false;
    }
  }

  Future<SegmentAPISettings?> settingsFor(String writeKey) async {
    final settingsURL = _url(
        _analytics.target!.state.configuration.state.cdnHost,
        "/projects/$writeKey/settings");
    final urlRequest = _configuredRequest(settingsURL, "GET");

    try {
      final response = await urlRequest.send();

      if (response.statusCode > 300) {
        reportInternalError(NetworkUnexpectedHTTPCode(response.statusCode),
            analytics: _analytics.target);
        return null;
      }
      final data = await response.stream.toBytes();
      const decoder = JsonDecoder();
      final jsonMap =
          decoder.convert(utf8.decode(data)) as Map<String, dynamic>;
      return SegmentAPISettings.fromJson(jsonMap);
    } catch (error) {
      reportInternalError(NetworkUnknown(error.toString()),
          analytics: _analytics.target);
      return null;
    }
  }

  http.Request _configuredRequest(Uri url, String method, {String? body}) {
    var request = http.Request(method, url);
    request.headers.addAll({
      "Content-Type": "application/json; charset=utf-8",
      "User-Agent": "analytics-flutter/${Analytics.version()}",
      "Accept-Encoding": "gzip"
    });
    if (body != null) {
      request.body = body;
    }
    return _analytics.target?.state.configuration.state.requestFactory != null
        ? _analytics.target!.state.configuration.state.requestFactory!(request)
        : request;
  }
}
