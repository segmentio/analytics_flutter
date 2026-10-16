#!/usr/bin/env bash
# Resolves which package a publish run targets and fails the run, before anyone
# is asked to approve it, if that package is inconsistent: pubspec, changelog,
# version.dart and the tag must all agree on the version.
#
# Inputs (env): EVENT    github.event_name (push of a tag, or workflow_dispatch)
#               TAG      github.ref_name, read only for push
#               PACKAGE  workflow_dispatch input: path under packages/
#               GITHUB_OUTPUT  receives `package=<path under packages/>`
set -euo pipefail

fail() { echo "::error::$*"; exit 1; }

if [[ "$EVENT" == "push" ]]; then
  # pub.dev only accepts tag pushes for push-triggered publishing, and the tag
  # is the sole selector of the package: <pubspec name>-v<version>.
  name="${TAG%%-v[0-9]*}"
  case "$name" in
    segment_analytics) PACKAGE=core ;;
    segment_analytics_plugin_[a-z_]*) PACKAGE="plugins/plugin_${name#segment_analytics_plugin_}" ;;
    *) fail "tag '$TAG' does not name a package in this repo" ;;
  esac
fi

# PACKAGE reaches working-directory in the workflow; reject anything that could
# escape packages/.
[[ "${PACKAGE:-}" =~ ^(core|plugins/plugin_[a-z_]+)$ ]] || fail "invalid package '${PACKAGE:-}'"
dir="packages/$PACKAGE"
[[ -f "$dir/pubspec.yaml" ]] || fail "$dir/pubspec.yaml not found"

name=$(sed -n 's/^name: *//p' "$dir/pubspec.yaml" | head -1)
version=$(sed -n 's/^version: *//p' "$dir/pubspec.yaml" | head -1)
[[ -n "$name" && -n "$version" ]] || fail "could not read name/version from $dir/pubspec.yaml"

# pub.dev publishes whatever pubspec.yaml says, so the tag must say the same.
if [[ "$EVENT" == "push" ]]; then
  [[ "$TAG" == "$name-v$version" ]] || fail "tag '$TAG' != '$name-v$version' (pubspec.yaml in $dir)"
fi

# Whatever triggered the run, the code being published must be on main.
git fetch -q origin main
git merge-base --is-ancestor "$GITHUB_SHA" origin/main || fail "$GITHUB_SHA is not on main"

top=$(sed -n 's/^## *//p' "$dir/CHANGELOG.md" | head -1)
[[ "$top" == "$version" ]] || fail "newest CHANGELOG section is '$top', pubspec version is '$version'"

if [[ "$PACKAGE" == "core" ]]; then
  # segmentVersion is sent as context.library.version on every event.
  dart_version=$(sed -n 's/^const segmentVersion = "\(.*\)";/\1/p' "$dir/lib/version.dart")
  [[ "$dart_version" == "$version" ]] || fail "lib/version.dart is '$dart_version', pubspec version is '$version'"
fi

echo "OK: $name $version"
echo "package=$PACKAGE" >> "${GITHUB_OUTPUT:-/dev/null}"
