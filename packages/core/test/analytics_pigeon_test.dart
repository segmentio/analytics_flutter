// test/analytics_platform_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics_pigeon.dart';

import 'package:segment_analytics/native_context.dart';
import 'mocks/mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsPlatformImpl Tests', () {
    late AnalyticsPlatformImpl analyticsPlatform;
    late MockNativeContextApi mockNativeContextApi;

    setUp(() {
      mockNativeContextApi = MockNativeContextApi();
      analyticsPlatform = AnalyticsPlatformImpl();
      analyticsPlatform.api = mockNativeContextApi;
    });

    test('getContext returns NativeContext', () async {
      final nativeContext = NativeContext();
      when(mockNativeContextApi.getContext(any))
          .thenAnswer((_) async => nativeContext);

      final result = await analyticsPlatform.getContext(collectDeviceId: true);

      expect(result, isA<NativeContext>());
      verify(mockNativeContextApi.getContext(true)).called(1);
    });
  });
}
