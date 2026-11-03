import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:segment_analytics/utils/store/io.dart';

class _Event {
  _Event(this.id);
  final int id;
  int encodes = 0;

  Map<String, dynamic> toJson() {
    encodes++;
    return {'id': id, 'padding': 'x' * 1000};
  }
}

List<int> _ids(String encoded) => (json.decode(encoded)['queue'] as List)
    .map((e) => e['id'] as int)
    .toList();

void main() {
  const maxBytes = 512 * 1024;
  const targetBytes = 475 * 1024;

  test('encodeQueue keeps every event under the limit', () {
    final events = List.generate(10, (i) => {'id': i});
    final encoded = encodeQueue(events, 'queue', maxBytes, targetBytes);
    expect(encoded, json.encode({'queue': events}));
  });

  test('encodeQueue trims to target keeping the newest events', () {
    final events = List.generate(2000, _Event.new);
    final encoded = encodeQueue(events, 'queue', maxBytes, targetBytes);
    final ids = _ids(encoded);

    expect(utf8.encode(encoded).length, lessThanOrEqualTo(targetBytes));
    expect(ids.last, 1999);
    expect(ids, List.generate(ids.length, (i) => 2000 - ids.length + i));
    final oneMore = json.encode({'queue': events.sublist(1999 - ids.length)});
    expect(utf8.encode(oneMore).length, greaterThan(targetBytes));
  });

  test('encodeQueue encodes each event at most once', () {
    final events = List.generate(20000, _Event.new);
    encodeQueue(events, 'queue', maxBytes, targetBytes);

    expect(events.every((e) => e.encodes <= 1), isTrue);
    expect(events.where((e) => e.encodes == 1).length, lessThan(600));
  });

  test('encodeQueue drops an event larger than the limit', () {
    final events = [
      {'id': 0, 'padding': 'x' * (maxBytes + 1)}
    ];
    expect(encodeQueue(events, 'queue', maxBytes, targetBytes),
        '{"queue":[]}');
  });
}
