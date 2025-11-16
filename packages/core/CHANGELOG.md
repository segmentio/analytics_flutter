## 1.1.10

- Migrating storage to proper application data directory

## 1.1.9

- Fix for storageJson configuration properly enabling/disabling writing of files on all platforms #171

## 1.1.8

- Reverting fix for #152 - The `integrations` field is vestigial and remains available for SDK users to populate to suppress extra events from server side destinations.

## 1.1.7

- Fix for setFlushPolicies method is overwriting Configuration properties #144 - Up to version 1.1.6, the `setFlushPolicies` method inadvertently overwrote the `Configuration.collectDeviceId`property.
- Fix for Android build error on nullable receiver in sdk 35 #147  - The `compileSdkVersion` in the `build.gradle` file has been updated from 31 to 35. Previously, this caused the following error:  
`Android build error "Only safe (?.) or non-null asserted (!!.) calls are allowed on a nullable receiver of type 'android.content.pm.ApplicationInfo?"`.
- Fix for Context app version wrong on Flutter web #138 - Prior to version 1.1.7, the version field returned the browser's version string instead of the app version from `pubspec.yaml`. Since `pubspec.yaml` is a build-time configuration file and not accessible at runtime (especially in browser environments), this was expected behavior.  
As of version 1.1.7, if the following tag is added to `<project-root>/web/index.html`: `<meta name="app-version" content="1.2.3">`
the app will return the value in the `content` attribute. 
**Note:** This value should be manually synchronized with the version in `pubspec.yaml`.
- Fix for Integrations field is empty in segment analytics #152 - Until version 1.1.6, the `integrations: {}` field was missing in the data payload sent to the Segment server.
- Fix for AppsFlyer Destination not initializing properly #98
- fix for Crash in Timeline.applyPlugins #157 - Resolves the `Concurrent modification during iteration: Instance(length: 6) of '_GrowableList'` error that occurred when multiple plugins were added simultaneously.

## 1.1.6

- Fix error loading storage files

## 1.1.5

- Update dependencies

## 1.1.4

- Fix Network Context deserialization issue

## 1.1.3

- Fix Deep Linking for iOS and Android

## 1.1.2

- Fix timestamp timezone
- Fix reported version

## 1.1.1

- Update dependencies
- Fixed event loss issue with flush
- Fixed timezone conversion issue

## 1.1.0

- Cleared out malformed files on error and reduced chance of files not writing completely if program exits prematurely
- Fixed podspec name
- Token added to device context
- Fixed route name on ScreenObserver
- Add flag to disable data storage

## 1.0.2

- Fixed an issue with EU Workspaces not respecting the proper apiHost

## 1.0.1

- Fix cocoapods

## 1.0.0

- iOS, Android, Web, and MacOS support
- Firebase, Adjust, and Appsflyer destination plugins
- adverising_id and IDFA enrichment plugins
- All event types supported (track, identify, screen, alias, group)
- Automatic Screen events
- Application life-cycle capture
- Customisable Flushing policies
- Customisable logging and error reporting
- Customisable HTTP (CDN) client
- Unit tested (although not all parts)
- Strongly typed, including User Traits and Context objects and plugin settings
- Fully asynchronous and concurrency safe state and persistence management
- Example app showing off usage of the SDK
