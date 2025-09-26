import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/plugins/queue_flushing_plugin_with_rotation.dart';
import 'package:segment_analytics/storage/file_rotation_config.dart';
import 'package:segment_analytics/storage/file_rotation_manager.dart';
import 'package:segment_analytics/storage/file_index_manager.dart';
import 'package:segment_analytics/storage/file_size_monitor.dart';
import 'package:segment_analytics/flush_policies/file_size_flush_policy.dart';

void main() {
  group('File Rotation Integration Tests', () {
    group('FileRotationConfig Integration', () {
      test('config variations work together correctly', () {
        final configs = [
          FileRotationConfig(), // Default
          FileRotationConfig(maxFileSize: 1024), // Small
          FileRotationConfig(maxFileSize: 10 * 1024 * 1024), // Large
          FileRotationConfig.disabled(), // Disabled
          FileRotationConfig(
            maxFileSize: 2048,
            baseFilename: 'custom-events',
            completedFileExtension: '.analytics',
            activeFileExtension: '.working',
          ), // Custom all
        ];

        for (final config in configs) {
          expect(config.maxFileSize, isA<int>());
          expect(config.baseFilename, isA<String>());
          expect(config.completedFileExtension, isA<String>());
          expect(config.activeFileExtension, isA<String>());
          expect(config.indexKey, isA<String>());
          expect(config.enabled, isA<bool>());
        }
      });

      test('config equality works correctly', () {
        final config1 = FileRotationConfig(maxFileSize: 1024);
        final config2 = FileRotationConfig(maxFileSize: 1024);
        final config3 = FileRotationConfig(maxFileSize: 2048);

        expect(config1, equals(config2));
        expect(config1, isNot(equals(config3)));
      });

      test('config copyWith works correctly', () {
        final original = FileRotationConfig();
        final modified = original.copyWith(
          maxFileSize: 2048,
          enabled: false,
        );

        expect(modified.maxFileSize, 2048);
        expect(modified.enabled, false);
        expect(modified.baseFilename, original.baseFilename);
      });
    });

    group('FileSizeMonitor Integration', () {
      test('monitor calculates size for all event types', () {
        final monitor = FileSizeMonitor();
        
        final events = [
          TrackEvent('Track Event', properties: {'key': 'value'}),
          ScreenEvent('Screen Event', properties: {'section': 'main'}),
          IdentifyEvent(userId: 'user123', traits: UserTraits(email: 'test@example.com')),
          GroupEvent('group123', traits: GroupTraits(name: 'Test Group')),
          AliasEvent('old_id', userId: 'new_id'),
        ];

        final totalSize = monitor.calculateEventsSize(events);
        expect(totalSize, greaterThan(0));

        // Individual sizes should sum to close to total size (allowing for overhead)
        var individualSum = 0;
        for (final event in events) {
          individualSum += monitor.calculateEventSize(event);
        }
        
        expect(totalSize, greaterThanOrEqualTo(individualSum));
      });

      test('monitor handles file size tracking workflow', () {
        final monitor = FileSizeMonitor();
        const filePath = '/test/rotation_file.json';
        
        // Initial state
        expect(monitor.getCachedFileSize(filePath), 0);
        expect(monitor.getSessionBytesWritten(filePath), 0);
        
        // Update cached size
        monitor.updateCachedFileSize(filePath, 1000);
        expect(monitor.getCachedFileSize(filePath), 1000);
        
        // Add bytes written
        monitor.addBytesWritten(filePath, 500);
        expect(monitor.getSessionBytesWritten(filePath), 500);
        expect(monitor.getCachedFileSize(filePath), 1500); // Should update cached size
        
        // Test limit checking
        final events = [TrackEvent('Test Event')];
        expect(monitor.wouldExceedLimit(filePath, 2000, events), false);
        expect(monitor.wouldExceedLimit(filePath, 1000, events), true);
        
        // Clear cache
        monitor.clearFileCache(filePath);
        expect(monitor.getCachedFileSize(filePath), 0);
        expect(monitor.getSessionBytesWritten(filePath), 0);
      });
    });

    group('FileIndexManager Integration', () {
      test('index manager filename generation works correctly', () async {
        final config = FileRotationConfig(
          baseFilename: 'test-events',
          activeFileExtension: '.temp',
          completedFileExtension: '.json',
        );
        
        final manager = FileIndexManager(config);
        await manager.ready;
        
        // Test filename generation
        final currentFilename = await manager.getCurrentFilename();
        expect(currentFilename, contains('test-events'));
        expect(currentFilename, contains('.temp'));
        
        final nextFilename = await manager.getNextFilename();
        expect(nextFilename, contains('test-events'));
        expect(nextFilename, contains('.temp'));
        expect(nextFilename, isNot(equals(currentFilename)));
        
        // Test completed filename
        final currentIndex = await manager.getCurrentIndex();
        final completedFilename = manager.getCompletedFilename(currentIndex);
        expect(completedFilename, contains('test-events'));
        expect(completedFilename, contains('.json'));
      });
    });

    group('FileRotationManager Integration', () {
      test('rotation manager integrates with all components', () async {
        final config = FileRotationConfig(maxFileSize: 2048); // 2KB
        final manager = FileRotationManager(config, '/tmp/test_rotation');
        
        await manager.ready;
        
        // Test initial state
        final debugInfo = await manager.getDebugInfo();
        expect(debugInfo['isInitialized'], true);
        expect(debugInfo['config'], contains('maxFileSize'));
        
        // Test file size info
        final sizeInfo = await manager.getFileSizeInfo();
        expect(sizeInfo, isA<Map<String, dynamic>>());
        expect(sizeInfo['maxSize'], 2048);
        
        // Test completed files listing
        final completedFiles = await manager.getCompletedFiles();
        expect(completedFiles, isA<List<String>>());
        
        // Test cleanup
        await manager.cleanupCompletedFiles(['/non/existent/file.json']);
        // Should not throw
      });

      test('rotation manager handles small vs large events correctly', () async {
        final config = FileRotationConfig(maxFileSize: 1024); // 1KB
        final manager = FileRotationManager(config, '/tmp/test_size');
        
        await manager.ready;
        
        // Small events should not trigger rotation
        final smallEvents = [TrackEvent('Small')];
        final smallResult = await manager.checkRotationNeeded(smallEvents);
        expect(smallResult, contains('/tmp/test_size'));
        
        // Large events should trigger rotation (but we can't easily test this
        // without a full file system, so we test the size calculation)
        final largeEvents = List.generate(50, (i) => 
            TrackEvent('Large Event $i', properties: {
              'data': 'x' * 100,
              'index': i,
            }));
        
        // This should return a path (either current or new after rotation)
        final largeResult = await manager.checkRotationNeeded(largeEvents);
        expect(largeResult, contains('/tmp/test_size'));
      });
    });

    group('FileSizeFlushPolicy Integration', () {
      test('flush policy works with file rotation workflow', () {
        final policy = FileSizeFlushPolicy(1024);
        policy.start();
        
        expect(policy.shouldFlush, false);
        
        // Add events until flush is triggered
        var eventCount = 0;
        while (!policy.shouldFlush && eventCount < 100) {
          final event = TrackEvent('Policy Test $eventCount', properties: {
            'index': eventCount,
            'data': 'x' * 50,
          });
          
          policy.onEvent(event);
          eventCount++;
        }
        
        expect(policy.shouldFlush, true);
        expect(eventCount, greaterThan(0));
        
        // Reset should clear the flush state
        policy.reset();
        expect(policy.shouldFlush, false);
        expect(policy.estimatedCurrentSize, 0);
      });

      test('flush policy integrates with size estimation', () {
        final policy = FileSizeFlushPolicy(2048);
        policy.start();
        
        // Manual size updates
        policy.updateEstimatedSize(1000);
        expect(policy.shouldFlush, false);
        
        policy.addEstimatedSize(1500);
        expect(policy.shouldFlush, true);
        expect(policy.estimatedCurrentSize, 2500);
        
        // Reset and try with events
        policy.reset();
        policy.start();
        
        final events = [
          TrackEvent('Event 1', properties: {'large_data': 'x' * 500}),
          TrackEvent('Event 2', properties: {'large_data': 'x' * 500}),
          TrackEvent('Event 3', properties: {'large_data': 'x' * 500}),
        ];
        
        for (final event in events) {
          policy.onEvent(event);
          if (policy.shouldFlush) break;
        }
        
        expect(policy.shouldFlush, true);
      });
    });

    group('QueueFlushingPluginWithRotation Integration', () {
      test('plugin integrates all rotation components', () async {
        final flushedEvents = <RawEvent>[];
        
        Future<void> flushCallback(List<RawEvent> events) async {
          flushedEvents.addAll(events);
        }
        
        final config = FileRotationConfig(maxFileSize: 1024);
        final plugin = QueueFlushingPluginWithRotation(
          flushCallback,
          rotationConfig: config,
        );
        
        expect(plugin.type, PluginType.after);
        
        // Test debug info access
        final debugInfo = await plugin.getRotationDebugInfo();
        expect(debugInfo, isA<Map<String, dynamic>>());
        
        // Test manual rotation trigger
        await plugin.triggerRotation();
        // Should not throw
        
        expect(flushedEvents, isEmpty); // No events flushed yet
      });

      test('plugin handles different configuration scenarios', () {
        Future<void> mockFlush(List<RawEvent> events) async {}
        
        // Test with various configs
        final configs = [
          FileRotationConfig(),
          FileRotationConfig.disabled(),
          FileRotationConfig(maxFileSize: 512),
          FileRotationConfig(
            baseFilename: 'integration-test',
            completedFileExtension: '.segment',
          ),
        ];
        
        for (final config in configs) {
          final plugin = QueueFlushingPluginWithRotation(
            mockFlush,
            rotationConfig: config,
          );
          
          expect(plugin, isNotNull);
          expect(plugin.type, PluginType.after);
        }
      });
    });

    group('End-to-End Integration', () {
      test('complete file rotation workflow simulation', () async {
        // Setup components
        final config = FileRotationConfig(
          maxFileSize: 2048,
          baseFilename: 'e2e-test',
        );
        
        final monitor = FileSizeMonitor();
        final flushPolicy = FileSizeFlushPolicy(2048);
        
        final processedBatches = <List<RawEvent>>[];
        
        Future<void> batchProcessor(List<RawEvent> batch) async {
          processedBatches.add(batch);
        }
        
        final plugin = QueueFlushingPluginWithRotation(
          batchProcessor,
          rotationConfig: config,
        );
        
        // Simulate event processing
        flushPolicy.start();
        
        final testEvents = <RawEvent>[];
        for (int i = 0; i < 50; i++) {
          final event = TrackEvent('E2E Event $i', properties: {
            'session_id': 'e2e_session_123',
            'index': i,
            'data': 'x' * 100, // Add bulk to trigger rotation
            'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          });
          
          testEvents.add(event);
          
          // Test size calculation
          final eventSize = monitor.calculateEventSize(event);
          expect(eventSize, greaterThan(0));
          
          // Test flush policy
          flushPolicy.onEvent(event);
        }
        
        // Verify total size estimation
        final totalSize = monitor.calculateEventsSize(testEvents);
        expect(totalSize, greaterThan(5000)); // Should be substantial
        
        // Verify flush policy triggered
        expect(flushPolicy.shouldFlush, true);
        expect(flushPolicy.estimatedCurrentSize, greaterThan(2048));
        
        // Test plugin components
        expect(plugin, isNotNull);
        expect(plugin.type, PluginType.after);
        
        final debugInfo = await plugin.getRotationDebugInfo();
        expect(debugInfo, isA<Map<String, dynamic>>());
      });

      test('handles configuration edge cases in integration', () async {
        // Test with extreme configurations
        final extremeConfigs = [
          FileRotationConfig(maxFileSize: 1), // Tiny
          FileRotationConfig(maxFileSize: 100 * 1024 * 1024), // Huge
          FileRotationConfig.disabled(), // Disabled
          FileRotationConfig(
            maxFileSize: 1024,
            baseFilename: '',
            completedFileExtension: '.test',
            activeFileExtension: '.work',
            indexKey: 'custom_key',
          ),
        ];
        
        for (final config in extremeConfigs) {
          // Should not throw during creation
          final monitor = FileSizeMonitor();
          final policy = FileSizeFlushPolicy(config.enabled ? config.maxFileSize : 1024);
          
          Future<void> handler(List<RawEvent> events) async {}
          final plugin = QueueFlushingPluginWithRotation(handler, rotationConfig: config);
          
          expect(monitor, isNotNull);
          expect(policy, isNotNull);
          expect(plugin, isNotNull);
          
          // Test basic functionality
          final event = TrackEvent('Edge Case Test');
          final size = monitor.calculateEventSize(event);
          expect(size, greaterThan(0));
          
          policy.start();
          policy.onEvent(event);
          expect(policy.estimatedCurrentSize, greaterThanOrEqualTo(0));
        }
      });

      test('stress test with many events', () async {
        final config = FileRotationConfig(maxFileSize: 10240); // 10KB
        final monitor = FileSizeMonitor();
        final policy = FileSizeFlushPolicy(10240);
        
        Future<void> counter(List<RawEvent> events) async {
          // Process events (in real scenario would handle the batch)
        }
        
        final plugin = QueueFlushingPluginWithRotation(counter, rotationConfig: config);
        
        policy.start();
        
        // Generate many events
        final stressEvents = <RawEvent>[];
        for (int i = 0; i < 500; i++) {
          final event = TrackEvent('Stress Event $i', properties: {
            'batch': i ~/ 50,
            'index': i % 50,
            'data': 'stress_test_data_$i',
          });
          
          stressEvents.add(event);
          policy.onEvent(event);
          
          // Should handle continuous processing
          if (policy.shouldFlush) {
            policy.reset();
            policy.start();
          }
        }
        
        expect(stressEvents.length, 500);
        
        // Verify size calculations scale appropriately
        final totalSize = monitor.calculateEventsSize(stressEvents);
        expect(totalSize, greaterThan(50000)); // Should be substantial
        
        // Plugin should handle the configuration
        expect(plugin, isNotNull);
        final debugInfo = await plugin.getRotationDebugInfo();
        expect(debugInfo, isA<Map<String, dynamic>>());
      });
    });

    group('Error Handling Integration', () {
      test('components handle null and invalid inputs gracefully', () {
        final monitor = FileSizeMonitor();
        final config = FileRotationConfig();
        final policy = FileSizeFlushPolicy(1024);
        
        // Test monitor with edge cases
        expect(monitor.calculateEventsSize([]), 0);
        expect(monitor.getCachedFileSize('/nonexistent'), 0);
        expect(monitor.getSessionBytesWritten('/nonexistent'), 0);
        
        // Test policy with edge cases
        policy.start();
        expect(policy.shouldFlush, false);
        
        policy.updateEstimatedSize(0);
        expect(policy.shouldFlush, false);
        
        // Test config edge cases
        expect(config.enabled, true);
        expect(config.maxFileSize, greaterThan(0));
        
        final disabledConfig = FileRotationConfig.disabled();
        expect(disabledConfig.enabled, false);
      });

      test('integration handles async operation failures gracefully', () async {
        Future<void> failingFlushCallback(List<RawEvent> events) async {
          throw Exception('Simulated flush failure');
        }
        
        final config = FileRotationConfig();
        
        // Plugin should be created even with a potentially failing callback
        final plugin = QueueFlushingPluginWithRotation(
          failingFlushCallback,
          rotationConfig: config,
        );
        
        expect(plugin, isNotNull);
        
        // Debug operations should not fail
        final debugInfo = await plugin.getRotationDebugInfo();
        expect(debugInfo, isA<Map<String, dynamic>>());
        
        // Manual operations should handle errors gracefully
        await plugin.triggerRotation();
        // Should not throw from the test perspective
      });
    });
  });
}