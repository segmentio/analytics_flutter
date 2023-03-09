import 'package:analytics/event.dart';
import 'package:analytics/plugin.dart';

class DestinationMetadataEnrichment extends UtilityPlugin {
  DestinationMetadataEnrichment(this._destinationKey)
      : super(PluginType.enrichment);

  final String _destinationKey;

  @override
  Future<RawEvent> execute(RawEvent event) async {
    final pluginSettings = analytics?.state.integrations.state;
    final plugins = analytics?.getPlugins(PluginType.destination);

    if (pluginSettings == null) {
      return event;
    }

    // Disable all destinations that have a device mode plugin
    final destinations =
        plugins?.map((plugin) => (plugin as DestinationPlugin).key) ?? [];
    final bundled = <String>{};

    for (var key in destinations) {
      if (key == _destinationKey) {
        continue;
      }

      if (pluginSettings.containsKey(key)) {
        bundled.add(key);
      }
    }

    final unbundled = <String>{};
    final segmentInfo = pluginSettings[_destinationKey] ?? {};
    List<dynamic> unbundledIntegrations =
        segmentInfo["unbundledIntegrations"] ?? [];

    // All active integrations, not in `bundled` are put in `unbundled`
    // All unbundledIntegrations not in `bundled` are put in `unbundled`
    for (var integration in pluginSettings.keys) {
      if (integration != _destinationKey && !bundled.contains(integration)) {
        unbundled.add(integration);
      }
    }
    for (var integration in unbundledIntegrations) {
      if (!bundled.contains(integration)) {
        unbundled.add(integration);
      }
    }

    // User/event defined integrations override the cloud/device mode merge
    event.metadata = DestinationMetadata(
        bundled: bundled.toList(),
        unbundled: unbundled.toList(),
        bundledIds: []);

    return event;
  }
}
