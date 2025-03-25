import 'package:flutter_test/flutter_test.dart';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/timer_service.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('TimerService Persistence Tests', () {
    late TimerService timerService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      timerService = TimerService();
    });

    test('should load predefined state correctly', () {
      // Act
      timerService.loadState();

      // Assert - verify the values match what we defined in the loadState method
      expect(timerService.timerState.status, equals(TimerStatus.running));
      expect(timerService.timerState.timeRemaining, equals(1200));
      expect(timerService.timerState.totalDuration, equals(1500));
      expect(timerService.timerState.progress, closeTo(0.8, 0.01));
      expect(timerService.timerState.isBreak, isFalse);
    });

    test('should notify listeners when state is loaded', () {
      // Arrange
      int notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.loadState();

      // Assert
      expect(
          notificationCount, equals(1)); // One notification for loading state
    });

    test('should maintain state persistence across timer operations', () {
      // Arrange - Load the predefined state
      timerService.loadState();

      // Act - Pause the timer
      timerService.pauseTimer();

      // Assert - State should be paused but keep other properties from loaded state
      expect(timerService.timerState.status, equals(TimerStatus.paused));
      expect(timerService.timerState.timeRemaining, equals(1200));
      expect(timerService.timerState.totalDuration, equals(1500));
      expect(timerService.timerState.progress, closeTo(0.8, 0.01));
      expect(timerService.timerState.isBreak, isFalse);
    });

    test('should reset state when resetTimer is called', () {
      // Arrange - Load the predefined state
      timerService.loadState();

      // Act - Reset the timer
      timerService.resetTimer(25);

      // Assert - State should be reset
      expect(timerService.timerState.status, equals(TimerStatus.idle));
      expect(timerService.timerState.timeRemaining, equals(0));
      expect(timerService.timerState.totalDuration, equals(0));
      expect(timerService.timerState.progress, equals(1.0));
      expect(timerService.timerState.isBreak, isFalse);
    });

    test('should override current state when loadState is called', () {
      // Arrange - Start a timer
      timerService.startTimer(10, () {});

      // Act - Load state
      timerService.loadState();

      // Assert - State should match the loaded state, not the started timer
      expect(timerService.timerState.status, equals(TimerStatus.running));
      expect(timerService.timerState.timeRemaining, equals(1200));
      expect(timerService.timerState.totalDuration, equals(1500));
      expect(timerService.timerState.progress, closeTo(0.8, 0.01));
      expect(timerService.timerState.isBreak, isFalse);
    });

    // Note: In a real-world application, we would test actual persistence to disk
    // using SharedPreferences or another storage mechanism. Since the current
    // implementation uses a hard-coded state for testing purposes, these tests
    // verify the current functionality.
  });
}
