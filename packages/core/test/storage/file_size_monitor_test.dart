import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/storage/file_size_monitor.dart';

void main() {
  group('FileSizeMonitor Tests', () {
    late FileSizeMonitor monitor;

    setUp(() {
      monitor = FileSizeMonitor();
    });

    group('calculateEventSize', () {
      test('calculates size for TrackEvent', () {
        final event = TrackEvent('Button Clicked', properties: {
          'button': 'submit',
          'page': 'checkout',
          'value': 100.0,
        });

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
        expect(size, greaterThan(200)); // Should be more than base size
      });

      test('calculates size for ScreenEvent', () {
        final event = ScreenEvent('HomePage', properties: {
          'section': 'main',
          'user_id': '123',
        });

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
        expect(size, greaterThan(200));
      });

      test('calculates size for IdentifyEvent', () {
        final event = IdentifyEvent(
          userId: 'user_123',
          traits: UserTraits(
            email: 'user@example.com',
            firstName: 'John',
            lastName: 'Doe',
          ),
        );

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
        expect(size, greaterThan(200));
      });

      test('calculates size for GroupEvent', () {
        final event = GroupEvent(
          'company_abc',
          traits: GroupTraits(
            name: 'Acme Corp',
            industry: 'Technology',
          ),
        );

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
        expect(size, greaterThan(200));
      });

      test('calculates size for AliasEvent', () {
        final event = AliasEvent('old_user_id', userId: 'new_user_id');

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
        expect(size, greaterThan(200));
      });

      test('handles events with null properties', () {
        final event = TrackEvent('Simple Event');

        final size = monitor.calculateEventSize(event);
        expect(size, greaterThan(0));
      });
    });

    group('calculateEventsSize', () {
      test('calculates size for empty list', () {
        final size = monitor.calculateEventsSize([]);
        expect(size, 0);
      });

      test('calculates size for single event', () {
        final events = [TrackEvent('Test Event')];
        
        final singleEventSize = monitor.calculateEventSize(events[0]);
        final totalSize = monitor.calculateEventsSize(events);
        
        expect(totalSize, greaterThanOrEqualTo(singleEventSize));
      });

      test('calculates size for multiple events', () {
        final events = [
          TrackEvent('Event 1'),
          TrackEvent('Event 2'),
          ScreenEvent('Screen 1'),
        ];

        final totalSize = monitor.calculateEventsSize(events);
        expect(totalSize, greaterThan(0));
        
        // Total should be greater than any individual event size
        for (final event in events) {
          final eventSize = monitor.calculateEventSize(event);
          expect(totalSize, greaterThan(eventSize));
        }
      });
    });

    group('file size caching', () {
      test('caches and retrieves file sizes', () {
        const filePath = '/test/file.json';
        const fileSize = 1024;

        monitor.updateCachedFileSize(filePath, fileSize);
        final cachedSize = monitor.getCachedFileSize(filePath);
        
        expect(cachedSize, fileSize);
      });

      test('returns 0 for uncached files', () {
        const filePath = '/test/unknown.json';
        
        final cachedSize = monitor.getCachedFileSize(filePath);
        expect(cachedSize, 0);
      });

      test('tracks bytes written in session', () {
        const filePath = '/test/file.json';
        
        monitor.addBytesWritten(filePath, 100);
        monitor.addBytesWritten(filePath, 200);
        
        final sessionBytes = monitor.getSessionBytesWritten(filePath);
        expect(sessionBytes, 300);
        
        final cachedSize = monitor.getCachedFileSize(filePath);
        expect(cachedSize, 300); // Should also update cached size
      });

      test('resets session bytes written', () {
        const filePath = '/test/file.json';
        
        monitor.addBytesWritten(filePath, 500);
        monitor.resetSessionBytesWritten(filePath);
        
        final sessionBytes = monitor.getSessionBytesWritten(filePath);
        expect(sessionBytes, 0);
      });

      test('clears file cache', () {
        const filePath = '/test/file.json';
        
        monitor.updateCachedFileSize(filePath, 1000);
        monitor.addBytesWritten(filePath, 500);
        
        monitor.clearFileCache(filePath);
        
        expect(monitor.getCachedFileSize(filePath), 0);
        expect(monitor.getSessionBytesWritten(filePath), 0);
      });

      test('clears all cache', () {
        const file1 = '/test/file1.json';
        const file2 = '/test/file2.json';
        
        monitor.updateCachedFileSize(file1, 1000);
        monitor.updateCachedFileSize(file2, 2000);
        monitor.addBytesWritten(file1, 100);
        monitor.addBytesWritten(file2, 200);
        
        monitor.clearCache();
        
        expect(monitor.getCachedFileSize(file1), 0);
        expect(monitor.getCachedFileSize(file2), 0);
        expect(monitor.getSessionBytesWritten(file1), 0);
        expect(monitor.getSessionBytesWritten(file2), 0);
      });
    });

    group('size limit checks', () {
      test('wouldExceedLimit checks correctly', () {
        const filePath = '/test/file.json';
        const maxSize = 1000;
        
        monitor.updateCachedFileSize(filePath, 800);
        
        final smallEvents = [TrackEvent('Small')];
        final largeEvents = List.generate(50, (i) => 
            TrackEvent('Large Event $i', properties: {
              'data': 'x' * 100, // Add some bulk
              'index': i,
            }));
        
        expect(monitor.wouldExceedLimit(filePath, maxSize, smallEvents), false);
        expect(monitor.wouldExceedLimit(filePath, maxSize, largeEvents), true);
      });
    });

    group('estimateSizeWithNewEvents', () {
      test('estimates size with existing data', () {
        final existingData = {
          'queue': [
            {'type': 'track', 'event': 'Existing Event'},
          ],
        };
        
        final newEvents = [TrackEvent('New Event')];
        
        final estimatedSize = monitor.estimateSizeWithNewEvents(existingData, newEvents);
        expect(estimatedSize, greaterThan(0));
      });

      test('handles empty existing data', () {
        final existingData = {'queue': <dynamic>[]};
        final newEvents = [TrackEvent('First Event')];
        
        final estimatedSize = monitor.estimateSizeWithNewEvents(existingData, newEvents);
        expect(estimatedSize, greaterThan(0));
      });

      test('falls back gracefully on serialization errors', () {
        final existingData = {
          'queue': [
            {'circular': 'reference'}, // This could cause issues
          ],
        };
        
        final newEvents = [TrackEvent('Event')];
        
        // Should not throw, should return reasonable estimate
        final estimatedSize = monitor.estimateSizeWithNewEvents(existingData, newEvents);
        expect(estimatedSize, greaterThan(0));
      });
    });

    group('debug info', () {
      test('provides debug information', () {
        const file1 = '/test/file1.json';
        const file2 = '/test/file2.json';
        
        monitor.updateCachedFileSize(file1, 1000);
        monitor.addBytesWritten(file2, 500);
        
        final debugInfo = monitor.getDebugInfo();
        
        expect(debugInfo['fileSizeCache'], isA<Map<String, int>>());
        expect(debugInfo['sessionBytesWritten'], isA<Map<String, int>>());
        expect((debugInfo['fileSizeCache'] as Map<String, int>)[file1], 1000);
        expect((debugInfo['sessionBytesWritten'] as Map<String, int>)[file2], 500);
      });
    });

    group('value size estimation', () {
      test('estimates different value types correctly', () {
        // Test through properties estimation which uses _estimateValueSize internally
        final properties = {
          'string': 'hello',
          'number': 42,
          'boolean': true,
          'null_value': null,
          'list': [1, 2, 3],
          'map': {'nested': 'value'},
        };
        
        final event = TrackEvent('Test', properties: properties);
        final size = monitor.calculateEventSize(event);
        
        expect(size, greaterThan(200)); // Should include all property sizes
      });
    });
  });
}