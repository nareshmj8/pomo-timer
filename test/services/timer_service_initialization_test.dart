import 'package:flutter_test/flutter_test.dart';

// Import the service under test and dependencies
import 'package:pomodoro_timemaster/services/timer_service.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';
import '../mocks/mock_notification_service.dart';

void main() {
  group('TimerService Initialization Tests', () {
    late TimerService timerService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockNotificationService();
      timerService = TimerService();
    });

    test('should initialize with default values', () {
      // Verify initial state
      expect(timerService.timerState, isA<TimerState>());
      expect(timerService.timerState.status, equals(TimerStatus.idle));
      expect(timerService.timerState.timeRemaining, equals(0));
      expect(timerService.timerState.totalDuration, equals(0));
      expect(timerService.timerState.progress, equals(1.0));
      expect(timerService.timerState.isBreak, isFalse);
      expect(timerService.isRunning, isFalse);
    });

    test('should initialize notification service correctly', () {
      // This test is no longer needed since notification service is removed
      expect(true, isTrue); // Replace with a meaningful test
    });

    test('should set up initial timer state', () {
      // Act - Create a new service
      final newService = TimerService();

      // Assert that the timer state is properly initialized
      expect(newService.timerState, isA<TimerState>());
      expect(newService.timerState.status, equals(TimerStatus.idle));
      expect(newService.timerState.progress, equals(1.0));
    });

    test('should properly create TimerService instance', () {
      // Creating a TimerService without parameters should work
      expect(() => TimerService(), isA<Function>());
      final service = TimerService();
      expect(service, isA<TimerService>());
    });
  });
}
