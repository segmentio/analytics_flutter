library plugin_firebase;

import 'package:analytics/event.dart';
import 'package:analytics/logger.dart';
import 'package:analytics/plugin.dart';
import 'package:analytics/map_transform.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions, Firebase;

export 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions, Firebase;

import 'package:analytics_plugin_firebase/properties.dart';

class FirebaseDestination extends DestinationPlugin {
  final Future<void> firebaseFuture;

  FirebaseDestination(FirebaseOptions? firebaseOptions)
      : firebaseFuture = Firebase.initializeApp(
          options: firebaseOptions,
        ),
        super('Firebase');

  @override
  Future<RawEvent?>? identify(IdentifyEvent event) async {
    if (event.userId != null) {
      await FirebaseAnalytics.instance.setUserId(id: event.userId!);
    }
    if (event.traits != null) {
      await Future.wait(event.traits!.toJson().entries.map((entry) async {
        await FirebaseAnalytics.instance
            .setUserProperty(name: entry.key, value: entry.value);
      }));
    }
    return event;
  }

  @override
  Future<RawEvent?>? track(TrackEvent event) async {
    await firebaseFuture;

    final properties = propertyMapper(event.properties, propertiesMapper);

    try {
      switch (event.event) {
        case 'Product Clicked':
          await FirebaseAnalytics.instance.logSelectContent(
              contentType: properties('contentType'),
              itemId: properties('itemId'));
          break;
        case 'Product Viewed':
          await FirebaseAnalytics.instance.logViewItem(
              currency: properties("currency", optional: true),
              items: event.properties == null
                  ? null
                  : [AnalyticsEventItemJson.fromJson(event.properties)],
              value: properties("value", optional: true));
          break;
        case 'Product Added':
          await FirebaseAnalytics.instance.logAddToCart(
              currency: properties("currency", optional: true),
              items: event.properties == null
                  ? null
                  : [AnalyticsEventItemJson.fromJson(event.properties)],
              value: properties("value", optional: true));
          break;
        case 'Product Removed':
          await FirebaseAnalytics.instance.logRemoveFromCart(
              currency: properties("currency", optional: true),
              items: event.properties == null
                  ? null
                  : [AnalyticsEventItemJson.fromJson(event.properties)],
              value: properties("value", optional: true));
          break;
        case 'Checkout Started':
          await FirebaseAnalytics.instance.logBeginCheckout(
              coupon: properties("coupon", optional: true),
              currency: properties("currency", optional: true),
              items: properties("items", optional: true),
              value: properties("value", optional: true));
          break;
        case 'Promotion Viewed':
          await FirebaseAnalytics.instance.logViewPromotion(
              creativeName: properties("creativeName", optional: true),
              creativeSlot: properties("creativeSlot", optional: true),
              items: properties("items", optional: true),
              locationId: properties("locationdId", optional: true),
              promotionId: properties("promotionId", optional: true),
              promotionName: properties("promotionName", optional: true));
          break;
        case 'Payment Info Entered':
          await FirebaseAnalytics.instance.logAddPaymentInfo(
              coupon: properties("coupon", optional: true),
              currency: properties("currency", optional: true),
              items: properties("items", optional: true),
              paymentType: properties("paymentType", optional: true),
              value: properties("value", optional: true));
          break;
        case 'Order Completed':
          await FirebaseAnalytics.instance.logPurchase(
              affiliation: properties("affiliation", optional: true),
              coupon: properties("coupon", optional: true),
              currency: properties("currency", optional: true),
              items: properties("items", optional: true),
              shipping: properties("shipping", optional: true),
              tax: properties("tax", optional: true),
              transactionId: properties("transactionId", optional: true),
              value: properties("value", optional: true));
          break;
        case 'Order Refunded':
          await FirebaseAnalytics.instance.logRefund(
              affiliation: properties("affiliation", optional: true),
              coupon: properties("coupon", optional: true),
              currency: properties("currency", optional: true),
              items: properties("items", optional: true),
              shipping: properties("shipping", optional: true),
              tax: properties("tax", optional: true),
              transactionId: properties("transactionId", optional: true),
              value: properties("value", optional: true));
          break;
        case 'Product List Viewed':
          await FirebaseAnalytics.instance.logViewItemList(
              itemListId: properties("itemListId", optional: true),
              itemListName: properties("itemListName", optional: true),
              items: properties("items", optional: true));
          break;
        case 'Product Added to Wishlist':
          await FirebaseAnalytics.instance.logAddToWishlist(
              currency: properties("currency", optional: true),
              items: properties("items", optional: true),
              value: properties("value", optional: true));
          break;
        case 'Cart Shared':
          if (event.properties == null ||
              event.properties!['products'] == null) {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          } else if (event.properties!['products'] is List) {
            await Future.wait(
                (event.properties!['products'] as List).map((product) async {
              final productProperties =
                  propertyMapper(product, propertiesMapper);
              await FirebaseAnalytics.instance.logShare(
                  contentType: productProperties("contentType", optional: true),
                  itemId: productProperties("itemId", optional: true),
                  method: properties("method", optional: true));
            }));
          } else {
            log("Error tracking event '${event.event}' for Firebase: products property must be a list of products");
          }
          break;
        case 'Product Shared':
          await FirebaseAnalytics.instance.logShare(
              contentType: properties("contentType", optional: true),
              itemId: properties("itemId", optional: true),
              method: properties("method", optional: true));
          break;
        case 'Products Searched':
          await FirebaseAnalytics.instance.logSearch(
              searchTerm: properties("searchTerm"),
              destination: properties("destination", optional: true),
              endDate: properties("endDate", optional: true),
              numberOfNights: properties("numberOfNights", optional: true),
              numberOfPassengers:
                  properties("numberOfPassengers", optional: true),
              numberOfRooms: properties("numberOfRooms", optional: true),
              origin: properties("origin", optional: true),
              startDate: properties("startDate", optional: true),
              travelClass: properties("travelClass", optional: true));
          break;
      }
    } catch (error) {
      log("Error tracking event '${event.event}' for Firebase: ${error.toString()}");
    }
    return event;
  }

  @override
  Future<RawEvent?>? screen(ScreenEvent event) async {
    FirebaseAnalytics.instance
        .logScreenView(screenClass: event.name, screenName: event.name);
    return event;
  }

  @override
  void reset() {
    FirebaseAnalytics.instance.resetAnalyticsData();
  }
}
