import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/utils/lifecycle/fgbg.dart';
import 'package:segment_analytics/utils/lifecycle/lifecycle.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';


void main() {
  group('FGBGLifecycle Tests', () {
    late FGBGLifecycle lifecycle;
    late StreamController<FGBGType> controller;

    setUp(() {
      controller = StreamController<FGBGType>.broadcast();
      lifecycle = FGBGLifecycle(controller.stream);
    });

    tearDown(() {
      controller.close();
    });

    test('should map FGBGType.foreground to AppStatus.foreground', () async {
      final events = <AppStatus>[];
      lifecycle.listen(events.add);

      controller.add(FGBGType.foreground);

      await Future.delayed(Duration.zero); // Allow stream event to propagate

      expect(events, [AppStatus.foreground]);
    });

    test('should map FGBGType.background to AppStatus.background', () async {
      final events = <AppStatus>[];
      lifecycle.listen(events.add);

      controller.add(FGBGType.background);

      await Future.delayed(Duration.zero); // Allow stream event to propagate

      expect(events, [AppStatus.background]);
    });

    test('should handle multiple events', () async {
      final events = <AppStatus>[];
      lifecycle.listen(events.add);

      controller.add(FGBGType.foreground);
      controller.add(FGBGType.background);
      controller.add(FGBGType.foreground);

      await Future.delayed(Duration.zero); // Allow stream events to propagate

      expect(events, [
        AppStatus.foreground,
        AppStatus.background,
        AppStatus.foreground,
      ]);
    });

    test('should call onDone when stream is closed', () async {
      bool isDone = false;
      lifecycle.listen(null, onDone: () => isDone = true);

      await controller.close(); // Close the stream

      expect(isDone, true);
    });

    test('should call onError on stream error', () async {
      dynamic error;
      lifecycle.listen(null, onError: (e) => error = e);

      controller.addError(Exception('Test error'));

      await Future.delayed(Duration.zero); // Allow error to propagate

      expect(error, isA<Exception>());
    });
  });
}
