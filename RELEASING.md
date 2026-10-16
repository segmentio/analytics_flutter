# Releasing

This repository is a monorepo of independently versioned packages published to [pub.dev](https://pub.dev). Pushing a package-qualified tag publishes that package from CI (`.github/workflows/publish.yml`) using pub.dev [automated publishing](https://dart.dev/tools/pub/automated-publishing) (OIDC, no stored credentials).

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

3. **Tag and push** from `main` at the merged release commit:

   ```bash
   git tag segment_analytics-vX.Y.Z
   git push origin segment_analytics-vX.Y.Z
   ```

   The tag is `<pubspec name>-v<version>`, e.g. `segment_analytics_plugin_firebase-v1.0.2` for a plugin. The tag alone selects the package.
4. **Approve** the `publish` job when it pauses on the `production` environment. Before that, the workflow checks that the tag, `pubspec.yaml`, the newest `CHANGELOG.md` section and (for core) `lib/version.dart` agree, that the commit is on `main`, and that the package's tests pass. A failure there publishes nothing.
5. **Verify** the version appears on the package's pub.dev page and that a fresh `flutter pub add <package>` resolves it.

When releasing several packages, wait for core to appear on pub.dev before tagging a plugin that needs it.

## Re-running a failed publish

If the tag-triggered run failed for a transient reason, re-run it from the Actions tab. If the tag points at the wrong commit, fix `main`, then delete and recreate the tag.

The **Publish to pub.dev** workflow can also be started by hand (`workflow_dispatch`) with `package` set to `core` or `plugins/plugin_<name>`. It runs the same checks. Do not tag afterwards: the tag would start a second publish of a version that already exists, which fails.

## One-time setup

**GitHub:** the `production` environment (Settings → Environments) needs required reviewers, and its deployment branches and tags limited to `main` and the tag patterns `segment_analytics-v*` and `segment_analytics_plugin_*-v*`. The pub.dev environment requirement below only checks that the job names the environment; the reviewers are what make it a gate.

**pub.dev, per package:** on the package's **Admin** tab, under **Automated publishing**, choose **Publishing from GitHub Actions** (not the Google Cloud service account option) and set:

- **Repository:** `segmentio/analytics_flutter`
- **Tag pattern:** `<package>-v{{version}}`, matching the tag above
- **Push** and **`workflow_dispatch`:** both enabled
- **Environment:** `production`, exactly as named in `publish.yml`

Without this the publish step fails with an authorization error.

## Changing the Flutter version

The Flutter SDK is pinned and checksum-verified. To bump it, change all of these together:

- `.github/actions/setup-flutter/action.yml` → default `flutter-version`
- `FLUTTER_VERSION` in `.github/workflows/ci.yml` and `.github/workflows/publish.yml`
- the `sha256:` input on every `setup-flutter` step in both workflows (one in `ci.yml`, two in `publish.yml`)

Take the checksum for the `stable/linux/flutter_linux_<version>-stable.tar.xz` archive from `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`.

## Break-glass

If automated publishing is unavailable, a pub.dev uploader can run `dart pub publish` locally from the package directory after `dart pub login`. Tag the release afterwards, noting that pushing the tag starts the workflow, which will fail on the already-published version; that is harmless.
