# @segment/analytics-flutter

> **Warning**
> This project is currently only available in Beta phase and is covered by Segment's First Access & Beta Preview Terms. We encourage you to try out this new library. Please provide feedback via Github issues/PRs, and feel free to submit pull requests.

The hassle-free way to add Segment analytics to your Flutter[^1] app.

This is a monorepo containing all Segment packages

## Core (`segment_analytics`)

The main [`segment_analytics](http://pub.dev/packages/segment_analytics) package.

[Pub.dev](http://pub.dev/packages/segment_analytics)

[Docs](packages/core#readme)

## Plugins

### Adjust (`segment_analytics_plugin_adjust`)

[Pub.dev](http://pub.dev/packages/segment_analytics_plugin_adjust)

[Docs](packages/plugins/plugin_adjust#readme)

### AdvertisingID (`segment_analytics_plugin_advertising_id`)

[Pub.dev](http://pub.dev/packages/segment_analytics_plugin_advertising_id)

[Docs](packages/plugins/plugin_advertising_id#readme)

### AppsFlyer (`segment_analytics_plugin_appsflyer`)

[Pub.dev](http://pub.dev/packages/segment_analytics_plugin_appsflyer)

[Docs](packages/plugins/plugin_appsflyer#readme)

### Firebase (`segment_analytics_plugin_firebase`)

[Pub.dev](http://pub.dev/packages/segment_analytics_plugin_firebase)

[Docs](packages/plugins/plugin_firebase#readme)

### IDFA (`segment_analytics_plugin_idfa`)

[Pub.dev](http://pub.dev/packages/segment_analytics_plugin_idfa)

[Docs](packages/plugins/plugin_idfa#readme)

## Platform Support

Supports the following platforms:

- Android
- iOS
- MacOS
- Web

Some destination plugins might not support all platform functionality. Refer to their own Platform SDKs for more details.

## Example App

See the [example app](./example/README.md) to check a full test app of how to integrate Analytics-Flutter into your own Flutter app.

## Release Notes

### Version 1.1.7

1. **Release Date** - 21<sup>st</sup> May 2025.

2. **Fixes Github Issue [#144](https://github.com/segmentio/analytics_flutter/issues/144)** - Up to version 1.1.6, the `setFlushPolicies` method inadvertently overwrote the `Configuration.collectDeviceId`property. This issue has been resolved in version 1.1.7.

3. **Fixes Github Issue [#147](https://github.com/segmentio/analytics_flutter/issues/147)** - The `compileSdkVersion` in the `build.gradle` file has been updated from 31 to 35. Previously, this caused the following error:  
`Android build error "Only safe (?.) or non-null asserted (!!.) calls are allowed on a nullable receiver of type 'android.content.pm.ApplicationInfo?"` . This update resolves the issue with `compileSdkVersion 35`.

4. **Fixes Github Issue [#138](https://github.com/segmentio/analytics_flutter/issues/138)** - Prior to version 1.1.7, the version field returned the browser's version string instead of the app version from `pubspec.yaml`. Since `pubspec.yaml` is a build-time configuration file and not accessible at runtime (especially in browser environments), this was expected behavior.  
As of version 1.1.7, if the following tag is added to `<project-root>/web/index.html`: `<meta name="app-version" content="1.2.3">`
the app will return the value in the `content` attribute. 
**Note:** This value should be manually synchronized with the version in `pubspec.yaml`.

5. **Fixes Github Issue [#152](https://github.com/segmentio/analytics_flutter/issues/152) and [#98](https://github.com/segmentio/analytics_flutter/issues/98)** - Until version 1.1.6, the `integrations: {}` field was missing in the data payload sent to the Segment server. This has been addressed in version 1.1.7.

6. **Fixes Github Issue [#157](https://github.com/segmentio/analytics_flutter/issues/157)** - Resolves the `Concurrent modification during iteration: Instance(length: 6) of '_GrowableList'` error that occurred when multiple plugins were added simultaneously.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Code of Conduct

Before contributing, please also see our [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT

[^1]: The Flutter name and logo are trademarks owned by Google.

[circleci-image]: TODO
[circleci-url]: https://app.circleci.com/pipelines/github/segmentio/analytics-flutter
