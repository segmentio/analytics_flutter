import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:segment_analytics/utils/lifecycle/fgbg.dart';
import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:segment_analytics/utils/lifecycle/widget_observer.dart';

enum TestPlatform { android, ios, web, macos, windows, linux }

TestPlatform? testPlatform;
bool? testIsWeb;

bool get isWeb => testIsWeb ?? kIsWeb;

class MockPlatform {
  bool get isAndroid => testPlatform == TestPlatform.android;
  bool get isIOS => testPlatform == TestPlatform.ios;
  bool get isMacOS => testPlatform == TestPlatform.macos;
  bool get isWindows => testPlatform == TestPlatform.windows;
  bool get isLinux => testPlatform == TestPlatform.linux;
}

MockPlatform mockPlatform = MockPlatform();

LifeCycle _getLifecycleStream() {
  if (!isWeb && (mockPlatform.isAndroid || mockPlatform.isIOS)) {
    return FGBGLifecycle(FGBGEvents.stream);
  } else {
    return WidgetObserverLifecycle();
  }
}

void main() {
  setUp(() {
    testPlatform = null;
    testIsWeb = null;
  });

  group('LifeCycle Tests', () {
    test('should return FGBGLifecycle for Android', () {
      testPlatform = TestPlatform.android;
      testIsWeb = false;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<FGBGLifecycle>());
    });

    test('should return FGBGLifecycle for iOS', () {
      testPlatform = TestPlatform.ios;
      testIsWeb = false;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<FGBGLifecycle>());
    });

    test('should return WidgetObserverLifecycle for Web', () {
      testIsWeb = true;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for macOS', () {
      testPlatform = TestPlatform.macos;
      testIsWeb = false;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for Windows', () {
      testPlatform = TestPlatform.windows;
      testIsWeb = false;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });

    test('should return WidgetObserverLifecycle for Linux', () {
      testPlatform = TestPlatform.linux;
      testIsWeb = false;

      final lifecycle = _getLifecycleStream();

      expect(lifecycle, isA<WidgetObserverLifecycle>());
    });
  });
}
