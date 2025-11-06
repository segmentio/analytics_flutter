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

  // Queue size limits (bytes)
  static const int _kMaxQueueBytes = 512 * 1024; // 512 KB
  static const int _kTargetQueueBytes = 475 * 1024; // target after trimming 475 KB

  // The fileKey used by the queue/flushing plugin in this repo.
  // The file produced will be analytics-flutter-queue_flushing_plugin.json
  static const String _kQueueFileKey = 'queue_flushing_plugin';

  // The field name inside the JSON payload that holds events (adjusted per user's example)
  // The user's queue JSON uses a top-level "queue" array.
  static const String _kQueueField = 'queue';

  StoreImpl({this.storageJson = true}) {
    // Start migration immediately but don't block construction
    _migrationCompleted = _migrateFilesFromDocumentsToSupport();
  }
  
  @override
  Future get ready => Future.value();

  @override
  void dispose() {}

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
    // Serialize once; may be replaced by trimmed version below
    String serialized = json.encode(data);
    List<int> buffer = utf8.encode(serialized);

    // If this is the queue file, enforce size limits by trimming oldest events
    if (fileKey == _kQueueFileKey) {
      // Ensure we operate against the configured queue field name.
      final currentEvents = <dynamic>[];
      if (data[_kQueueField] is List) {
        currentEvents.addAll(data[_kQueueField] as List);
      }

      // If the serialized payload is already too large, attempt trim before writing
      if (buffer.length > _kMaxQueueBytes) {
        final trimmed = _trimQueueToTargetMap(data, _kTargetQueueBytes, _kQueueField);
        serialized = json.encode(trimmed);
        buffer = utf8.encode(serialized);

        // If still too big after trimming to target, write empty queue as last resort
        if (buffer.length > _kMaxQueueBytes) {
          serialized = json.encode({_kQueueField: []});
          buffer = utf8.encode(serialized);
        }
      }
    }

    RandomAccessFile? file;
    try {
      file = await _getFile(fileKey, create: true) as RandomAccessFile;
      // Acquire exclusive lock and write
      file.lockSync(FileLock.blockingExclusive);
      try {
        file.setPositionSync(0);
        file.writeFromSync(buffer);
        file.truncateSync(buffer.length);
      } finally {
        // Ensure unlock and close
        try {
          file.unlockSync();
        } catch (_) {}
        try {
          file.closeSync();
        } catch (_) {}
      }
      return;
    } on FileSystemException catch (_) {
      // Recovery path for disk full / write errors for queue file
      if (fileKey != _kQueueFileKey) {
        rethrow;
      }

      // Try reading existing stored events and aggressively trim until we can write
      try {
        final existing = await _readFile(fileKey);
        List<dynamic> events =
            (existing != null && existing[_kQueueField] is List)
                ? List<dynamic>.from(existing[_kQueueField] as List)
                : <dynamic>[];

        // Try progressively trimming and writing, removing oldest events first
        while (true) {
          // Build candidate payload
          final candidateMap = {_kQueueField: events};
          final candidateText = json.encode(candidateMap);
          final candidateBuffer = utf8.encode(candidateText);

          if (candidateBuffer.length <= _kMaxQueueBytes) {
            // Attempt to write this candidate
            RandomAccessFile? f;
            try {
              f = await _getFile(fileKey, create: true) as RandomAccessFile;
              f.lockSync(FileLock.blockingExclusive);
              try {
                f.setPositionSync(0);
                f.writeFromSync(candidateBuffer);
                f.truncateSync(candidateBuffer.length);
                // success
                try {
                  f.unlockSync();
                } catch (_) {}
                try {
                  f.closeSync();
                } catch (_) {}
                return;
              } finally {
                // Ensure unlock/close in case of failures inside try
                try {
                  f.unlockSync();
                } catch (_) {}
                try {
                  f.closeSync();
                } catch (_) {}
              }
            } on FileSystemException {
              // Couldn't write; fall through to trimming more events
            }
          }

          // If no events left, try to write an empty queue
          if (events.isEmpty) {
            final emptyBuf = utf8.encode(json.encode({_kQueueField: []}));
            try {
              RandomAccessFile? f2 =
                  await _getFile(fileKey, create: true) as RandomAccessFile;
              f2.lockSync(FileLock.blockingExclusive);
              try {
                f2.setPositionSync(0);
                f2.writeFromSync(emptyBuf);
                f2.truncateSync(emptyBuf.length);
                try {
                  f2.unlockSync();
                } catch (_) {}
                try {
                  f2.closeSync();
                } catch (_) {}
                return;
              } finally {
                try {
                  f2.unlockSync();
                } catch (_) {}
                try {
                  f2.closeSync();
                } catch (_) {}
              }
            } on FileSystemException {
              // rethrow original error
              rethrow;
            }
          }

          // Remove the oldest event and try again
          events.removeAt(0);
        }
      } catch (e) {
        // If recovery fails, rethrow the original exception
        rethrow;
      }
    } finally {
      // Ensure any opened file is closed/unlocked (defensive)
      try {
        // Use null-aware calls to avoid calling on null.
        file?.unlockSync();
      } catch (_) {}
      try {
        file?.closeSync();
      } catch (_) {}
    }
  }

  /// Trim the queue in [data] (expected to be a map containing an array under [queueField])
  /// until the serialized size is <= targetBytes. Returns a new Map containing
  /// the trimmed queue list.
  Map<String, dynamic> _trimQueueToTargetMap(
      Map<String, dynamic> data, int targetBytes, String queueField) {
    final events = <dynamic>[];
    if (data[queueField] is List) {
      events.addAll(data[queueField] as List);
    }

    // If no events or not a list, return minimal representation
    if (events.isEmpty) {
      return {queueField: []};
    }

    // Fast path: if current serialized size is already small enough, return input
    var candidate = {queueField: events};
    var s = json.encode(candidate);
    var b = utf8.encode(s);
    if (b.length <= targetBytes) {
      return candidate;
    }

    // Iteratively remove oldest events until serialized size <= targetBytes or no events left
    while (b.length > targetBytes && events.isNotEmpty) {
      events.removeAt(0);
      candidate = {queueField: events};
      s = json.encode(candidate);
      b = utf8.encode(s);
    }

    return {queueField: events};
  }

  Future<Map<String, dynamic>?> _readFile(String fileKey) async {
    RandomAccessFile? file = await _getFile(fileKey);
    if (file == null) {
      return null;
    }

    try {
      file = await file.lock(FileLock.blockingShared);
      final length = file.lengthSync();
      file.setPositionSync(0);
      final buffer = Uint8List(length);
      file.readIntoSync(buffer);
      file.unlockSync();
      file.closeSync();
      final contentText = utf8.decode(buffer);
      if (contentText == "{}") {
        return null; // empty file
      }

      return json.decode(contentText) as Map<String, dynamic>;
    } on FileSystemException {
      // Can't read the file -> return null for safety
      try {
        file?.unlockSync();
      } catch (_) {}
      try {
        file?.closeSync();
      } catch (_) {}
      return null;
    }
  }

  Future<String> _fileName(String fileKey) async {
    final path = (await _getNewDocumentDir()).path;
    return "$path/analytics-flutter-$fileKey.json";
  }

  Future<RandomAccessFile?> _getFile(String fileKey,
      {bool create = false}) async {
    final file = File(await _fileName(fileKey));

    if (await file.exists()) {
      // Open in append mode so we can lock and then write/truncate
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

  /// Move any analytics-flutter-*.json files from Documents (old location) to
  /// ApplicationSupport (new location). This migration is best-effort and will
  /// ignore errors so SDK initialization can proceed.
  Future<void> _migrateFilesFromDocumentsToSupport() async {
    if (!storageJson) return;
    try {
      final oldDir = await _getOldDocumentDir();
      final newDir = await _getNewDocumentDir();

      // If same path, nothing to do
      if (oldDir.path == newDir.path) return;

      // Ensure new dir exists
      try {
        if (!await Directory(newDir.path).exists()) {
          await Directory(newDir.path).create(recursive: true);
        }
      } catch (_) {}

      // List files in old directory and move ones that match analytics-flutter-*.json
      final oldDirectory = Directory(oldDir.path);
      if (!await oldDirectory.exists()) return;

      await for (final entity in oldDirectory.list()) {
        if (entity is File) {
          final name = entity.uri.pathSegments.isNotEmpty
              ? entity.uri.pathSegments.last
              : '';
          if (name.startsWith('analytics-flutter-') &&
              name.endsWith('.json')) {
            final destPath = '${newDir.path}/$name';
            final destFile = File(destPath);

            try {
              // If destination already exists, skip or optionally merge - we skip here.
              if (!await destFile.exists()) {
                await entity.rename(destPath);
              } else {
                // If a file already exists at the destination, attempt to remove the old file.
                try {
                  await entity.delete();
                } catch (_) {}
              }
            } catch (_) {
              // Try fallback: copy then delete
              try {
                await entity.copy(destPath);
                await entity.delete();
              } catch (_) {
              }
            }
          }
        }
      }
    } catch (_) {
      return;
    }
  }
}