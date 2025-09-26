import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/state.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/utils/store/store.dart';
import '../storage/file_rotation_config.dart';
import '../storage/file_rotation_manager.dart';

typedef OnFlush = Future Function(List<RawEvent> events);

/// Enhanced queue flushing plugin with file rotation support.
/// 
/// This plugin extends the original QueueFlushingPlugin to support automatic
/// file rotation when storage files exceed the maximum size limit.
class QueueFlushingPluginWithRotation extends UtilityPlugin {
  QueueStateWithRotation<RawEvent>? _state;
  
  bool _isPendingUpload = false;
  final OnFlush _onFlush;
  final FileRotationConfig _rotationConfig;

  /// Creates a queue flushing plugin with file rotation support
  /// 
  /// @param onFlush callback to execute when the queue is flushed
  /// @param rotationConfig configuration for file rotation behavior
  QueueFlushingPluginWithRotation(
    this._onFlush, {
    FileRotationConfig? rotationConfig,
  }) : _rotationConfig = rotationConfig ?? const FileRotationConfig(),
       super(PluginType.after);

  @override
  configure(Analytics analytics) {
    super.configure(analytics);

    _state = QueueStateWithRotation(
      "queue_flushing_plugin", 
      analytics.store,
      (json) => eventFromJson(json),
      _rotationConfig,
    );

    _state!.init(analytics.error, true);
  }

  @override
  Future<RawEvent> execute(RawEvent event) async {
    await _state!.ready;
    await _state!.add(event);
    return event;
  }

  /// Calls the onFlush callback with the events in the queue
  @override
  flush() async {
    if (_state != null) {
      await _state!.ready;
      final events = await _state!.state;
      try {
        if (!_isPendingUpload && events.isNotEmpty) {
          _isPendingUpload = true;
          await _onFlush(events);
        }
      } finally {
        _isPendingUpload = false;
      }
    }
  }

  /// Removes one or multiple events from the queue
  /// @param events events to remove
  Future dequeue(List<RawEvent> eventsToRemove) async {
    await _state!.ready;
    final events = await _state!.events;
    for (var event in eventsToRemove) {
      events.remove(event);
    }
    _state!.setEvents(events);
  }

  /// Get file rotation debug information
  Future<Map<String, dynamic>> getRotationDebugInfo() async {
    if (_state == null) return {};
    return await _state!.getRotationDebugInfo();
  }

  /// Manually trigger file rotation (for testing)
  Future<void> triggerRotation() async {
    if (_state != null) {
      await _state!.triggerRotation();
    }
  }
}

/// Enhanced queue state that supports file rotation
class QueueStateWithRotation<T extends JSONSerialisable> extends PersistedState<List<T>> {
  final T Function(Map<String, dynamic> json) _elementFromJson;
  final FileRotationConfig _rotationConfig;
  FileRotationManager? _rotationManager;

  QueueStateWithRotation(
    String key, 
    Store store, 
    this._elementFromJson,
    this._rotationConfig,
  ) : super(key, store, () async => []);

  @override
  void init(ErrorHandler errorHandler, bool storageJson) {
    // Initialize rotation manager if enabled
    if (_rotationConfig.enabled) {
      // Get storage directory path from store implementation
      _getStoragePath().then((storePath) async {
        _rotationManager = FileRotationManager(_rotationConfig, storePath);
        await _rotationManager!.ready;
      });
    }
    
    // Call parent initialization
    super.init(errorHandler, storageJson);
  }

  /// Get the storage path from the store implementation
  Future<String> _getStoragePath() async {
    // This is a simplified approach - in a real implementation,
    // you'd need to extract the actual path from the store
    // For now, we'll use a reasonable default
    try {
      // Try to get documents directory (platform-specific)
      // This would need to be implemented based on the actual Store interface
      return '/tmp/segment_analytics'; // Fallback path
    } catch (e) {
      log('Could not determine storage path, using fallback: $e', 
          kind: LogFilterKind.warning);
      return '/tmp/segment_analytics';
    }
  }

  Future add(T t) async {
    await modifyState((state) async {
      // Check if file rotation is needed before adding
      if (_rotationConfig.enabled && _rotationManager != null) {
        await _checkAndRotateIfNeeded([t]);
      }
      
      setState([...state, t]);
    });
  }

  /// Check if rotation is needed and perform it if necessary
  Future<void> _checkAndRotateIfNeeded(List<T> newEvents) async {
    if (_rotationManager == null) return;
    
    try {
      // Convert to RawEvent list (assuming T extends RawEvent for our use case)
      final events = newEvents.whereType<RawEvent>().toList();
      if (events.isEmpty) return;

      final targetFilePath = await _rotationManager!.checkRotationNeeded(events);
      
      // Update file size tracking
      _rotationManager!.updateFileSize(targetFilePath, events);
      
    } catch (e) {
      log('Error during rotation check: $e', kind: LogFilterKind.error);
    }
  }

  /// Manually trigger rotation for testing
  Future<void> triggerRotation() async {
    if (_rotationManager != null) {
      await _rotationManager!.finishCurrentFile();
    }
  }

  /// Get rotation debug information
  Future<Map<String, dynamic>> getRotationDebugInfo() async {
    if (_rotationManager == null) {
      return {'rotationEnabled': false};
    }
    
    return {
      'rotationEnabled': true,
      ...(await _rotationManager!.getDebugInfo()),
    };
  }

  @override
  List<T> fromJson(Map<String, dynamic> json) {
    final rawList = json['queue'] as List<dynamic>;
    return rawList.map((e) => _elementFromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson(List<T> t) {
    return {"queue": t.map((e) => e.toJson()).toList()};
  }

  Future<List<T>> get events => state;
  void setEvents(List<T> events) => setState([...events]);

  Future<void> flush({int? number}) async {
    final events = await state;
    if (number == null || number >= events.length) {
      setState([]);
      return;
    }
    events.removeRange(0, number);
    setEvents(events);
  }
}