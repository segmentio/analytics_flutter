class Settings {
  Map<String, dynamic>? integrations;
  Map<String, dynamic>? plan;
  Map<String, dynamic>? edgeFunctions;

  Settings(String writeKey, String apiHost) {
    integrations = Map<String, dynamic>()
  }
}