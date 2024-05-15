import 'dart:io';

import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics_plugin_idfa/native_idfa.dart';

import 'plugin_idfa_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class IdfaData {
  final bool adTrackingEnabled;
  final String? advertisingId;
  final TrackingStatus? trackingStatus;

  IdfaData(this.adTrackingEnabled, this.advertisingId, this.trackingStatus);
}

class PluginIdfa extends Plugin {
  PluginIdfa({bool shouldAskPermission = true}) : super(PluginType.enrichment) {
    if (kIsWeb) {
      return;
    }
    if (!Platform.isIOS) {
      return;
    }
    if (shouldAskPermission) {
      getTrackingStatus();
    }
  }

  /// `requestTrackingPermission()` will prompt the user for
  /// tracking permission and returns a promise you can use to
  /// make additional tracking decisions based on the user response
  Future<bool> requestTrackingPermission() async {
    final idfaData = await getTrackingStatus();
    return idfaData.adTrackingEnabled;
  }

  Future<IdfaData> getTrackingStatus() async {
    final NativeIdfaData idfaData =
        await PluginIdfaPlatform.instance.getTrackingAuthorizationStatus();

    final context = await analytics?.state.context.state;

    if (context == null) {
    } else {
      context.device.adTrackingEnabled = idfaData.adTrackingEnabled ?? false;
      context.device.advertisingId = idfaData.advertisingId;
      context.device.trackingStatus = idfaData.trackingStatus?.toString();

      analytics?.state.context.setState(context);
    }

    return IdfaData(idfaData.adTrackingEnabled ?? false, idfaData.advertisingId,
        idfaData.trackingStatus);
  }
}
