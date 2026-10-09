# Releasing

This repository is a monorepo of independently-versioned packages published to [pub.dev](https://pub.dev). There is no automated release workflow; releases are published manually with the Dart/Flutter `pub` tooling. CI (`.github/workflows/analytics_flutter.yml`) only runs analysis and tests.

## Packages

Each package under `packages/` is versioned and published on its own:

| Package | Path | pub.dev |
|---------|------|---------|
| `segment_analytics` (core) | `packages/core` | https://pub.dev/packages/segment_analytics |
| `segment_analytics_plugin_adjust` | `packages/plugins/plugin_adjust` | https://pub.dev/packages/segment_analytics_plugin_adjust |
| `segment_analytics_plugin_advertising_id` | `packages/plugins/plugin_advertising_id` | https://pub.dev/packages/segment_analytics_plugin_advertising_id |
| `segment_analytics_plugin_amplitude` | `packages/plugins/plugin_amplitude` | https://pub.dev/packages/segment_analytics_plugin_amplitude |
| `segment_analytics_plugin_appsflyer` | `packages/plugins/plugin_appsflyer` | https://pub.dev/packages/segment_analytics_plugin_appsflyer |
| `segment_analytics_plugin_firebase` | `packages/plugins/plugin_firebase` | https://pub.dev/packages/segment_analytics_plugin_firebase |
| `segment_analytics_plugin_idfa` | `packages/plugins/plugin_idfa` | https://pub.dev/packages/segment_analytics_plugin_idfa |

The plugins depend on the core package via a pub.dev version constraint (`segment_analytics: ^1.1.x`), **not** a path dependency. Because of this, if a release touches both core and a plugin, **publish core first** so the plugin's constraint can resolve against the already-published core version.

## Versioning

All packages follow [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`), and commits follow the [Conventional Commits](https://www.conventionalcommits.org/) convention (see [CONTRIBUTING.md](CONTRIBUTING.md)). Versions are bumped manually per package.

For the **core** package, the version is declared in two places that must be kept in sync:

- `packages/core/pubspec.yaml` → `version:`
- `packages/core/lib/version.dart` → `const segmentVersion = "X.Y.Z";` (sent as `context.library.version` on every event)

Each plugin's version lives only in its own `pubspec.yaml`.

## Prerequisites

- Flutter SDK installed (matching the version pinned in CI, currently `3.29.2` on the `stable` channel).
- A [pub.dev](https://pub.dev) account that is a verified uploader/publisher for the `segment_analytics*` packages. Authenticate once with `dart pub login`.
- A clean checkout of `main` with all changes for the release already merged and CI green.

## Releasing a package

Do this for each package you are releasing (core first if both core and plugins are changing).

1. **Bump the version.** Edit the package's `pubspec.yaml` `version:` field following SemVer. For the core package, also update `packages/core/lib/version.dart` to match.

2. **Update the changelog.** Add a new section to the package's `CHANGELOG.md` at the top (newest entries first), matching the existing format:

   ```markdown
   ## X.Y.Z

   - Short description of each change (reference the issue/PR number where relevant).
   ```

3. **Open a PR** with the version bump and changelog entry, get it reviewed, and merge into `main`.

4. **Verify before publishing.** From the package directory, run a dry run and fix any warnings:

   ```bash
   cd packages/core          # or the plugin you are releasing
   flutter pub get
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```

5. **Publish to pub.dev:**

   ```bash
   dart pub publish
   ```

6. **Tag the release (recommended).** Tag the published commit so the release is traceable in git. Because packages are versioned independently, use a package-qualified tag name, e.g.:

   ```bash
   git tag segment_analytics-vX.Y.Z      # core
   # or: segment_analytics_plugin_firebase-vX.Y.Z for a plugin
   git push origin --tags
   ```

7. **Confirm** the new version appears on the package's pub.dev page and that a fresh `flutter pub add` resolves it.

## Notes

- **Publish order:** core → plugins, whenever a plugin release depends on a new core version.
- **No automated publishing:** there is intentionally no CI publish step; `dart pub publish` is run by a verified publisher locally.
- **Keep `version.dart` in sync** with `pubspec.yaml` for the core package — a mismatch ships the wrong SDK version string in event metadata.
