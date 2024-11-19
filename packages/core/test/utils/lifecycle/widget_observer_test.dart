import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/utils/lifecycle/widget_observer.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetObserverLifecycle', () {
    testWidgets('should add observer to WidgetsBinding', (WidgetTester tester) async {
      final mockWidgetsBinding = MockWidgetsBinding();
      final observer = WidgetObserverLifecycle();

      when(mockWidgetsBinding.addObserver(observer)).thenReturn(mockWidgetsBinding.initInstances());
      when(mockWidgetsBinding.removeObserver(observer)).thenReturn(true);

      observer.lifeCycleImpl();
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      observer.listen((event) { });
      verifyNever(mockWidgetsBinding.addObserver(observer));
    });
  });
}
