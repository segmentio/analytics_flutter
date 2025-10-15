import 'dart:convert';
import 'dart:io';
import 'package:segment_analytics/event.dart';

/// Monitors file sizes and tracks bytes written during storage operations.
/// 
/// This class provides utilities for checking file sizes, estimating event sizes,
/// and determining when files need to be rotated.
class FileSizeMonitor {
  /// Cache of file sizes to avoid frequent file system checks
  final Map<String, int> _fileSizeCache = {};
  
  /// Track bytes written in current session for each file
  final Map<String, int> _sessionBytesWritten = {};

  /// Get the current size of a file
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        _fileSizeCache[filePath] = size;
        return size;
      }
      return 0;
    } catch (e) {
      // If we can't read the file size, assume 0
      return 0;
    }
  }

  /// Get the cached file size without file system access
  int getCachedFileSize(String filePath) {
    return _fileSizeCache[filePath] ?? 0;
  }

  /// Update the cached file size
  void updateCachedFileSize(String filePath, int size) {
    _fileSizeCache[filePath] = size;
  }

  /// Get the number of bytes written in the current session
  int getSessionBytesWritten(String filePath) {
    return _sessionBytesWritten[filePath] ?? 0;
  }

  /// Add bytes written to the session counter
  void addBytesWritten(String filePath, int bytes) {
    _sessionBytesWritten[filePath] = 
        (_sessionBytesWritten[filePath] ?? 0) + bytes;
    
    // Update cached file size as well
    _fileSizeCache[filePath] = 
        (_fileSizeCache[filePath] ?? 0) + bytes;
  }

  /// Reset the session bytes written counter for a file
  void resetSessionBytesWritten(String filePath) {
    _sessionBytesWritten[filePath] = 0;
  }

  /// Calculate the size in bytes of a single event when serialized
  int calculateEventSize(RawEvent event) {
    try {
      final serialized = json.encode(event.toJson());
      final buffer = utf8.encode(serialized);
      return buffer.length;
    } catch (e) {
      // If we can't serialize the event, estimate based on a typical event size
      return 1024; // 1KB estimate for a typical event
    }
  }

  /// Calculate the size in bytes of a list of events when serialized
  int calculateEventsSize(List<RawEvent> events) {
    if (events.isEmpty) return 0;
    
    try {
      // Add JSON array overhead: [], commas between events
      final arrayOverhead = 2 + (events.length - 1); // [] and commas
      final eventsSize = events.fold<int>(0, (sum, event) => 
          sum + calculateEventSize(event));
      return eventsSize + arrayOverhead;
    } catch (e) {
      // Fallback estimation
      return events.length * 1024; // 1KB per event estimate
    }
  }

  /// Estimate the size when adding new events to existing queue data
  int estimateSizeWithNewEvents(Map<String, dynamic> existingData, 
                               List<RawEvent> newEvents) {
    try {
      // Get size of existing serialized data
      final existingJson = json.encode(existingData);
      final existingSize = utf8.encode(existingJson).length;
      
      // Calculate size of new events
      final newEventsSize = calculateEventsSize(newEvents);
      
      // Account for JSON structure changes (adding to existing array)
      // If existing queue is empty, we're just adding events
      final existingQueue = existingData['queue'] as List<dynamic>? ?? [];
      final structureOverhead = existingQueue.isEmpty ? 0 : newEvents.length; // commas
      
      return existingSize + newEventsSize + structureOverhead;
    } catch (e) {
      // Fallback: estimate based on event count
      final existingSize = json.encode(existingData).length;
      final newEventsSize = newEvents.length * 1024; // 1KB per event
      return existingSize + newEventsSize;
    }
  }

  /// Check if adding events would exceed the maximum file size
  bool wouldExceedLimit(String filePath, int maxSize, List<RawEvent> newEvents) {
    final currentSize = getCachedFileSize(filePath);
    final newEventsSize = calculateEventsSize(newEvents);
    return (currentSize + newEventsSize) > maxSize;
  }

  /// Check if a file exceeds the maximum size limit
  Future<bool> exceedsLimit(String filePath, int maxSize) async {
    final size = await getFileSize(filePath);
    return size > maxSize;
  }

  /// Clear all cached data
  void clearCache() {
    _fileSizeCache.clear();
    _sessionBytesWritten.clear();
  }

  /// Clear cached data for a specific file
  void clearFileCache(String filePath) {
    _fileSizeCache.remove(filePath);
    _sessionBytesWritten.remove(filePath);
  }

  /// Get debug information about tracked files
  Map<String, Map<String, int>> getDebugInfo() {
    return {
      'fileSizeCache': Map<String, int>.from(_fileSizeCache),
      'sessionBytesWritten': Map<String, int>.from(_sessionBytesWritten),
    };
  }
}