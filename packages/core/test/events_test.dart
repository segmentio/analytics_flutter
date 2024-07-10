import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:segment_analytics/analytics_platform_interface.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/native_context.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPlatform extends AnalyticsPlatform {
  @override
  Future<NativeContext> getContext({bool collectDeviceId = false}) {
    final mockNativeContext = NativeContext();
    mockNativeContext.app = NativeContextApp();
    mockNativeContext.app!.name = "Segment Example";
    mockNativeContext.app!.version = "1.0";
    mockNativeContext.locale = "en_GB";
    mockNativeContext.os = NativeContextOS();
    mockNativeContext.os!.name = "iOS";
    mockNativeContext.os!.version = "14.1";
    mockNativeContext.screen = NativeContextScreen();
    mockNativeContext.screen!.height = 800;
    mockNativeContext.screen!.width = 600;
    mockNativeContext.timezone = "Europe/London";

    return Future.value(mockNativeContext);
  }

  final List<Object> contextObj = [
    "build",
    "name",
    "namespace",
    "version"
  ];

  final List<Object> deviceObj = [
    "id",
    "manufacturer",
    "model",
    "name",
    "type",
    false,
    "advertisingId",
    "trackingStatus",
    "token"
  ];

  final List<Object> libraryObj = [
    "name",
    "version"
  ];

  final List<Object> networkObj = [
    true,
    false,
    false
  ];

  final List<Object> osObj = [
    "name",
    "version"
  ];

  final List<Object> screenObj = [
    100,
    100,
    5.5
  ];

  Object buildObject() {
    final List<Object> encondeObj = [
      contextObj,
      deviceObj,
      libraryObj,
      "en_EN",
      networkObj,
      osObj,
      screenObj,
      "timezone",
      "userAgent"
    ];
    return encondeObj;
  }
}

void main() {
  group("Context", () {
    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      AnalyticsPlatform.instance = MockPlatform();
    });
    test("It gets native context", () async {
      final context = await AnalyticsPlatform.instance.getContext();
      expect(context.app, isNotNull);
    });
    test("It flattens custom properties", () async {
      final context = Context.fromNative(
          await AnalyticsPlatform.instance.getContext(),
          UserTraits(
              firstName: "Christy", custom: {"myCustomTrait": "customValue"}));

      final contextJson = context.toJson();

      expect(contextJson["traits"], isNotNull);
      expect(contextJson["traits"]["custom"], isNull);
      expect(contextJson["traits"]["myCustomTrait"], "customValue");
    });
    test("It handles custom properties", () async {
      final context = Context.fromNative(
          await AnalyticsPlatform.instance.getContext(),
          UserTraits(
              firstName: "Christy",
              custom: {"myCustomTrait": "customValue", "custom": "value"}));

      final contextJson = context.toJson();

      expect(contextJson["traits"], isNotNull);
      expect(contextJson["traits"]["custom"], "value");
    });
    test("JSON serialisation works with custom properties", () async {
      final context = Context.fromNative(
          await AnalyticsPlatform.instance.getContext(),
          UserTraits(
              firstName: "Christy",
              custom: {"myCustomTrait": "customValue", "custom": "value"}));

      final contextJson = context.toJson();
      final contextStr = jsonEncode(contextJson);
      final reverseContextJson = jsonDecode(contextStr);
      final reverseContext = Context.fromJson(reverseContextJson);

      expect(context.app.name, "Segment Example");
      expect(context.app.name, reverseContext.app.name);

      expect(context.traits.firstName, "Christy");
      expect(context.traits.firstName, reverseContext.traits.firstName);

      expect(context.traits.lastName, null);
      expect(reverseContext.traits.lastName, null);

      expect(context.traits.custom["myCustomTrait"], "customValue");
      expect(context.traits.custom["myCustomTrait"],
          reverseContext.traits.custom["myCustomTrait"]);

      expect(context.traits.custom["custom"], "value");
      expect(context.traits.custom["custom"],
          reverseContext.traits.custom["custom"]);
    });

    test("Test encode method on NativeContext", () async {
      final context = await AnalyticsPlatform.instance.getContext();
      final contextEncode = context.encode();
      expect(contextEncode.toString() != context.toString(), true);
    });

    test("Test decode method on NativeContext", () async {
      final encodeObject = MockPlatform().buildObject();
      final contextDecode = NativeContext.decode(encodeObject);
      expect(contextDecode.toString() != encodeObject.toString(), true);
    });

    test("Test encode method on NativeContextApp", () async {
      final context = await AnalyticsPlatform.instance.getContext();
      final contextEncode = context.app?.encode();
      expect(contextEncode.toString() != context.toString(), true);
    });

    test("Test encode method on NativeContextDevice", () async {
      final context = NativeContextDevice();
      final contextEncode = context.encode();
      expect(contextEncode.toString() != context.toString(), true);
    });

    test("Test encode method on NativeContextLibrary", () async {
      final context = NativeContextLibrary();
      final contextEncode = context.encode();
      expect(contextEncode.toString() != context.toString(), true);
    });

    test("Test encode method on NativeContextNetwork", () async {
      final context = NativeContextNetwork();
      final contextEncode = context.encode();
      expect(contextEncode.toString() != context.toString(), true);
    });

    test("Test writeValue of NativeContextApi", () {
      final nativeContextApi = NativeContextApi();
      nativeContextApi.getContext(true);
    });
    
  });
}
