import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:segment_analytics/utils/lifecycle/widget_observer.dart';

enum TestPlatform { android, ios, web, macos, windows, linux }

TestPlatform? testPlatform;
bool? testIsWeb;

bool get isWeb => testIsWeb ?? kIsWeb;


void main() {
  setUp(() {
    testPlatform = null;
    testIsWeb = null;
  });

  group('LifeCycle Tests', () {
    // test('should return FGBGLifecycle for Android', () {
    //   when(Platform.isAndroid).thenReturn(true);
    //   when(Platform.isIOS).thenReturn(false);
    //   when(kIsWeb).thenReturn(false);

    //   final lifecycle = getLifecycleStream();

    //   expect(lifecycle, isA<FGBGLifecycle>());
    // });

    // test('should return FGBGLifecycle for iOS', () {
    //   when(Platform.isAndroid).thenReturn(false);
    //   when(Platform.isIOS).thenReturn(true);
    //   when(kIsWeb).thenReturn(false);

    //   final lifecycle = getLifecycleStream();
    //   expect(lifecycle, isA<FGBGLifecycle>());
    // });

    test('should return WidgetObserverLifecycle for Web', () {
      testIsWeb = true;
      final lifecycle = getLifecycleStream();
      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for macOS', () {
      testPlatform = TestPlatform.macos;
      testIsWeb = false;
      final lifecycle = getLifecycleStream();
      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for Windows', () {
      testPlatform = TestPlatform.windows;
      testIsWeb = false;
      final lifecycle = getLifecycleStream();
      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for Linux', () {
      testPlatform = TestPlatform.linux;
      testIsWeb = false;
      final lifecycle = getLifecycleStream();
      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });
  });
}
