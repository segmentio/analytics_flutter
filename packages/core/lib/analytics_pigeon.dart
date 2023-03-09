import 'package:analytics/analytics_platform_interface.dart';

import 'native_context.dart';

/// An implementation of [AnalyticsPlatform] that uses Pigeon.
class AnalyticsPlatformImpl extends AnalyticsPlatform {
  final NativeContextApi _api = NativeContextApi();

  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) {
    return _api.getContext(collectDeviceId);
  }
}
