import 'package:segment_analytics_plugin_idfa/native_idfa.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'plugin_idfa_pigeon.dart';

abstract class PluginIdfaPlatform extends PlatformInterface {
  /// Constructs a PluginIdfaPlatform.
  PluginIdfaPlatform() : super(token: _token);

  static final Object _token = Object();

  static PluginIdfaPlatform _instance = PigeonPluginIdfa();

  /// The default instance of [PluginIdfaPlatform] to use.
  ///
  /// Defaults to [MethodChannelPluginIdfa].
  static PluginIdfaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PluginIdfaPlatform] when
  /// they register themselves.
  static set instance(PluginIdfaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<NativeIdfaData> getTrackingAuthorizationStatus() =>
      throw UnimplementedError('platformVersion() has not been implemented.');
}
