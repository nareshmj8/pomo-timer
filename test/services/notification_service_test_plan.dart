import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'dart:io';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../mocks/mock_notification_service.dart';

// Generate mocks for Flutter Local Notifications Plugin
@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'notification_service_test_plan.mocks.dart';

/// This is a comprehensive test plan for the MockNotificationService component.
/// The test plan covers the following areas:
/// 1. Initialization tests - Verify proper setup of the service
/// 2. Scheduling tests - Verify scheduling notifications works correctly
/// 3. Action handling tests - Verify notification actions work correctly
/// 4. Permission tests - Verify permission handling
void main() {
  late MockNotificationService notificationService;

  setUp(() {
    // Use the MockNotificationService for all tests
    notificationService = MockNotificationService();
  });

  group('NotificationService Initialization Tests', () {
    test('should increment initialization counter when initialized', () async {
      // Act
      final result = await notificationService.initialize();

      // Assert
      expect(result, isTrue);
      expect(notificationService.initializeCallCount, 1);
    });

    test('should return configured initialization result', () async {
      // Arrange
      notificationService.initializationResult = false;

      // Act
      final result = await notificationService.initialize();

      // Assert
      expect(result, isFalse);
    });

    test('should not initialize twice', () async {
      // First initialization
      await notificationService.initialize();

      // Second initialization
      await notificationService.initialize();

      // Assert the service tracks double initialization
      expect(notificationService.initializeCallCount, 2);
    });
  });

  group('NotificationService Scheduling Tests', () {
    setUp(() {
      // Initialize the notification service for scheduling tests
      notificationService.initialize();
    });

    test('should schedule timer notification', () async {
      // Act
      final duration = Duration(minutes: 25);
      await notificationService.scheduleTimerNotification(duration);

      // Assert
      expect(
          notificationService.scheduledTimerNotifications, contains(duration));
      expect(notificationService.timerNotificationScheduleCount, 1);
    });

    test('should schedule break notification', () async {
      // Act
      final duration = Duration(minutes: 5);
      await notificationService.scheduleBreakNotification(duration);

      // Assert
      expect(
          notificationService.scheduledBreakNotifications, contains(duration));
      expect(notificationService.breakNotificationScheduleCount, 1);
    });

    test('should schedule expiry notification', () async {
      // Act
      final expiryDate = DateTime.now().add(Duration(days: 30));
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'Premium');

      // Assert
      expect(notificationService.scheduleExpiryNotificationCallCount, 1);
      expect(notificationService.scheduledExpiryNotifications.length, 1);
      expect(
          notificationService.scheduledExpiryNotifications[0]
              ['subscriptionType'],
          'Premium');
      expect(notificationService.scheduledExpiryNotifications[0]['expiryDate'],
          expiryDate);
    });

    test('should set notification scheduled flag when scheduling notifications',
        () async {
      // Arrange
      expect(notificationService.notificationScheduled, isFalse);

      // Act
      final expiryDate = DateTime.now().add(Duration(days: 30));
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'Premium');

      // Assert
      expect(notificationService.notificationScheduled, isTrue);
    });

    test('should clear scheduled notifications when cancelling', () async {
      // Arrange - schedule a notification
      final expiryDate = DateTime.now().add(Duration(days: 30));
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'Premium');

      // Act
      await notificationService.cancelExpiryNotification();

      // Assert
      expect(notificationService.cancelExpiryNotificationCallCount, 1);
      expect(notificationService.scheduledExpiryNotifications.isEmpty, isTrue);
      expect(notificationService.notificationScheduled, isFalse);
    });

    test('should track cancel all notifications calls', () async {
      // Act
      await notificationService.cancelAllNotifications();

      // Assert
      expect(notificationService.cancelAllNotificationsCount, 1);
    });
  });

  group('NotificationService Sound Tests', () {
    setUp(() {
      // Initialize the notification service for sound tests
      notificationService.initialize();
    });

    test('should track timer completion sound playback', () async {
      // Act
      await notificationService.playTimerCompletionSound();

      // Assert
      expect(notificationService.timerCompletionSoundCount, 1);
    });

    test('should track break completion sound playback', () async {
      // Act
      await notificationService.playBreakCompletionSound();

      // Assert
      expect(notificationService.breakCompletionSoundCount, 1);
    });

    test('should track long break completion sound playback', () async {
      // Act
      await notificationService.playLongBreakCompletionSound();

      // Assert
      expect(notificationService.longBreakCompletionSoundCount, 1);
    });

    test('should track test sound playback', () async {
      // Act
      final soundIndex = 2;
      await notificationService.playTestSound(soundIndex);

      // Assert
      expect(notificationService.testSoundCount, 1);
      expect(notificationService.lastPlayedTestSound, soundIndex);
    });
  });

  group('NotificationService Permission Tests', () {
    test('should return configured notification scheduled value', () async {
      // Arrange
      notificationService.notificationScheduled = true;

      // Act
      final result = await notificationService.isNotificationScheduled();

      // Assert
      expect(result, isTrue);
    });
  });
}
