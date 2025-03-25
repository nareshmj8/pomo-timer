import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_timer_settings/timer_settings_provider.dart';
import 'package:test_timer_settings/test_notification_service.dart';

void main() {
  late TimerSettingsProvider provider;
  late SharedPreferences preferences;
  late TestNotificationService testNotificationService;

  setUp(() async {
    // Setup test SharedPreferences
    SharedPreferences.setMockInitialValues({
      'session_duration': 25.0,
      'short_break_duration': 5.0,
      'long_break_duration': 15.0,
      'sessions_before_long_break': 4,
      'sound_enabled': true,
      'notification_sound_type': 0,
    });
    preferences = await SharedPreferences.getInstance();

    // Setup test notification service
    testNotificationService = TestNotificationService();
    await testNotificationService.initialize();

    // Initialize the provider with the test dependencies
    provider = TimerSettingsProvider(
      preferences,
      notificationService: testNotificationService,
    );
  });

  group('TimerSettingsProvider initialization', () {
    test('should initialize with default values', () {
      expect(provider.sessionDuration, 25.0);
      expect(provider.shortBreakDuration, 5.0);
      expect(provider.longBreakDuration, 15.0);
      expect(provider.sessionsBeforeLongBreak, 4);
      expect(provider.soundEnabled, true);
      expect(provider.notificationSoundType, 0);
      expect(provider.completedSessions, 0);
      expect(provider.isTimerRunning, false);
      expect(provider.isBreak, false);
      expect(provider.progress, 1.0);
    });

    test('should have initialized notification service', () {
      expect(testNotificationService.isInitialized, true);
    });
  });

  group('TimerSettingsProvider notification interactions', () {
    test(
        'should play test sound when testNotificationSound is called and sound is enabled',
        () async {
      // Ensure sound is enabled
      provider.setSoundEnabled(true);

      // Call the method
      provider.testNotificationSound();

      // Verify the sound was played
      expect(testNotificationService.testSoundCount, 1);
    });

    test(
        'should not play test sound when testNotificationSound is called and sound is disabled',
        () async {
      // Disable sound
      provider.setSoundEnabled(false);

      // Call the method
      provider.testNotificationSound();

      // Verify the sound was not played
      expect(testNotificationService.testSoundCount, 0);
    });

    test('should play test sound with selected sound type', () async {
      // Set a different sound type
      provider.setNotificationSoundType(3);

      // Call the method
      provider.testNotificationSound();

      // Verify the correct sound type was passed to the service
      expect(testNotificationService.testSoundCount, 1);
      expect(testNotificationService.lastNotificationSoundType, 3);
    });
  });

  group('TimerSettingsProvider settings', () {
    test('should update session duration', () {
      provider.setSessionDuration(30.0);
      expect(provider.sessionDuration, 30.0);
    });

    test('should update short break duration', () {
      provider.setShortBreakDuration(7.0);
      expect(provider.shortBreakDuration, 7.0);
    });

    test('should update long break duration', () {
      provider.setLongBreakDuration(20.0);
      expect(provider.longBreakDuration, 20.0);
    });

    test('should update sessions before long break', () {
      provider.setSessionsBeforeLongBreak(5);
      expect(provider.sessionsBeforeLongBreak, 5);
    });

    test('should toggle sound', () {
      provider.toggleSound(false);
      expect(provider.soundEnabled, false);
      provider.toggleSound(true);
      expect(provider.soundEnabled, true);
    });

    test('should update notification sound type', () {
      provider.setNotificationSoundType(2);
      expect(provider.notificationSoundType, 2);
    });
  });

  group('TimerSettingsProvider timer controls', () {
    test('should start timer', () {
      provider.startTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
    });

    test('should pause timer', () {
      provider.startTimer();
      provider.pauseTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, true);
    });

    test('should resume timer', () {
      provider.startTimer();
      provider.pauseTimer();
      provider.resumeTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
    });

    test('should reset timer', () {
      provider.startTimer();
      provider.resetTimer();
      expect(provider.isTimerRunning, false);
      expect(provider.isTimerPaused, false);
      expect(provider.progress, 1.0);
    });

    test('should start break', () {
      provider.startBreak();
      expect(provider.isTimerRunning, true);
      expect(provider.isBreak, true);
    });

    test('should switch to focus mode', () {
      // First switch to break mode
      provider.switchToBreakMode();
      expect(provider.isBreak, true);

      // Then switch to focus mode
      provider.switchToFocusMode();
      expect(provider.isBreak, false);
    });

    test('should switch to break mode', () {
      // First ensure we're in focus mode
      provider.switchToFocusMode();
      expect(provider.isBreak, false);

      // Then switch to break mode
      provider.switchToBreakMode();
      expect(provider.isBreak, true);
    });
  });
}
