import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create a notification service implementation for testing
  late NotificationServiceInterface notificationService;
  late TestNotificationService testNotificationService;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create notification service test implementation
    testNotificationService = TestNotificationService();
    notificationService = testNotificationService;

    // Initialize timezone data
    tz_data.initializeTimeZones();
  });

  group('NotificationService Tests', () {
    test('Should initialize successfully', () async {
      // Act
      final result = await notificationService.initialize();

      // Assert
      expect(result, isTrue);
      expect(testNotificationService.isInitialized, isTrue);
    });

    test('Should schedule notification for monthly subscription', () async {
      // Arrange
      final expiryDate = DateTime.now().add(const Duration(days: 30));

      // Act
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'monthly');

      // Assert
      expect(testNotificationService.scheduledExpiryNotifications, isNotEmpty);
      expect(
          testNotificationService
              .scheduledExpiryNotifications.first['subscriptionType'],
          'monthly');
    });

    test('Should schedule notification for yearly subscription', () async {
      // Arrange
      final expiryDate = DateTime.now().add(const Duration(days: 365));

      // Act
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'yearly');

      // Assert
      expect(testNotificationService.scheduledExpiryNotifications, isNotEmpty);
      expect(
          testNotificationService
              .scheduledExpiryNotifications.first['subscriptionType'],
          'yearly');
    });

    test('Should not schedule notification for expired subscription', () async {
      // Arrange
      final expiryDate = DateTime.now().subtract(const Duration(days: 1));

      // Act
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'monthly');

      // Assert
      expect(testNotificationService.scheduledExpiryNotifications, isEmpty);
    });

    test('Should cancel scheduled notification', () async {
      // Arrange
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await notificationService.scheduleExpiryNotification(
          expiryDate, 'monthly');

      // Verify we have a notification
      expect(testNotificationService.scheduledExpiryNotifications, isNotEmpty);

      // Act
      await notificationService.cancelExpiryNotification();

      // Assert
      expect(testNotificationService.cancelExpiryNotificationCount, 1);
      expect(testNotificationService.scheduledExpiryNotifications, isEmpty);
    });
  });

  group('NotificationService', () {
    test('initialize should set initialization flag', () async {
      expect(testNotificationService.isInitialized, false);

      final result = await notificationService.initialize();

      expect(result, isTrue);
      expect(testNotificationService.isInitialized, true);
    });

    test('playTimerCompletionSound should play timer sound', () async {
      await notificationService.playTimerCompletionSound();

      expect(testNotificationService.timerCompletionSoundCount, 1);
      expect(testNotificationService.breakCompletionSoundCount, 0);
      expect(testNotificationService.longBreakCompletionSoundCount, 0);
    });

    test('playBreakCompletionSound should play break sound', () async {
      await notificationService.playBreakCompletionSound();

      expect(testNotificationService.timerCompletionSoundCount, 0);
      expect(testNotificationService.breakCompletionSoundCount, 1);
      expect(testNotificationService.longBreakCompletionSoundCount, 0);
    });

    test('playLongBreakCompletionSound should play long break sound', () async {
      await notificationService.playLongBreakCompletionSound();

      expect(testNotificationService.timerCompletionSoundCount, 0);
      expect(testNotificationService.breakCompletionSoundCount, 0);
      expect(testNotificationService.longBreakCompletionSoundCount, 1);
    });

    test('playTestSound should play test sound', () async {
      await notificationService.playTestSound(1);

      expect(testNotificationService.testSoundCount, 1);
    });

    test('scheduleTimerNotification should schedule a timer notification',
        () async {
      const duration = Duration(minutes: 25);

      await notificationService.scheduleTimerNotification(duration);

      expect(testNotificationService.scheduledTimerNotifications.length, 1);
      expect(
          testNotificationService.scheduledTimerNotifications.first, duration);
    });

    test('scheduleBreakNotification should schedule a break notification',
        () async {
      const duration = Duration(minutes: 5);

      await notificationService.scheduleBreakNotification(duration);

      expect(testNotificationService.scheduledBreakNotifications.length, 1);
      expect(
          testNotificationService.scheduledBreakNotifications.first, duration);
    });

    test('cancelAllNotifications should cancel all notifications', () async {
      // Schedule some notifications first
      await notificationService
          .scheduleTimerNotification(const Duration(minutes: 25));
      await notificationService
          .scheduleBreakNotification(const Duration(minutes: 5));

      // Verify they were scheduled
      expect(testNotificationService.scheduledTimerNotifications.length, 1);
      expect(testNotificationService.scheduledBreakNotifications.length, 1);

      // Cancel all notifications
      await notificationService.cancelAllNotifications();

      // Verify they were canceled
      expect(testNotificationService.cancelAllNotificationsCount, 1);
      expect(testNotificationService.scheduledTimerNotifications.length, 0);
      expect(testNotificationService.scheduledBreakNotifications.length, 0);
    });

    test('reset should clear all tracked events', () {
      // Generate some test data
      testNotificationService.timerCompletionSoundCount = 2;
      testNotificationService.breakCompletionSoundCount = 1;
      testNotificationService.scheduledTimerNotifications
          .add(const Duration(minutes: 25));

      // Reset everything
      testNotificationService.reset();

      // Verify everything was reset
      expect(testNotificationService.timerCompletionSoundCount, 0);
      expect(testNotificationService.breakCompletionSoundCount, 0);
      expect(testNotificationService.scheduledTimerNotifications, isEmpty);
    });
  });
}

