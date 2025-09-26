import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_rotation_config.dart';

/// Manages the file index counter for file rotation.
/// 
/// This class handles the persistent storage of the file index used for
/// generating unique file names during file rotation.
class FileIndexManager {
  final FileRotationConfig _config;
  SharedPreferences? _prefs;
  final Completer<SharedPreferences> _prefsCompleter = Completer<SharedPreferences>();
  
  FileIndexManager(this._config) {
    _initializePrefs();
  }

  /// Initialize SharedPreferences asynchronously
  Future<void> _initializePrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _prefsCompleter.complete(_prefs!);
    } catch (e) {
      _prefsCompleter.completeError(e);
    }
  }

  /// Get the current file index
  Future<int> getCurrentIndex() async {
    final prefs = await _prefsCompleter.future;
    return prefs.getInt(_config.indexKey) ?? 0;
  }

  /// Increment the file index and return the new value
  Future<int> incrementIndex() async {
    final prefs = await _prefsCompleter.future;
    final currentIndex = prefs.getInt(_config.indexKey) ?? 0;
    final newIndex = currentIndex + 1;
    await prefs.setInt(_config.indexKey, newIndex);
    return newIndex;
  }

  /// Set a specific index value (for testing or recovery purposes)
  Future<void> setIndex(int index) async {
    final prefs = await _prefsCompleter.future;
    await prefs.setInt(_config.indexKey, index);
  }

  /// Reset the index to 0
  Future<void> resetIndex() async {
    final prefs = await _prefsCompleter.future;
    await prefs.setInt(_config.indexKey, 0);
  }

  /// Generate filename for the current index
  Future<String> getCurrentFilename() async {
    final index = await getCurrentIndex();
    return '$index-${_config.baseFilename}${_config.activeFileExtension}';
  }

  /// Generate filename for the next index (used during rotation)
  Future<String> getNextFilename() async {
    final index = await incrementIndex();
    return '$index-${_config.baseFilename}${_config.activeFileExtension}';
  }

  /// Generate completed filename for a given index
  String getCompletedFilename(int index) {
    return '$index-${_config.baseFilename}${_config.completedFileExtension}';
  }

  /// Check if SharedPreferences is ready
  bool get isReady => _prefs != null;

  /// Wait for SharedPreferences to be ready
  Future<void> get ready => _prefsCompleter.future.then((_) => null);
}