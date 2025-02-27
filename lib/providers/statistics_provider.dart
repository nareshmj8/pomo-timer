import 'package:flutter/foundation.dart';
import '../models/chart_data.dart';
import '../models/history_entry.dart';

class StatisticsProvider with ChangeNotifier {
  static const int minutesPerHour = 60;

  double _minutesToHours(int minutes) {
    return minutes / minutesPerHour;
  }

  Map<String, double> getCategoryStats(
      List<HistoryEntry> history, String category) {
    var stats = history
        .where((entry) => entry.category == category)
        .fold<Map<String, double>>({'hours': 0, 'sessions': 0},
            (Map<String, double> acc, HistoryEntry entry) {
      acc['hours'] = (acc['hours'] ?? 0) + _minutesToHours(entry.duration);
      acc['sessions'] = (acc['sessions'] ?? 0) + 1;
      return acc;
    });
    return stats;
  }

  List<ChartData> getDailyData(List<HistoryEntry> history, String category) {
    final Map<DateTime, Map<String, double>> dailyStats = {};

    for (var entry in history.where((e) => e.category == category)) {
      final date = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      dailyStats.putIfAbsent(date, () => {'hours': 0, 'sessions': 0});
      dailyStats[date]!['hours'] =
          (dailyStats[date]!['hours'] ?? 0) + _minutesToHours(entry.duration);
      dailyStats[date]!['sessions'] = (dailyStats[date]!['sessions'] ?? 0) + 1;
    }

    return dailyStats.entries
        .map((e) => ChartData(
              date: e.key,
              hours: e.value['hours'] ?? 0,
              sessions: (e.value['sessions'] ?? 0).toInt(),
              isCurrentPeriod: e.key.day == DateTime.now().day,
            ))
        .toList();
  }

  // ... Add weekly and monthly data methods
}
