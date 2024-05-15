# segment_analytics_plugin_advertising_id

`EnrichmentPlugin` to collect advertisingId on Android

## Installation

Manually add this package to your `pubspec.yaml` file.

```yaml
dependencies:
  analytics_plugin_advertising_id:
    git:
      url: https://github.com/segmentio/analytics_flutter
      ref: main
      path: packages/plugins/plugin_advertising_id
```

This plugin requires a `compileSdkVersion` of at least 19.

See [Google Play Services documentation](https://developers.google.com/admob/android/quick-start) for `advertisingId` setup

## Usage

Follow the [instructions for adding plugins](https://github.com/segmentio/analytics_flutter_#adding-plugins) on the main Analytics client:

In your code where you initialize the analytics client call the `.add(plugin)` method with an `AdvertisingIdDestination` instance. 

```dart
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics_plugin_advertising_id/plugin_advertising_id.dart'
    show PluginAdvertisingId;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    // ...

    analytics
        .addPlugin(PluginAdvertisingId());
  }
}
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

```
MIT License

Copyright (c) 2023 Segment

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
