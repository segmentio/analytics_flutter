import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'plugin_advertising_id_platform_interface.dart';

/// An implementation of [PluginAdvertisingIdPlatform] that uses method channels.
class MethodChannelPluginAdvertisingId extends PluginAdvertisingIdPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('plugin_advertising_id');

  @override
  Future<String?> getAdvertisingId() async {
    final version =
        await methodChannel.invokeMethod<String>('getAdvertisingId');
    return version;
  }
}
