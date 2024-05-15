import 'package:segment_analytics/analytics.dart';
import 'package:logger/logger.dart';

/// The foundation for building out a special logger. If logs need to be directed to a certain area, this is the
/// interface to start off with. For instance a console logger, a networking logger or offline storage logger
/// would all start off with LogTarget.
mixin LogTarget {
  /// Implement this method to process logging messages. This is where the logic for the target will be
  /// added. Feel free to add your own data queueing and offline storage.
  /// - important: Use the Segment Network stack for Segment library compatibility and simplicity.
  void parseLog(LogMessage log);
}

/// Used for analytics.log() types. This lets the system know what to filter on and how to set priorities.
enum LogFilterKind {
  error, // Not Verbose (fail cases | non-recoverable errors)
  warning, // Semi-verbose (deprecations | potential issues)
  debug; // Verbose (everything of interest)

  @override
  String toString() {
    switch (this) {
      case error:
        return "ERROR";
      case warning:
        return "Warning";
      case debug:
        return "Debug";
    }
  }
}

enum LogDestination { log, metric, history }

/// The interface to the message being returned to `LogTarget` -> `parseLog()`.
class LogMessage {
  final LogFilterKind kind;
  final String message;
  final LogDestination logType;

  LogMessage(this.kind, this.message, this.logType);
}

enum MetricType {
  counter, // Not Verbose
  gauge; // Semi-verbose

  @override
  String toString() {
    var typeString = "Gauge";
    if (this == counter) {
      typeString = "Counter";
    }
    return typeString;
  }

  static MetricType fromString(String string) {
    var returnType = counter;
    if (string == "Gauge") {
      returnType = gauge;
    }

    return returnType;
  }
}

class SystemLogger with LogTarget {
  var logger = Logger();

  @override
  void parseLog(LogMessage log) {
    switch (log.kind) {
      case LogFilterKind.debug:
        logger.d("Segment: ${log.message}");
        break;
      case LogFilterKind.warning:
        logger.w("Segment: ${log.message}");
        break;
      case LogFilterKind.error:
        logger.e("Segment: ${log.message}");
        break;
    }
  }
}

class LogFactory {
  static LogTarget logger = SystemLogger();

  static LogMessage buildLog(
      LogDestination destination, String message, LogFilterKind kind) {
    switch (destination) {
      case LogDestination.log:
        return LogMessage(kind, message, LogDestination.log);
      case LogDestination.metric:
        return LogMessage(LogFilterKind.debug, message, LogDestination.metric);
      case LogDestination.history:
        return LogMessage(LogFilterKind.debug, message, LogDestination.history);
    }
  }
}

void log(String message, {LogFilterKind? kind = LogFilterKind.debug}) {
  if (kind != LogFilterKind.debug || Analytics.debug) {
    final log = LogFactory.buildLog(
        LogDestination.log, message, kind ?? LogFilterKind.debug);
    LogFactory.logger.parseLog(log);
  }
}
