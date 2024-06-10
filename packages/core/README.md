# segment_analytics

> **Warning**
> This project is currently only available in Beta phase and is covered by Segment's First Access & Beta Preview Terms. We encourage you to try out this new library. Please provide feedback via Github issues/PRs, and feel free to submit pull requests.

The hassle-free way to add Segment analytics to your Flutter[^1] app.

Supports the following platforms:

- Android
- iOS
- MacOS
- Web

Some destination plugins might not support all platform functionality. Refer to their own Platform SDKs for more details.

## Table of Contents

- [segment_analytics](#segment_analytics)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Upgrading from Pilot](#upgrading-from-pilot)
    - [Permissions](#permissions)
  - [Usage](#usage)
    - [Setting up the client](#setting-up-the-client)
    - [Client Options](#client-options)
  - [Client methods](#client-methods)
    - [Track](#track)
    - [Screen](#screen)
    - [Identify](#identify)
    - [Group](#group)
    - [Alias](#alias)
    - [Reset](#reset)
    - [Flush](#flush)
    - [(Advanced) Cleanup](#advanced-cleanup)
  - [Automatic screen tracking](#automatic-screen-tracking)
  - [Plugins + Timeline architecture](#plugins--timeline-architecture)
    - [Plugin Types](#plugin-types)
    - [Destination Plugins](#destination-plugins)
    - [Adding Plugins](#adding-plugins)
    - [Writing your own Plugins](#writing-your-own-plugins)
    - [Supported Plugins](#supported-plugins)
  - [Controlling Upload With Flush Policies](#controlling-upload-with-flush-policies)
  - [Adding or removing policies](#adding-or-removing-policies)
    - [Creating your own flush policies](#creating-your-own-flush-policies)
  - [Custom Logging](#custom-logging)
  - [Handling errors](#handling-errors)
    - [Reporting errors from plugins](#reporting-errors-from-plugins)
  - [Example App](#example-app)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
  - [License](#license)

## Installation

Run:

`flutter pub add segment_analytics`

```dart
import 'package:segment_analytics/client.dart';
```

### Upgrading from Pilot

Since pilot phase we have renamed the package of this library from `analytics` to `segment_analytics`. Some changes have to be applied after upgrading to the v1 package:

In your `pubspec.yaml` remove the `analytics` package and use `segment_analytics` instead.

```diff
-   analytics:
-     git:
-       url: https://github.com/segmentio/analytics_flutter
-       ref: main
-       path: packages/core
+   segment_analytics: ^1.0.1
```

In your dart files change the imports from `package:segment_analytics` to `package:segment_analytics`:

```diff
- import 'package:segment_analytics/client.dart';
+ import 'package:segment_analytics/client.dart';
```

### Permissions

<details>

<summary>Android</summary>
In your app's `AndroidManifest.xml` add the below line between the `<manifest>` tags.

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

</details>

## Usage

### Setting up the client

The package exposes a method called `createClient` which we can use to create the Segment Analytics client. This central client manages all our tracking events. It is recommended you add this as a property on your main app's state class.

```dart
const writeKey = 'SEGMENT_API_KEY';
final analytics = createClient(Configuration(writeKey));
```

You must pass at least the `writeKey`. Additional configuration options are listed below:

### Client Options

| Name                              | Default                       | Description                                                                                                                                                                                                                                                                     |
| --------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | 
| `writeKey` **(REQUIRED)**         | ''                            | Your Segment API key.                                                                                                                                                                                                                                                           |
| `debug`                           | false                         | When set to false, it will not generate any info logs.                                                                                                                                                                                                                          |
| `collectDeviceId`                 | false                         | Set to true to automatically collect the device ID from the DRM API on Android devices.                                                                                                                                                                                         |
| `flushPolicies`                   | count=30,time=20s             | List of flush policies controlling when to send batches of events to the plugins                                                                                                                                                                                                |
| `apiHost`                         | "api.segment.io/v1"           | Used to specify the regional Segment event endpoint                                                                                                                                                                                                                             |
| `cdnHost`                         | "cdn-settings.segment.com/v1" | Used to specify the regional Segment settings endpoint                                                                                                                                                                                                                          |
| `errorHandler`                    | null                          | Custom error handler. By default logs errors to the standard flutter logger                                                                                                                                                                                                     |
| `trackApplicationLifecycleEvents` | false                         | Enable automatic tracking for [app lifecycle events](https://segment.com/docs/connections/spec/mobile/#lifecycle-events): application installed, opened, updated, backgrounded)                                                                                                 |
| `trackDeeplinks`                  | false                         | Enable automatic tracking for when the user opens the app via a deep link. \*NOTE: when sending this flag, the sdk plugin_appsflyer will ignore [onAppOpenAttribution](https://github.com/AppsFlyerSDK/appsflyer-flutter-plugin/blob/master/doc/Guides.md#Unified-deep-linking) |
| `autoAddSegmentDestination`       | true                          | Set to false to skip adding the SegmentDestination plugin                                                                                                                                                                                                                       |
| `defaultIntegrationSettings`      | null                          | Plugin settings that will be used if the request to get the settings from Segment fails.                                                                                                                                                                                        |
| `maxBatchSize`                    | true                          | 100 Maximum number of events to send to the API at once.                                                                                                                                                                                                                        |
| `appStateStream`                  | null                          | Set to override the stream of application foreground or background events.                                                                                                                                                                                                      |
| `requestFactory`                  | true                          | Set to override the factory to generate HTTP requests. Type: [RequestFactory](https://github.com/segmentio/analytics_flutter/blob/master/packages/core/lib/state.dart#L546)                                                                                                     |
| `storageJson`                     | true                          | Enable or disable automatic the generation JSON files for the serialization library                                                                                                                                                                                             |

## Client methods

### Track

The [track](https://segment.com/docs/connections/spec/track/) method is how you record any actions your users perform, along with any properties that describe the action.

Method signature:

```dart
Future track(String event: string, {Map<String, dynamic>? properties});
```

Example usage:

```dart
analytics.track("View Product", properties: {
  "productId": 123,
  "productName": "Striped trousers"
});
```

### Screen

The [screen](https://segment.com/docs/connections/spec/screen/) call lets you record whenever a user sees a screen in your mobile app, along with any properties about the screen.

Method signature:

```dart
Future screen(String name: string, {Map<String, dynamic>? properties});
```

Example usage:

```dart
analytics.screen("ScreenName", properties: {
  "productSlug": "example-product-123",
});
```

For setting up automatic screen tracking, see the [instructions below](#automatic-screen-tracking).

### Identify

The [identify](https://segment.com/docs/connections/spec/identify/) call lets you tie a user to their actions and record traits about them. This includes a unique user ID and any optional traits you know about them like their email, name, etc. The traits option can include any information you might want to tie to the user, but when using any of the [reserved user traits](https://segment.com/docs/connections/spec/identify/#traits), you should make sure to only use them for their intended meaning. All reserved traits are strongly typed by the `UserTraits` class. When using traits not listsed as a reserved user trait, these will go under the `custom` property.

Method signature:

```dart
Future identify({String? userId, UserTraits? userTraits});
```

Example usage:

```dart
analytics.identify(userId: "testUserId", userTraits: UserTraits(
  username: "MisterWhiskers",
  email: "hello@test.com",
  custom: {
    "plan": "premium"
  }
);
```

### Group

The [group](https://segment.com/docs/connections/spec/group/) API call is how you associate an individual user with a group—be it a company, organization, account, project, team or whatever other crazy name you came up with for the same concept! This includes a unique group ID and any optional group traits you know about them like the company name industry, number of employees, etc. The traits option can include any information you might want to tie to the group, but when using any of the [reserved group traits](https://segment.com/docs/connections/spec/group/#traits), you should make sure to only use them for their intended meaning. All reserved traits are strongly typed by the `GroupTraits` class. When using traits not listsed as a reserved user trait, these will go under the `custom` property.

Method signature:

```dart
Future group(String groupId, {GroupTraits? groupTraits});
```

Example usage:

```dart
analytics.group("some-company", groupTraits: GroupTraits(
  name: 'Segment',
  custom: {
    "region": "UK"
  }
);
```

### Alias

The [alias](https://segment.com/docs/connections/spec/alias/) method is used to merge two user identities, effectively connecting two sets of user data as one. This is an advanced method, but it is required to manage user identities successfully in some of our destinations.

Method signature:

```dart
Future alias(String newUserId);
```

Example usage:

```dart
analytics.alias("user-123");
```

### Reset

The reset method clears the internal state of the library for the current user and group. This is useful for apps where users can log in and out with different identities over time.

Note: Each time you call reset, a new AnonymousId is generated automatically.

Method signature:

```dart
void reset();
```

Example usage:

```dart
analytics.reset();
```

### Flush

By default, the analytics will be sent to the API after 30 seconds or when 20 items have accumulated, whatever happens sooner, and whenever the app resumes if the user has closed the app with some events unsent. These values can be modified by the `flushAt` and `flushInterval` config options. You can also trigger a flush event manually.

Method signature:

```dart
Future flush();
```

Example usage:

```dart
analytics.flush();
```

### (Advanced) Cleanup

You probably don't need this!

In case you need to reinitialize the client, that is, you've called `createClient` more than once for the same client in your application lifecycle, use this method _on the old client_ to clear any subscriptions and timers first.

```dart
var analytics = createClient(Configuration(writeKey));

analytics.cleanup();

analytics = createClient(Configuration(writeKey));
```

If you don't do this, the old client instance would still exist and retain the timers, making all your events fire twice.

Ideally, you shouldn't need this though, and the Segment client should be initialized only once in the application lifecycle.

## Automatic screen tracking

Sending a `screen()` event with each navigation action will get tiresome quick, so you'll probably want to track navigation globally. To set this up, you'll need to add the analytics navigator observer to your app's navigator observers. For example, if you're using the `MaterialApp` class, you would add the following:

```dart
return MaterialApp(navigatorObservers: [
  ScreenObserver()
]);
```

## Plugins + Timeline architecture

You have complete control over how the events are processed before being uploaded to the Segment API.

In order to customise what happens after an event is created, you can create and place various Plugins along the processing pipeline that an event goes through. This pipeline is referred to as a Timeline.

### Plugin Types

| Plugin Type | Description                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------ |
| before      | Executed before event processing begins.                                                               |
| enrichment  | Executed as the first level of event processing.                                                       |
| destination | Executed as events begin to pass off to destinations.                                                  |
| after       | Executed after all event processing is completed. This can be used to perform cleanup operations, etc. |
| utility     | Executed only when called manually, such as Logging.                                                   |

Plugins can have their own native code (such as the iOS-only `analytics_plugin_idfa`) or wrap an underlying library (such as `analytics_plugin_firebase` which uses `firebase_core` and `firebase_analytics` under the hood)

### Destination Plugins

Segment is included as a `DestinationPlugin` out of the box. You can add as many other DestinationPlugins as you like, and upload events and data to them in addition to Segment.

Or if you prefer, you can pass `autoAddSegmentDestination = false` in the options when setting up your client. This prevents the SegmentDestination plugin from being added automatically for you.

### Adding Plugins

You can add a plugin at any time through the `add()` method.

```dart
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/state.dart';
import 'package:segment_analytics_plugin_advertising_id/plugin_advertising_id.dart';
import 'package:segment_analytics_plugin_idfa/plugin_idfa.dart';
import 'package:segment_analytics_plugin_firebase/plugin_firebase.dart'
    show FirebaseDestination;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    super.initState();
    initPlatformState();

    analytics
        .addPlugin(FirebaseDestination(DefaultFirebaseOptions.currentPlatform));
    analytics.addPlugin(PluginAdvertisingId());
    analytics.addPlugin(PluginIdfa());
  }
}
```

### Writing your own Plugins

Plugins are implemented by extending one of the provided plugin classes. The available plugin classes are:-

- `Plugin`
- `EventPlugin`
- `DestinationPlugin`
- `UtilityPlugin`
- `PlatformPlugin`

Any plugins must be an extension of one of these classes.

You can them customise the functionality by overriding different methods on the base class. For example, here is a simple `Logger` plugin:

```dart
import 'dart:convert';

import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/logger.dart';

class EventLogger extends DestinationPlugin {
  var logKind = LogFilterKind.debug;

  EventLogger() : super("event_logger");

  @override
  void configure(Analytics analytics) {
    pAnalytics = analytics;
  }

  @override
  Future<RawEvent?>? execute(RawEvent event) async {
    log("${event.type.toString().toUpperCase()} event${event is TrackEvent ? " (${event.event})" : ''} saved: \n${jsonEncode(event.toJson())}",
        kind: logKind);
    return event;
  }
}
```

As it overrides the `execute()` method, this `Logger` will call `log` for every event going through the Timeline.

### Supported Plugins

Refer to the following table for Plugins you can use to meet your tracking needs:

| Plugin                                                                                                                      | Package                           |
| --------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| [Adjust](https://github.com/segmentio/analytics_flutter/tree/master/packages/plugins/plugin_adjust)                         | `analytics_plugin_adjust`         |
| [AppsFlyer](https://github.com/segmentio/analytics_flutter/tree/master/packages/plugins/plugin_appsflyer)                   | `analytics_plugin_appsflyer`      |
| [Firebase](https://github.com/segmentio/analytics_flutter/tree/master/packages/plugins/plugin_firebase)                     | `analytics_plugin_firebase`       |
| [IDFA](https://github.com/segmentio/analytics_flutter/tree/master/packages/plugins/plugin_idfa)                             | `analytics_plugin_idfa`           |
| [Android Advertising ID](https://github.com/segmentio/analytics_flutter/tree/master/packages/plugins/plugin_advertising_id) | `analytics_plugin_advertising-id` |

## Controlling Upload With Flush Policies

To more granurily control when events are uploaded you can use `FlushPolicies`

A Flush Policy defines the strategy for deciding when to flush, this can be on an interval, on a certain time of day, after receiving a certain number of events or even after receiving a particular event. This gives you even more flexibility on when to send event to Segment.

To make use of flush policies you can set them in the configuration of the client:

```dart
import 'package:segment_analytics/flush_policies/count_flush_policy.dart';
import 'package:segment_analytics/flush_policies/timer_flush_policy.dart';

final analytics = createClient(Configuration(/*...*/, flushPolicies: [
  CountFlushPolicy(10),
  TimerFlushPolicy(100000)
]));
```

You can set several policies at a time. Whenever any of them decides it is time for a flush it will trigger an upload of the events. The rest get reset so that their logic restarts after every flush.

That means only the first policy to reach `shouldFlush` gets to trigger a flush at a time. In the example above either the event count gets to 5 or the timer reaches 500ms, whatever comes first will trigger a flush.

We have several standard FlushPolicies:

- `CountFlushPolicy` triggers whenever a certain number of events is reached
- `TimerFlushPolicy` triggers on an interval of milliseconds
- `StartupFlushPolicy` triggers on client startup only

## Adding or removing policies

One of the main advatanges of FlushPolicies is that you can add and remove policies on the fly. This is very powerful when you want to reduce or increase the amount of flushes.

For example you might want to disable flushes if you detect the user has no network:

```dart
if (isConnected) {
  analytics.addFlushPolicy(policiesIfNetworkIsUp);
} else {
  analytics.removeFlushPolicy(policiesIfNetworkIsUp)
}
```

### Creating your own flush policies

You can create a custom FlushPolicy special for your application needs by implementing the `FlushPolicy` interface. You can also extend the `FlushPolicyBase` class that already creates and handles the `shouldFlush` value reset.

A `FlushPolicy` only needs to implement 1 method:

- `onEvent(RawEvent event)`: Gets called on every event tracked by your client

and optionally can implement:

- `reset()`: Called after a flush is triggered (either by your policy, by another policy or manually)
- `start()`: Executed when the flush policy is enabled and added to the client. This is a good place to start background operations, make async calls, configure things before execution

They also have a `shouldFlush` boolean value. When this is set to true the client will atempt to upload events. Each policy should reset this value to `false` according to its own logic, although it is pretty common to do it inside the `reset` method.

```dart
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';

class FlushOnScreenEventsPolicy extends FlushPolicy {

  @override
  onEvent(RawEvent event) {
    // Only flush when a screen even happens
    if (event is ScreenEvent) {
      this.shouldFlush = true;
    }
  }

  @override
  reset() {
    // Superclass will reset the shouldFlush value so that the next screen event triggers a flush again
    // But you can also reset the value whenever, say another event comes in or after a timeout
    super.reset();
  }
}
```

## Custom Logging

By default any logging is done via the standard Flutter logging mechanism. To customise logging, you can build your own logger, which must implement the `LogTarget` mixin. For example:

```dart
import 'package:segment_analytics/logger.dart';

void customDebugLog(String msg) {
  // ...
}

void customWarningLog(String msg) {
  // ...
}

void customErrorLog(String msg) {
  // ...
}

class CustomLogger with LogTarget {
  @override
  void parseLog(LogMessage log) {
    switch (log.kind) {
      case LogFilterKind.debug:
        customDebugLog("Segment: ${log.message}");
        break;
      case LogFilterKind.warning:
        customWarningLog("Segment: ${log.message}");
        break;
      case LogFilterKind.error:
        customErrorLog("Segment: ${log.message}");
        break;
    }
  }
}

// Set the default logger to use the CustomLogger
LogFactory.logger = CustomLogger();
```

## Handling errors

You can handle analytics client errors through the `errorHandler` option.

The error handler configuration receives a function which will get called whenever an error happens on the analytics client. It will receive an Exception, that will extend one of the errors from [errors.dart](./lib/errors.dart).

You can use this error handling to trigger different behaviours in the client when a problem occurs. For example if the client gets rate limited you could use the error handler to swap flush policies to be less aggressive:

```dart
import 'package:segment_analytics/errors.dart';

//...

final flushPolicies = [CountFlushPolicy(5), TimerFlushPolicy(500)];

void errorHandler(Exception error) {
  if (error is NetworkServerLimited) {
    // Remove all flush policies
    analytics.removeFlushPolicy(analytics.getFlushPolicies());
    // Add less persistent flush policies
    analytics.addFlushPolicy([
      CountFlushPolicy(100),
      TimerFlushPolicy(5000)
    ]);
  }
}

final analytics = createClient(Configuration(writeKey),
  errorHandler: errorHandler,
  flushPolicies: flushPolicies);
```

### Reporting errors from plugins

Plugins can also report errors to the handler by using the [`.error`](./lib/analytics.dart#L55) function of the analytics client, we recommend using the `PluginError` for consistency, and attaching the `innerError` with the actual exception that was hit:

```dart
import 'package:segment_analytics/errors.dart';

//...

try {
  distinctId = await mixpanel.getDistinctId();
} catch (e) {
  analytics.error(
    PluginError('Error: Mixpanel error calling getDistinctId', e)
  );
}
```

## Example App

See the [example app](../../example/README.md) to check a full test app of how to integrate Analytics-Flutter into your own Flutter app.

## Contributing

See the [contributing guide](./CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Code of Conduct

Before contributing, please also see our [code of conduct](../../CODE_OF_CONDUCT.md).

## License

MIT

[^1]: The Flutter name and logo are trademarks owned by Google.

[circleci-image]: TODO
[circleci-url]: https://app.circleci.com/pipelines/github/segmentio/analytics-flutter
