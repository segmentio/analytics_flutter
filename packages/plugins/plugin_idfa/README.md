# segment_analytics_plugin_idfa

`Plugin` which retrieves IDFA data (iOS only). IDFA data will then be included in `event` payloads under `event.context.device`

**This plugin only works on iOS. Android calls will result in no-op.**

## Installation

Manually add this package to your `pubspec.yaml` file.

```yaml
dependencies:
  analytics_plugin_idfa:
    git:
      url: https://github.com/segmentio/analytics_flutter
      ref: main
      path: packages/plugins/plugin_idfa
```

You also need to ensure you have a description for `NSUserTrackingUsageDescription` in your `Info.plist`, or your app will crash.

## Usage

Follow the [instructions for adding plugins](https://github.com/segmentio/analytics_flutter_#adding-plugins) on the main Analytics client:

In your code where you initialize the analytics client call the `.add(plugin)` method with an `PluginIdfa` instance. 

```dart
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics_plugin_idfa/plugin_idfa.dart'
    show PluginIdfa;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    // ...

    analytics
        .addPlugin(PluginIdfa());
  }
}
```

## Customize IDFA Plugin Initialization

To delay the `IDFA Plugin` initialization (ie. to avoid race condition with push notification prompt) implement the following:

```dart
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics_plugin_idfa/plugin_idfa.dart'
    show PluginIdfa;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    // ...

    final idfaPlugin = PluginIdfa(shouldAskPermission: false);

    analytics
        .addPlugin(idfaPlugin);

    // ...

    idfaPlugin.requestTrackingPermission().then((enabled) {
      /**  ... */
    });
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
