import 'package:flutter/cupertino.dart';

/// Utility class for chart formatting functions
class ChartFormatting {
  /// Format a duration in hours to a readable string
  static String formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();
    int displayHours = totalMinutes ~/ 60;
    int displayMinutes = totalMinutes % 60;

    if (displayHours == 0) {
      return '${displayMinutes}m';
    } else if (displayMinutes == 0) {
      return '${displayHours}h';
    } else {
      return '${displayHours}h ${displayMinutes}m';
    }
  }

  /// Format a value based on whether it represents hours or sessions
  static String formatValue(double value, bool showHours,
      {bool forTooltip = false}) {
    if (showHours) {
      return formatDuration(value);
    }
    return forTooltip ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
  }

  /// Calculate the appropriate interval for the Y-axis based on the maximum value
  static double calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 4;
    if (maxY <= 50) return 10;
    return (maxY / 5).ceil().toDouble();
  }

  /// Get the gradient for chart bars
  static LinearGradient get barGradient => LinearGradient(
        colors: [
          CupertinoColors.systemBlue,
          CupertinoColors.systemBlue.withAlpha((0.8 * 255).toInt()),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Calculate the maximum Y value for a chart
  static double calculateMaxY(List<double> data) {
    if (data.isEmpty) return 5.0;
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return (maxValue * 1.2).ceilToDouble();
    return ((maxValue * 1.2) / 5).ceil() * 5.0;
  }
}
