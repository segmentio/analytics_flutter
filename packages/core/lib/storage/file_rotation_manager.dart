import 'dart:io';
import 'dart:async';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/logger.dart';
import 'file_rotation_config.dart';
import 'file_index_manager.dart';
import 'file_size_monitor.dart';

/// Manages file rotation for event storage.
/// 
/// This class handles the automatic creation of new files when the current
/// file exceeds the maximum size limit, following the same pattern as the
/// Segment Swift SDK.
class FileRotationManager {
  final FileRotationConfig config;
  final String basePath;
  late final FileIndexManager _indexManager;
  late final FileSizeMonitor _sizeMonitor;
  
  String? _currentFilePath;
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  FileRotationManager(this.config, this.basePath) {
    _indexManager = FileIndexManager(config);
    _sizeMonitor = FileSizeMonitor();
    _initialize();
  }

  /// Initialize the file rotation manager
  Future<void> _initialize() async {
    try {
      await _indexManager.ready;
      _currentFilePath = await _getCurrentFilePath();
      _isInitialized = true;
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  /// Wait for initialization to complete
  Future<void> get ready => _initCompleter.future;

  /// Get the current active file path
  Future<String> _getCurrentFilePath() async {
    final filename = await _indexManager.getCurrentFilename();
    return '$basePath/$filename';
  }

  /// Check if file rotation is needed before writing events
  /// Returns the file path to write to (may be a new file after rotation)
  Future<String> checkRotationNeeded(List<RawEvent> eventsToWrite) async {
    if (!config.enabled) {
      return _currentFilePath ?? await _getCurrentFilePath();
    }

    await ready;
    
    final currentFile = _currentFilePath!;
    
    // Check if current file would exceed limit with new events
    if (_sizeMonitor.wouldExceedLimit(currentFile, config.maxFileSize, eventsToWrite)) {
      log('File size limit would be exceeded, rotating to new file', 
          kind: LogFilterKind.debug);
      return await _rotateToNewFile();
    }

    return currentFile;
  }

  /// Rotate to a new file and return the new file path
  Future<String> _rotateToNewFile() async {
    try {
      // Finish current file (mark as completed)
      if (_currentFilePath != null) {
        await _finishCurrentFile();
      }

      // Create new file with incremented index
      final newFilename = await _indexManager.getNextFilename();
      _currentFilePath = '$basePath/$newFilename';
      
      // Clear size monitor cache for the new file
      _sizeMonitor.clearFileCache(_currentFilePath!);
      
      log('Rotated to new file: $_currentFilePath', kind: LogFilterKind.debug);
      
      return _currentFilePath!;
    } catch (e) {
      log('Error during file rotation: $e', kind: LogFilterKind.error);
      rethrow;
    }
  }

  /// Finish the current file (rename from .temp to .json)
  Future<void> _finishCurrentFile() async {
    if (_currentFilePath == null) return;
    
    try {
      final currentFile = File(_currentFilePath!);
      if (!await currentFile.exists()) return;

      // Generate completed filename
      final currentIndex = await _indexManager.getCurrentIndex();
      final completedFilename = _indexManager.getCompletedFilename(currentIndex);
      final completedPath = '$basePath/$completedFilename';
      
      // Rename file from .temp to .json
      await currentFile.rename(completedPath);
      
      log('Finished file: $_currentFilePath -> $completedPath', 
          kind: LogFilterKind.debug);
    } catch (e) {
      log('Error finishing current file: $e', kind: LogFilterKind.error);
      // Don't rethrow - this shouldn't prevent rotation
    }
  }

  /// Update file size tracking after writing events
  void updateFileSize(String filePath, List<RawEvent> writtenEvents) {
    if (!config.enabled) return;
    
    final eventSize = _sizeMonitor.calculateEventsSize(writtenEvents);
    _sizeMonitor.addBytesWritten(filePath, eventSize);
  }

  /// Get current file size information
  Future<Map<String, dynamic>> getFileSizeInfo() async {
    if (!config.enabled) return {};
    
    await ready;
    final currentFile = _currentFilePath!;
    
    return {
      'currentFile': currentFile,
      'actualSize': await _sizeMonitor.getFileSize(currentFile),
      'cachedSize': _sizeMonitor.getCachedFileSize(currentFile),
      'sessionBytesWritten': _sizeMonitor.getSessionBytesWritten(currentFile),
      'maxSize': config.maxFileSize,
      'index': await _indexManager.getCurrentIndex(),
    };
  }

  /// List all completed files ready for upload
  Future<List<String>> getCompletedFiles() async {
    try {
      final dir = Directory(basePath);
      if (!await dir.exists()) return [];

      final files = await dir.list().toList();
      final completedFiles = <String>[];

      for (final entity in files) {
        if (entity is File && entity.path.endsWith(config.completedFileExtension)) {
          completedFiles.add(entity.path);
        }
      }

      // Sort by index (extract index from filename)
      completedFiles.sort((a, b) {
        final aIndex = _extractIndexFromPath(a);
        final bIndex = _extractIndexFromPath(b);
        return aIndex.compareTo(bIndex);
      });

      return completedFiles;
    } catch (e) {
      log('Error listing completed files: $e', kind: LogFilterKind.error);
      return [];
    }
  }

  /// Extract index number from file path
  int _extractIndexFromPath(String path) {
    try {
      final filename = path.split('/').last;
      final indexStr = filename.split('-').first;
      return int.parse(indexStr);
    } catch (e) {
      return 0;
    }
  }

  /// Clean up completed files after successful upload
  Future<void> cleanupCompletedFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          log('Cleaned up completed file: $path', kind: LogFilterKind.debug);
        }
      } catch (e) {
        log('Error cleaning up file $path: $e', kind: LogFilterKind.error);
      }
    }
  }

  /// Force finish the current file (useful for manual flush or shutdown)
  Future<void> finishCurrentFile() async {
    if (!config.enabled) return;
    await ready;
    await _finishCurrentFile();
  }

  /// Reset file rotation state (for testing)
  Future<void> reset() async {
    await _indexManager.resetIndex();
    _sizeMonitor.clearCache();
    _currentFilePath = await _getCurrentFilePath();
  }

  /// Get debug information
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'config': config.toString(),
      'isInitialized': _isInitialized,
      'currentFilePath': _currentFilePath,
      'indexManager': {
        'isReady': _indexManager.isReady,
        'currentIndex': await _indexManager.getCurrentIndex(),
      },
      'sizeMonitor': _sizeMonitor.getDebugInfo(),
      'fileSizeInfo': await getFileSizeInfo(),
    };
  }
}