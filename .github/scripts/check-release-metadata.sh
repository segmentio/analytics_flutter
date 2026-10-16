#!/usr/bin/env bash
# Fails the publish run before anyone is asked to approve it if the package about
# to be published is inconsistent: pubspec, changelog, version.dart and (for a
# release trigger) the tag must all agree on the version.
#
# Inputs (env): PACKAGE  path under packages/ (e.g. core, plugins/plugin_firebase)
#               EVENT    github.event_name
#               TAG      github.ref_name, only read for the release event
set -euo pipefail

fail() { echo "::error::$*"; exit 1; }

# PACKAGE reaches working-directory in the workflow; reject anything that could
# escape packages/.
[[ "$PACKAGE" =~ ^(core|plugins/plugin_[a-z_]+)$ ]] || fail "invalid package '$PACKAGE'"
dir="packages/$PACKAGE"
[[ -f "$dir/pubspec.yaml" ]] || fail "$dir/pubspec.yaml not found"

name=$(sed -n 's/^name: *//p' "$dir/pubspec.yaml" | head -1)
version=$(sed -n 's/^version: *//p' "$dir/pubspec.yaml" | head -1)
[[ -n "$name" && -n "$version" ]] || fail "could not read name/version from $dir/pubspec.yaml"

# pub.dev publishes whatever pubspec.yaml says, regardless of the tag.
if [[ "$EVENT" == "release" ]]; then
  expected="$name-v$version"
  [[ "$TAG" == "$expected" ]] || fail "release tag '$TAG' != '$expected' (a release event always publishes packages/core; publish plugins with workflow_dispatch)"
fi

top=$(sed -n 's/^## *//p' "$dir/CHANGELOG.md" | head -1)
[[ "$top" == "$version" ]] || fail "newest CHANGELOG section is '$top', pubspec version is '$version'"

if [[ "$PACKAGE" == "core" ]]; then
  # segmentVersion is sent as context.library.version on every event.
  dart_version=$(sed -n 's/^const segmentVersion = "\(.*\)";/\1/p' "$dir/lib/version.dart")
  [[ "$dart_version" == "$version" ]] || fail "lib/version.dart is '$dart_version', pubspec version is '$version'"
fi

echo "OK: $name $version"
