# segment_analytics_plugin_appsflyer

`DestinationPlugin` for [Appsflyer](https://www.appsflyer.com/). Wraps [`appsflyer_sdk`](https://pub.dev/packages/appsflyer_sdk).

## Installation

Manually add this package to your `pubspec.yaml` file.

```yaml
dependencies:
  segment_analytics_plugin_appsflyer:
    git:
      url: https://github.com/segmentio/analytics_flutter
      ref: main
      path: packages/plugins/plugin_appsflyer
```

## Usage

Follow the [instructions for adding plugins](https://github.com/segmentio/analytics_flutter_#adding-plugins) on the main Analytics client:

In your code where you initialize the analytics client call the `.add(plugin)` method with an `AppsFlyerDestination` instance.

```dart
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics_plugin_appsflyer/plugin_appsflyer.dart'
    show AppsFlyerDestination;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    // ...

    analytics
        .addPlugin(AppsFlyerDestination());
  }
}
```

## Support

Please use Github issues, Pull Requests, or feel free to reach out to our [support team](https://segment.com/help/).

## Integrating with Segment

Interested in integrating your service with us? Check out our [Partners page](https://segment.com/partners/) for more details.

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
