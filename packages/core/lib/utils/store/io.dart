// coverage:ignore-file
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:path_provider/path_provider.dart';

class StoreImpl with Store {
  @override
  Future<Map<String, dynamic>?> getPersisted(String key) {
    return _readFile(key);
  }

  @override
  Future get ready => Future.value();

  @override
  Future setPersisted(String key, Map<String, dynamic> value) {
    return _writeFile(key, value);
  }

  Future _writeFile(String fileKey, Map<String, dynamic> data) async {
    RandomAccessFile file =
        await _getFile(fileKey, create: true) as RandomAccessFile;
    final serialized = json.encode(data);
    final buffer = utf8.encode(serialized);

    file.lockSync(FileLock.blockingExclusive);
    file.setPositionSync(0);
    file.writeFromSync(buffer);
    file.truncateSync(buffer.length);
    file.unlockSync();
    file.closeSync();
  }

  Future<Map<String, dynamic>?> _readFile(String fileKey) async {
    RandomAccessFile? file = await _getFile(fileKey);
    if (file == null) {
      return null;
    }
    file = await file.lock(FileLock.blockingShared);
    final length = file.lengthSync();
    file.setPositionSync(0);
    final buffer = Uint8List(length);
    file.readIntoSync(buffer);
    file.unlockSync();
    file.closeSync();
    final contentText = utf8.decode(buffer);
    if (contentText == "{}") {
      return null; // Prefer null to empty map, because we'll want to initialise a valid empty value.
    }

    return json.decode(contentText) as Map<String, dynamic>;
  }

  Future<String> _fileName(String fileKey) async {
    final path = (await _getDocumentDir()).path;
    return "$path/analytics-flutter-$fileKey.json";
  }

  Future<RandomAccessFile?> _getFile(String fileKey,
      {bool create = false}) async {
    final file = File(await _fileName(fileKey));

    if (await file.exists()) {
      return await file.open(mode: FileMode.append);
    } else if (create) {
      await file.create(recursive: true);
      return await file.open(mode: FileMode.append);
    } else {
      return null;
    }
  }

  Future<Directory> _getDocumentDir() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (err) {
      throw PlatformNotSupportedError();
    }
  }

  @override
  void dispose() {}
}
