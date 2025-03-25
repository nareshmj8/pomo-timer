import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:fake_async/fake_async.dart';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/timer_service.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('TimerService Callback Tests', () {
    late TimerService timerService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      timerService = TimerService();
    });

    test('should notifyListeners when timer starts', () {
      // Arrange
      int notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.startTimer(25, () {});

      // Assert
      expect(notificationCount, equals(1)); // One notification for starting
    });

    test('should notifyListeners when break starts', () {
      // Arrange
      int notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.startBreak(5, () {});

      // Assert
      expect(
          notificationCount, equals(1)); // One notification for starting break
    });

    test('should notifyListeners when timer pauses', () {
      // Arrange
      int notificationCount = 0;
      timerService.startTimer(25, () {});

      // Reset the counter after starting the timer
      notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.pauseTimer();

      // Assert
      expect(notificationCount, equals(1)); // One notification for pausing
    });

    test('should notifyListeners when timer resumes', () {
      // Arrange
      int notificationCount = 0;
      timerService.startTimer(25, () {});
      timerService.pauseTimer();

      // Reset the counter after starting and pausing
      notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.resumeTimer(() {});

      // Assert
      expect(notificationCount, equals(1)); // One notification for resuming
    });

    test('should notifyListeners when timer resets', () {
      // Arrange
      int notificationCount = 0;
      timerService.startTimer(25, () {});

      // Reset the counter after starting
      notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      // Act
      timerService.resetTimer(25);

      // Assert
      expect(notificationCount, equals(1)); // One notification for resetting
    });

    test('should call onComplete callback when timer completes', () {
      // Using fake_async to simulate time passage
      FakeAsync().run((fakeAsync) {
        // Arrange
        bool onCompleteWasCalled = false;
        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Create a timer with very short duration for testing
        timerService.startTimer(1, onComplete); // 1 minute

        // Fast-forward 61 seconds to ensure timer completes
        fakeAsync.elapse(const Duration(seconds: 61));

        // Assert
        expect(onCompleteWasCalled, isTrue);
      });
    });

    test('should change timer state to completed when timer ends', () {
      // Using fake_async to simulate time passage
      FakeAsync().run((fakeAsync) {
        // Arrange
        timerService.startTimer(1, () {}); // 1 minute

        // Fast-forward 61 seconds to ensure timer completes
        fakeAsync.elapse(const Duration(seconds: 61));

        // Assert
        expect(timerService.timerState.status, equals(TimerStatus.completed));
        expect(timerService.timerState.timeRemaining, equals(0));
        expect(timerService.timerState.progress, equals(0.0));
      });
    });

    test('should call onComplete callback when break timer completes', () {
      // Using fake_async to simulate time passage
      FakeAsync().run((fakeAsync) {
        // Arrange
        bool onCompleteWasCalled = false;
        void onComplete() {
          onCompleteWasCalled = true;
        }

        // Create a break timer with very short duration for testing
        timerService.startBreak(1, onComplete); // 1 minute

        // Fast-forward 61 seconds to ensure timer completes
        fakeAsync.elapse(const Duration(seconds: 61));

        // Assert
        expect(onCompleteWasCalled, isTrue);
      });
    });

    test('should update timer progress correctly during countdown', () {
      // Using fake_async to simulate time passage
      FakeAsync().run((fakeAsync) {
        // Arrange
        timerService.startTimer(1, () {}); // 1 minute

        // Act - Fast-forward 30 seconds
        fakeAsync.elapse(const Duration(seconds: 30));

        // Assert
        expect(timerService.timerState.timeRemaining, lessThan(60));
        expect(timerService.timerState.progress, lessThan(1.0));
      });
    });

    test('should notify listeners during countdown', () {
      // Using fake_async to simulate time passage
      FakeAsync().run((fakeAsync) {
        // Arrange
        int notificationCount = 0;
        timerService.startTimer(1, () {}); // 1 minute

        // Reset counter after start notification
        notificationCount = 0;
        timerService.addListener(() {
          notificationCount++;
        });

        // Act - Fast-forward several seconds to trigger notifications
        fakeAsync.elapse(const Duration(seconds: 3));

        // Assert
        expect(notificationCount,
            greaterThan(0)); // Should have notified at least once
      });
    });

    test('should not trigger additional callbacks after disposing service', () {
      // Arrange
      int notificationCount = 0;
      timerService.addListener(() {
        notificationCount++;
      });

      timerService.startTimer(25, () {});

      // Reset the counter after starting
      notificationCount = 0;

      // Act
      timerService.dispose();

      // Try to trigger notifications after dispose
      try {
        timerService.pauseTimer();
        timerService.resumeTimer(() {});
        timerService.resetTimer(25);
      } catch (e) {
        // Might throw if listeners can't be modified after dispose
      }

      // Assert
      expect(notificationCount, equals(0)); // No notifications after dispose
    });
  });
}
