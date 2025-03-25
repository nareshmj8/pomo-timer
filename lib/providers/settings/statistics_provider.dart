import 'package:flutter/foundation.dart';
import '../../models/chart_data.dart';
import '../../models/history_entry.dart';

/// Manages statistics calculations and data
class StatisticsProvider with ChangeNotifier {
  final List<HistoryEntry> _history;

  // Constants for time calculations
  static const double minutesPerHour = 60.0;

  StatisticsProvider(this._history);

  // Method that can be overridden in tests to provide a fixed date
  DateTime getNow() {
    return DateTime.now();
  }

  /// Convert minutes to hours
  double _minutesToHours(int minutes) {
    return minutes / minutesPerHour;
  }

  /// Calculate number of sessions based on duration
  double _calculateSessions(int minutes) {
    return minutes * 0.04; // Each minute is 0.04 sessions
  }

  /// Get daily data for the last 7 days
  List<ChartData> getDailyData(String category) {
    final now = getNow();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(dayStart) &&
            entry.timestamp.isBefore(dayEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: dayStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  /// Get weekly data for the last 7 weeks
  List<ChartData> getWeeklyData(String category) {
    final now = getNow();
    final List<ChartData> data = [];

    // Calculate the start of the current week (Monday)
    final currentWeekStart =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));

    for (int i = 6; i >= 0; i--) {
      // Calculate week start by going back i weeks from current week start
      final weekStart = i == 0
          ? currentWeekStart
          : currentWeekStart.subtract(Duration(days: 7 * i));

      final weekEnd = weekStart.add(const Duration(days: 7));

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(weekStart) &&
            entry.timestamp.isBefore(weekEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: weekStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  /// Get monthly data for the last 7 months
  List<ChartData> getMonthlyData(String category) {
    final now = getNow();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = i == 0
          ? DateTime(now.year, now.month + 1, 0)
          : DateTime(now.year, now.month - i + 1, 0);

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(monthStart) &&
            entry.timestamp.isBefore(monthEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: monthStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  /// Get statistics for a specific category
  Map<String, double> getCategoryStats(String category,
      {bool showHours = true}) {
    final now = getNow();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todayHours = 0;
    double weekHours = 0;
    double monthHours = 0;
    double totalHours = 0;
    double todaySessions = 0;
    double weekSessions = 0;
    double monthSessions = 0;
    double totalSessions = 0;

    for (var entry in _history) {
      if (category != 'All Categories' && entry.category != category) {
        continue;
      }

      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final hours = _minutesToHours(entry.duration);
      final sessions = _calculateSessions(entry.duration);

      if (entryDate.isAtSameMomentAs(today)) {
        todayHours += hours;
        todaySessions += sessions;
      }
      if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weekHours += hours;
        weekSessions += sessions;
      }
      if (entryDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        monthHours += hours;
        monthSessions += sessions;
      }
      totalHours += hours;
      totalSessions += sessions;
    }

    if (showHours) {
      return {
        'today': todayHours,
        'week': weekHours,
        'month': monthHours,
        'total': totalHours,
      };
    } else {
      return {
        'today': todaySessions,
        'week': weekSessions,
        'month': monthSessions,
        'total': totalSessions,
      };
    }
  }
}
