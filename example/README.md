# analytics_example

Demonstrates how to use the analytics plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the application

1. Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

2. The example app showcases the Firebase integration, so you will need to get your own Firebase Project. Create an account and a new project [here](https://firebase.google.com/).

3. Follow the instructions to add Firebase to your Flutter app. 
   1. It will require you to install [Firebase CLI](https://firebase.google.com/docs/cli?hl=en&authuser=1#install_the_firebase_cli).
   2. At the root of the example app, run the `flutterfire configure --project={your-project-id}` command.
   3. You can skip the step for "Initialize Firebase and add plugins"

4. On your Segment Workspace create your own [Flutter source](https://app.segment.com/{workspace-name}/sources/setup/flutter)
5. Set your Segment `WriteKey` in [`config.dart`](https://github.com/segmentio/analytics_flutter/blob/7a9c1f92d59b3520b9d1029045be6d80eaf1bad5/example/lib/config.dart#L1)
6. Run `flutter run` on the example

