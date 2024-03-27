import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:flutter/services.dart';

import 'native_context.dart';

/// An implementation of [AnalyticsPlatform] that uses Pigeon.
class AnalyticsPlatformImpl extends AnalyticsPlatform {
  static const EventChannel _eChannel =
      EventChannel('analytics/deep_link_events');
  final NativeContextApi _api = NativeContextApi();

  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) {
    return _api.getContext(collectDeviceId);
  }

  @override
  late final Stream<Map<String, dynamic>> linkStream = _eChannel
      .receiveBroadcastStream()
      .map<Map<String, dynamic>>((dynamic link) => link.cast<String, dynamic>());
}