// import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_advertising_id/plugin_advertising_id.dart';
// import 'package:plugin_advertising_id/plugin_advertising_id_platform_interface.dart';
// import 'package:plugin_advertising_id/plugin_advertising_id_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockPluginAdvertisingIdPlatform
//     with MockPlatformInterfaceMixin
//     implements PluginAdvertisingIdPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final PluginAdvertisingIdPlatform initialPlatform = PluginAdvertisingIdPlatform.instance;

//   test('$MethodChannelPluginAdvertisingId is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelPluginAdvertisingId>());
//   });

//   test('getPlatformVersion', () async {
//     PluginAdvertisingId pluginAdvertisingIdPlugin = PluginAdvertisingId();
//     MockPluginAdvertisingIdPlatform fakePlatform = MockPluginAdvertisingIdPlatform();
//     PluginAdvertisingIdPlatform.instance = fakePlatform;

//     expect(await pluginAdvertisingIdPlugin.getPlatformVersion(), '42');
//   });
// }
