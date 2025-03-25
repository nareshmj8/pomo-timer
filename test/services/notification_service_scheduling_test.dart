import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('NotificationService Scheduling Tests', () {
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      mockNotificationService.reset(); // Reset state between tests
    });

    test('should schedule timer notification with correct duration', () async {
      // Arrange
      const duration = Duration(minutes: 25);

      // Act
      await mockNotificationService.scheduleTimerNotification(duration);

      // Assert
      expect(mockNotificationService.scheduledTimerNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledTimerNotifications.first,
          equals(duration));
    });

    test('should schedule break notification with correct duration', () async {
      // Arrange
      const duration = Duration(minutes: 5);

      // Act
      await mockNotificationService.scheduleBreakNotification(duration);

      // Assert
      expect(mockNotificationService.scheduledBreakNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledBreakNotifications.first,
          equals(duration));
    });

    test('should schedule multiple notifications correctly', () async {
      // Arrange
      const focusDuration = Duration(minutes: 25);
      const breakDuration = Duration(minutes: 5);

      // Act
      await mockNotificationService.scheduleTimerNotification(focusDuration);
      await mockNotificationService.scheduleBreakNotification(breakDuration);

      // Assert
      expect(mockNotificationService.scheduledTimerNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledBreakNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledTimerNotifications.first,
          equals(focusDuration));
      expect(mockNotificationService.scheduledBreakNotifications.first,
          equals(breakDuration));
    });

    test('should schedule expiry notification with correct date and type',
        () async {
      // Arrange
      final expiryDate = DateTime.now().add(Duration(days: 30));
      const subscriptionType = 'Premium';

      // Act
      await mockNotificationService.scheduleExpiryNotification(
          expiryDate, subscriptionType);

      // Assert
      expect(mockNotificationService.scheduledExpiryNotifications.length,
          equals(1));
      expect(
          mockNotificationService
              .scheduledExpiryNotifications.first['expiryDate'],
          equals(expiryDate));
      expect(
          mockNotificationService
              .scheduledExpiryNotifications.first['subscriptionType'],
          equals(subscriptionType));
    });

    test('should cancel all notifications', () async {
      // Arrange - schedule some notifications
      await mockNotificationService
          .scheduleTimerNotification(Duration(minutes: 25));
      await mockNotificationService
          .scheduleBreakNotification(Duration(minutes: 5));

      // Act
      await mockNotificationService.cancelAllNotifications();

      // Assert
      expect(mockNotificationService.cancelAllNotificationsCount, equals(1));
      expect(mockNotificationService.scheduledTimerNotifications, isEmpty);
      expect(mockNotificationService.scheduledBreakNotifications, isEmpty);
    });

    test('should cancel expiry notification', () async {
      // Arrange - schedule an expiry notification
      final expiryDate = DateTime.now().add(Duration(days: 30));
      await mockNotificationService.scheduleExpiryNotification(
          expiryDate, 'Premium');

      // Act
      await mockNotificationService.cancelExpiryNotification();

      // Assert
      expect(
          mockNotificationService.cancelExpiryNotificationCallCount, equals(1));
      expect(mockNotificationService.scheduledExpiryNotifications, isEmpty);
    });

    test('should reschedule notifications with new duration', () async {
      // Arrange
      const initialDuration = Duration(minutes: 25);
      const newDuration = Duration(minutes: 30);

      // Act - schedule and then reschedule
      await mockNotificationService.scheduleTimerNotification(initialDuration);
      await mockNotificationService.scheduleTimerNotification(newDuration);

      // Assert - should have both notifications in the list
      expect(mockNotificationService.scheduledTimerNotifications.length,
          equals(2));
      expect(mockNotificationService.scheduledTimerNotifications[0],
          equals(initialDuration));
      expect(mockNotificationService.scheduledTimerNotifications[1],
          equals(newDuration));
    });

    test('should schedule different types of notifications simultaneously',
        () async {
      // Arrange
      const timerDuration = Duration(minutes: 25);
      const breakDuration = Duration(minutes: 5);
      final expiryDate = DateTime.now().add(Duration(days: 30));

      // Act
      await mockNotificationService.scheduleTimerNotification(timerDuration);
      await mockNotificationService.scheduleBreakNotification(breakDuration);
      await mockNotificationService.scheduleExpiryNotification(
          expiryDate, 'Premium');

      // Assert
      expect(mockNotificationService.scheduledTimerNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledBreakNotifications.length,
          equals(1));
      expect(mockNotificationService.scheduledExpiryNotifications.length,
          equals(1));
    });
  });
}
