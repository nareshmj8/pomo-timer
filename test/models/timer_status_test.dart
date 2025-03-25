import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';

void main() {
  group('TimerStatus', () {
    test('should have exactly 4 values', () {
      expect(TimerStatus.values.length, equals(4));
    });

    test('should have the correct enum values', () {
      expect(
          TimerStatus.values,
          containsAll([
            TimerStatus.idle,
            TimerStatus.running,
            TimerStatus.paused,
            TimerStatus.completed,
          ]));
    });

    test('should have the correct order of enum values', () {
      expect(TimerStatus.values[0], equals(TimerStatus.idle));
      expect(TimerStatus.values[1], equals(TimerStatus.running));
      expect(TimerStatus.values[2], equals(TimerStatus.paused));
      expect(TimerStatus.values[3], equals(TimerStatus.completed));
    });

    test('should convert to string correctly', () {
      expect(TimerStatus.idle.toString(), equals('TimerStatus.idle'));
      expect(TimerStatus.running.toString(), equals('TimerStatus.running'));
      expect(TimerStatus.paused.toString(), equals('TimerStatus.paused'));
      expect(TimerStatus.completed.toString(), equals('TimerStatus.completed'));
    });
  });
}
