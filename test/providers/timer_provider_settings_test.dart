import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';
import '../mocks/test_notification_service.dart';

/// A subclass of TimerSettingsProvider for testing purposes
class TestableTimerSettingsProvider extends TimerSettingsProvider {
  TestableTimerSettingsProvider(
    SharedPreferences prefs, {
    dynamic notificationService,
  }) : super(prefs, notificationService: notificationService);

  // Helper method to simulate time passing in tests
  void advanceTimerBy(Duration duration) {
    // Simulate the timer advancing by adjusting the remaining time
    if (remainingTime != null && isTimerRunning) {
      final newRemaining = remainingTime! - duration;
      setRemainingTime(newRemaining.isNegative ? Duration.zero : newRemaining);

      // Update progress
      if (totalSeconds > 0) {
        setProgress(remainingTime!.inSeconds / totalSeconds);
      }
    }
  }

  // Helper method to set remaining time for testing
  void setRemainingTime(Duration time) {
    super.notifyListeners(); // This will update the UI in a real scenario
  }

  // Helper method to set progress for testing
  void setProgress(double value) {
    super.notifyListeners(); // This will update the UI in a real scenario
  }

  // Access to internal _totalSeconds for testing
  int get totalSeconds => 25 * 60; // Default to 25 minutes in seconds
}

