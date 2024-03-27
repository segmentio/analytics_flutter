import 'dart:convert';

import 'package:segment_analytics/event.dart';

List<List<T>> chunk<T extends JSONSerialisable>(List<T> array, int count,
    {int? maxKB}) {
  if (array.isEmpty || count == 0) {
    return [];
  }

  final max = maxKB == null ? null : maxKB * 1024;
  var currentChunk = 0;
  var rollingSize = 0;
  var index = 0;
  List<List<T>> chunks = [[]];

  for (var item in array) {
    if (max != null) {
      final size = sizeOf(item);
      rollingSize += size;

      if (rollingSize >= max) {
        chunks.add([]);
        currentChunk++;
        index = 0;
        rollingSize = size;
      }
    }
    if (index == count) {
      chunks.add([]);
      currentChunk++;
      index = 0;
    }
    chunks[currentChunk].add(item);
    index++;
  }

  return chunks;
}

int sizeOf(JSONSerialisable obj) {
  final serialized = json.encode(obj.toJson());
  final buffer = utf8.encode(serialized);
  final size = buffer.length;
  return size;
}
