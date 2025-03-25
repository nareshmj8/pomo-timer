import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerSettings Direct Persistence Tests', () {
    late TimerSettingsProvider timerSettingsProvider;
    late MockNotificationService mockNotificationService;
    late SharedPreferences prefs;

    setUp(() async {
      // Initialize SharedPreferences for testing with default values
      SharedPreferences.setMockInitialValues({
        'sessionDuration': 25.0,
        'shortBreakDuration': 5.0,
        'longBreakDuration': 15.0,
        'sessionsBeforeLongBreak': 4,
        'soundEnabled': true,
        'notificationSoundType': 0,
        'completedSessions': 0
      });

      prefs = await SharedPreferences.getInstance();

      debugPrint('==== SETUP: Initial values ====');
      debugPrint('sessionDuration: ${prefs.getDouble('sessionDuration')}');
      debugPrint(
          'shortBreakDuration: ${prefs.getDouble('shortBreakDuration')}');
      debugPrint('longBreakDuration: ${prefs.getDouble('longBreakDuration')}');
      debugPrint(
          'sessionsBeforeLongBreak: ${prefs.getInt('sessionsBeforeLongBreak')}');
      debugPrint('soundEnabled: ${prefs.getBool('soundEnabled')}');

      // Set up notification service
      mockNotificationService = MockNotificationService();
      final serviceLocator = ServiceLocator();
      serviceLocator.reset();
      serviceLocator.registerNotificationService(mockNotificationService);

      // Create a timer settings provider for testing
      timerSettingsProvider = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() async {
      // Clean up
      timerSettingsProvider.dispose();
      final serviceLocator = ServiceLocator();
      serviceLocator.reset();
    });

    test('Session duration change should persist', () async {
      // Change session duration
      timerSettingsProvider.setSessionDuration(30.0);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify provider value updated
      expect(timerSettingsProvider.sessionDuration, 30.0);

      // Verify SharedPreferences value updated
      expect(prefs.getDouble('sessionDuration'), 30.0);

      // Create a new provider to simulate app restart
      final newProvider = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify persisted value
      expect(newProvider.sessionDuration, 30.0);

      // Clean up
      newProvider.dispose();
    });

    test('Short break duration change should persist', () async {
      // Change short break duration
      timerSettingsProvider.setShortBreakDuration(7.0);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify provider value updated
      expect(timerSettingsProvider.shortBreakDuration, 7.0);

      // Verify SharedPreferences value updated
      expect(prefs.getDouble('shortBreakDuration'), 7.0);

      // Create a new provider to simulate app restart
      final newProvider = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify persisted value
      expect(newProvider.shortBreakDuration, 7.0);

      // Clean up
      newProvider.dispose();
    });

    test('Sound settings change should persist', () async {
      // Change sound settings
      timerSettingsProvider.setSoundEnabled(false);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify provider value updated
      expect(timerSettingsProvider.soundEnabled, false);

      // Verify SharedPreferences value updated
      expect(prefs.getBool('soundEnabled'), false);

      // Create a new provider to simulate app restart
      final newProvider = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify persisted value
      expect(newProvider.soundEnabled, false);

      // Clean up
      newProvider.dispose();
    });

    test('Reset to defaults should restore default values', () async {
      // First change values
      timerSettingsProvider.setSessionDuration(30.0);
      timerSettingsProvider.setShortBreakDuration(7.0);
      timerSettingsProvider.setSoundEnabled(false);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify values changed
      expect(timerSettingsProvider.sessionDuration, 30.0);
      expect(timerSettingsProvider.shortBreakDuration, 7.0);
      expect(timerSettingsProvider.soundEnabled, false);

      // Reset to defaults
      await timerSettingsProvider.resetSettingsToDefault();
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify values reset in provider
      expect(timerSettingsProvider.sessionDuration, 25.0);
      expect(timerSettingsProvider.shortBreakDuration, 5.0);
      expect(timerSettingsProvider.soundEnabled, true);

      // Create a new provider to verify persistence
      final newProvider = TimerSettingsProvider(prefs);
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify defaults persisted
      expect(newProvider.sessionDuration, 25.0);
      expect(newProvider.shortBreakDuration, 5.0);
      expect(newProvider.soundEnabled, true);

      // Clean up
      newProvider.dispose();
    });
  });
}

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
