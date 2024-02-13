import 'dart:convert';

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
}

void main() {
  group("Context", () {
    setUp(() {
      AnalyticsPlatform.instance = MockPlatform();
    });
    // });
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
  });
}
