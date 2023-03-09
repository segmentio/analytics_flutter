import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'plugin_advertising_id_method_channel.dart';

abstract class PluginAdvertisingIdPlatform extends PlatformInterface {
  /// Constructs a PluginAdvertisingIdPlatform.
  PluginAdvertisingIdPlatform() : super(token: _token);

  static final Object _token = Object();

  static PluginAdvertisingIdPlatform _instance =
      MethodChannelPluginAdvertisingId();

  /// The default instance of [PluginAdvertisingIdPlatform] to use.
  ///
  /// Defaults to [MethodChannelPluginAdvertisingId].
  static PluginAdvertisingIdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PluginAdvertisingIdPlatform] when
  /// they register themselves.
  static set instance(PluginAdvertisingIdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getAdvertisingId() {
    throw UnimplementedError('getAdvertisingId() has not been implemented.');
  }
}
