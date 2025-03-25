import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import '../mocks/mock_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Integration Tests', () {
    late SettingsProvider settingsProvider;
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
        'selectedTheme': 'System',
        'notificationsEnabled': true,
        'vibrationEnabled': true,
        'completedSessions': 0,
        'history': <String>[]
      });

      prefs = await SharedPreferences.getInstance();

      // Set up notification service
      mockNotificationService = MockNotificationService();
      final serviceLocator = ServiceLocator();
      serviceLocator.reset();
      serviceLocator.registerNotificationService(mockNotificationService);

      // Create a settings provider for testing
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() async {
      settingsProvider.dispose();
      final serviceLocator = ServiceLocator();
      serviceLocator.reset();
    });

    test('Delegation to TimerSettingsProvider works correctly', () async {
      // Test initial values
      expect(settingsProvider.sessionDuration, 25.0);
      expect(settingsProvider.shortBreakDuration, 5.0);
      expect(settingsProvider.longBreakDuration, 15.0);
      expect(settingsProvider.sessionsBeforeLongBreak, 4);
      expect(settingsProvider.soundEnabled, true);

      // Change settings through main provider
      settingsProvider.setSessionDuration(30.0);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(settingsProvider.sessionDuration, 30.0);
      expect(prefs.getDouble('sessionDuration'), 30.0);

      // Test multiple settings changes
      settingsProvider.setShortBreakDuration(7.0);
      settingsProvider.setSoundEnabled(false);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(settingsProvider.shortBreakDuration, 7.0);
      expect(settingsProvider.soundEnabled, false);
      expect(prefs.getDouble('shortBreakDuration'), 7.0);
      expect(prefs.getBool('soundEnabled'), false);

      // Create a new provider to verify persistence
      final newSettingsProvider = SettingsProvider(prefs);
      await newSettingsProvider.init();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(newSettingsProvider.sessionDuration, 30.0);
      expect(newSettingsProvider.shortBreakDuration, 7.0);
      expect(newSettingsProvider.soundEnabled, false);

      newSettingsProvider.dispose();
    });

    test('Delegation to ThemeSettingsProvider works correctly', () async {
      // Test initial values
      expect(settingsProvider.selectedTheme, 'System');
      expect(settingsProvider.isDarkTheme, false);

      // Change theme
      settingsProvider.setTheme('Dark');
      await Future.delayed(const Duration(milliseconds: 200));

      expect(settingsProvider.selectedTheme, 'Dark');
      expect(settingsProvider.isDarkTheme, true);
      expect(prefs.getString('selectedTheme'), 'Dark');

      // Create a new provider to verify persistence
      final newSettingsProvider = SettingsProvider(prefs);
      await newSettingsProvider.init();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(newSettingsProvider.selectedTheme, 'Dark');
      expect(newSettingsProvider.isDarkTheme, true);

      newSettingsProvider.dispose();
    });

    test('Reset settings to defaults works correctly', () async {
      // Change multiple settings
      settingsProvider.setSessionDuration(30.0);
      settingsProvider.setShortBreakDuration(7.0);
      settingsProvider.setTheme('Dark');
      settingsProvider.setSoundEnabled(false);
      settingsProvider.setNotificationsEnabled(false);
      await Future.delayed(const Duration(milliseconds: 200));

      // Reset to defaults
      await settingsProvider.resetSettingsToDefault();
      await Future.delayed(const Duration(milliseconds: 200));

      // Verify settings were reset
      expect(settingsProvider.sessionDuration, 25.0);
      expect(settingsProvider.shortBreakDuration, 5.0);
      expect(settingsProvider.selectedTheme, 'System');
      expect(settingsProvider.soundEnabled, true);
      expect(settingsProvider.notificationsEnabled, true);

      // Verify persistence
      final newSettingsProvider = SettingsProvider(prefs);
      await newSettingsProvider.init();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(newSettingsProvider.sessionDuration, 25.0);
      expect(newSettingsProvider.shortBreakDuration, 5.0);
      expect(newSettingsProvider.selectedTheme, 'System');
      expect(newSettingsProvider.soundEnabled, true);
      expect(newSettingsProvider.notificationsEnabled, true);

      newSettingsProvider.dispose();
    });

    test('Notification settings work correctly', () async {
      // Test initial values
      expect(settingsProvider.notificationsEnabled, true);
      expect(settingsProvider.vibrationEnabled, true);

      // Change notification settings
      settingsProvider.setNotificationsEnabled(false);
      settingsProvider.setVibrationEnabled(false);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(settingsProvider.notificationsEnabled, false);
      expect(settingsProvider.vibrationEnabled, false);
      expect(prefs.getBool('notificationsEnabled'), false);
      expect(prefs.getBool('vibrationEnabled'), false);

      // Create a new provider to verify persistence
      final newSettingsProvider = SettingsProvider(prefs);
      await newSettingsProvider.init();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(newSettingsProvider.notificationsEnabled, false);
      expect(newSettingsProvider.vibrationEnabled, false);

      newSettingsProvider.dispose();
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
