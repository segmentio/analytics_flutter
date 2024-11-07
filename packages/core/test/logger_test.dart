import 'package:flutter_test/flutter_test.dart';
import 'package:logger/web.dart';
import 'package:segment_analytics/logger.dart';

class MockLogger extends Logger {
  List<String> logs = [];

  @override
  void d(dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace}) {
    logs.add('Debug: $message');
  }

  @override
  void w(dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('Warning: $message');
  }

  @override
  void e(dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('Error: $message');
  }
} 

void main() {
  group('SystemLogger', () {
    test('should log debug messages correctly', () {
      final mockLogger = MockLogger();
      final logger = SystemLogger()..logger = mockLogger;

      final logMessage = LogMessage(LogFilterKind.debug, 'Debug message', LogDestination.log);
      logger.parseLog(logMessage);
      expect(mockLogger.logs, contains('Debug: Segment: Debug message'));
    });

    test('should log warning messages correctly', () {
      final mockLogger = MockLogger();
      final logger = SystemLogger()..logger = mockLogger;

      final logMessage = LogMessage(LogFilterKind.warning, 'Warning message', LogDestination.log);
      logger.parseLog(logMessage);
      expect(mockLogger.logs, contains('Warning: Segment: Warning message'));
    });

    test('should log error messages correctly', () {
      final mockLogger = MockLogger();
      final logger = SystemLogger()..logger = mockLogger;

      final logMessage = LogMessage(LogFilterKind.error, 'Error message', LogDestination.log);
      logger.parseLog(logMessage);
      
      expect(mockLogger.logs, contains('Error: Segment: Error message'));
    });
  });

  test('should return LogFilterKind', () {
      expect(LogFilterKind.debug.toString(), "Debug");
      expect(LogFilterKind.warning.toString(), "Warning");
      expect(LogFilterKind.error.toString(), "ERROR");
  });

  test('MetricType  methods', () {
    expect(MetricType.counter.toString(), "Counter");
    expect(MetricType.fromString("Gauge"), MetricType.gauge);
  });

  test('should LogFactory buildLog Method', () {
    LogMessage lmMetric = LogFactory.buildLog(LogDestination.metric, "Test metric", LogFilterKind.debug);
    LogMessage lmHistory = LogFactory.buildLog(LogDestination.history, "Test history", LogFilterKind.debug);
    expect(lmMetric.logType, LogDestination.metric);
    expect(lmHistory.logType, LogDestination.history);
  });
}
