import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/errors.dart';

void main() {
  group('errors classes', () {

    test('StorageUnableToCreate error validation', () {
      const message = 'Test error message';
      final exception = StorageUnableToCreate(message);
      final result = exception.toString();
      expect(result, 'Unable to create storage: $message');
    });

    test('StorageUnableToWrite error validation', () {
      const message = 'Test error message';
      final exception = StorageUnableToWrite(message);
      final result = exception.toString();
      expect(result, 'Unable to write to storage: $message');
    });

    test('StorageUnableToRename error validation', () {
      const message = 'Test error message';
      final exception = StorageUnableToRename(message);
      final result = exception.toString();
      expect(result, 'Unable to rename storage: $message');
    });

    test('StorageUnableToOpen error validation', () {
      const message = 'Test error message';
      final exception = StorageUnableToOpen(message);
      final result = exception.toString();
      expect(result, 'Unable to open storage: $message');
    });

    test('StorageUnableToClose error validation', () {
      const message = 'Test error message';
      final exception = StorageUnableToClose(message);
      final result = exception.toString();
      expect(result, 'Unable to close storage: $message');
    });

    test('StorageInvalid error validation', () {
      const message = 'Test error message';
      final exception = StorageInvalid(message);
      final result = exception.toString();
      expect(result, 'Invalide storage: $message');
    });

    test('StorageUnknown error validation', () {
      const message = 'Test error message';
      final exception = StorageUnknown(message);
      final result = exception.toString();
      expect(result, 'Unknown storage error: $message');
    });

    test('JSONUnableToDeserialize error validation', () {
      const message = 'Test error message';
      const type = 'Data';
      final exception = JSONUnableToDeserialize(type, message);
      final result = exception.toString();
      expect(result, 'Unable to deserialize JSON to $type: $message');
    });

    test('InconsistentStateError error validation', () {
      const key = 'Data';
      final exception = InconsistentStateError(key);
      final result = exception.toString();
      expect(result, 'Store for $key is in an inconsistent state');
    });

    test('ErrorLoadingStorage error validation', () {
      const innerError = 'Data error';
      final exception = ErrorLoadingStorage(innerError);
      final result = exception.toString();
      expect(result, 'Error loading storage: $innerError');
    });

  });
}
