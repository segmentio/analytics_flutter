typedef JSONMap = Map<String, dynamic>; // TODO: Better types

class SegmentAPIIntegration {
  final String apiKey;
  final String apiHost;

  SegmentAPIIntegration({required this.apiKey, required this.apiHost});
}

class SegmentAPISettings {
  JSONMap integrations;
  // TODO: We don't support Destination Filters yet, when we do add them here

  SegmentAPISettings({this.integrations = const {}});
}
