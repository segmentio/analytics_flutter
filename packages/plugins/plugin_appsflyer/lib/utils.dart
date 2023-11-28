double? extractRevenue(String key, Map<String, dynamic> properties) {
  if (properties[key] == null) {
    return null;
  }

  if (properties[key] is double || properties[key] is int) {
    return properties[key];
  } else if (properties[key] is String) {
    return double.parse(properties[key]);
  } else {
    return null;
  }
}

String? extractCurrency(
    String key, Map<String, dynamic> properties, String? defaultCurrency) {
  return properties[key] ?? defaultCurrency;
}