/// A test implementation of NotificationServiceInterface for testing purposes
class TestNotificationService implements NotificationServiceInterface {
  bool _initialized = false;

  // Counters to track method calls
  int timerCompletionSoundCount = 0;
  int breakCompletionSoundCount = 0;
  int longBreakCompletionSoundCount = 0;
  int testSoundCount = 0;
  int cancelAllNotificationsCount = 0;
  int cancelExpiryNotificationCount = 0;

  // Last sound type played for testing
  int? lastNotificationSoundType;

  // Track scheduled notifications
  final List<Duration> scheduledTimerNotifications = [];
  final List<Duration> scheduledBreakNotifications = [];
  final List<Map<String, dynamic>> scheduledExpiryNotifications = [];

  @override
  Future<bool> initialize() async {
    _initialized = true;
    return true;
  }

  @override
  Future<void> playTimerCompletionSound() async {
    timerCompletionSoundCount++;
  }

  @override
  Future<void> playBreakCompletionSound() async {
    breakCompletionSoundCount++;
  }

  @override
  Future<void> playLongBreakCompletionSound() async {
    longBreakCompletionSoundCount++;
  }

  @override
  Future<void> playTestSound(int soundType) async {
    testSoundCount++;
    lastNotificationSoundType = soundType;
  }

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    scheduledTimerNotifications.add(duration);
    return true;
  }

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    scheduledBreakNotifications.add(duration);
    return true;
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllNotificationsCount++;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
  }

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    // Only schedule notifications for non-expired subscriptions
    if (expiryDate.isAfter(DateTime.now())) {
      scheduledExpiryNotifications.add({
        'expiryDate': expiryDate,
        'subscriptionType': subscriptionType,
      });
    }
    return true;
  }

  @override
  Future<void> cancelExpiryNotification() async {
    cancelExpiryNotificationCount++;
    scheduledExpiryNotifications.clear();
  }

  @override
  Future<List<int>> checkMissedNotifications() async {
    return [];
  }

  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    // Mock implementation for testing
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    return {
      'scheduled': scheduledTimerNotifications.length +
          scheduledBreakNotifications.length +
          scheduledExpiryNotifications.length,
      'delivered': 0
    };
  }

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    // Mock implementation for testing
  }

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    return false; // Default to not delivered for testing
  }

  // Helper methods for testing
  bool get isInitialized => _initialized;

  // Methods for checking notification status
  Future<bool> isNotificationScheduled() async {
    return scheduledExpiryNotifications.isNotEmpty;
  }

  // Helper methods to check notification status
  bool wereTimerNotificationsScheduled() {
    return scheduledTimerNotifications.isNotEmpty;
  }

  bool wereBreakNotificationsScheduled() {
    return scheduledBreakNotifications.isNotEmpty;
  }

  bool wereExpiryNotificationsScheduled() {
    return scheduledExpiryNotifications.isNotEmpty;
  }

  // Helper method to check if any sounds were played
  bool wereSoundsPlayed() {
    return timerCompletionSoundCount > 0 ||
        breakCompletionSoundCount > 0 ||
        longBreakCompletionSoundCount > 0 ||
        testSoundCount > 0;
  }

  // Reset all counters for fresh tests
  void reset() {
    _initialized = false;
    timerCompletionSoundCount = 0;
    breakCompletionSoundCount = 0;
    longBreakCompletionSoundCount = 0;
    testSoundCount = 0;
    cancelAllNotificationsCount = 0;
    cancelExpiryNotificationCount = 0;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
    scheduledExpiryNotifications.clear();
    lastNotificationSoundType = null;
  }
}
