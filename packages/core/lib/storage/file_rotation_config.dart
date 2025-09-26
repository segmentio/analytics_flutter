/// Configuration for file rotation functionality.
/// 
/// This configuration defines the parameters used for automatic file rotation
/// when storage files exceed the maximum size limit.
class FileRotationConfig {
  /// Maximum file size in bytes (default: 475KB matching Swift SDK)
  final int maxFileSize;
  
  /// Base filename for storage files (e.g., "segment-events")
  final String baseFilename;
  
  /// File extension for active files (default: ".temp")
  final String activeFileExtension;
  
  /// File extension for completed files ready for upload (default: ".json")
  final String completedFileExtension;
  
  /// SharedPreferences key for storing the file index counter
  final String indexKey;
  
  /// Whether file rotation is enabled
  final bool enabled;

  const FileRotationConfig({
    this.maxFileSize = 475 * 1024, // 475KB in bytes
    this.baseFilename = "segment-events",
    this.activeFileExtension = ".temp",
    this.completedFileExtension = ".json", 
    this.indexKey = "segment_file_index",
    this.enabled = true,
  });

  /// Creates a configuration with file rotation disabled
  const FileRotationConfig.disabled()
      : maxFileSize = 0,
        baseFilename = "segment-events",
        activeFileExtension = ".temp",
        completedFileExtension = ".json",
        indexKey = "segment_file_index",
        enabled = false;

  /// Copy constructor for creating modified configurations
  FileRotationConfig copyWith({
    int? maxFileSize,
    String? baseFilename,
    String? activeFileExtension,
    String? completedFileExtension,
    String? indexKey,
    bool? enabled,
  }) {
    return FileRotationConfig(
      maxFileSize: maxFileSize ?? this.maxFileSize,
      baseFilename: baseFilename ?? this.baseFilename,
      activeFileExtension: activeFileExtension ?? this.activeFileExtension,
      completedFileExtension: completedFileExtension ?? this.completedFileExtension,
      indexKey: indexKey ?? this.indexKey,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileRotationConfig &&
          runtimeType == other.runtimeType &&
          maxFileSize == other.maxFileSize &&
          baseFilename == other.baseFilename &&
          activeFileExtension == other.activeFileExtension &&
          completedFileExtension == other.completedFileExtension &&
          indexKey == other.indexKey &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      maxFileSize.hashCode ^
      baseFilename.hashCode ^
      activeFileExtension.hashCode ^
      completedFileExtension.hashCode ^
      indexKey.hashCode ^
      enabled.hashCode;

  @override
  String toString() {
    return 'FileRotationConfig{'
        'maxFileSize: $maxFileSize, '
        'baseFilename: $baseFilename, '
        'activeFileExtension: $activeFileExtension, '
        'completedFileExtension: $completedFileExtension, '
        'indexKey: $indexKey, '
        'enabled: $enabled'
        '}';
  }
}