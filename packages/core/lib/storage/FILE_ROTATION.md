# File Rotation Implementation for Flutter Analytics SDK

## Overview

This implementation adds automatic file rotation functionality to the Flutter Analytics SDK, similar to the Segment Swift SDK. The feature automatically creates new files when the current file exceeds a maximum size limit (default: 475KB) to ensure efficient batch processing and prevent server upload failures.

## Architecture

The file rotation system consists of several coordinated components:

### Core Components

#### 1. FileRotationConfig
Configuration class that defines rotation behavior:
- **maxFileSize**: Maximum file size in bytes (default: 475KB)
- **baseFilename**: Base name for storage files (default: "segment-events")
- **activeFileExtension**: Extension for active files (default: ".temp")
- **completedFileExtension**: Extension for completed files (default: ".json")
- **indexKey**: SharedPreferences key for index counter (default: "segment_file_index")
- **enabled**: Whether rotation is enabled (default: true)

#### 2. FileIndexManager
Manages persistent file index counter using SharedPreferences:
- Tracks current file index across app restarts
- Generates unique filenames with incremental indices
- Handles filename patterns for active and completed files

#### 3. FileSizeMonitor
Monitors file sizes and estimates event storage requirements:
- Calculates serialized size estimates for different event types
- Caches file sizes to avoid repeated I/O operations
- Tracks session bytes written for accurate size monitoring

#### 4. FileRotationManager
Core orchestration component that coordinates all rotation logic:
- Checks if rotation is needed before writing events
- Manages file transitions from active to completed state
- Handles file cleanup after successful uploads
- Provides debug information and status reporting

#### 5. QueueFlushingPluginWithRotation
Enhanced queue plugin that integrates rotation with existing event processing:
- Extends the original queue flushing behavior
- Automatically triggers rotation when size limits are exceeded
- Maintains compatibility with existing flush policies and analytics workflow

#### 6. FileSizeFlushPolicy
Flush policy that works with rotation to trigger uploads based on estimated file size:
- Accumulates estimated event sizes
- Triggers flush when threshold is exceeded
- Provides manual size tracking methods for external coordination

## Usage

### Basic Setup

```dart
import 'package:segment_analytics/storage/file_rotation_config.dart';
import 'package:segment_analytics/plugins/queue_flushing_plugin_with_rotation.dart';

// Create rotation configuration
final rotationConfig = FileRotationConfig(
  maxFileSize: 512 * 1024, // 512KB
  baseFilename: 'my-analytics-events',
);

// Create enhanced plugin with rotation
final plugin = QueueFlushingPluginWithRotation(
  (events) async {
    // Handle event batch upload
    await uploadEvents(events);
  },
  rotationConfig: rotationConfig,
);

// Add plugin to analytics instance
analytics.addPlugin(plugin);
```

### Custom Configuration

```dart
// Disabled rotation
final disabledConfig = FileRotationConfig.disabled();

// Custom file extensions and paths
final customConfig = FileRotationConfig(
  maxFileSize: 1024 * 1024, // 1MB
  baseFilename: 'custom-events',
  activeFileExtension: '.working',
  completedFileExtension: '.analytics',
  indexKey: 'custom_file_index',
);

// Copy with modifications
final modifiedConfig = originalConfig.copyWith(
  maxFileSize: 2048 * 1024, // 2MB
  enabled: false,
);
```

### Integration with Flush Policies

```dart
import 'package:segment_analytics/flush_policies/file_size_flush_policy.dart';

// Create size-based flush policy
final flushPolicy = FileSizeFlushPolicy(475 * 1024); // 475KB

// Add to analytics configuration
final analytics = Analytics(Configuration(
  writeKey: 'your-write-key',
  flushPolicies: [flushPolicy],
));
```

### Manual Rotation Control

```dart
// Access rotation manager for manual control
final debugInfo = await plugin.getRotationDebugInfo();
print('Current file: ${debugInfo['currentFilePath']}');
print('Estimated size: ${debugInfo['estimatedSize']}');

// Manually trigger rotation
await plugin.triggerRotation();
```

## File Management

### File Naming Convention

Files follow this naming pattern:
- Active files: `{index}-{baseFilename}{activeFileExtension}`
- Completed files: `{index}-{baseFilename}{completedFileExtension}`

Examples:
- Active: `0-segment-events.temp`, `1-segment-events.temp`
- Completed: `0-segment-events.json`, `1-segment-events.json`

