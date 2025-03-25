import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/widgets/statistics/utils/chart_formatting.dart';

void main() {
  group('ChartFormatting', () {
    group('formatDuration', () {
      test('should format hours only correctly', () {
        expect(ChartFormatting.formatDuration(2.0), '2h');
        expect(ChartFormatting.formatDuration(1.0), '1h');
      });

      test('should format minutes only correctly', () {
        expect(ChartFormatting.formatDuration(0.5), '30m');
        expect(ChartFormatting.formatDuration(0.25), '15m');
      });

      test('should format hours and minutes correctly', () {
        expect(ChartFormatting.formatDuration(1.5), '1h 30m');
        expect(ChartFormatting.formatDuration(2.75), '2h 45m');
      });

      test('should handle zero correctly', () {
        expect(ChartFormatting.formatDuration(0.0), '0m');
      });

      test('should round to nearest minute', () {
        expect(ChartFormatting.formatDuration(1.01), '1h 1m');
        expect(ChartFormatting.formatDuration(0.99), '59m');
      });
    });

    group('formatValue', () {
      test('should format hours correctly', () {
        expect(ChartFormatting.formatValue(2.5, true), '2h 30m');
        expect(ChartFormatting.formatValue(0.75, true), '45m');
      });

      test('should format sessions with no decimal places by default', () {
        expect(ChartFormatting.formatValue(2.5, false), '3');
        expect(ChartFormatting.formatValue(2.4, false), '2');
      });

      test('should format sessions with 1 decimal place for tooltips', () {
        expect(
            ChartFormatting.formatValue(2.5, false, forTooltip: true), '2.5');
        expect(
            ChartFormatting.formatValue(2.42, false, forTooltip: true), '2.4');
      });
    });

    group('calculateInterval', () {
      test('should return appropriate interval based on max value', () {
        expect(ChartFormatting.calculateInterval(3.0), 1.0);
        expect(ChartFormatting.calculateInterval(5.0), 1.0);
        expect(ChartFormatting.calculateInterval(8.0), 2.0);
        expect(ChartFormatting.calculateInterval(10.0), 2.0);
        expect(ChartFormatting.calculateInterval(15.0), 4.0);
        expect(ChartFormatting.calculateInterval(20.0), 4.0);
        expect(ChartFormatting.calculateInterval(30.0), 10.0);
        expect(ChartFormatting.calculateInterval(50.0), 10.0);
        expect(ChartFormatting.calculateInterval(60.0), 12.0);
        expect(ChartFormatting.calculateInterval(100.0), 20.0);
      });
    });

    group('barGradient', () {
      test('should have correct gradient properties', () {
        final gradient = ChartFormatting.barGradient;
        expect(gradient, isA<LinearGradient>());
        expect(gradient.colors.length, 2);
        expect(gradient.colors[0], CupertinoColors.systemBlue);
        expect(gradient.colors[1].alpha, (0.8 * 255).toInt());
        expect(gradient.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
      });
    });

    group('calculateMaxY', () {
      test('should return 5.0 for empty data', () {
        expect(ChartFormatting.calculateMaxY([]), 5.0);
      });

      test('should scale small values by 1.2x and round up to nearest integer',
          () {
        expect(ChartFormatting.calculateMaxY([3.0, 2.0, 4.0]), 5.0);
        expect(ChartFormatting.calculateMaxY([8.0, 4.0, 6.0]), 10.0);
      });

      test(
          'should scale large values by 1.2x and round up to nearest multiple of 5',
          () {
        expect(ChartFormatting.calculateMaxY([15.0, 8.0, 10.0]), 20.0);
        expect(ChartFormatting.calculateMaxY([45.0, 30.0, 20.0]), 55.0);
      });
    });
  });
}
