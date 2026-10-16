import 'dart:io';

import 'package:segment_analytics/event.dart';
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
  Future<IdfaData>? _trackingStatusFuture;

  PluginIdfa({bool shouldAskPermission = true}) : super(PluginType.enrichment) {
    if (kIsWeb) {
      return;
    }
    if (!Platform.isIOS) {
      return;
    }
    if (shouldAskPermission) {
      _trackingStatusFuture = getTrackingStatus();
    }
  }

  @override
  Future<RawEvent?> execute(RawEvent event) async {
    // Wait for the initial IDFA fetch to complete before allowing events through,
    // so that Application Installed / Application Opened are stamped with IDFA data.
    await _trackingStatusFuture;
    return event;
  }

  /// `requestTrackingPermission()` will prompt the user for
  /// tracking permission and returns a promise you can use to
  /// make additional tracking decisions based on the user response
  Future<bool> requestTrackingPermission() async {
    _trackingStatusFuture = getTrackingStatus();
    final idfaData = await _trackingStatusFuture!;
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
