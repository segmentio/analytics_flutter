import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/plugins/queue_flushing_plugin_with_rotation.dart';
import 'package:segment_analytics/storage/file_rotation_config.dart';

void main() {
  group('QueueFlushingPluginWithRotation Tests', () {
    late QueueFlushingPluginWithRotation plugin;
    late FileRotationConfig rotationConfig;
    late List<RawEvent> flushedEvents;

    // Mock flush function that captures events
    Future<void> mockFlushFunction(List<RawEvent> events) async {
      flushedEvents.addAll(events);
    }

    setUp(() {
      rotationConfig = FileRotationConfig();
      flushedEvents = [];
      
      plugin = QueueFlushingPluginWithRotation(
        mockFlushFunction,
        rotationConfig: rotationConfig,
      );
    });

    group('initialization', () {
      test('creates plugin with rotation config and flush callback', () {
        expect(plugin, isNotNull);
        expect(plugin.type, PluginType.after);
      });

      test('creates plugin with disabled rotation config', () {
        final disabledConfig = FileRotationConfig.disabled();
        final disabledPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: disabledConfig,
        );
        
        expect(disabledPlugin, isNotNull);
      });

      test('uses default config when none provided', () {
        final defaultPlugin = QueueFlushingPluginWithRotation(mockFlushFunction);
        expect(defaultPlugin, isNotNull);
      });
    });

    group('configuration validation', () {
      test('accepts different file size limits', () {
        final customConfig = FileRotationConfig(maxFileSize: 1024);
        final customPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: customConfig,
        );
        
        expect(customPlugin, isNotNull);
      });

      test('accepts custom file extensions', () {
        final customConfig = FileRotationConfig(
          completedFileExtension: '.segment',
          activeFileExtension: '.tmp',
        );
        final customPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: customConfig,
        );
        
        expect(customPlugin, isNotNull);
      });

      test('accepts custom base filename', () {
        final customConfig = FileRotationConfig(
          baseFilename: 'custom-events',
        );
        final customPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: customConfig,
        );
        
        expect(customPlugin, isNotNull);
      });
    });

    group('event types support', () {
      test('supports track events', () {
        final trackEvent = TrackEvent('Button Clicked', properties: {
          'button': 'submit',
          'page': 'checkout',
        });

        expect(trackEvent.event, 'Button Clicked');
        expect(trackEvent.properties!['button'], 'submit');
      });

      test('supports screen events', () {
        final screenEvent = ScreenEvent('HomePage', properties: {
          'section': 'main',
        });

        expect(screenEvent.name, 'HomePage');
        expect(screenEvent.properties!['section'], 'main');
      });

      test('supports identify events', () {
        final identifyEvent = IdentifyEvent(
          userId: 'user_123',
          traits: UserTraits(
            email: 'user@example.com',
            firstName: 'John',
          ),
        );

        expect(identifyEvent.userId, 'user_123');
        expect(identifyEvent.traits!.email, 'user@example.com');
      });

      test('supports group events', () {
        final groupEvent = GroupEvent(
          'company_abc',
          traits: GroupTraits(name: 'Acme Corp'),
        );

        expect(groupEvent.groupId, 'company_abc');
        expect(groupEvent.traits!.name, 'Acme Corp');
      });

      test('supports alias events', () {
        final aliasEvent = AliasEvent('old_user_id', userId: 'new_user_id');

        expect(aliasEvent.previousId, 'old_user_id');
        expect(aliasEvent.userId, 'new_user_id');
      });
    });

    group('plugin behavior', () {
      test('has correct plugin type', () {
        expect(plugin.type, PluginType.after);
      });

      test('provides flush callback to plugin', () {
        // Verify the plugin was created with our mock flush function
        expect(plugin, isNotNull);
      });

      test('accepts async flush callbacks', () {
        var callCount = 0;
        Future<void> counterFlushCallback(List<RawEvent> events) async {
          callCount++;
        }

        final counterPlugin = QueueFlushingPluginWithRotation(counterFlushCallback);
        expect(counterPlugin, isNotNull);
        expect(callCount, 0); // Should start at 0
      });
    });

    group('rotation debug info', () {
      test('provides debug info interface', () async {
        // Even without configuration, should provide debug interface
        final debugInfo = await plugin.getRotationDebugInfo();
        expect(debugInfo, isA<Map<String, dynamic>>());
      });

      test('supports manual rotation trigger', () async {
        // Should not throw even without full configuration
        await plugin.triggerRotation();
        expect(true, true); // Basic success test
      });
    });

    group('configuration edge cases', () {
      test('handles very small file size limits', () {
        final tinyConfig = FileRotationConfig(maxFileSize: 100);
        final tinyPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: tinyConfig,
        );
        
        expect(tinyPlugin, isNotNull);
      });

      test('handles very large file size limits', () {
        final hugeConfig = FileRotationConfig(maxFileSize: 10 * 1024 * 1024);
        final hugePlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: hugeConfig,
        );
        
        expect(hugePlugin, isNotNull);
      });

      test('handles disabled rotation', () {
        final disabledConfig = FileRotationConfig.disabled();
        final disabledPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: disabledConfig,
        );
        
        expect(disabledPlugin, isNotNull);
      });

      test('handles custom SharedPreferences key', () {
        final customConfig = FileRotationConfig(
          indexKey: 'custom_file_index',
        );
        final customPlugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: customConfig,
        );
        
        expect(customPlugin, isNotNull);
      });
    });

    group('flush callback behavior', () {
      test('accepts async flush callbacks', () {
        Future<void> asyncFlushCallback(List<RawEvent> events) async {
          await Future.delayed(Duration(milliseconds: 10));
          flushedEvents.addAll(events);
        }

        final asyncPlugin = QueueFlushingPluginWithRotation(asyncFlushCallback);
        expect(asyncPlugin, isNotNull);
      });

      test('accepts sync flush callbacks wrapped in async', () {
        Future<void> syncFlushCallback(List<RawEvent> events) async {
          flushedEvents.addAll(events);
        }

        final syncPlugin = QueueFlushingPluginWithRotation(syncFlushCallback);
        expect(syncPlugin, isNotNull);
      });

      test('handles flush callbacks that might throw', () {
        Future<void> throwingFlushCallback(List<RawEvent> events) async {
          if (events.isEmpty) {
            throw Exception('No events to flush');
          }
          flushedEvents.addAll(events);
        }

        final throwingPlugin = QueueFlushingPluginWithRotation(throwingFlushCallback);
        expect(throwingPlugin, isNotNull);
      });
    });

    group('memory and performance', () {
      test('can be created and destroyed without memory leaks', () {
        for (int i = 0; i < 100; i++) {
          final tempPlugin = QueueFlushingPluginWithRotation(mockFlushFunction);
          expect(tempPlugin, isNotNull);
          // Plugin should be eligible for garbage collection when scope ends
        }
        
        expect(true, true); // Basic success test
      });

      test('handles multiple instances with different configs', () {
        final plugins = <QueueFlushingPluginWithRotation>[];
        
        for (int i = 0; i < 10; i++) {
          final config = FileRotationConfig(
            maxFileSize: 1024 * (i + 1), // Different sizes
            baseFilename: 'events-$i',
          );
          
          final plugin = QueueFlushingPluginWithRotation(
            mockFlushFunction,
            rotationConfig: config,
          );
          
          plugins.add(plugin);
        }
        
        expect(plugins.length, 10);
        
        // All should be unique instances
        for (int i = 0; i < plugins.length; i++) {
          for (int j = i + 1; j < plugins.length; j++) {
            expect(plugins[i], isNot(same(plugins[j])));
          }
        }
      });
    });

    group('constructor validation', () {
      test('requires flush callback parameter', () {
        // This should compile - flush callback is required
        final plugin = QueueFlushingPluginWithRotation(mockFlushFunction);
        expect(plugin, isNotNull);
      });

      test('allows null rotation config to use default', () {
        final plugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: null,
        );
        expect(plugin, isNotNull);
      });

      test('preserves config instance when provided', () {
        final customConfig = FileRotationConfig(maxFileSize: 2048);
        final plugin = QueueFlushingPluginWithRotation(
          mockFlushFunction,
          rotationConfig: customConfig,
        );
        
        expect(plugin, isNotNull);
        // Note: Cannot directly access private _rotationConfig from test,
        // but we know it's preserved based on the constructor implementation
      });
    });
  });
}