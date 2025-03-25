import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('NotificationService Permission Handling Tests', () {
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      mockNotificationService.reset(); // Reset state between tests
    });

    test('should check if notifications are enabled', () async {
      // Arrange
      mockNotificationService.notificationsEnabled = true;

      // Act
      final result = await mockNotificationService.areNotificationsEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should check if notifications are disabled', () async {
      // Arrange
      mockNotificationService.notificationsEnabled = false;

      // Act
      final result = await mockNotificationService.areNotificationsEnabled();

      // Assert
      expect(result, isFalse);
    });

    test('should toggle notification state', () async {
      // Arrange
      mockNotificationService.notificationsEnabled = false;

      // Act
      await mockNotificationService.setNotificationsEnabled(true);
      final result = await mockNotificationService.areNotificationsEnabled();

      // Assert
      expect(result, isTrue);

      // Toggle back
      await mockNotificationService.setNotificationsEnabled(false);
      final newResult = await mockNotificationService.areNotificationsEnabled();
      expect(newResult, isFalse);
    });

    test('should check if sounds are enabled', () async {
      // Arrange
      mockNotificationService.soundEnabled = true;

      // Act
      final result = await mockNotificationService.isSoundEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should toggle sound state', () async {
      // Arrange
      mockNotificationService.soundEnabled = false;

      // Act
      await mockNotificationService.setSoundEnabled(true);
      final result = await mockNotificationService.isSoundEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should check if vibration is enabled', () async {
      // Arrange
      mockNotificationService.vibrationEnabled = true;

      // Act
      final result = await mockNotificationService.isVibrationEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should toggle vibration state', () async {
      // Arrange
      mockNotificationService.vibrationEnabled = false;

      // Act
      await mockNotificationService.setVibrationEnabled(true);
      final result = await mockNotificationService.isVibrationEnabled();

      // Assert
      expect(result, isTrue);
    });

    test('should check if notifications are scheduled', () async {
      // Arrange
      mockNotificationService.notificationScheduled = true;

      // Act & Assert
      final result = await mockNotificationService.isNotificationScheduled();
      expect(result, isTrue);

      mockNotificationService.notificationScheduled = false;
      final newResult = await mockNotificationService.isNotificationScheduled();
      expect(newResult, isFalse);
    });

    test('should notify listeners when settings change', () {
      // Arrange
      int notificationCount = 0;
      mockNotificationService.addListener(() {
        notificationCount++;
      });

      // Act
      mockNotificationService.setNotificationsEnabled(true);
      mockNotificationService.setSoundEnabled(true);
      mockNotificationService.setVibrationEnabled(true);

      // Assert
      expect(notificationCount, equals(3));
    });

    test('should not schedule notifications when notifications are disabled',
        () async {
      // Arrange
      mockNotificationService.notificationsEnabled = false;

      // Act
      await mockNotificationService
          .scheduleTimerNotification(const Duration(minutes: 25));

      // Assert
      expect(mockNotificationService.timerNotificationScheduleCount, equals(0));
    });

    test('should schedule notifications when notifications are enabled',
        () async {
      // Arrange
      mockNotificationService.notificationsEnabled = true;

      // Act
      await mockNotificationService
          .scheduleTimerNotification(const Duration(minutes: 25));

      // Assert
      expect(mockNotificationService.timerNotificationScheduleCount, equals(1));
    });
  });
}
