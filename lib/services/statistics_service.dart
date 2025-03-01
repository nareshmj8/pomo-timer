import '../models/chart_data.dart';
import '../models/history_entry.dart';

class StatisticsService {
  static const int defaultSessionMinutes = 25;
  static const int minutesPerHour = 60;

  double _minutesToHours(int minutes) {
    return minutes / minutesPerHour;
  }

  Map<String, double> getCategoryStats(
      List<HistoryEntry> history, String category) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todayHours = 0;
    double weekHours = 0;
    double monthHours = 0;
    double totalHours = 0;

    for (var entry in history) {
      if (category != 'All Categories' && entry.category != category) {
        continue;
      }

      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final sessionHours = _minutesToHours(entry.duration);

      if (entryDate == today) {
        todayHours += sessionHours;
      }
      if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weekHours += sessionHours;
      }
      if (entryDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        monthHours += sessionHours;
      }
      totalHours += sessionHours;
    }

    return {
      'today': todayHours,
      'week': weekHours,
      'month': monthHours,
      'total': totalHours,
    };
  }

  List<ChartData> getDailyData(List<HistoryEntry> history, String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      double hours = 0;
      double sessions = 0;

      for (var entry in history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(dayStart) &&
            entry.timestamp.isBefore(dayEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions +=
              (entry.duration / defaultSessionMinutes).floor().toDouble();
        }
      }

      data.add(ChartData(
        date: dayStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  List<ChartData> getWeeklyData(List<HistoryEntry> history, String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      double hours = 0;
      double sessions = 0;

      for (var entry in history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(weekStart) &&
            entry.timestamp.isBefore(weekEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions +=
              (entry.duration / defaultSessionMinutes).floor().toDouble();
        }
      }

      data.add(ChartData(
        date: weekStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  List<ChartData> getMonthlyData(List<HistoryEntry> history, String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      double hours = 0;
      double sessions = 0;

      for (var entry in history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(monthStart) &&
            entry.timestamp.isBefore(monthEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions +=
              (entry.duration / defaultSessionMinutes).floor().toDouble();
        }
      }

      data.add(ChartData(
        date: monthStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }
}
