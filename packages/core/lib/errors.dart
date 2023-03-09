import 'package:analytics/logger.dart';

class StorageUnableToCreate implements Exception {
  final String msg;
  StorageUnableToCreate(this.msg);
  @override
  String toString() => "Unable to create storage: $msg";
}

class StorageUnableToWrite implements Exception {
  final String msg;
  StorageUnableToWrite(this.msg);
  @override
  String toString() => "Unable to write to storage: $msg";
}

class StorageUnableToRename implements Exception {
  final String msg;
  StorageUnableToRename(this.msg);
  @override
  String toString() => "Unable to rename storage: $msg";
}

class StorageUnableToOpen implements Exception {
  final String msg;
  StorageUnableToOpen(this.msg);
  @override
  String toString() => "Unable to open storage: $msg";
}

class StorageUnableToClose implements Exception {
  final String msg;
  StorageUnableToClose(this.msg);
  @override
  String toString() => "Unable to close storage: $msg";
}

class StorageInvalid implements Exception {
  final String msg;
  StorageInvalid(this.msg);
  @override
  String toString() => "Invalide storage: $msg";
}

class StorageUnknown implements Exception {
  final String msg;
  StorageUnknown(this.msg);
  @override
  String toString() => "Unknown storage error: $msg";
}

class NetworkUnexpectedHTTPCode implements Exception {
  final int code;
  NetworkUnexpectedHTTPCode(this.code);
  @override
  String toString() => "Unexpected HTTP response code: $code";
}

class NetworkServerLimited implements Exception {
  final int code;
  NetworkServerLimited(this.code);
  @override
  String toString() => "HTTP server limited: $code";
}

class NetworkServerRejected implements Exception {
  final int code;
  NetworkServerRejected(this.code);
  @override
  String toString() => "HTTP server rejected request: $code";
}

class NetworkUnknown implements Exception {
  final String msg;
  NetworkUnknown(this.msg);
  @override
  String toString() => "Unknown network error: $msg";
}

class NetworkInvalidData implements Exception {
  @override
  String toString() => "Invalid network data";
}

class JSONUnableToDeserialize implements Exception {
  final String msg;
  final String type;
  JSONUnableToDeserialize(this.type, this.msg);
  @override
  String toString() => "Unable to deserialize JSON to $type: $msg";
}

class PluginError implements Exception {
  final Object inner;
  PluginError(this.inner);
}

class InconsistentStateError implements Exception {
  final String key;
  InconsistentStateError(this.key);
  @override
  String toString() => "Store for $key is in an inconsistent state";
}

class PlatformNotSupportedError extends Error {
  final String message = 'Current platform is not supported';
}

class ErrorLoadingStorage implements Exception {
  final Object innerError;
  ErrorLoadingStorage(this.innerError);

  @override
  String toString() => "Error loading storage: $innerError";
}

void reportInternalError(Exception error,
    {bool fatal = false, int? frameDepth}) {
  log("An internal error occurred: $error", kind: LogFilterKind.error);
  if (fatal) {
    AssertionError("A critical error occurred: $error");
  }
}
