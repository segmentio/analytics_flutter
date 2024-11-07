import 'package:segment_analytics/map_transform.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:json_annotation/json_annotation.dart';

const Map<String, PropertyMapper> mappings = {
  "total": PropertyMapper("value"),
  "products": PropertyMapper("items", fromJson: itemsFromJson),
  "name": PropertyMapper("itemName"),
  "product_id": PropertyMapper("itemId"),
  "productId": PropertyMapper("itemId"),
  "query": PropertyMapper("searchTerm"),
  "share_via": PropertyMapper("method"),
  "category": PropertyMapper("contentType")
};

dynamic itemsFromJson(dynamic items) {
  if (items is List<dynamic>) {
    return items.map((item) {
      final mappedObject = mapProperties(item, mappings);
      return AnalyticsEventItemJson(mappedObject);
    }).toList();
  } else {
    return items;
  }
}

String sanitizeEventName(String eventName) {
  return eventName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
}

Map<String, Object> castParameterType(Map<String, Object?> properties) {
  Map<String, Object> safeProperties = {};
  properties.forEach((key, value) {
    if (value != null) {
      if (value is String || value is num) {
        safeProperties[key] = value;
      } else {
        safeProperties[key] = value.toString();
      }
    }
  });
  return safeProperties;
}

@JsonSerializable()
class AnalyticsEventItemJson extends AnalyticsEventItem {
  AnalyticsEventItemJson(Map<String, Object?> json)
      : super(
          affiliation: json['affiliation'].toString(),
          currency: json['currency'].toString(),
          coupon: json['coupon'].toString(),
          creativeName: json['creativeName'].toString(),
          creativeSlot: json['creativeSlot'].toString(),
          discount: num.tryParse(json['discount'].toString()),
          index: int.tryParse(json['index'].toString()),
          itemBrand: json['itemBrand'].toString(),
          itemCategory: json['itemCategory'].toString(),
          itemCategory2: json['itemCategory2'].toString(),
          itemCategory3: json['itemCategory3'].toString(),
          itemCategory4: json['itemCategory4'].toString(),
          itemCategory5: json['itemCategory5'].toString(),
          itemId: json['itemId'].toString(),
          itemListId: json['itemListId'].toString(),
          itemListName: json['itemListName'].toString(),
          itemName: json['itemName'].toString(),
          itemVariant: json['itemVariant'].toString(),
          locationId: json['locationId'].toString(),
          price: num.tryParse(json['price'].toString()),
          promotionId: json['promotionId'].toString(),
          promotionName: json['promotionName'].toString(),
          quantity: int.tryParse(json['quantity'].toString()),
        );
}
