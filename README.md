# @segment/analytics-flutter

The hassle-free way to add Segment analytics to your Flutter app.

## Table of Contents

- [@segment/analytics-flutter](#segmentanalytics-flutter)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Permissions](#permissions)
  - [Usage](#usage)
    - [Setting up the client](#setting-up-the-client)
    - [Client Options](#client-options)
    - [iOS Deep Link Tracking Setup](#ios-deep-link-tracking-setup)
    - [Usage with Client](#usage-with-client)
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
  - [Handling errors](#handling-errors)
    - [Reporting errors from plugins](#reporting-errors-from-plugins)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
  - [License](#license)

## Installation

TODO

### Permissions

TODO

## Usage

### Setting up the client

TODO
  
### Client Options

TODO

### iOS Deep Link Tracking Setup
*Note: This is only required for iOS if you are using the `trackDeepLinks` option. Android does not require any additional setup*

To track deep links in iOS you must add the following to your `AppDelegate.m` file:

```objc
  #import <segment_analytics_react_native-Swift.h>
  
  ...
  
- (BOOL)application:(UIApplication *)application
            openURL: (NSURL *)url
            options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  
  [AnalyticsReactNative trackDeepLink:url withOptions:options];  
  return YES;
}
```

### Usage with Client

TODO

## Client methods

### Track

The [track](https://segment.com/docs/connections/spec/track/) method is how you record any actions your users perform, along with any properties that describe the action.

Method signature:

```dart
Future track(String event: string, {Map<String, dynamic>? properties});
```

Example usage:

```dart
TODO
```

### Screen

The [screen](https://segment.com/docs/connections/spec/screen/) call lets you record whenever a user sees a screen in your mobile app, along with any properties about the screen.

Method signature:

```dart
Future screen(String name: string, {Map<String, dynamic>? properties});
```

Example usage:

```dart
TODO
```

For setting up automatic screen tracking, see the [instructions below](#automatic-screen-tracking).

### Identify

The [identify](https://segment.com/docs/connections/spec/identify/) call lets you tie a user to their actions and record traits about them. This includes a unique user ID and any optional traits you know about them like their email, name, etc. The traits option can include any information you might want to tie to the user, but when using any of the [reserved user traits](https://segment.com/docs/connections/spec/identify/#traits), you should make sure to only use them for their intended meaning.

Method signature:

```dart
Future identify({String? userId, Map<String, dynamic>? traits});
```

Example usage:

```dart
TODO
```

### Group

The [group](https://segment.com/docs/connections/spec/group/) API call is how you associate an individual user with a group—be it a company, organization, account, project, team or whatever other crazy name you came up with for the same concept! This includes a unique group ID and any optional group traits you know about them like the company name industry, number of employees, etc. The traits option can include any information you might want to tie to the group, but when using any of the [reserved group traits](https://segment.com/docs/connections/spec/group/#traits), you should make sure to only use them for their intended meaning.

Method signature:

```dart
Future group(String groupId, {Map<String, dynamic>? traits});
```

Example usage:

```dart
TODO
```

### Alias

The [alias](https://segment.com/docs/connections/spec/alias/) method is used to merge two user identities, effectively connecting two sets of user data as one. This is an advanced method, but it is required to manage user identities successfully in some of our destinations.

Method signature:

```dart
Future alias(String newUserId);
```

Example usage:

```dart
TODO
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
TODO
```

### Flush

By default, the analytics will be sent to the API after 30 seconds or when 20 items have accumulated, whatever happens sooner, and whenever the app resumes if the user has closed the app with some events unsent. These values can be modified by the `flushAt` and `flushInterval` config options. You can also trigger a flush event manually.

Method signature:

```dart
Future flush();
```

Example usage:

```dart
TODO
```

### (Advanced) Cleanup

TODO

## Automatic screen tracking

Sending a `screen()` event with each navigation action will get tiresome quick, so you'll probably want to track navigation globally. The implementation will be different depending on which library you use for navigation. The two main navigation libraries for React Native are [React Navigation](https://reactnavigation.org/) and [React Native Navigation](https://wix.github.io/react-native-navigation).

## Plugins + Timeline architecture

You have complete control over how the events are processed before being uploaded to the Segment API.

In order to customise what happens after an event is created, you can create and place various Plugins along the processing pipeline that an event goes through. This pipeline is referred to as a Timeline.

### Plugin Types

| Plugin Type  | Description                                                                                             |
|--------------|---------------------------------------------------------------------------------------------------------|
| before       | Executed before event processing begins.                                                                |
| enrichment   | Executed as the first level of event processing.                                                        |
| destination  | Executed as events begin to pass off to destinations.                                                   |
| after        | Executed after all event processing is completed.  This can be used to perform cleanup operations, etc. |
| utility      | Executed only when called manually, such as Logging.                                                    |

Plugins can have their own native code (such as the iOS-only `IdfaPlugin`) or wrap an underlying library (such as `FirebasePlugin` which uses `react-native-firebase` under the hood)

### Destination Plugins

Segment is included as a `DestinationPlugin` out of the box. You can add as many other DestinationPlugins as you like, and upload events and data to them in addition to Segment.

Or if you prefer, you can pass `autoAddSegmentDestination = false` in the options when setting up your client. This prevents the SegmentDestination plugin from being added automatically for you.

### Adding Plugins

TODO

### Writing your own Plugins

TODO
  
### Supported Plugins 
  
Refer to the following table for Plugins you can use to meet your tracking needs:
  
| Plugin      | Package     |
| ----------- | ----------- |
  
  
## Controlling Upload With Flush Policies

To more granurily control when events are uploaded you can use `FlushPolicies`

A Flush Policy defines the strategy for deciding when to flush, this can be on an interval, on a certain time of day, after receiving a certain number of events or even after receiving a particular event. This gives you even more flexibility on when to send event to Segment.

To make use of flush policies you can set them in the configuration of the client:

```dart
TODO
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
TODO
```

### Creating your own flush policies

TODO

## Handling errors

TODO

### Reporting errors from plugins

TODO

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Code of Conduct

Before contributing, please also see our [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT

[circleci-image]: TODO
[circleci-url]: https://app.circleci.com/pipelines/github/segmentio/analytics-flutter
