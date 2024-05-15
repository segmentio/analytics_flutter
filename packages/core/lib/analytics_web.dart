import 'dart:async';
import 'dart:html' as html show window;

import 'package:segment_analytics/native_context.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:segment_analytics/analytics_platform_interface.dart';

export 'package:segment_analytics/client.dart';

/// A web implementation of the AnalyticsPlatform of the Analytics plugin.
class AnalyticsPlatformImpl extends AnalyticsPlatform {
  /// Constructs a AnalyticsWeb
  AnalyticsPlatformImpl();

  /// Returns a [String] containing the version of the platform.
  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) =>
      Future.value(NativeContext(
          app: NativeContextApp(
              name: html.window.navigator.appName,
              version: html.window.navigator.appVersion,
              namespace: html.window.navigator.appCodeName),
          userAgent: html.window.navigator.userAgent,
          locale: html.window.navigator.language,
          screen: html.window.screen != null
              ? NativeContextScreen(
                  height: html.window.screen?.height,
                  width: html.window.screen?.width)
              : null));
}

class AnalyticsWeb {
  static void registerWith(Registrar registrar) {
    AnalyticsPlatform.instance = AnalyticsPlatformImpl();
  }
}
