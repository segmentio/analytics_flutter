import 'package:analytics_plugin_adjust/types.dart';

String? mappedCustomEventToken(String eventName, AdjustSettings settings) {
  String? result;
  final tokens = settings.customEvents;
  if (tokens != null) {
    result = tokens[eventName];
  }
  return result;
}

T? extract<T>(String key, Map<String, dynamic>? properties, {T? defaultValue}) {
  var result = defaultValue;
  if (properties == null) {
    return result;
  }
  for (final entry in properties.entries) {
    // not sure if this comparison is actually necessary,
    // but existed in the old destination so ...
    if (key.toLowerCase() == entry.key.toLowerCase()) {
      result = entry.value;
    }
  }

  return result;
}