### File Lifecycle

1. **Active State**: Events are written to `.temp` files
2. **Rotation Trigger**: When size limit is reached, current file is "finished"
3. **Completion**: Active file is renamed from `.temp` to `.json`
4. **New File**: New active file is created with incremented index
5. **Upload**: Completed `.json` files are uploaded to server
6. **Cleanup**: Successfully uploaded files are deleted

### Storage Location

Files are stored in the application's document directory:
- iOS: `~/Documents/`
- Android: Internal storage documents directory
- Web: localStorage (different implementation)

## Size Estimation

The system estimates event sizes to minimize actual file I/O:

### Event Type Calculations

```dart
// Base event overhead
const baseEventSize = 200;

// Track Event
size += event.eventName.length * 2; // UTF-8 estimation
size += estimatePropertiesSize(event.properties);

// Screen Event
size += event.screenName.length * 2;
size += estimatePropertiesSize(event.properties);

// Identify Event
size += (event.userId?.length ?? 0) * 2;
size += estimateUserTraitsSize(event.traits);

// Context overhead
size += 500; // Estimated context size
```

### Property Size Estimation

The system recursively estimates sizes for:
- Strings: `length * 2 + 2` (UTF-8 + quotes)
- Numbers: `20` bytes (reasonable estimate)
- Booleans: `5` bytes ("true"/"false")
- Lists: Recursive estimation of items
- Maps: Recursive estimation of key-value pairs

## Error Handling

### Graceful Degradation

The system is designed to fail gracefully:
- If rotation is disabled, falls back to original behavior
- File I/O errors don't prevent event processing
- Size estimation errors use conservative fallbacks
- SharedPreferences failures reset to index 0

### Error Scenarios

```dart
// Handle rotation errors
try {
  await rotationManager.checkRotationNeeded(events);
} catch (e) {
  // Falls back to current file path
  log('Rotation check failed: $e', kind: LogFilterKind.warning);
}

// Handle size estimation errors
try {
  final size = monitor.calculateEventSize(event);
} catch (e) {
  // Uses conservative size estimate
  return 1000; // Fallback size
}
```

## Performance Considerations

### Memory Usage

- File size cache prevents repeated I/O operations
- Event size estimation avoids JSON serialization during writes
- Index counter persisted only when changed

### I/O Optimization

- Batch file operations when possible
- Use cached file sizes when available
- Avoid file system calls in hot paths

### Background Processing

- File rotation happens asynchronously
- Size calculations are lightweight
- Cleanup operations are non-blocking

## Testing

### Unit Tests

Each component has comprehensive unit tests:
- `file_rotation_config_test.dart`: Configuration behavior
- `file_index_manager_test.dart`: Index management and persistence
- `file_size_monitor_test.dart`: Size calculation and caching
- `file_rotation_manager_test.dart`: Core rotation logic
- `queue_flushing_plugin_with_rotation_test.dart`: Plugin integration
- `file_size_flush_policy_test.dart`: Flush policy behavior

### Integration Tests

End-to-end testing of complete rotation workflow:
- `file_rotation_integration_test.dart`: Full system integration

### Running Tests

```bash
# Run all rotation-related tests
cd analytics_flutter/packages/core
flutter test test/storage/
flutter test test/plugins/queue_flushing_plugin_with_rotation_test.dart
flutter test test/flush_policies/file_size_flush_policy_test.dart
flutter test test/integration/file_rotation_integration_test.dart

# Run with coverage
flutter test --coverage
```

## Debugging

### Debug Information

Access comprehensive debug information:

```dart
final plugin = QueueFlushingPluginWithRotation(/* ... */);

// Get rotation status
final debugInfo = await plugin.getRotationDebugInfo();

// Size monitor info
final sizeInfo = monitor.getDebugInfo();
print('File size cache: ${sizeInfo['fileSizeCache']}');
print('Session bytes: ${sizeInfo['sessionBytesWritten']}');

// Rotation manager info
final rotationInfo = await rotationManager.getDebugInfo();
print('Current file: ${rotationInfo['currentFilePath']}');
print('Is initialized: ${rotationInfo['isInitialized']}');
```

### Logging

The system uses structured logging for debugging:

```dart
import 'package:segment_analytics/logger.dart';

// Enable debug logging
log('File rotation triggered', kind: LogFilterKind.debug);
log('File size exceeded: $currentSize > $maxSize', kind: LogFilterKind.info);
log('Rotation error: $error', kind: LogFilterKind.error);
```

