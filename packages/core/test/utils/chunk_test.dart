import 'package:analytics/event.dart';
import 'package:analytics/utils/chunk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Event chunker", () {
    test("It chunks by number correctly", () async {
      final chunkedEvents = chunk([
        TrackEvent("event"),
        TrackEvent("event"),
        TrackEvent("event"),
        TrackEvent("event"),
        TrackEvent("event")
      ], 2);
      expect(chunkedEvents.length, 3);
      expect(chunkedEvents[0].length, 2);
      expect(chunkedEvents[1].length, 2);
      expect(chunkedEvents[2].length, 1);
    });
    test("It chunks by size correctly", () async {
      final chunkedEvents = chunk([
        TrackEvent("event", properties: {
          "large_prop_1":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_2":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
        }),
        TrackEvent("event", properties: {
          "large_prop_1":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_2":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
        }),
        TrackEvent("event", properties: {
          "large_prop_1":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_2":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_3":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
        }),
        TrackEvent("event", properties: {
          "large_prop_1":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_2":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_3":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
        }),
        TrackEvent("event", properties: {
          "large_prop_1":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
          "large_prop_2":
              "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890",
        })
      ], 10, maxKB: 1);

      expect(chunkedEvents.length, 3);
      expect(chunkedEvents[0].length, 2);
      expect(chunkedEvents[1].length, 1);
      expect(chunkedEvents[2].length, 2);
    });
  });
}
