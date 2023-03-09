// import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_idfa/plugin_idfa.dart';
// import 'package:plugin_idfa/plugin_idfa_platform_interface.dart';
// import 'package:plugin_idfa/plugin_idfa_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockPluginIdfaPlatform
//     with MockPlatformInterfaceMixin
//     implements PluginIdfaPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final PluginIdfaPlatform initialPlatform = PluginIdfaPlatform.instance;

//   test('$MethodChannelPluginIdfa is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelPluginIdfa>());
//   });

//   test('getPlatformVersion', () async {
//     PluginIdfa pluginIdfaPlugin = PluginIdfa();
//     MockPluginIdfaPlatform fakePlatform = MockPluginIdfaPlatform();
//     PluginIdfaPlatform.instance = fakePlatform;

//     expect(await pluginIdfaPlugin.getPlatformVersion(), '42');
//   });
// }
