import 'package:analytics/analytics.dart';
import 'package:analytics/event.dart';
import 'package:analytics/screen_observer.dart';
import 'package:analytics/state.dart';
import 'package:analytics_example/config.dart';
import 'package:analytics_plugin_advertising_id/plugin_advertising_id.dart';
import 'package:analytics_plugin_idfa/plugin_idfa.dart';
import 'package:analytics_example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:analytics_plugin_firebase/plugin_firebase.dart'
    show FirebaseDestination;

void main() {
  runApp(const MyApp());
}

class MyApp extends MaterialApp {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();

    Analytics.init(Configuration(writeKey,
        debug: true, trackApplicationLifecycleEvents: false));

    Analytics.instance
        .addPlugin(FirebaseDestination(DefaultFirebaseOptions.currentPlatform));
    Analytics.instance.addPlugin(PluginAdvertisingId());
    Analytics.instance.addPlugin(PluginIdfa());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(navigatorObservers: [
      ScreenObserver()
    ], routes: {
      '/': (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/next");
                },
                child: const Text('Next Screen'),
              ),
              TextButton(
                onPressed: () {
                  Analytics.instance
                      .track("Test Event", properties: {"prop1": "value1"});
                },
                child: const Text('Track Product Viewed'),
              ),
              TextButton(
                onPressed: () {
                  Analytics.instance.track('Products Searched',
                      properties: {"query": 'blue roses'});
                  Analytics.instance.track('Product List Viewed', properties: {
                    "list_id": 'hot_deals_1',
                    "category": 'Deals',
                    "products": [
                      {
                        "product_id": '507f1f77bcf86cd799439011',
                        "sku": '45790-32',
                        "name": 'Monopoly: 3rd Edition',
                        "price": 19,
                        "position": 1,
                        "category": 'Games',
                        "url": 'https://www.example.com/product/path',
                        "image_url": 'https://www.example.com/product/path.jpg'
                      },
                      {
                        "product_id": '505bd76785ebb509fc183733',
                        "sku": '46493-32',
                        "name": 'Uno Card Game',
                        "price": 3,
                        "position": 2,
                        "category": 'Games'
                      }
                    ]
                  });
                  Analytics.instance.track('Promotion Viewed', properties: {
                    "promotion_id": 'promo_1',
                    "creative": 'top_banner_2',
                    "name": '75% store-wide shoe sale',
                    "position": 'home_banner_top'
                  });
                  Analytics.instance.track('Product Clicked', properties: {
                    "product_id": '507f1f77bcf86cd799439011',
                    "sku": 'G-32',
                    "category": 'Games',
                    "name": 'Monopoly: 3rd Edition',
                    "brand": 'Hasbro',
                    "variant": '200 pieces',
                    "price": 18.99,
                    "quantity": 1,
                    "coupon": 'MAYDEALS',
                    "position": 3,
                    "url": 'https://www.example.com/product/path',
                    "image_url": 'https://www.example.com/product/path.jpg'
                  });
                  Analytics.instance.track('Product Shared', properties: {
                    "share_via": 'email',
                    "share_message": 'Hey, check out this item',
                    "recipient": 'friend@example.com',
                    "product_id": '507f1f77bcf86cd799439011',
                    "sku": 'G-32',
                    "category": 'Games',
                    "name": 'Monopoly: 3rd Edition',
                    "brand": 'Hasbro',
                    "variant": '200 pieces',
                    "price": 18.99,
                    "url": 'https://www.example.com/product/path',
                    "image_url": 'https://www.example.com/product/path.jpg'
                  });
                  Analytics.instance.track('Cart Shared', properties: {
                    "share_via": 'email',
                    "share_message": 'Hey, check out this item',
                    "recipient": 'friend@example.com',
                    "cart_id": 'd92jd29jd92jd29j92d92jd',
                    "products": [
                      {"product_id": '507f1f77bcf86cd799439011'},
                      {"product_id": '505bd76785ebb509fc183733'}
                    ]
                  });
                },
                child: const Text('Track eCommerce events'),
              ),
              TextButton(
                onPressed: () {
                  Analytics.instance.reset();
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  Analytics.instance.flush();
                },
                child: const Text('Flush'),
              ),
            ])),
          ),
      '/next': (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Next Screen'),
              ),
              TextButton(
                onPressed: () {
                  Analytics.instance.identify(
                      userId: "testUserId",
                      userTraits: UserTraits(name: "Test User"));
                },
                child: const Text('Identify Event'),
              ),
            ])),
          )
    });
  }
}
