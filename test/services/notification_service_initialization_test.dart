import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('NotificationService Initialization Tests', () {
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      mockNotificationService.reset(); // Reset state between tests
    });

    test('should initialize successfully', () async {
      // Act
      final result = await mockNotificationService.initialize();

      // Assert
      expect(result, isTrue);
      expect(mockNotificationService.initializeCallCount, equals(1));
    });

    test('should handle initialization failures', () async {
      // Arrange
      mockNotificationService.setInitializationResult(false);

      // Act
      final result = await mockNotificationService.initialize();

      // Assert
      expect(result, isFalse);
      expect(mockNotificationService.initializeCallCount, equals(1));
    });

    test('should initialize only once when methods are called', () async {
      // Act - call methods that should initialize if needed
      await mockNotificationService.playTimerCompletionSound();
      await mockNotificationService.playBreakCompletionSound();

      // Assert
      expect(mockNotificationService.initializeCallCount, equals(1));
      expect(mockNotificationService.timerCompletionSoundCount, equals(1));
      expect(mockNotificationService.breakCompletionSoundCount, equals(1));
    });

    test('should initialize before scheduling notifications', () async {
      // Act
      await mockNotificationService
          .scheduleTimerNotification(Duration(minutes: 25));

      // Assert
      expect(mockNotificationService.initializeCallCount, equals(1));
      expect(mockNotificationService.scheduledTimerNotifications.length,
          equals(1));
      expect(
          mockNotificationService.scheduledTimerNotifications.first.inMinutes,
          equals(25));
    });

    test('should initialize before cancelling notifications', () async {
      // Act
      await mockNotificationService.cancelAllNotifications();

      // Assert
      expect(mockNotificationService.initializeCallCount, equals(1));
      expect(mockNotificationService.cancelAllNotificationsCount, equals(1));
    });
  });
}
