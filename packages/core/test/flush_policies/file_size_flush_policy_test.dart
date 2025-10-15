import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/flush_policies/file_size_flush_policy.dart';
import 'package:segment_analytics/event.dart';

void main() {
  group('FileSizeFlushPolicy Tests', () {
    late FileSizeFlushPolicy policy;

    setUp(() {
      policy = FileSizeFlushPolicy(1024); // 1KB threshold
    });

    group('initialization', () {
      test('creates policy with specified max file size', () {
        expect(policy.maxFileSize, 1024);
        expect(policy.estimatedCurrentSize, 0);
      });

      test('creates policy with custom threshold', () {
        const customThreshold = 2048;
        final customPolicy = FileSizeFlushPolicy(customThreshold);
        
        expect(customPolicy.maxFileSize, customThreshold);
        expect(customPolicy.estimatedCurrentSize, 0);
      });

      test('creates policy with very small threshold', () {
        const smallThreshold = 100;
        final smallPolicy = FileSizeFlushPolicy(smallThreshold);
        
        expect(smallPolicy.maxFileSize, smallThreshold);
      });

      test('creates policy with very large threshold', () {
        const largeThreshold = 10 * 1024 * 1024; // 10MB
        final largePolicy = FileSizeFlushPolicy(largeThreshold);
        
        expect(largePolicy.maxFileSize, largeThreshold);
      });
    });

    group('flush triggering', () {
      test('does not flush initially', () {
        expect(policy.shouldFlush, false);
      });

      test('accumulates size and triggers flush when threshold exceeded', () {
        policy.start();
        
        // Add events until we exceed the threshold
        for (int i = 0; i < 20; i++) {
          final event = TrackEvent('Large Event $i', properties: {
            'index': i,
            'data': 'x' * 100, // Add significant bulk
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          
          policy.onEvent(event);
          
          if (policy.shouldFlush) break;
        }
        
        expect(policy.shouldFlush, true);
        expect(policy.estimatedCurrentSize, greaterThan(1024));
      });

      test('resets size counter after reset', () {
        policy.start();
        
        // Add some events
        final event = TrackEvent('Test Event', properties: {'data': 'test'});
        policy.onEvent(event);
        
        expect(policy.estimatedCurrentSize, greaterThan(0));
        
        policy.reset();
        
        expect(policy.estimatedCurrentSize, 0);
        expect(policy.shouldFlush, false);
      });
    });

    group('event size estimation', () {
      test('estimates track events', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final trackEvent = TrackEvent('Button Clicked', properties: {
          'button': 'submit',
          'page': 'checkout',
          'value': 100,
        });

        policy.onEvent(trackEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
        expect(policy.estimatedCurrentSize, greaterThan(200)); // Should include overhead
      });

      test('estimates screen events', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final screenEvent = ScreenEvent('HomePage', properties: {
          'section': 'main',
          'user_type': 'premium',
        });

        policy.onEvent(screenEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
      });

      test('estimates identify events', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final identifyEvent = IdentifyEvent(
          userId: 'user_12345',
          traits: UserTraits(
            email: 'user@example.com',
            firstName: 'John',
            lastName: 'Doe',
          ),
        );

        policy.onEvent(identifyEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
      });

      test('estimates group events', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final groupEvent = GroupEvent(
          'company_abc123',
          traits: GroupTraits(
            name: 'Acme Corporation',
            industry: 'Technology',
          ),
        );

        policy.onEvent(groupEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
      });

      test('estimates alias events', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final aliasEvent = AliasEvent('old_user_id_123', userId: 'new_user_id_456');

        policy.onEvent(aliasEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
      });
    });

    group('size tracking methods', () {
      test('updateEstimatedSize sets size correctly', () {
        policy.start();
        
        policy.updateEstimatedSize(500);
        expect(policy.estimatedCurrentSize, 500);
        expect(policy.shouldFlush, false);
        
        policy.updateEstimatedSize(2000);
        expect(policy.estimatedCurrentSize, 2000);
        expect(policy.shouldFlush, true); // Should exceed 1024 threshold
      });

      test('addEstimatedSize accumulates correctly', () {
        policy.start();
        
        policy.addEstimatedSize(300);
        expect(policy.estimatedCurrentSize, 300);
        expect(policy.shouldFlush, false);
        
        policy.addEstimatedSize(800);
        expect(policy.estimatedCurrentSize, 1100);
        expect(policy.shouldFlush, true); // Should exceed 1024 threshold
      });

      test('addEstimatedSize with exact threshold', () {
        policy.start();
        
        policy.addEstimatedSize(1024);
        expect(policy.estimatedCurrentSize, 1024);
        expect(policy.shouldFlush, true); // Should trigger at exact threshold
      });
    });

    group('threshold behavior', () {
      test('works with very small thresholds', () {
        final tinyPolicy = FileSizeFlushPolicy(50);
        tinyPolicy.start();
        
        final event = TrackEvent('Any Event');
        tinyPolicy.onEvent(event);
        
        // Even a single event should exceed 50 bytes
        expect(tinyPolicy.shouldFlush, true);
      });

      test('works with very large thresholds', () {
        final hugePolicy = FileSizeFlushPolicy(100 * 1024 * 1024); // 100MB
        hugePolicy.start();
        
        // Add many events
        for (int i = 0; i < 1000; i++) {
          final event = TrackEvent('Event $i', properties: {'index': i});
          hugePolicy.onEvent(event);
        }
        
        // Even many events shouldn't reach 100MB
        expect(hugePolicy.shouldFlush, false);
      });

      test('handles zero threshold edge case', () {
        final zeroPolicy = FileSizeFlushPolicy(0);
        zeroPolicy.start();
        
        final event = TrackEvent('Any Event');
        zeroPolicy.onEvent(event);
        
        // Any event should exceed 0 bytes
        expect(zeroPolicy.shouldFlush, true);
      });
    });

    group('performance and edge cases', () {
      test('handles events with no properties', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final simpleEvent = TrackEvent('Simple Event');
        policy.onEvent(simpleEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize));
      });

      test('handles events with complex nested properties', () {
        policy.start();
        final initialSize = policy.estimatedCurrentSize;
        
        final complexEvent = TrackEvent('Complex Event', properties: {
          'level1': {
            'level2': {
              'level3': ['item1', 'item2', 'item3'],
              'metadata': {
                'timestamps': [1234567890, 1234567891, 1234567892],
                'flags': {'feature_a': true, 'feature_b': false},
              },
            },
          },
          'simple_array': [1, 2, 3, 4, 5],
          'mixed_types': ['string', 42, true, null],
        });

        policy.onEvent(complexEvent);
        
        expect(policy.estimatedCurrentSize, greaterThan(initialSize + 500)); // Should be substantial
      });

      test('handles mixed event types consistently', () {
        policy.start();
        
        final mixedEvents = [
          TrackEvent('Track 1', properties: {'data': 'value'}),
          ScreenEvent('Screen 1', properties: {'section': 'main'}),
          IdentifyEvent(userId: 'user_1', traits: UserTraits(email: 'test@example.com')),
          GroupEvent('group_1', traits: GroupTraits(name: 'Test Group')),
          AliasEvent('old_id', userId: 'new_id'),
        ];

        for (final event in mixedEvents) {
          policy.onEvent(event);
        }
        
        expect(policy.estimatedCurrentSize, greaterThan(0));
      });

      test('multiple start calls reset size', () {
        policy.start();
        
        final event = TrackEvent('Test Event');
        policy.onEvent(event);
        
        final sizeAfterEvent = policy.estimatedCurrentSize;
        expect(sizeAfterEvent, greaterThan(0));
        
        policy.start(); // Should reset
        
        expect(policy.estimatedCurrentSize, 0);
      });
    });

    group('integration scenarios', () {
      test('simulates typical batch processing', () {
        final batchPolicy = FileSizeFlushPolicy(2048); // 2KB threshold
        batchPolicy.start();
        
        var eventCount = 0;
        while (!batchPolicy.shouldFlush && eventCount < 100) {
          final event = TrackEvent('Batch Event $eventCount', properties: {
            'index': eventCount,
            'timestamp': DateTime.now().millisecondsSinceEpoch + eventCount,
          });
          
          batchPolicy.onEvent(event);
          eventCount++;
        }
        
        expect(batchPolicy.shouldFlush, true);
        expect(eventCount, greaterThan(0));
        expect(batchPolicy.estimatedCurrentSize, greaterThanOrEqualTo(2048));
      });

      test('simulates reset and restart cycle', () {
        policy.start();
        
        // Fill up to near threshold
        policy.addEstimatedSize(1000);
        expect(policy.shouldFlush, false);
        
        // Reset
        policy.reset();
        expect(policy.estimatedCurrentSize, 0);
        expect(policy.shouldFlush, false);
        
        // Start again
        policy.start();
        
        // Add more data
        policy.addEstimatedSize(2000);
        expect(policy.shouldFlush, true);
      });
    });
  });
}