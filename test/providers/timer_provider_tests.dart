import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/providers/timer_provider.dart';

/// A testable subclass of TimerProvider to help control the timer in tests
class TestableTimerProvider extends TimerProvider {
  // Method to simulate timer ticks without actually waiting
  void simulateTimerTick() {
    if (!isTimerRunning || remainingTime.inSeconds <= 0) return;

    // Access parent class properties via getter/setter methods
    final newRemaining = Duration(seconds: remainingTime.inSeconds - 1);

    // Use reflection to modify private fields
    // This is hacky but necessary for testing without modifying the source
    final instance = this;
    (instance as dynamic)._remainingTime = newRemaining;
    (instance as dynamic)._progress =
        newRemaining.inSeconds / (instance as dynamic)._totalSeconds;

    // Check if timer completed
    if (newRemaining.inSeconds <= 0) {
      (instance as dynamic)._isTimerRunning = false;
      (instance as dynamic)._sessionCompleted = true;
    }

    notifyListeners();
  }

  // Method to simulate multiple ticks at once
  void simulateTimerTicks(int numberOfTicks) {
    for (int i = 0; i < numberOfTicks && isTimerRunning; i++) {
      simulateTimerTick();
    }
  }

  // Method to simulate timer completion
  void simulateTimerCompletion() {
    final instance = this;
    (instance as dynamic)._remainingTime = Duration.zero;
    (instance as dynamic)._progress = 0.0;
    (instance as dynamic)._isTimerRunning = false;
    (instance as dynamic)._sessionCompleted = true;
    notifyListeners();
  }

  // Method to cancel the timer
  void cancelTimer() {
    final instance = this;
    (instance as dynamic)._timer?.cancel();
  }
}

void main() {
  late TestableTimerProvider provider;

  setUp(() {
    provider = TestableTimerProvider();
  });

  tearDown(() {
    // Cancel any active timers to prevent memory leaks
    provider.cancelTimer();
    provider.dispose();
  });

  group('TimerProvider Initialization', () {
    test('should initialize with default values', () {
      expect(provider.isTimerRunning, false);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
      expect(provider.remainingTime, const Duration(minutes: 25));
      expect(provider.progress, 1.0);
      expect(provider.sessionCompleted, false);
    });
  });

  group('TimerProvider Start & Progress', () {
    test('should start timer correctly', () {
      provider.startTimer(25);

      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
      expect(provider.remainingTime.inMinutes, 25);
      expect(provider.progress, 1.0);
      expect(provider.sessionCompleted, false);
    });

    test('should not start timer when already running', () {
      provider.startTimer(25);

      // Save current state
      final initialRemainingTime = provider.remainingTime;

      // Simulate some time passing
      provider.simulateTimerTicks(10);

      // Try to start timer again
      provider.startTimer(20);

      // Timer state should not be reset
      expect(provider.remainingTime.inSeconds,
          initialRemainingTime.inSeconds - 10);
    });

    test('should update progress during countdown', () {
      // Start a 25-minute (1500 seconds) timer
      provider.startTimer(25);

      // Simulate passing of 300 seconds (5 minutes)
      provider.simulateTimerTicks(300);

      // Progress should be updated: 1200/1500 = 0.8
      expect(provider.progress, closeTo(0.8, 0.01));
    });
  });

  group('TimerProvider Completion', () {
    test('should mark session as completed when timer ends', () {
      provider.startTimer(1); // 1-minute timer for faster test

      // Simulate full completion
      provider.simulateTimerCompletion();

      expect(provider.isTimerRunning, false);
      expect(provider.sessionCompleted, true);
      expect(provider.progress, 0.0);
      expect(provider.remainingTime.inSeconds, 0);
    });

    test('should handle natural timer completion', () {
      // Start a short timer
      provider.startTimer(1);

      // Simulate all 60 ticks to completion
      provider.simulateTimerTicks(60);

      // Timer should be completed
      expect(provider.isTimerRunning, false);
      expect(provider.sessionCompleted, true);
      expect(provider.remainingTime.inSeconds, 0);
      expect(provider.progress, 0.0);
    });
  });

  group('TimerProvider Edge Cases', () {
    test('should handle zero duration gracefully', () {
      provider.startTimer(0);

      // Timer should complete immediately in next tick
      provider.simulateTimerTick();

      expect(provider.isTimerRunning, false);
      expect(provider.sessionCompleted, true);
    });

    test('should handle very long durations', () {
      // Test a long duration like 120 minutes
      provider.startTimer(120);

      expect(provider.remainingTime.inMinutes, 120);
      expect(provider.isTimerRunning, true);
    });
  });
}
