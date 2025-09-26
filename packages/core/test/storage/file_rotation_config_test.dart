import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/storage/file_rotation_config.dart';

void main() {
  group('FileRotationConfig Tests', () {
    test('creates default configuration with correct values', () {
      const config = FileRotationConfig();

      expect(config.maxFileSize, 475 * 1024); // 475KB
      expect(config.baseFilename, 'segment-events');
      expect(config.activeFileExtension, '.temp');
      expect(config.completedFileExtension, '.json');
      expect(config.indexKey, 'segment_file_index');
      expect(config.enabled, true);
    });

    test('creates disabled configuration', () {
      const config = FileRotationConfig.disabled();

      expect(config.enabled, false);
      expect(config.maxFileSize, 0);
    });

    test('copyWith creates modified configuration', () {
      const original = FileRotationConfig();
      final modified = original.copyWith(
        maxFileSize: 1024 * 1024, // 1MB
        enabled: false,
      );

      expect(modified.maxFileSize, 1024 * 1024);
      expect(modified.enabled, false);
      expect(modified.baseFilename, original.baseFilename); // Unchanged
      expect(modified.activeFileExtension, original.activeFileExtension); // Unchanged
    });

    test('equality works correctly', () {
      const config1 = FileRotationConfig();
      const config2 = FileRotationConfig();
      final config3 = config1.copyWith(maxFileSize: 1024);

      expect(config1, config2);
      expect(config1, isNot(config3));
    });

    test('hashCode works correctly', () {
      const config1 = FileRotationConfig();
      const config2 = FileRotationConfig();
      final config3 = config1.copyWith(maxFileSize: 1024);

      expect(config1.hashCode, config2.hashCode);
      expect(config1.hashCode, isNot(config3.hashCode));
    });

    test('toString includes all properties', () {
      const config = FileRotationConfig();
      final str = config.toString();

      expect(str, contains('maxFileSize: ${475 * 1024}'));
      expect(str, contains('baseFilename: segment-events'));
      expect(str, contains('enabled: true'));
    });

    test('custom configuration values work', () {
      const config = FileRotationConfig(
        maxFileSize: 1000 * 1024, // 1000KB
        baseFilename: 'custom-events',
        activeFileExtension: '.writing',
        completedFileExtension: '.complete',
        indexKey: 'custom_index_key',
        enabled: false,
      );

      expect(config.maxFileSize, 1000 * 1024);
      expect(config.baseFilename, 'custom-events');
      expect(config.activeFileExtension, '.writing');
      expect(config.completedFileExtension, '.complete');
      expect(config.indexKey, 'custom_index_key');
      expect(config.enabled, false);
    });
  });
}