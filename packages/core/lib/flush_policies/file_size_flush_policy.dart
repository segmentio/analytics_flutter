import 'package:flutter/foundation.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/flush_policies/flush_policy.dart';

/// Flush policy that triggers when the current file size exceeds a threshold.
/// 
/// This policy works in conjunction with file rotation to ensure files
/// don't grow too large before being uploaded.
class FileSizeFlushPolicy extends FlushPolicy {
  final int _maxFileSize;
  int _estimatedCurrentSize = 0;
  
  /// Creates a flush policy that triggers when file size exceeds maxFileSize
  /// 
  /// @param maxFileSize Maximum file size in bytes before triggering flush
  FileSizeFlushPolicy(this._maxFileSize);

  @visibleForTesting
  int get estimatedCurrentSize => _estimatedCurrentSize;
  
  @visibleForTesting
  int get maxFileSize => _maxFileSize;

  @override
  void start() {
    _estimatedCurrentSize = 0;
  }

  @override
  onEvent(RawEvent event) {
    // Estimate the serialized size of the event
    final eventSize = _estimateEventSize(event);
    _estimatedCurrentSize += eventSize;
    
    if (_estimatedCurrentSize >= _maxFileSize) {
      shouldFlush = true;
    }
  }

  @override
  reset() {
    super.reset();
    _estimatedCurrentSize = 0;
  }

  /// Estimate the serialized size of an event in bytes
  int _estimateEventSize(RawEvent event) {
    // Base size estimate for different event types
    const baseEventSize = 200; // Basic event structure
    
    int size = baseEventSize;
    
    // Add size based on event type and properties
    if (event is TrackEvent) {
      size += event.event.length * 2; // Event name (UTF-8 can be up to 2 bytes per char)
      size += _estimatePropertiesSize(event.properties);
    } else if (event is ScreenEvent) {
      size += event.name.length * 2;
      size += _estimatePropertiesSize(event.properties);
    } else if (event is IdentifyEvent) {
      size += (event.userId?.length ?? 0) * 2;
      size += _estimateUserTraitsSize(event.traits);
    } else if (event is GroupEvent) {
      size += event.groupId.length * 2;
      size += _estimateGroupTraitsSize(event.traits);
    } else if (event is AliasEvent) {
      size += (event.previousId.length * 2).toInt();
    }
    
    // Add context size estimate
    size += 500; // Estimated context size
    
    return size;
  }

  /// Estimate the size of properties map
  int _estimatePropertiesSize(Map<String, dynamic>? properties) {
    if (properties == null || properties.isEmpty) return 0;
    
    int size = 0;
    properties.forEach((key, value) {
      size += key.length * 2; // Key size
      size += _estimateValueSize(value);
    });
    
    return size;
  }

  /// Estimate the size of user traits
  int _estimateUserTraitsSize(UserTraits? traits) {
    if (traits == null) return 0;
    
    // This would need to be implemented based on UserTraits structure
    // For now, provide a reasonable estimate
    return 100; // Base estimate for user traits
  }

  /// Estimate the size of group traits
  int _estimateGroupTraitsSize(GroupTraits? traits) {
    if (traits == null) return 0;
    
    // This would need to be implemented based on GroupTraits structure
    // For now, provide a reasonable estimate
    return 100; // Base estimate for group traits
  }

  /// Estimate the size of a dynamic value
  int _estimateValueSize(dynamic value) {
    if (value == null) return 4; // "null"
    
    if (value is String) {
      return value.length * 2 + 2; // String content + quotes
    } else if (value is num) {
      return 20; // Reasonable estimate for numbers
    } else if (value is bool) {
      return 5; // "true" or "false"
    } else if (value is List) {
      int size = 2; // []
      for (var item in value) {
        size += _estimateValueSize(item) + 1; // Item + comma
      }
      return size;
    } else if (value is Map) {
      int size = 2; // {}
      value.forEach((key, val) {
        size += key.toString().length * 2 + 3; // Key + quotes + colon
        size += _estimateValueSize(val) + 1; // Value + comma
      });
      return size;
    }
    
    // Fallback for other types
    return value.toString().length * 2;
  }

  /// Manually update the estimated file size (for external size tracking)
  void updateEstimatedSize(int newSize) {
    _estimatedCurrentSize = newSize;
    if (_estimatedCurrentSize >= _maxFileSize) {
      shouldFlush = true;
    }
  }

  /// Add to the estimated size
  void addEstimatedSize(int additionalSize) {
    _estimatedCurrentSize += additionalSize;
    if (_estimatedCurrentSize >= _maxFileSize) {
      shouldFlush = true;
    }
  }
}