## Migration Guide

### From Original Plugin

If you're currently using the standard `QueueFlushingPlugin`:

```dart
// Before
final oldPlugin = QueueFlushingPlugin(uploadCallback);

// After
final newPlugin = QueueFlushingPluginWithRotation(
  uploadCallback,
  rotationConfig: FileRotationConfig(), // Use defaults
);
```

### Backward Compatibility

The enhanced plugin maintains full backward compatibility:
- Same callback signature
- Same event processing behavior
- Optional rotation configuration

### Gradual Adoption

You can enable rotation gradually:

```dart
// Start with rotation disabled
final plugin = QueueFlushingPluginWithRotation(
  uploadCallback,
  rotationConfig: FileRotationConfig.disabled(),
);

// Enable later with custom settings
final enabledConfig = FileRotationConfig(maxFileSize: 1024 * 1024);
// Create new plugin instance with enabled config
```

## Best Practices

### Configuration

1. **Size Limits**: Choose appropriate size limits based on:
   - Network conditions of target users
   - Server upload limits
   - Device storage constraints

2. **File Extensions**: Use descriptive extensions:
   - `.temp` or `.working` for active files
   - `.json` or `.analytics` for completed files

3. **Base Filenames**: Use meaningful names:
   - Include app name or service identifier
   - Avoid special characters

### Integration

1. **Flush Policies**: Coordinate with file size limits:
   ```dart
   // Ensure flush policy threshold <= rotation threshold
   final rotationSize = 512 * 1024; // 512KB
   final flushThreshold = 400 * 1024; // 400KB (leave buffer)
   
   final config = FileRotationConfig(maxFileSize: rotationSize);
   final policy = FileSizeFlushPolicy(flushThreshold);
   ```

2. **Error Handling**: Always handle rotation errors gracefully:
   ```dart
   Future<void> uploadCallback(List<RawEvent> events) async {
     try {
       await uploadToServer(events);
       // Successful upload - files will be cleaned up
     } catch (e) {
       // Log error but don't rethrow - prevents blocking rotation
       log('Upload failed: $e', kind: LogFilterKind.error);
       // Consider retry logic or offline storage
     }
   }
   ```

3. **Performance**: Monitor rotation impact:
   - Use debug info to track rotation frequency
   - Adjust size limits if rotation is too frequent
   - Monitor device storage usage

### Monitoring

1. **Rotation Frequency**: Track how often rotation occurs:
   ```dart
   var rotationCount = 0;
   final plugin = QueueFlushingPluginWithRotation((events) async {
     rotationCount++;
     await uploadEvents(events);
   });
   ```

2. **File Sizes**: Monitor actual vs estimated sizes:
   ```dart
   final sizeInfo = await rotationManager.getFileSizeInfo();
   final actualSize = sizeInfo['actualSize'];
   final estimatedSize = sizeInfo['cachedSize'];
   
   if ((actualSize - estimatedSize).abs() > actualSize * 0.1) {
     log('Size estimation off by >10%', kind: LogFilterKind.warning);
   }
   ```

## Troubleshooting

### Common Issues

1. **Rotation Not Triggering**
   - Check if rotation is enabled: `config.enabled == true`
   - Verify size threshold is appropriate for your events
   - Ensure events are being processed through the plugin

2. **Files Not Being Cleaned Up**
   - Verify upload callback completes successfully
   - Check file permissions in storage directory
   - Review error logs for cleanup failures

3. **Size Estimates Inaccurate**
   - Compare actual vs estimated sizes using debug info
   - Adjust estimation logic for custom event properties
   - Consider app-specific serialization overhead

### Debug Checklist

1. Enable debug logging
2. Check rotation configuration
3. Verify file system permissions
4. Monitor size estimation accuracy
5. Review upload callback success rate
6. Check SharedPreferences accessibility

## Contributing

When contributing to the file rotation system:

1. **Follow Patterns**: Maintain consistency with existing code patterns
2. **Add Tests**: Include unit and integration tests for new features
3. **Update Documentation**: Keep documentation current with changes
4. **Performance**: Consider impact on app startup and event processing
5. **Backward Compatibility**: Maintain compatibility with existing APIs

### Code Style

- Use descriptive variable names
- Add comprehensive documentation comments
- Handle errors gracefully with appropriate fallbacks
- Follow Flutter/Dart style guidelines
- Use appropriate visibility modifiers (@visibleForTesting, etc.)