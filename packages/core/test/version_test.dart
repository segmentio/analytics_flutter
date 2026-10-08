import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/version.dart';

void main() {
  // segmentVersion is sent as context.library.version and in the User-Agent,
  // and is bumped by hand alongside pubspec.yaml at release time.
  test('segmentVersion matches the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(segmentVersion, match!.group(1));
  });
}
