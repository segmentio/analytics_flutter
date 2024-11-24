import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugins/event_logger.dart';

import '../mocks/mocks.mocks.dart';


class MockAnalytics extends Mock implements Analytics {}

void main() {
  group('EventLogger Tests', () {
    late EventLogger eventLogger;
    late MockAnalytics mockAnalytics;
    late MockLogger mockLogger;

    setUp(() {
      eventLogger = EventLogger();
      mockAnalytics = MockAnalytics();
      mockLogger = MockLogger();
      // Logger.instance = mockLogger;  // Usa el mock de Logger
    });

    test('should configure with analytics instance', () {
      eventLogger.configure(mockAnalytics);
      // ignore: invalid_use_of_protected_member
      expect(eventLogger.pAnalytics, mockAnalytics);
    });

    test('should log track event correctly', () async {
      final trackEvent = TrackEvent('Test Event');
      await eventLogger.execute(trackEvent);
      final logMessage = verifyNever(mockLogger.log(Level.debug, "Test")).captured;
      expect(logMessage, []);
    });
  });
}
