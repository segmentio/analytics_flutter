import 'package:analytics/map_transform.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:json_annotation/json_annotation.dart';
part 'properties.g.dart';

const Map<String, PropertyMapper> propertiesMapper = {
  "value": PropertyMapper({"total"}),
  "items": PropertyMapper({"products"}, fromJson: itemsFromJson),
  "itemName": PropertyMapper({"name"}),
  "itemId": PropertyMapper({"product_id", "productId"}),
  "searchTerm": PropertyMapper({"query"}),
  "method": PropertyMapper({"share_via"}),
  "contentType": PropertyMapper({"category"})
};

dynamic itemsFromJson(dynamic items) {
  return (items as List<dynamic>).map(AnalyticsEventItemJson.fromJson);
}

@JsonSerializable()
class AnalyticsEventItemJson extends AnalyticsEventItem {
  static AnalyticsEventItemJson fromJson(dynamic item) =>
      _$AnalyticsEventItemJsonFromJson(recurseMapper(item, propertiesMapper));
}
