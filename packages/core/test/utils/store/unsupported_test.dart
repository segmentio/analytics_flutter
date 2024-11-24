import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/utils/store/impl.dart';

void main() {
  group('StoreImpl unsupported Tests', () {
    late StoreImpl store;

    setUp(() {
      store = StoreImpl();
    });

    test('getPersisted should throw PlatformNotSupportedError', () {
      expect(() => store.getPersisted('test_key'), throwsA(isA<PlatformNotSupportedError>()));
    });

    test('setPersisted should throw PlatformNotSupportedError', () {
      expect(() => store.setPersisted('test_key', {'field': 'value'}), throwsA(isA<PlatformNotSupportedError>()));
    });

  });
}
