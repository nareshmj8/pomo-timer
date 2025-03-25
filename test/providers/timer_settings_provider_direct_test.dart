import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';

/// Mock implementation of NotificationServiceInterface for testing
class MockNotificationService implements NotificationServiceInterface {
  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<void> playTimerCompletionSound() async {}

  @override
  Future<void> playBreakCompletionSound() async {}

  @override
  Future<void> playLongBreakCompletionSound() async {}

  @override
  Future<void> playTestSound(int soundType) async {}

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    return true;
  }

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    return true;
  }

  @override
  Future<void> showNotification(String title, String body) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> scheduleNotification(
      String title, String body, DateTime scheduledTime) async {}

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    return true;
  }

  @override
  Future<void> cancelExpiryNotification() async {}

  @override
  Future<void> playSound(int soundType) async {}

  @override
  Future<List<int>> checkMissedNotifications() async {
    return [];
  }

  @override
  void displayNotificationDeliveryStats(BuildContext context) {}

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    return {'scheduled': 0, 'delivered': 0};
  }

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {}

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    return false;
  }

  @override
  Future<void> openNotificationSettings() async {}

  @override
  Future<void> scheduleAllNotifications() async {}

  @override
  void showDeliveryStats(BuildContext context) {}

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}

  @override
  Future<void> startDeliveryVerification() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerSettingsProvider Direct Persistence Tests', () {
    late MockNotificationService mockNotificationService;
    late SharedPreferences prefs;
    late TimerSettingsProvider timerSettings;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Set up notification service
      mockNotificationService = MockNotificationService();
      ServiceLocator().reset();
      ServiceLocator().registerNotificationService(mockNotificationService);

      // Create a timer settings provider for testing
      timerSettings = TimerSettingsProvider(prefs);

      // Allow time for settings to initialize
      await Future.delayed(const Duration(milliseconds: 100));

      // Log initial values
      debugPrint('==== SETUP: Initial values ====');
      debugPrint('sessionDuration: ${timerSettings.sessionDuration}');
      debugPrint('shortBreakDuration: ${timerSettings.shortBreakDuration}');
      debugPrint('longBreakDuration: ${timerSettings.longBreakDuration}');
      debugPrint(
          'sessionsBeforeLongBreak: ${timerSettings.sessionsBeforeLongBreak}');
      debugPrint('soundEnabled: ${timerSettings.soundEnabled}');
    });

    tearDown(() {
      // Clean up
      timerSettings.dispose();
      ServiceLocator().reset();
    });

    test('Session duration change should persist', () async {
      // Change session duration
      timerSettings.setSessionDuration(30.0);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the current value
      expect(timerSettings.sessionDuration, 30.0);

      // Verify SharedPreferences value
      expect(prefs.getDouble('sessionDuration'), 30.0);

      // Create a new provider to verify persistence
      final newTimerSettings = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify persisted value
      expect(newTimerSettings.sessionDuration, 30.0);

      // Clean up
      newTimerSettings.dispose();
    });

    test('Short break duration change should persist', () async {
      // Change short break duration
      timerSettings.setShortBreakDuration(7.0);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the current value
      expect(timerSettings.shortBreakDuration, 7.0);

      // Verify SharedPreferences value
      expect(prefs.getDouble('shortBreakDuration'), 7.0);

      // Create a new provider to verify persistence
      final newTimerSettings = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify persisted value
      expect(newTimerSettings.shortBreakDuration, 7.0);

      // Clean up
      newTimerSettings.dispose();
    });

    test('Sound settings change should persist', () async {
      // Change sound settings
      timerSettings.setSoundEnabled(false);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the current value
      expect(timerSettings.soundEnabled, false);

      // Verify SharedPreferences value
      expect(prefs.getBool('soundEnabled'), false);

      // Create a new provider to verify persistence
      final newTimerSettings = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify persisted value
      expect(newTimerSettings.soundEnabled, false);

      // Clean up
      newTimerSettings.dispose();
    });

    test('Reset to defaults should restore default values', () async {
      // First change various settings
      timerSettings.setSessionDuration(30.0);
      timerSettings.setShortBreakDuration(7.0);
      timerSettings.setLongBreakDuration(20.0);
      timerSettings.setSoundEnabled(false);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify the changes were applied
      expect(timerSettings.sessionDuration, 30.0);
      expect(timerSettings.shortBreakDuration, 7.0);
      expect(timerSettings.longBreakDuration, 20.0);
      expect(timerSettings.soundEnabled, false);

      // Reset to defaults
      await timerSettings.resetSettingsToDefault();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify settings were reset in the current provider
      expect(timerSettings.sessionDuration, 25.0);
      expect(timerSettings.shortBreakDuration, 5.0);
      expect(timerSettings.longBreakDuration, 15.0);
      expect(timerSettings.soundEnabled, true);

      // Create a new provider to verify persistence of reset values
      final newTimerSettings = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify reset values were persisted
      expect(newTimerSettings.sessionDuration, 25.0);
      expect(newTimerSettings.shortBreakDuration, 5.0);
      expect(newTimerSettings.longBreakDuration, 15.0);
      expect(newTimerSettings.soundEnabled, true);

      // Clean up
      newTimerSettings.dispose();
    });
  });
}
