import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/chart_data.dart';

void main() {
  group('ChartData', () {
    test('should be initialized with correct values', () {
      final date = DateTime(2023, 5, 15);
      const hours = 2.5;
      const sessions = 5.0;
      const isCurrentPeriod = true;

      final chartData = ChartData(
        date: date,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: isCurrentPeriod,
      );

      expect(chartData.date, equals(date));
      expect(chartData.hours, equals(hours));
      expect(chartData.sessions, equals(sessions));
      expect(chartData.isCurrentPeriod, equals(isCurrentPeriod));
    });

    test('should accept zero values', () {
      final date = DateTime(2023, 5, 16);
      const hours = 0.0;
      const sessions = 0.0;
      const isCurrentPeriod = false;

      final chartData = ChartData(
        date: date,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: isCurrentPeriod,
      );

      expect(chartData.date, equals(date));
      expect(chartData.hours, equals(0.0));
      expect(chartData.sessions, equals(0.0));
      expect(chartData.isCurrentPeriod, equals(false));
    });

    test('should handle large values', () {
      final date = DateTime(2023, 5, 17);
      const hours = 24.0; // Full day
      const sessions = 100.0; // Many sessions
      const isCurrentPeriod = true;

      final chartData = ChartData(
        date: date,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: isCurrentPeriod,
      );

      expect(chartData.date, equals(date));
      expect(chartData.hours, equals(24.0));
      expect(chartData.sessions, equals(100.0));
      expect(chartData.isCurrentPeriod, equals(true));
    });
  });
}
