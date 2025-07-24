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
          version: getAppVersion(), // Patch Github Issue #138
          namespace: web.window.navigator.appCodeName,
        ),
        userAgent: web.window.navigator.userAgent,
        locale: web.window.navigator.language,
        referrer: web.window.document.referrer, // SETH PLZ CHECK ME ON THIS
        screen: NativeContextScreen(
          height: web.window.screen.height,
          width: web.window.screen.width,
        ),
      );
      
      /*
          - Checks for <meta name="app-version" content="1.2.3"> in <root>/web/index.html 
             and return the value inside 'content'
          - Returns the browser version as fallback
      */
      String getAppVersion() {
        final meta = web.document.querySelector('meta[name="app-version"]');
        return meta?.getAttribute('content') ?? web.window.navigator.appVersion;
      }
}

class AnalyticsWeb {
  static void registerWith(Registrar registrar) {
    AnalyticsPlatform.instance = AnalyticsPlatformImpl();
  }
}
