import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/timeline.dart';

// Clases Mock
class MockPlugin extends Mock implements Plugin {
  @override
  final PluginType type;

  MockPlugin(this.type);
}

void main() {
  group('Timeline Tests', () {
    late Timeline timeline;
    late MockPlugin mockPluginBefore;
    late MockPlugin mockPluginEnrichment;

    setUp(() {
      timeline = Timeline();
      mockPluginBefore = MockPlugin(PluginType.before);
      mockPluginEnrichment = MockPlugin(PluginType.enrichment);
    });

    test('add should add plugin to correct type', () {
      timeline.add(mockPluginBefore);
      expect(timeline.getPlugins(PluginType.before), contains(mockPluginBefore));
    });

    test('remove should remove plugin from correct type', () {
      timeline.add(mockPluginBefore);
      timeline.remove(mockPluginBefore);
      expect(timeline.getPlugins(PluginType.before), isNot(contains(mockPluginBefore)));
    });

    test('apply should execute closure on all plugins', () {
      timeline.add(mockPluginBefore);
      timeline.add(mockPluginEnrichment);

      int closureCallCount = 0;
      timeline.apply((plugin) {
        closureCallCount++;
      });

      expect(closureCallCount, 2);
    });

    test('getPlugins should return plugins of specified type', () {
      timeline.add(mockPluginBefore);
      timeline.add(mockPluginEnrichment);

      final beforePlugins = timeline.getPlugins(PluginType.before);
      final enrichmentPlugins = timeline.getPlugins(PluginType.enrichment);
      final emptyPlugins = timeline.getPlugins(null);

      expect(beforePlugins, contains(mockPluginBefore));
      expect(enrichmentPlugins, contains(mockPluginEnrichment));
      expect(emptyPlugins, contains(mockPluginBefore));
    });

    test('getPluginsWithFlush sholudd return plugins', (){
      timeline.add(mockPluginBefore);
      timeline.add(mockPluginEnrichment);
      final list = getPluginsWithFlush(timeline);
      expect(list.length, 0);
    });

    test('getPluginsWithReset sholudd return plugins', (){
      timeline.add(mockPluginBefore);
      timeline.add(mockPluginEnrichment);
      final list = getPluginsWithReset(timeline);
      expect(list.length, 0);
    });
  });
}
