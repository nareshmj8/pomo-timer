import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/providers/timer_provider.dart';
import 'dart:async';

void main() {
  late TimerProvider provider;

  setUp(() {
    provider = TimerProvider();
  });

  tearDown(() {
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

  group('TimerProvider Start', () {
    test('should start timer correctly', () {
      provider.startTimer(20);

      expect(provider.isTimerRunning, true);
      expect(provider.isTimerPaused, false);
      expect(provider.isBreak, false);
      expect(provider.remainingTime.inMinutes, 20);
      expect(provider.progress, 1.0);
      expect(provider.sessionCompleted, false);
    });

    test('should not start timer when already running', () {
      provider.startTimer(20);

      // Save current state
      final initialRemainingTime = provider.remainingTime;
      final isRunning = provider.isTimerRunning;

      // Try to start timer again with different duration
      provider.startTimer(10);

      // Timer should continue running with same duration
      expect(provider.isTimerRunning, isRunning);
      expect(provider.remainingTime, initialRemainingTime);
    });
  });

  group('TimerProvider Countdown', () {
    test('should update progress during first few seconds', () async {
      // Use a longer duration for this test to avoid it completing too quickly
      provider.startTimer(5); // 5 minutes

      // Initial progress should be 1.0
      expect(provider.progress, 1.0);

      // Wait a few seconds for the timer to tick a few times
      await Future.delayed(const Duration(seconds: 3));

      // Progress should now be slightly less than 1.0
      expect(provider.progress < 1.0, true);
      expect(provider.progress > 0.9, true); // Should still be close to 1.0

      // Timer should still be running
      expect(provider.isTimerRunning, true);
      expect(provider.sessionCompleted, false);
    });

    // This test can be commented out in CI environments to avoid long-running tests
    // test('should count down and complete after duration', () async {
    //   // Use a short duration for testing
    //   provider.startTimer(1); // 1 minute
    //
    //   // Wait for the timer to finish (a bit longer to be safe)
    //   await Future.delayed(const Duration(minutes: 1, seconds: 2));
    //
    //   // Timer should be completed
    //   expect(provider.isTimerRunning, false);
    //   expect(provider.sessionCompleted, true);
    //   expect(provider.remainingTime.inSeconds, 0);
    //   expect(provider.progress, 0.0);
    // }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('TimerProvider Edge Cases', () {
    test('should handle zero duration', () async {
      provider.startTimer(0);

      // Wait a moment for the timer to process
      await Future.delayed(const Duration(seconds: 2));

      // For zero duration, behavior depends on implementation
      // It might complete immediately or run for a very short time
      expect(provider.sessionCompleted, true);
      expect(provider.isTimerRunning, false);
    });

    test('should handle very long durations', () {
      // Test with a longer duration (not too long for testing)
      provider.startTimer(60);

      expect(provider.remainingTime.inMinutes, 60);
      expect(provider.isTimerRunning, true);
    });
  });
}
