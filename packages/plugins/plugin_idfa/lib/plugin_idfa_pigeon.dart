import 'package:segment_analytics_plugin_idfa/native_idfa.dart';
import 'package:segment_analytics_plugin_idfa/plugin_idfa_platform_interface.dart';

/// An implementation of [AnalyticsPlatform] that uses Pigeon.
class PigeonPluginIdfa extends PluginIdfaPlatform {
  final NativeIdfaApi _api = NativeIdfaApi();

  @override
  Future<NativeIdfaData> getTrackingAuthorizationStatus() {
    return _api.getTrackingAuthorizationStatus();
  }
}
