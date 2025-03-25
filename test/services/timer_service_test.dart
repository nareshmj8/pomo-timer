import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/timer_service.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('TimerService Tests', () {
    late TimerService timerService;
    late MockNotificationService mockNotificationService;

    // Setup method that runs before each test
    setUp(() {
      mockNotificationService = MockNotificationService();

      // Initialize the timer service without notification service
      timerService = TimerService();
    });

    test('should initialize with default values', () {
      // Verify initial state
      expect(timerService.timerState, isA<TimerState>());
      expect(timerService.timerState.status, equals(TimerStatus.idle));
      expect(timerService.timerState.timeRemaining, equals(0));
      expect(timerService.isRunning, isFalse);
    });

    test('should start timer correctly', () {
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
      expect(
          timerService.timerState.timeRemaining, equals(initialDuration * 60));
      expect(timerService.isRunning, isTrue);
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
      expect(timerService.isRunning, isFalse);
    });

    test('should load timer state correctly', () {
      // Act
      timerService.loadState();

      // Assert - verify the values match what we defined in the loadState method
      expect(timerService.timerState.status, equals(TimerStatus.running));
      expect(timerService.timerState.timeRemaining, equals(1200));
      expect(timerService.timerState.totalDuration, equals(1500));
    });
  });
}
