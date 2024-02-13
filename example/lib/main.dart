import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/state.dart';
import 'package:segment_analytics_example/config.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:segment_analytics/client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends MaterialApp {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey,
      debug: true, trackApplicationLifecycleEvents: true));

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
                  analytics
                      .track("Test Event", properties: {"prop1": "value1"});
                },
                child: const Text('Track Product Viewed'),
              ),
              TextButton(
                onPressed: () {
                  analytics.track('Products Searched',
                      properties: {"query": 'blue roses'});
                  analytics.track('Product List Viewed', properties: {
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
                  analytics.track('Promotion Viewed', properties: {
                    "promotion_id": 'promo_1',
                    "creative": 'top_banner_2',
                    "name": '75% store-wide shoe sale',
                    "position": 'home_banner_top'
                  });
                  analytics.track('Product Clicked', properties: {
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
                  analytics.track('Product Shared', properties: {
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
                  analytics.track('Cart Shared', properties: {
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
                  analytics.reset();
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () {
                  analytics.flush();
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
                  analytics.identify(
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
