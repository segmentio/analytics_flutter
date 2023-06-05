class PropertyMapper {
  final String targetKey;
  final dynamic Function(dynamic)? fromJson;

  const PropertyMapper(this.targetKey, {this.fromJson});
}

dynamic recurseMapper(dynamic value, Map<String, PropertyMapper> mappings) {
  if (value is List) {
    return value.map((value) => recurseMapper(value, mappings));
  } else if (value is Map<String, dynamic>) {
    return mapProperties(value, mappings);
  } else if (value is Map) {
    return value
        .map((key, value) => MapEntry(key, recurseMapper(value, mappings)));
  } else {
    return value;
  }
}

Map<String, Object?> mapProperties(
    Map<String, dynamic>? properties, Map<String, PropertyMapper> mappings) {
  final Map<String, Object?> output = {};

  if (properties == null) {
    return {};
  }

  for (final entry in properties.entries) {
    final sourceKey = entry.key;
    final sourceValue = properties[sourceKey];
    if (mappings.containsKey(sourceKey)) {
      final mapping = mappings[sourceKey]!;

      output[mapping.targetKey] = (mapping.fromJson != null)
          ? mapping.fromJson!(sourceValue)
          : sourceValue;
    } else {
      output[sourceKey] = sourceValue;
    }
  }

  return output;
}
