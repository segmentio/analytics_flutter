# segment_analytics_plugin_firebase

`DestinationPlugin` for [Firebase](https://firebase.google.com). Wraps [`firebase_analytics`](https://pub.dev/packages/firebase_analytics).

## Installation

Manually add this package to your `pubspec.yaml` file.

```yaml
dependencies:
  segment_analytics_plugin_firebase:
    git:
      url: https://github.com/segmentio/analytics_flutter
      ref: main
      path: packages/plugins/plugin_firebase
```

You will then need to configure your Firebase settings as per the [core Firebase documentation](https://firebase.google.com/docs/flutter/setup?platform=web) by running:

```bash
flutterfire configure
```

This will create a `firebase_options.dart` file under your `lib` folder.

## Usage

Follow the [instructions for adding plugins](https://github.com/segmentio/analytics_flutter_#adding-plugins) on the main Analytics client:

In your code where you initialize the analytics client call the `.add(plugin)` method with an `FirebaseDestination` instance.

```dart
import 'firebase_options.dart';
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics_plugin_firebase/plugin_firebase.dart'
    show FirebaseDestination;

const writeKey = 'SEGMENT_API_KEY';

class _MyAppState extends State<MyApp> {
  final analytics = createClient(Configuration(writeKey));

  @override
  void initState() {
    // ...

    analytics
        .addPlugin(FirebaseDestination(DefaultFirebaseOptions.currentPlatform));
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