void main() {
  late TestableTimerSettingsProvider provider;
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
    provider = TestableTimerSettingsProvider(
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

      final newProvider = TestableTimerSettingsProvider(
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

    test('should initialize with correct timer state', () {
      expect(provider.isTimerRunning, false);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
      expect(provider.progress, 1.0);
      expect(provider.remainingTime, isNotNull);
      expect(provider.remainingTime!.inMinutes, 25);
    });
  });

  group('Timer State Management Tests', () {
    test('should start timer correctly', () {
      provider.startTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
    });

    test('should pause and resume timer correctly', () {
      provider.startTimer();

      // Pause
      provider.pauseTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, true);

      // Resume
      provider.resumeTimer();
      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
    });

    test('should reset timer correctly', () {
      provider.startTimer();

      provider.resetTimer();
      expect(provider.isTimerRunning, false);
      expect(provider.isTimerPaused, false);
      expect(provider.progress, 1.0);
      expect(provider.remainingTime!.inMinutes, 25);
    });

    test('should handle break mode transitions', () {
      // Start in focus mode
      expect(provider.isBreak, false);
      expect(
          provider.remainingTime!.inMinutes, provider.sessionDuration.round());

      // Switch to break
      provider.switchToBreakMode();
      expect(provider.isBreak, true);
      expect(provider.remainingTime!.inMinutes,
          provider.shortBreakDuration.round());

      // Switch back to focus
      provider.switchToFocusMode();
      expect(provider.isBreak, false);
      expect(
          provider.remainingTime!.inMinutes, provider.sessionDuration.round());
    });

    test('should start break timer correctly', () {
      provider.startBreak();
      expect(provider.isTimerRunning, true);
      expect(provider.isBreak, true);
    });
  });

  group('Session Management Tests', () {
    test('should track completed sessions correctly', () {
      expect(provider.completedSessions, 0);

      provider.incrementCompletedSessions();
      expect(provider.completedSessions, 1);

      provider.incrementCompletedSessions();
      expect(provider.completedSessions, 2);

      provider.resetCompletedSessions();
      expect(provider.completedSessions, 0);
    });

    test('should determine long break correctly', () {
      expect(provider.shouldTakeLongBreak(), false);

      // Complete sessions until long break
      for (int i = 0; i < provider.sessionsBeforeLongBreak; i++) {
        provider.incrementCompletedSessions();
      }

      expect(provider.shouldTakeLongBreak(), true);

      // After taking long break, the counter should reset
      provider.resetCompletedSessions();
      expect(provider.shouldTakeLongBreak(), false);
    });

    test('should handle session completion state', () {
      expect(provider.sessionCompleted, false);

      provider.setSessionCompleted(true);
      expect(provider.sessionCompleted, true);

      provider.clearSessionCompleted();
      expect(provider.sessionCompleted, false);
    });

    test('should select correct break duration based on completed sessions',
        () {
      // Initially should be short break
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes,
          provider.shortBreakDuration.round());

      // Complete enough sessions for long break
      for (int i = 0; i < provider.sessionsBeforeLongBreak; i++) {
        provider.incrementCompletedSessions();
      }

      // Now should be long break
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes,
          provider.longBreakDuration.round());
    });
  });

  group('Settings Management Tests', () {
    test('should update session duration', () {
      provider.setSessionDuration(30.0);
      expect(provider.sessionDuration, 30.0);

      // When in focus mode, should also update remaining time
      provider.switchToFocusMode();
      expect(provider.remainingTime!.inMinutes, 30);
    });

    test('should update short break duration', () {
      provider.setShortBreakDuration(8.0);
      expect(provider.shortBreakDuration, 8.0);

      // When in short break mode, should also update remaining time
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes, 8);
    });

    test('should update long break duration', () {
      provider.setLongBreakDuration(20.0);
      expect(provider.longBreakDuration, 20.0);

      // When in long break mode, should also update remaining time
      for (int i = 0; i < provider.sessionsBeforeLongBreak; i++) {
        provider.incrementCompletedSessions();
      }
      provider.switchToBreakMode();
      expect(provider.remainingTime!.inMinutes, 20);
    });

    test('should update sessions before long break', () {
      provider.setSessionsBeforeLongBreak(5);
      expect(provider.sessionsBeforeLongBreak, 5);

      // Check it affects long break logic
      for (int i = 0; i < 4; i++) {
        provider.incrementCompletedSessions();
      }
      expect(provider.shouldTakeLongBreak(), false); // Now need 5 sessions

      provider.incrementCompletedSessions();
      expect(provider.shouldTakeLongBreak(), true); // Now have 5 sessions
    });

    test('should update sound settings', () {
      // Toggle sound off
      provider.setSoundEnabled(false);
      expect(provider.soundEnabled, false);

      // Toggle sound on
      provider.setSoundEnabled(true);
      expect(provider.soundEnabled, true);

      // Set notification sound type
      provider.setNotificationSoundType(2);
      expect(provider.notificationSoundType, 2);
    });
  });

  group('Notification Tests', () {
    test('should play test sound when sound is enabled', () {
      provider.setSoundEnabled(true);
      provider.testNotificationSound();
      expect(testNotificationService.testSoundCount, 1);
    });

    test('should not play test sound when sound is disabled', () {
      provider.setSoundEnabled(false);
      provider.testNotificationSound();
      expect(testNotificationService.testSoundCount, 0);
    });

    test('should play notification with correct sound type', () {
      provider.setNotificationSoundType(3);
      provider.testNotificationSound();
      expect(testNotificationService.lastNotificationSoundType, 3);
    });
  });

  group('Persistence Tests', () {
    test('should persist timer settings to SharedPreferences', () async {
      // Modify all settings
      provider.setSessionDuration(30.0);
      provider.setShortBreakDuration(8.0);
      provider.setLongBreakDuration(20.0);
      provider.setSessionsBeforeLongBreak(5);
      provider.setSoundEnabled(false);
      provider.setNotificationSoundType(3);
      provider.incrementCompletedSessions();

      // Wait for async operations to complete
      await Future.delayed(Duration.zero);

      // Verify the values are stored in SharedPreferences directly
      expect(preferences.getDouble('sessionDuration'), 30.0);
      expect(preferences.getDouble('shortBreakDuration'), 8.0);
      expect(preferences.getDouble('longBreakDuration'), 20.0);
      expect(preferences.getInt('sessionsBeforeLongBreak'), 5);
      expect(preferences.getBool('soundEnabled'), false);
      expect(preferences.getInt('notificationSoundType'), 3);
      expect(preferences.getInt('completedSessions'), 1);
    });
  });
}
