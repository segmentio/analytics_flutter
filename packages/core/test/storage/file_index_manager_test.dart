import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segment_analytics/storage/file_rotation_config.dart';
import 'package:segment_analytics/storage/file_index_manager.dart';

void main() {
  group('FileIndexManager Tests', () {
    late FileRotationConfig config;
    late FileIndexManager indexManager;

    setUp(() {
      config = const FileRotationConfig();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      // Clean up shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with correct configuration', () {
      indexManager = FileIndexManager(config);
      expect(indexManager, isNotNull);
    });

    test('getCurrentIndex returns 0 for new installation', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;
      
      final index = await indexManager.getCurrentIndex();
      expect(index, 0);
    });

    test('incrementIndex increases and returns new value', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      final newIndex = await indexManager.incrementIndex();
      expect(newIndex, 1);

      final currentIndex = await indexManager.getCurrentIndex();
      expect(currentIndex, 1);
    });

    test('setIndex sets specific value', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      await indexManager.setIndex(5);
      final index = await indexManager.getCurrentIndex();
      expect(index, 5);
    });

    test('resetIndex sets value to 0', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      await indexManager.setIndex(10);
      await indexManager.resetIndex();
      
      final index = await indexManager.getCurrentIndex();
      expect(index, 0);
    });

    test('getCurrentFilename generates correct filename', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      await indexManager.setIndex(3);
      final filename = await indexManager.getCurrentFilename();
      expect(filename, '3-segment-events.temp');
    });

    test('getNextFilename increments and generates filename', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      await indexManager.setIndex(5);
      final filename = await indexManager.getNextFilename();
      expect(filename, '6-segment-events.temp');

      // Verify index was actually incremented
      final currentIndex = await indexManager.getCurrentIndex();
      expect(currentIndex, 6);
    });

    test('getCompletedFilename generates correct completed filename', () {
      indexManager = FileIndexManager(config);
      
      final filename = indexManager.getCompletedFilename(7);
      expect(filename, '7-segment-events.json');
    });

    test('persists index across manager instances', () async {
      // Create first manager and set index
      indexManager = FileIndexManager(config);
      await indexManager.ready;
      await indexManager.setIndex(15);

      // Create second manager and verify index persisted
      final indexManager2 = FileIndexManager(config);
      await indexManager2.ready;
      final index = await indexManager2.getCurrentIndex();
      expect(index, 15);
    });

    test('uses custom index key from config', () async {
      final customConfig = config.copyWith(indexKey: 'custom_key');
      indexManager = FileIndexManager(customConfig);
      await indexManager.ready;

      await indexManager.setIndex(20);

      // Verify it's stored under custom key by checking SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('custom_key'), 20);
      expect(prefs.getInt('segment_file_index'), isNull); // Default key should be null
    });

    test('uses custom filename format from config', () async {
      final customConfig = config.copyWith(
        baseFilename: 'analytics-data',
        activeFileExtension: '.writing',
        completedFileExtension: '.ready',
      );
      indexManager = FileIndexManager(customConfig);
      await indexManager.ready;

      await indexManager.setIndex(8);

      final currentFilename = await indexManager.getCurrentFilename();
      expect(currentFilename, '8-analytics-data.writing');

      final completedFilename = indexManager.getCompletedFilename(8);
      expect(completedFilename, '8-analytics-data.ready');
    });

    test('ready property reflects initialization state', () async {
      indexManager = FileIndexManager(config);
      
      // Initially not ready
      expect(indexManager.isReady, false);
      
      // Wait for initialization
      await indexManager.ready;
      
      // Now should be ready
      expect(indexManager.isReady, true);
    });

    test('handles multiple concurrent operations correctly', () async {
      indexManager = FileIndexManager(config);
      await indexManager.ready;

      // Start multiple increment operations concurrently
      final futures = List.generate(5, (_) => indexManager.incrementIndex());
      final results = await Future.wait(futures);

      // Results should be sequential (1, 2, 3, 4, 5)
      expect(results, [1, 2, 3, 4, 5]);

      // Final index should be 5
      final finalIndex = await indexManager.getCurrentIndex();
      expect(finalIndex, 5);
    });
  });
}