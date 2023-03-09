// class PropertyMap {
//   final Set<String>? keys;
//   final bool optional;

//   PropertyMap({this.keys, this.optional = false});
// }

class PropertyMapper {
  final Set<String> sourceKeys;
  final dynamic Function(dynamic)? fromJson;

  const PropertyMapper(this.sourceKeys, {this.fromJson});
}

dynamic recurseMapper(
    dynamic value, Map<String, PropertyMapper> propertiesMapper) {
  if (value is List) {
    return value.map((value) => recurseMapper(value, propertiesMapper));
  } else if (value is Map) {
    value.map(
        (key, value) => MapEntry(key, recurseMapper(value, propertiesMapper)));
  } else {
    return value;
  }
}

dynamic Function(String targetKey,
        {bool? optional, dynamic Function(dynamic)? fromJson})
    propertyMapper(Map<String, dynamic>? properties,
        Map<String, PropertyMapper> propertiesMapper) {
  return (String targetKey,
      {bool? optional, dynamic Function(dynamic)? fromJson}) {
    final propertyMapper = propertiesMapper[targetKey];
    if (properties != null) {
      for (final sourceKey in (propertyMapper != null
          ? propertyMapper.sourceKeys
          : {targetKey})) {
        final value = properties[sourceKey];
        if (value != null) {
          return fromJson == null
              ? (propertyMapper?.fromJson == null
                  ? value
                  : propertyMapper?.fromJson!(value))
              : fromJson(value);
        }
      }
    }
    if (optional == null || optional == false) {
      throw Exception(
          "Missing properties: ${propertyMapper == null ? targetKey : propertyMapper.sourceKeys.join(',')}");
    } else {
      return null;
    }
  };
}

// Map<String, dynamic> mapProperties(
//     Map<String, dynamic> properties, Map<String, PropertyMap> mapper) {
//   final Map<String, dynamic> output = {};
//   final Set<String> missing = {};

//   for (final entry in mapper.entries) {
//     var found = false;
//     for (final sourceKey in entry.value.keys ?? {entry.key}) {
//       final value = properties[sourceKey];
//       if (value != null) {
//         output[entry.key] = value;
//         found = true;
//         break;
//       }
//     }
//     if (!found && !entry.value.optional) {
//       missing.add(entry.value.keys?.first ?? entry.key);
//     }
//   }

//   if (missing.isNotEmpty) {
//     throw Exception("Missing properties: ${missing.join(',')}");
//   }

//   return output;
// }
