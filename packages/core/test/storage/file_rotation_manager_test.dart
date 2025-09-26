import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/storage/file_rotation_config.dart';
import 'package:segment_analytics/storage/file_rotation_manager.dart';

void main() {
  group('FileRotationManager Tests', () {
    late FileRotationManager rotationManager;
    late FileRotationConfig config;
    late String testBasePath;

    setUp(() {
      config = FileRotationConfig();
      testBasePath = '/tmp/test_segment';
      
      rotationManager = FileRotationManager(config, testBasePath);
    });

    group('initialization', () {
      test('creates manager with provided config and base path', () {
        expect(rotationManager.config, equals(config));
      });

      test('handles disabled configuration', () {
        final disabledConfig = FileRotationConfig(enabled: false);
        final disabledManager = FileRotationManager(disabledConfig, testBasePath);

        expect(disabledManager.config.enabled, false);
      });

      test('initializes asynchronously', () async {
        // Wait for initialization to complete
        await rotationManager.ready;
        
        // Should be able to get debug info after initialization
        final debugInfo = await rotationManager.getDebugInfo();
        expect(debugInfo['isInitialized'], true);
      });
    });

    group('checkRotationNeeded', () {
      test('returns current file path when rotation is disabled', () async {
        final disabledConfig = FileRotationConfig(enabled: false);
        rotationManager = FileRotationManager(disabledConfig, testBasePath);

        final events = [TrackEvent('Test Event')];
        final result = await rotationManager.checkRotationNeeded(events);
        
        expect(result, contains(testBasePath));
      });

      test('returns current file path for small events', () async {
        final events = [TrackEvent('Small Event')];
        
        final result = await rotationManager.checkRotationNeeded(events);
        expect(result, contains(testBasePath));
        expect(result, contains('0-')); // Should be first file
      });

      test('handles empty event list', () async {
        final result = await rotationManager.checkRotationNeeded([]);
        expect(result, contains(testBasePath));
      });
    });

    group('file size tracking', () {
      test('updates file size after writing events', () async {
        await rotationManager.ready;
        
        final events = [
          TrackEvent('Event 1', properties: {'test': 'data'}),
          TrackEvent('Event 2', properties: {'more': 'data'}),
        ];
        
        final filePath = await rotationManager.checkRotationNeeded(events);
        
        // This should not throw
        rotationManager.updateFileSize(filePath, events);
        
        final sizeInfo = await rotationManager.getFileSizeInfo();
        expect(sizeInfo['currentFile'], equals(filePath));
        expect(sizeInfo['maxSize'], equals(config.maxFileSize));
      });

      test('provides file size information', () async {
        await rotationManager.ready;
        
        final sizeInfo = await rotationManager.getFileSizeInfo();
        
        expect(sizeInfo, isA<Map<String, dynamic>>());
        expect(sizeInfo.containsKey('currentFile'), true);
        expect(sizeInfo.containsKey('maxSize'), true);
        expect(sizeInfo.containsKey('index'), true);
      });
    });

    group('file management', () {
      test('lists completed files', () async {
        final completedFiles = await rotationManager.getCompletedFiles();
        expect(completedFiles, isA<List<String>>());
      });

      test('handles cleanup of completed files', () async {
        // Should not throw even with non-existent files
        await rotationManager.cleanupCompletedFiles(['/non/existent/file.json']);
      });

      test('can finish current file manually', () async {
        await rotationManager.ready;
        
        // Should not throw
        await rotationManager.finishCurrentFile();
      });
    });

    group('reset and state management', () {
      test('can reset rotation state', () async {
        await rotationManager.ready;
        
        // Should not throw
        await rotationManager.reset();
        
        final debugInfo = await rotationManager.getDebugInfo();
        expect(debugInfo['isInitialized'], true);
      });

      test('provides comprehensive debug information', () async {
        await rotationManager.ready;
        
        final debugInfo = await rotationManager.getDebugInfo();
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo.containsKey('config'), true);
        expect(debugInfo.containsKey('isInitialized'), true);
        expect(debugInfo.containsKey('currentFilePath'), true);
        expect(debugInfo.containsKey('indexManager'), true);
        expect(debugInfo.containsKey('sizeMonitor'), true);
      });
    });

    group('error handling', () {
      test('handles initialization gracefully when directory does not exist', () async {
        final manager = FileRotationManager(config, '/invalid/non/existent/path');
        
        // Should complete without throwing (may complete with error)
        try {
          await manager.ready;
        } catch (e) {
          // Expected for invalid path
          expect(e, isNotNull);
        }
      });

      test('handles large event lists without crashing', () async {
        await rotationManager.ready;
        
        // Create a large number of events
        final largeEventList = List.generate(1000, (i) => 
            TrackEvent('Event $i', properties: {
              'index': i,
              'data': 'x' * 100, // Add some bulk
            }));
        
        // Should not throw
        final result = await rotationManager.checkRotationNeeded(largeEventList);
        expect(result, isNotNull);
      });
    });

    group('configuration behavior', () {
      test('respects different file size limits', () async {
        final smallLimitConfig = FileRotationConfig(maxFileSize: 1024); // 1KB
        final smallLimitManager = FileRotationManager(smallLimitConfig, testBasePath);
        
        await smallLimitManager.ready;
        
        expect(smallLimitManager.config.maxFileSize, 1024);
        
        final sizeInfo = await smallLimitManager.getFileSizeInfo();
        expect(sizeInfo['maxSize'], 1024);
      });

      test('works with different file extensions', () async {
        final customConfig = FileRotationConfig(
          completedFileExtension: '.segment',
          activeFileExtension: '.tmp',
        );
        final customManager = FileRotationManager(customConfig, testBasePath);
        
        await customManager.ready;
        
        expect(customManager.config.completedFileExtension, '.segment');
        expect(customManager.config.activeFileExtension, '.tmp');
      });
    });

    group('concurrent operations', () {
      test('handles multiple checkRotationNeeded calls', () async {
        await rotationManager.ready;
        
        final events = [TrackEvent('Test Event')];
        
        // Make multiple concurrent calls
        final futures = List.generate(5, (i) => 
            rotationManager.checkRotationNeeded(events));
        
        final results = await Future.wait(futures);
        
        // All should succeed and return valid paths
        expect(results.length, 5);
        for (final result in results) {
          expect(result, contains(testBasePath));
        }
      });
    });
  });
}