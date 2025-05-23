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

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## Code of Conduct

Before contributing, please also see our [code of conduct](CODE_OF_CONDUCT.md).

## License

MIT

[^1]: The Flutter name and logo are trademarks owned by Google.

[circleci-image]: TODO
[circleci-url]: https://app.circleci.com/pipelines/github/segmentio/analytics-flutter
