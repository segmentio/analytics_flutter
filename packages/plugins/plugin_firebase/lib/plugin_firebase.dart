library analytics_plugin_firebase;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions, Firebase;
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/map_transform.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics_plugin_firebase/properties.dart';

export 'package:firebase_core/firebase_core.dart' show FirebaseOptions, Firebase;

class FirebaseDestination extends DestinationPlugin {
  final Future<void> firebaseFuture;

  FirebaseDestination([FirebaseOptions? firebaseOptions])
      : firebaseFuture = firebaseOptions != null
            ? Firebase.initializeApp(
                options: firebaseOptions,
              )
            : Future.value(),
        super('Firebase');

  @override
  Future<RawEvent?> identify(IdentifyEvent event) async {
    // Set user ID if provided
    if (event.userId != null) {
      await FirebaseAnalytics.instance.setUserId(id: event.userId);
    }

    // Set user properties from traits if provided
    if (event.traits != null) {
      // Transform and cast traits to the required format
      final transformedTraits = recurseMapper(event.traits?.toJson(), mappings);
      final userProperties = castParameterType(transformedTraits as Map<String, Object?>);

      // Set each user property individually
      for (final entry in userProperties.entries) {
        await FirebaseAnalytics.instance.setUserProperty(
          name: entry.key,
          value: entry.value.toString(),
        );
      }
    }

    return event;
  }

  @override
  Future<RawEvent?> track(TrackEvent event) async {
    await firebaseFuture;
    final properties = mapProperties(event.properties, mappings);

    try {
      switch (event.event) {
        case 'Product Clicked':
          if (!(properties.containsKey('list_id') ||
              properties.containsKey('list_name') ||
              properties.containsKey('name') ||
              properties.containsKey('itemId'))) {
            throw Exception("Missing properties: list_name, list_id, name and itemID");
          }

          AnalyticsEventItem itemClicked =
              AnalyticsEventItem(itemName: properties['name'].toString(), itemId: properties['itemId'].toString());

          await FirebaseAnalytics.instance.logSelectItem(
            itemListName: properties['list_name'].toString(),
            itemListId: properties['list_id'].toString(),
            items: [itemClicked],
          );
          break;
        case 'Product Viewed':
          await FirebaseAnalytics.instance.logViewItem(
              currency: properties["currency"]?.toString(),
              items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Product Added':
          await FirebaseAnalytics.instance.logAddToCart(
              currency: properties["currency"]?.toString(),
              items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Product Removed':
          await FirebaseAnalytics.instance.logRemoveFromCart(
              currency: properties["currency"]?.toString(),
              items: event.properties == null ? null : [AnalyticsEventItemJson(event.properties!)],
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Checkout Started':
          await FirebaseAnalytics.instance.logBeginCheckout(
              coupon: properties["coupon"]?.toString(),
              currency: properties["currency"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Promotion Viewed':
          await FirebaseAnalytics.instance.logViewPromotion(
              creativeName: properties["creativeName"]?.toString(),
              creativeSlot: properties["creativeSlot"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              locationId: properties["locationId"]?.toString(),
              promotionId: properties["promotionId"]?.toString(),
              promotionName: properties["promotionName"]?.toString());
          break;
        case 'Payment Info Entered':
          await FirebaseAnalytics.instance.logAddPaymentInfo(
              coupon: properties["coupon"]?.toString(),
              currency: properties["currency"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              paymentType: properties["paymentType"]?.toString(),
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Order Completed':
          await FirebaseAnalytics.instance.logPurchase(
              affiliation: properties["affiliation"]?.toString(),
              coupon: properties["coupon"]?.toString(),
              currency: properties["currency"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              shipping: double.tryParse(properties["shipping"].toString()),
              tax: double.tryParse(properties["tax"].toString()),
              transactionId: properties["transactionId"]?.toString(),
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Order Refunded':
          await FirebaseAnalytics.instance.logRefund(
              affiliation: properties["affiliation"]?.toString(),
              coupon: properties["coupon"]?.toString(),
              currency: properties["currency"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              shipping: double.tryParse(properties["shipping"].toString()),
              tax: double.tryParse(properties["tax"].toString()),
              transactionId: properties["transactionId"]?.toString(),
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Product List Viewed':
          await FirebaseAnalytics.instance.logViewItemList(
              itemListId: properties["itemListId"]?.toString(),
              itemListName: properties["itemListName"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>);
          break;
        case 'Product Added to Wishlist':
          await FirebaseAnalytics.instance.logAddToWishlist(
              currency: properties["currency"]?.toString(),
              items: properties["items"] as List<AnalyticsEventItemJson>,
              value: double.tryParse(properties["value"].toString()));
          break;
        case 'Cart Shared':
          if (event.properties == null || event.properties!['products'] == null) {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          } else if (event.properties!['products'] is List) {
            await Future.wait((event.properties!['products'] as List).map((product) async {
              final productProperties = mapProperties(product, mappings);
              if (productProperties.containsKey("contentType") &&
                  productProperties.containsKey("itemId") &&
                  productProperties.containsKey("method")) {
                await FirebaseAnalytics.instance.logShare(
                    contentType: productProperties["contentType"].toString(),
                    itemId: productProperties["itemId"].toString(),
                    method: properties["method"].toString());
              } else {
                log("Error tracking Cart Shared, product missing properties. Required: contentType, itemId, method");
              }
            }));
          } else {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          }
          break;
        case 'Product Shared':
          if (!properties.containsKey("contentType") ||
              !properties.containsKey("itemId") ||
              !properties.containsKey("method")) {
            throw Exception("Missing properties: contentType, itemId, method");
          }
          await FirebaseAnalytics.instance.logShare(
              contentType: properties["contentType"].toString(),
              itemId: properties["itemId"].toString(),
              method: properties["method"].toString());
          break;
        case 'Products Searched':
          if (!properties.containsKey("searchTerm")) {
            throw Exception("Missing property: searchTerm");
          }

          await FirebaseAnalytics.instance.logSearch(
              searchTerm: properties["searchTerm"].toString(),
              destination: properties["destination"]?.toString(),
              endDate: properties["endDate"]?.toString(),
              numberOfNights: int.tryParse(properties["numberOfNights"].toString()),
              numberOfPassengers: int.tryParse(properties["numberOfPassengers"].toString()),
              numberOfRooms: int.tryParse(properties["numberOfRooms"].toString()),
              origin: properties["origin"]?.toString(),
              startDate: properties["startDate"]?.toString(),
              travelClass: properties["travelClass"]?.toString());
          break;
        default:
          await FirebaseAnalytics.instance.logEvent(
            name: sanitizeEventName(event.event),
            parameters: castParameterType(properties),
          );
          break;
      }
    } catch (error) {
      log("Error tracking event '${event.event}' for Firebase: ${error.toString()}");
    }
    return event;
  }

  @override
  Future<RawEvent?> screen(ScreenEvent event) async {
    // Transform and cast properties to the required format
    final transformedProperties = recurseMapper(event.properties, mappings);
    final parameters = castParameterType(transformedProperties as Map<String, Object?>);

    FirebaseAnalytics.instance.logScreenView(
      screenClass: event.name,
      screenName: event.name,
      parameters: parameters,
    );
    return event;
  }

  @override
  void reset() {
    FirebaseAnalytics.instance.resetAnalyticsData();
  }
}
