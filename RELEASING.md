# Releasing

This repository is a monorepo of independently versioned packages published to [pub.dev](https://pub.dev). Publishing runs in CI (`.github/workflows/publish.yml`) using pub.dev [automated publishing](https://dart.dev/tools/pub/automated-publishing) (OIDC, no stored credentials). Nobody runs `dart pub publish` from a laptop.

## Packages

| Package | Path |
|---------|------|
| `segment_analytics` (core) | `packages/core` |
| `segment_analytics_plugin_adjust` | `packages/plugins/plugin_adjust` |
| `segment_analytics_plugin_advertising_id` | `packages/plugins/plugin_advertising_id` |
| `segment_analytics_plugin_amplitude` | `packages/plugins/plugin_amplitude` |
| `segment_analytics_plugin_appsflyer` | `packages/plugins/plugin_appsflyer` |
| `segment_analytics_plugin_firebase` | `packages/plugins/plugin_firebase` |
| `segment_analytics_plugin_idfa` | `packages/plugins/plugin_idfa` |

Plugins depend on core through a pub.dev constraint (`segment_analytics: ^1.x`), not a path dependency, so a plugin can only be published against a core version that is already on pub.dev. **Release core first.**

## Versioning

[SemVer](https://semver.org/) per package; commits follow [Conventional Commits](CONTRIBUTING.md#commit-message-convention). Versions are bumped by hand in the release PR.

- A raised minimum Flutter or Dart SDK constraint is a breaking change for every consumer, including Android and web, because pub resolves it for the whole package. Bump the major version.
- Core's version lives in two files that must match, or events report the wrong `context.library.version`:
  - `packages/core/pubspec.yaml` → `version:`
  - `packages/core/lib/version.dart` → `segmentVersion`
- A plugin's version lives only in its own `pubspec.yaml`.
- When core ships a new major, every plugin's `segment_analytics:` constraint stops matching it. Widen the constraint (e.g. `">=1.1.1 <3.0.0"`) and release the plugins after core.

## Release steps

1. **Release PR.** Bump the version(s), add a `## X.Y.Z` section at the top of each package's `CHANGELOG.md`, and update the README if compatibility changes. Merge to `main` with CI green.
2. **Dry run** from the package directory:

   ```bash
   cd packages/core            # or the plugin being released
   flutter pub get
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```

3. **Publish.** Core: publish a GitHub Release on `main` with tag `segment_analytics-vX.Y.Z`. That fires `publish.yml`, which always publishes `packages/core`; the tag does not select the package. A plugin: run the **Publish to pub.dev** workflow manually (`workflow_dispatch`) with `package` set to its path under `packages/`, e.g. `plugins/plugin_firebase`.
4. **Approve** the `publish` job if the `production` environment requires review. The workflow runs the package's tests first and publishes only if they pass.
5. **Verify** the version appears on the package's pub.dev page and that a fresh `flutter pub add <package>` resolves it.

When releasing several packages, wait for core to appear on pub.dev before publishing a plugin that needs it.

## Tags

Use `<package>-v<version>` (`segment_analytics-v1.2.0`, `segment_analytics_plugin_firebase-v1.0.2`). Packages version independently, so a bare `vX.Y.Z` is ambiguous. The tag pattern configured under each package's **Admin → Automated publishing** on pub.dev must match this format.

## One-time setup per package (pub.dev)

On each package's **Admin** tab, enable automated publishing from GitHub Actions for repository `segmentio/analytics_flutter` with the tag pattern above. A package without this fails at the publish step with an authorization error.

## Changing the Flutter version

The Flutter SDK is pinned and checksum-verified. To bump it, change all of these together:

- `.github/actions/setup-flutter/action.yml` → default `flutter-version`
- `FLUTTER_VERSION` in `.github/workflows/ci.yml` and `.github/workflows/publish.yml`
- the `sha256:` input on every `setup-flutter` step in both workflows (one in `ci.yml`, two in `publish.yml`)

Take the checksum for the `stable/linux/flutter_linux_<version>-stable.tar.xz` archive from `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`.

## Break-glass

If automated publishing is unavailable, a pub.dev publisher can run `dart pub publish` locally from the package directory after `dart pub login`. Record the release in the CHANGELOG as usual and tag it afterwards.
