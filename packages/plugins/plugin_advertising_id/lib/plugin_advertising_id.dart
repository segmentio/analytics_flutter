import 'dart:io';

import 'package:analytics/analytics.dart';
import 'package:analytics/plugin.dart';

import 'plugin_advertising_id_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PluginAdvertisingId extends Plugin {
  PluginAdvertisingId() : super(PluginType.enrichment);

  @override
  void configure(Analytics analytics) {
    super.configure(analytics);

    if (kIsWeb) {
      return;
    }
    if (!Platform.isAndroid) {
      return;
    }

    PluginAdvertisingIdPlatform.instance.getAdvertisingId().then((id) {
      if (id == null) {
        analytics
            .track('LimitAdTrackingEnabled (Google Play Services) is enabled');
      } else {
        setContext(id);
      }
    });
  }

  Future setContext(String id) async {
    final context = await analytics?.state.context.state;

    if (context == null) {
    } else {
      context.device.adTrackingEnabled = true;
      context.device.advertisingId = id;

      analytics?.state.context.setState(context);
    }
  }
}
