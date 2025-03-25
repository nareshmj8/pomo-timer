import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';

void main() {
  group('TimerState', () {
    test('should be initialized with correct values', () {
      const state = TimerState(
        status: TimerStatus.running,
        timeRemaining: 1500, // 25 minutes
        totalDuration: 1500,
        isBreak: false,
        progress: 1.0,
      );

      expect(state.status, equals(TimerStatus.running));
      expect(state.timeRemaining, equals(1500));
      expect(state.totalDuration, equals(1500));
      expect(state.isBreak, equals(false));
      expect(state.progress, equals(1.0));
    });

    test('should create initial state with factory constructor', () {
      final initialState = TimerState.initial();

      expect(initialState.status, equals(TimerStatus.idle));
      expect(initialState.timeRemaining, equals(0));
      expect(initialState.totalDuration, equals(0));
      expect(initialState.isBreak, equals(false));
      expect(initialState.progress, equals(1.0));
    });

    test('should correctly copy with partial updates', () {
      const originalState = TimerState(
        status: TimerStatus.running,
        timeRemaining: 1500,
        totalDuration: 1500,
        isBreak: false,
        progress: 1.0,
      );

      // Test updating only status
      final pausedState = originalState.copyWith(
        status: TimerStatus.paused,
      );
      expect(pausedState.status, equals(TimerStatus.paused));
      expect(pausedState.timeRemaining, equals(originalState.timeRemaining));
      expect(pausedState.totalDuration, equals(originalState.totalDuration));
      expect(pausedState.isBreak, equals(originalState.isBreak));
      expect(pausedState.progress, equals(originalState.progress));

      // Test updating time remaining and progress
      final progressState = originalState.copyWith(
        timeRemaining: 750,
        progress: 0.5,
      );
      expect(progressState.status, equals(originalState.status));
      expect(progressState.timeRemaining, equals(750));
      expect(progressState.totalDuration, equals(originalState.totalDuration));
      expect(progressState.isBreak, equals(originalState.isBreak));
      expect(progressState.progress, equals(0.5));

      // Test switching to break mode
      final breakState = originalState.copyWith(
        status: TimerStatus.running,
        timeRemaining: 300,
        totalDuration: 300,
        isBreak: true,
        progress: 1.0,
      );
      expect(breakState.status, equals(TimerStatus.running));
      expect(breakState.timeRemaining, equals(300));
      expect(breakState.totalDuration, equals(300));
      expect(breakState.isBreak, equals(true));
      expect(breakState.progress, equals(1.0));
    });

    test('should correctly handle completed state', () {
      const runningState = TimerState(
        status: TimerStatus.running,
        timeRemaining: 1500,
        totalDuration: 1500,
        isBreak: false,
        progress: 1.0,
      );

      final completedState = runningState.copyWith(
        status: TimerStatus.completed,
        timeRemaining: 0,
        progress: 0.0,
      );

      expect(completedState.status, equals(TimerStatus.completed));
      expect(completedState.timeRemaining, equals(0));
      expect(completedState.progress, equals(0.0));
      expect(completedState.totalDuration, equals(runningState.totalDuration));
      expect(completedState.isBreak, equals(runningState.isBreak));
    });
  });
}
