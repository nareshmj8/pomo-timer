import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timemaster/models/chart_data.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/providers/settings/statistics_provider.dart';

// Create a test wrapper for DateTime.now() so we can test with a fixed date
class TestableStatisticsProvider extends StatisticsProvider {
  final DateTime _fixedNow;

  TestableStatisticsProvider(List<HistoryEntry> history, this._fixedNow)
      : super(history);

  // Override to provide a fixed "now" for testing
  @override
  DateTime getNow() {
    return _fixedNow;
  }
}

void main() {
  late TestableStatisticsProvider provider;
  late List<HistoryEntry> testHistory;
  final referenceDate = DateTime(2023, 5, 15); // May 15, 2023 (Monday)

  // Helper to create a date relative to the reference date
  DateTime dateOffset(int days) {
    return referenceDate.add(Duration(days: days));
  }

  setUp(() {
    // Setup test history data
    testHistory = [
      // Today (reference date)
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: dateOffset(0).add(const Duration(hours: 9)),
      ),
      HistoryEntry(
        category: 'Work',
        duration: 30,
        timestamp: dateOffset(0).add(const Duration(hours: 14)),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 45,
        timestamp: dateOffset(0).add(const Duration(hours: 18)),
      ),

      // Yesterday
      HistoryEntry(
        category: 'Work',
        duration: 50,
        timestamp: dateOffset(-1).add(const Duration(hours: 10)),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 25,
        timestamp: dateOffset(-1).add(const Duration(hours: 15)),
      ),

      // Last week
      HistoryEntry(
        category: 'Personal',
        duration: 35,
        timestamp: dateOffset(-7).add(const Duration(hours: 16)),
      ),

      // Last month
      HistoryEntry(
        category: 'Work',
        duration: 40,
        timestamp: dateOffset(-35).add(const Duration(hours: 11)),
      ),
    ];

    provider = TestableStatisticsProvider(testHistory, referenceDate);
  });

  group('StatisticsProvider Initialization', () {
    test('should initialize with provided history data', () {
      expect(provider, isNotNull);
    });
  });

  group('StatisticsProvider Time Calculations', () {
    test('should convert minutes to hours correctly', () {
      // We can only test indirectly by checking output of other methods
      final dailyData = provider.getDailyData('Work');

      // Check hours calculation for work entries on reference date
      // 25 + 30 minutes = 55 minutes = 55/60 = 0.9166... hours
      final todayHours = dailyData.firstWhere((d) => d.isCurrentPeriod).hours;
      expect(todayHours, closeTo(55 / 60, 0.001));
    });

    test('should calculate sessions correctly', () {
      // Each minute is 0.04 sessions
      // Test indirectly through other methods
      final stats = provider.getCategoryStats('Work', showHours: false);

      // For Work category on reference date: 25 + 30 = 55 minutes
      // 55 * 0.04 = 2.2 sessions
      expect(stats['today'], closeTo(55 * 0.04, 0.001));
    });
  });

  group('StatisticsProvider Data Calculations', () {
    test('should calculate daily data correctly', () {
      // Test for Work category
      final workData = provider.getDailyData('Work');

      // Should have 7 days of data
      expect(workData.length, 7);

      // Check data for reference date (today)
      final todayData = workData.firstWhere((d) => d.isCurrentPeriod);
      expect(todayData.hours, closeTo(55 / 60, 0.001)); // 25 + 30 = 55 minutes
      expect(todayData.sessions, closeTo(55 * 0.04, 0.001));
      expect(todayData.isCurrentPeriod, isTrue);

      // Check data for yesterday
      final yesterdayData = workData[workData.length - 2]; // Second to last
      expect(yesterdayData.hours, closeTo(50 / 60, 0.001)); // 50 minutes
      expect(yesterdayData.sessions, closeTo(50 * 0.04, 0.001));
      expect(yesterdayData.isCurrentPeriod, isFalse);

      // Test for All Categories
      final allData = provider.getDailyData('All Categories');
      final allTodayData = allData.firstWhere((d) => d.isCurrentPeriod);
      expect(allTodayData.hours,
          closeTo((25 + 30 + 45) / 60, 0.001)); // Total minutes for today
      expect(allTodayData.sessions, closeTo((25 + 30 + 45) * 0.04, 0.001));
    });

    test('should calculate weekly data correctly', () {
      final workData = provider.getWeeklyData('Work');

      // Should have 7 weeks of data
      expect(workData.length, 7);

      // Get the current week data
      final currentWeekData = workData.firstWhere((d) => d.isCurrentPeriod);

      // Based on our test data and the actual implementation,
      // only today's work entries are counted for current week
      // The implementation uses weekday to determine the current week
      expect(currentWeekData.hours,
          closeTo(55 / 60, 0.001)); // Just today's entries: 25 + 30
      expect(currentWeekData.sessions, closeTo(55 * 0.04, 0.001));
      expect(currentWeekData.isCurrentPeriod, isTrue);
    });

    test('should calculate monthly data correctly', () {
      final workData = provider.getMonthlyData('Work');

      // Should have 7 months of data
      expect(workData.length, 7);

      // Current month should include current month work entries
      final currentMonthData = workData.firstWhere((d) => d.isCurrentPeriod);
      // Work entries this month: 25 + 30 + 50 = 105 minutes
      expect(currentMonthData.hours, closeTo(105 / 60, 0.001));
      expect(currentMonthData.sessions, closeTo(105 * 0.04, 0.001));
      expect(currentMonthData.isCurrentPeriod, isTrue);
    });
  });

  group('StatisticsProvider Category Stats', () {
    test('should calculate category stats in hours correctly', () {
      final workStats = provider.getCategoryStats('Work', showHours: true);

      // Today: 25 + 30 = 55 minutes = 0.9166... hours
      expect(workStats['today'], closeTo(55 / 60, 0.001));

      // Based on implementation, this includes only today's entries
      expect(workStats['week'], closeTo(55 / 60, 0.001));

      // Total: 25 + 30 + 50 + 40 = 145 minutes = 2.4166... hours
      expect(workStats['total'], closeTo(145 / 60, 0.001));
    });

    test('should calculate category stats in sessions correctly', () {
      final workStats = provider.getCategoryStats('Work', showHours: false);

      // Today: 25 + 30 = 55 minutes = 55 * 0.04 = 2.2 sessions
      expect(workStats['today'], closeTo(55 * 0.04, 0.001));

      // Based on implementation, this includes only today's entries
      expect(workStats['week'], closeTo(55 * 0.04, 0.001));

      // Total: 25 + 30 + 50 + 40 = 145 minutes = 145 * 0.04 = 5.8 sessions
      expect(workStats['total'], closeTo(145 * 0.04, 0.001));
    });

    test('should handle all categories stats calculation', () {
      final allStats =
          provider.getCategoryStats('All Categories', showHours: true);

      // Today: all categories = 25 + 30 + 45 = 100 minutes = 1.6666... hours
      expect(allStats['today'], closeTo(100 / 60, 0.001));

      // Based on implementation, this includes only today's entries
      expect(allStats['week'], closeTo(100 / 60, 0.001));

      // Total: all entries = 25 + 30 + 45 + 50 + 25 + 35 + 40 = 250 minutes = 4.1666... hours
      expect(allStats['total'], closeTo(250 / 60, 0.001));
    });
  });

  group('StatisticsProvider Edge Cases', () {
    test('should handle empty history', () {
      final emptyProvider = TestableStatisticsProvider([], referenceDate);

      final dailyData = emptyProvider.getDailyData('Work');
      expect(dailyData.length, 7); // Still returns 7 days
      expect(dailyData.every((d) => d.hours == 0), isTrue);
      expect(dailyData.every((d) => d.sessions == 0), isTrue);

      final stats = emptyProvider.getCategoryStats('Work');
      expect(stats['today'], 0);
      expect(stats['week'], 0);
      expect(stats['month'], 0);
      expect(stats['total'], 0);
    });

    test('should handle non-existent category', () {
      final nonExistentData = provider.getDailyData('NonExistentCategory');
      expect(nonExistentData.length, 7);
      expect(nonExistentData.every((d) => d.hours == 0), isTrue);

      final stats = provider.getCategoryStats('NonExistentCategory');
      expect(stats['today'], 0);
      expect(stats['total'], 0);
    });
  });
}
