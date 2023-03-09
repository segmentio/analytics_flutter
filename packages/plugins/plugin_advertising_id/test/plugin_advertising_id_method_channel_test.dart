// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_advertising_id/plugin_advertising_id_method_channel.dart';

// void main() {
//   MethodChannelPluginAdvertisingId platform = MethodChannelPluginAdvertisingId();
//   const MethodChannel channel = MethodChannel('plugin_advertising_id');

//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       return '42';
//     });
//   });

//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });

//   test('getPlatformVersion', () async {
//     expect(await platform.getPlatformVersion(), '42');
//   });
// }
