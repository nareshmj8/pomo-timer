import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';
import '../mocks/test_notification_service.dart';

void main() {
  late TimerSettingsProvider provider;
  late SharedPreferences preferences;
  late TestNotificationService testNotificationService;

  setUp(() async {
    // Setup test SharedPreferences
    SharedPreferences.setMockInitialValues({
      'sessionDuration': 25.0,
      'shortBreakDuration': 5.0,
      'longBreakDuration': 15.0,
      'sessionsBeforeLongBreak': 4,
      'soundEnabled': true,
      'notificationSoundType': 0,
      'completedSessions': 0,
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

  group('Initialization Tests', () {
    test('should initialize with default values when no saved data exists',
        () async {
      // Setup with empty preferences
      SharedPreferences.setMockInitialValues({});
      final emptyPrefs = await SharedPreferences.getInstance();

      final newProvider = TimerSettingsProvider(
        emptyPrefs,
        notificationService: testNotificationService,
      );

      // Verify defaults
      expect(newProvider.sessionDuration, 25.0);
      expect(newProvider.shortBreakDuration, 5.0);
      expect(newProvider.longBreakDuration, 15.0);
      expect(newProvider.sessionsBeforeLongBreak, 4);
      expect(newProvider.soundEnabled, true);
      expect(newProvider.notificationSoundType, 0);
      expect(newProvider.completedSessions, 0);
    });

    test('should initialize with saved values', () {
      // Should use values from the SharedPreferences setup
      expect(provider.sessionDuration, 25.0);
      expect(provider.shortBreakDuration, 5.0);
      expect(provider.longBreakDuration, 15.0);
      expect(provider.sessionsBeforeLongBreak, 4);
      expect(provider.soundEnabled, true);
      expect(provider.notificationSoundType, 0);
    });

    test('should initialize notification service on startup', () {
      // Notification service should have been initialized
      expect(testNotificationService.isInitialized, true);
    });

    test('should initialize with correct timer state', () {
      expect(provider.isTimerRunning, false);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
      expect(provider.progress, 1.0);
      expect(provider.remainingTime, isNotNull);
      expect(provider.remainingTime!.inMinutes, 25);
    });
  });

  group('State Management Tests', () {
    test('should correctly track timer running state', () {
      // Initially not running
      expect(provider.isTimerRunning, false);

      // Start the timer
      provider.startTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);

      // Reset the timer
      provider.resetTimer();
      expect(provider.isTimerRunning, false);
    });

    test('should correctly track timer paused state', () {
      // Start and then pause
      provider.startTimer();
      provider.pauseTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, true);

      // Resume
      provider.resumeTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
    });

    test('should track break vs focus mode', () {
      // Initially in focus mode
      expect(provider.isBreak, false);

      // Switch to break
      provider.switchToBreakMode();
      expect(provider.isBreak, true);

      // Switch back to focus
      provider.switchToFocusMode();
      expect(provider.isBreak, false);
    });

    test('should update remaining time based on mode', () {
      // Initially in focus mode with session duration
      expect(
          provider.remainingTime!.inMinutes, provider.sessionDuration.round());

      // Switch to break mode
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes,
          provider.shortBreakDuration.round());

      // Complete enough sessions for long break
      for (int i = 0; i < provider.sessionsBeforeLongBreak; i++) {
        provider.incrementCompletedSessions();
      }

      // Switch to break mode again - should now be long break
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes,
          provider.longBreakDuration.round());
    });

    test('should update remaining time when duration settings change', () {
      // Change session duration
      provider.setSessionDuration(30.0);
      expect(provider.remainingTime!.inMinutes, 30);

      // Change to break mode and change break duration
      provider.switchToBreakMode();
      provider.setShortBreakDuration(8.0);
      expect(provider.remainingTime!.inMinutes, 8);
    });

    test('should handle completed sessions counter correctly', () {
      expect(provider.completedSessions, 0);

      // Increment
      provider.incrementCompletedSessions();
      expect(provider.completedSessions, 1);

      // Increment more
      provider.incrementCompletedSessions();
      provider.incrementCompletedSessions();
      expect(provider.completedSessions, 3);

      // Reset
      provider.resetCompletedSessions();
      expect(provider.completedSessions, 0);
    });

    test('should correctly identify when to take long break', () {
      // Initially should not take long break
      expect(provider.shouldTakeLongBreak(), false);

      // Complete exactly the number of sessions needed
      for (int i = 0; i < provider.sessionsBeforeLongBreak; i++) {
        provider.incrementCompletedSessions();
      }

      // Now should take long break
      // With 4 completed sessions and a sessionsBeforeLongBreak of 4, should be true
      expect(provider.shouldTakeLongBreak(), true);

      // Reset sessions
      provider.resetCompletedSessions();

      // Complete just 1 session
      provider.incrementCompletedSessions();
      // With 1 completed session, should not take long break
      expect(provider.shouldTakeLongBreak(), false);
    });

    test('should track session completed state', () {
      expect(provider.sessionCompleted, false);

      provider.setSessionCompleted(true);
      expect(provider.sessionCompleted, true);

      provider.clearSessionCompleted();
      expect(provider.sessionCompleted, false);
    });
  });

  group('Persistence Tests', () {
    test('should set and persist session duration', () {
      // Update the value
      provider.setSessionDuration(30.0);

      // Verify in-memory state was updated
      expect(provider.sessionDuration, 30.0);
    });

    test('should set and persist short break duration', () {
      provider.setShortBreakDuration(8.0);
      expect(provider.shortBreakDuration, 8.0);
    });

    test('should set and persist long break duration', () {
      provider.setLongBreakDuration(20.0);
      expect(provider.longBreakDuration, 20.0);
    });

    test('should set and persist sessions before long break', () {
      provider.setSessionsBeforeLongBreak(5);
      expect(provider.sessionsBeforeLongBreak, 5);
    });

    test('should set and persist sound enabled state', () {
      provider.setSoundEnabled(false);
      expect(provider.soundEnabled, false);
    });

    test('should set and persist notification sound type', () {
      provider.setNotificationSoundType(2);
      expect(provider.notificationSoundType, 2);
    });

    test('should increment and persist completed sessions', () {
      provider.incrementCompletedSessions();
      expect(provider.completedSessions, 1);
    });

    test('should persist settings after reset to defaults', () async {
      // First change all settings
      provider.setSessionDuration(30.0);
      provider.setShortBreakDuration(8.0);
      provider.setLongBreakDuration(20.0);
      provider.setSessionsBeforeLongBreak(5);

      // Then reset to defaults
      await provider.resetSettingsToDefault();

      // Verify values are back to defaults
      expect(provider.sessionDuration, 25.0);
      expect(provider.shortBreakDuration, 5.0);
      expect(provider.longBreakDuration, 15.0);
      expect(provider.sessionsBeforeLongBreak, 4);
    });
  });

  group('Configuration Tests', () {
    test('should play notification sounds when enabled', () async {
      // Enable sounds and start a timer
      provider.setSoundEnabled(true);

      // Call method that plays sound
      provider.testNotificationSound();

      // Allow async processing
      await Future.delayed(Duration.zero);

      // Verify sound was played
      expect(testNotificationService.testSoundCount, 1);
    });

    test('should not play notification sounds when disabled', () async {
      // Disable sounds
      provider.setSoundEnabled(false);

      // Call method that would play sound
      provider.testNotificationSound();

      // Allow async processing
      await Future.delayed(Duration.zero);

      // Verify no sound was played
      expect(testNotificationService.testSoundCount, 0);
    });

    test('should use correct sound type when playing test sound', () async {
      // Set sound type and enable sounds
      provider.setNotificationSoundType(3);
      provider.setSoundEnabled(true);

      // Play test sound
      provider.testNotificationSound();

      // Allow async processing
      await Future.delayed(Duration.zero);

      // Verify correct sound type was used
      expect(testNotificationService.lastNotificationSoundType, 3);
    });

    test('should update category selection', () {
      expect(provider.selectedCategory, 'Work');

      provider.setSelectedCategory('Study');
      expect(provider.selectedCategory, 'Study');
    });

    test('should not update remaining time when timer is running', () {
      // Start the timer
      provider.startTimer();

      // Try to change duration while timer is running
      provider.setSessionDuration(30.0);

      // Remaining time should still be based on original duration
      expect(provider.remainingTime!.inMinutes, 25);
    });

    test('should allow updating duration settings while timer is not running',
        () {
      // Update duration
      provider.setSessionDuration(30.0);

      // Remaining time should update
      expect(provider.remainingTime!.inMinutes, 30);
    });
  });
}
