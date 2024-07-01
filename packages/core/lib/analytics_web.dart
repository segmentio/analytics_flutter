import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/native_context.dart';
import 'package:web/web.dart' as web;

export 'package:segment_analytics/client.dart';

/// A web implementation of the AnalyticsPlatform of the Analytics plugin.
class AnalyticsPlatformImpl extends AnalyticsPlatform {
  /// Constructs a AnalyticsWeb
  AnalyticsPlatformImpl();

  /// Returns a [String] containing the version of the platform.
  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) async =>
      NativeContext(
        app: NativeContextApp(
          name: web.window.navigator.appName,
          version: web.window.navigator.appVersion,
          namespace: web.window.navigator.appCodeName,
        ),
        userAgent: web.window.navigator.userAgent,
        locale: web.window.navigator.language,
        screen: NativeContextScreen(
          height: web.window.screen.height,
          width: web.window.screen.width,
        ),
      );
}

class AnalyticsWeb {
  static void registerWith(Registrar registrar) {
    AnalyticsPlatform.instance = AnalyticsPlatformImpl();
  }
}
