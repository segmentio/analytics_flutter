// coverage:ignore-file
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:segment_analytics/errors.dart';
import 'package:segment_analytics/utils/store/store.dart';
import 'package:path_provider/path_provider.dart';

class StoreImpl with Store {
  final bool storageJson;
  late final Future<void> _migrationCompleted;
  
  StoreImpl({this.storageJson = true}) {
    // Start migration immediately but don't block construction
    _migrationCompleted = _migrateFilesFromDocumentsToSupport();
  }
  @override
  Future get ready => Future.value();

  @override
  Future<Map<String, dynamic>?> getPersisted(String key) async {
    if (!storageJson) return Future.value(null);
    // Ensure migration is complete before reading files
    await _migrationCompleted;
    return _readFile(key);
  }

  @override
  Future setPersisted(String key, Map<String, dynamic> value) async {
    if (!storageJson) return Future.value();
    // Ensure migration is complete before writing files
    await _migrationCompleted;
    return _writeFile(key, value);
  }
  
  @override
  Future deletePersisted(String key) async {
    if (!storageJson) return;
    final file = File(await _fileName(key));
    if (await file.exists()) {
      await file.delete();
    }
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
    final path = (await _getNewDocumentDir()).path;
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

  Future<Directory> _getNewDocumentDir() async {
    try {
      return await getApplicationSupportDirectory();
    } catch (err) {
      throw PlatformNotSupportedError();
    }
  }

  Future<Directory> _getOldDocumentDir() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (err) {
      throw PlatformNotSupportedError();
    }
  }

  /// Migrates existing analytics files from Documents directory to Application Support directory
  Future<void> _migrateFilesFromDocumentsToSupport() async {
    try {
      final oldDir = await _getOldDocumentDir();
      final newDir = await _getNewDocumentDir();
      
      // List all analytics files in the old directory
      final oldDirFiles = oldDir.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('analytics-flutter-') && file.path.endsWith('.json'))
          .toList();
      
      for (final oldFile in oldDirFiles) {
        final fileName = oldFile.path.split('/').last;
        final newFilePath = '${newDir.path}/$fileName';
        final newFile = File(newFilePath);
        
        // Only migrate if the file doesn't already exist in the new location
        if (!await newFile.exists()) {
          try {
            // Ensure the new directory exists
            await newDir.create(recursive: true);
            
            // Copy the file to the new location
            await oldFile.copy(newFilePath);
            
            // Delete the old file after successful copy
            await oldFile.delete();
          } catch (e) {
            // The app should continue to work even if migration fails
          }
        }
      }
    } catch (e) {
      // Migration failure shouldn't break the app
    }
  }

  @override
  void dispose() {}
}
