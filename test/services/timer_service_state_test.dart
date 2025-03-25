import 'package:flutter_test/flutter_test.dart';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/timer_service.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('TimerService State Tests', () {
    late TimerService timerService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      timerService = TimerService();
    });

    // Focus timer tests
    group('Focus Timer State Tests', () {
      test('should start focus timer correctly', () {
        // Arrange
        const initialDuration = 25; // 25 minutes
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Act
        timerService.startTimer(initialDuration, onComplete);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.running));
        expect(timerService.timerState.timeRemaining,
            equals(initialDuration * 60));
        expect(timerService.timerState.totalDuration,
            equals(initialDuration * 60));
        expect(timerService.timerState.isBreak, isFalse);
        expect(timerService.timerState.progress, equals(1.0));
        expect(timerService.isRunning, isTrue);
      });

      test('should not start timer if already running', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;
        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Start the timer
        timerService.startTimer(initialDuration, onComplete);

        // Get the initial state for comparison
        final initialState = timerService.timerState;

        // Act: Try to start timer again
        timerService.startTimer(30, onComplete);

        // Assert: State should not have changed
        expect(timerService.timerState.timeRemaining,
            equals(initialState.timeRemaining));
        expect(timerService.timerState.status, equals(initialState.status));
      });

      test('should pause timer correctly', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startTimer(initialDuration, onComplete);

        // Act
        timerService.pauseTimer();

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.paused));
        expect(timerService.isRunning, isFalse);
      });

      test('should not pause timer if not running', () {
        // Arrange - timer is idle

        // Act
        timerService.pauseTimer();

        // Assert - status should still be idle
        expect(timerService.timerState.status, equals(TimerStatus.idle));
      });

      test('should resume timer correctly', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startTimer(initialDuration, onComplete);
        timerService.pauseTimer();

        // Act
        timerService.resumeTimer(onComplete);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.running));
        expect(timerService.isRunning, isTrue);
      });

      test('should not resume timer if not paused', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;
        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Timer is in idle state

        // Act
        timerService.resumeTimer(onComplete);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.idle));
        expect(timerService.isRunning, isFalse);
      });

      test('should reset timer correctly', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startTimer(initialDuration, onComplete);

        // Act
        timerService.resetTimer(25);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.idle));
        expect(timerService.timerState.timeRemaining, equals(0));
        expect(timerService.timerState.totalDuration, equals(0));
        expect(timerService.timerState.progress, equals(1.0));
        expect(timerService.isRunning, isFalse);
      });
    });

    // Break timer tests
    group('Break Timer State Tests', () {
      test('should start break timer correctly', () {
        // Arrange
        const breakDuration = 5; // 5 minutes
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Act
        timerService.startBreak(breakDuration, onComplete);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.running));
        expect(
            timerService.timerState.timeRemaining, equals(breakDuration * 60));
        expect(
            timerService.timerState.totalDuration, equals(breakDuration * 60));
        expect(timerService.timerState.isBreak, isTrue);
        expect(timerService.timerState.progress, equals(1.0));
        expect(timerService.isRunning, isTrue);
      });

      test('should not start break if already running', () {
        // Arrange
        const initialDuration = 25;
        bool onCompleteWasCalled = false;
        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Start the timer
        timerService.startTimer(initialDuration, onComplete);

        // Get the initial state for comparison
        final initialState = timerService.timerState;

        // Act: Try to start a break
        timerService.startBreak(5, onComplete);

        // Assert: State should not have changed
        expect(timerService.timerState.timeRemaining,
            equals(initialState.timeRemaining));
        expect(timerService.timerState.status, equals(initialState.status));
      });

      test('should pause break timer correctly', () {
        // Arrange
        const breakDuration = 5;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startBreak(breakDuration, onComplete);

        // Act
        timerService.pauseTimer();

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.paused));
        expect(timerService.isRunning, isFalse);
        expect(timerService.timerState.isBreak,
            isTrue); // Should still be in break mode
      });

      test('should resume break timer correctly', () {
        // Arrange
        const breakDuration = 5;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startBreak(breakDuration, onComplete);
        timerService.pauseTimer();

        // Act
        timerService.resumeTimer(onComplete);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.running));
        expect(timerService.isRunning, isTrue);
        expect(timerService.timerState.isBreak,
            isTrue); // Should still be in break mode
      });

      test('should reset break timer correctly', () {
        // Arrange
        const breakDuration = 5;
        bool onCompleteWasCalled = false;

        void onComplete() {
          onCompleteWasCalled = true;
        }

        timerService.startBreak(breakDuration, onComplete);

        // Act
        timerService.resetTimer(25);

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.idle));
        expect(timerService.timerState.timeRemaining, equals(0));
        expect(timerService.timerState.totalDuration, equals(0));
        expect(timerService.timerState.isBreak,
            isFalse); // Should be reset to focus mode
        expect(timerService.timerState.progress, equals(1.0));
        expect(timerService.isRunning, isFalse);
      });
    });

    // State persistence tests
    group('Timer State Persistence Tests', () {
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
    });
  });
}
