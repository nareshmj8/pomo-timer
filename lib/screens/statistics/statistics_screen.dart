import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/chart_data.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/providers/statistics_provider.dart';
import 'package:pomodoro_timemaster/providers/history_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/category_selector.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/toggle_buttons.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/stat_cards.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/statistics_charts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool showHours = true;
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer3<StatisticsProvider, HistoryProvider, SettingsProvider>(
      builder: (context, statsProvider, historyProvider, settings, child) {
        final isTablet = ResponsiveUtils.isTablet(context);
        final List<HistoryEntry> history = historyProvider.history;

        // Get available categories
        final List<String> categories = ['All', 'Work', 'Study', 'Personal'];

        // Filter history by category if not 'All'
        final List<HistoryEntry> filteredHistory = selectedCategory == 'All'
            ? history
            : history
                .where((entry) => entry.category == selectedCategory)
                .toList();

        // Get statistics data
        final Map<String, double> statsData =
            _calculateStats(filteredHistory, showHours);

        // Get chart data
        final List<ChartData> dailyData =
            statsProvider.getDailyData(filteredHistory, selectedCategory);
        final List<ChartData> weeklyData = _getWeeklyData(filteredHistory);
        final List<ChartData> monthlyData = _getMonthlyData(filteredHistory);

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: settings.backgroundColor,
            border: null,
            middle: Text(
              'Statistics',
              style: TextStyle(
                color: settings.textColor,
                fontSize: isTablet
                    ? ThemeConstants.largeFontSize
                    : ThemeConstants.mediumFontSize + 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                top: ThemeConstants.mediumSpacing,
                bottom: ThemeConstants.largeSpacing,
              ),
              children: [
                // Category selector
                CategorySelector(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),

                const SizedBox(height: ThemeConstants.mediumSpacing),

                // Toggle buttons for hours/sessions
                ToggleButtons(
                  showHours: showHours,
                  onToggle: (value) {
                    setState(() {
                      showHours = value;
                    });
                  },
                ),

                const SizedBox(height: ThemeConstants.mediumSpacing),

                // Stat cards
                StatCards(
                  stats: statsData,
                  showHours: showHours,
                ),

                const SizedBox(height: ThemeConstants.largeSpacing),

                // Section title for charts
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveUtils.getResponsiveHorizontalPadding(context)
                            .horizontal,
                  ),
                  child: Text(
                    'Trends',
                    style: TextStyle(
                      fontSize: isTablet
                          ? ThemeConstants.largeFontSize + 2
                          : ThemeConstants.largeFontSize,
                      fontWeight: FontWeight.w600,
                      color: settings.textColor,
                    ),
                  ),
                ),

                const SizedBox(height: ThemeConstants.mediumSpacing),

                // Charts
                StatisticsCharts(
                  dailyData: dailyData,
                  weeklyData: weeklyData,
                  monthlyData: monthlyData,
                  showHours: showHours,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to calculate statistics
  Map<String, double> _calculateStats(
      List<HistoryEntry> history, bool showHours) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todayValue = 0;
    double weekValue = 0;
    double monthValue = 0;
    double totalValue = 0;

    for (var entry in history) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final value = showHours
          ? entry.duration / 60 // Convert minutes to hours
          : 1.0; // Count as one session

      // Add to total
      totalValue += value;

      // Check if entry is from today
      if (entryDate.isAtSameMomentAs(today)) {
        todayValue += value;
      }

      // Check if entry is from this week
      if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weekValue += value;
      }

      // Check if entry is from this month
      if (entryDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        monthValue += value;
      }
    }

    return {
      'today': todayValue,
      'week': weekValue,
      'month': monthValue,
      'total': totalValue,
    };
  }

  // Helper method to get weekly data
  List<ChartData> _getWeeklyData(List<HistoryEntry> history) {
    final now = DateTime.now();
    final List<ChartData> weeklyData = [];

    // Create data for the last 7 weeks
    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));

      double hours = 0;
      int sessions = 0;

      for (var entry in history) {
        if (entry.timestamp
                .isAfter(weekStart.subtract(const Duration(days: 1))) &&
            entry.timestamp.isBefore(weekEnd.add(const Duration(days: 1)))) {
          hours += entry.duration / 60; // Convert minutes to hours
          sessions++;
        }
      }

      weeklyData.add(ChartData(
        date: weekStart,
        hours: hours,
        sessions: sessions.toDouble(),
        isCurrentPeriod: i == 0,
      ));
    }

    return weeklyData;
  }

  // Helper method to get monthly data
  List<ChartData> _getMonthlyData(List<HistoryEntry> history) {
    final now = DateTime.now();
    final List<ChartData> monthlyData = [];

    // Create data for the last 7 months
    for (int i = 6; i >= 0; i--) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;

      final monthStart = DateTime(year, adjustedMonth, 1);
      final monthEnd =
          DateTime(year, adjustedMonth + 1, 0); // Last day of month

      double hours = 0;
      int sessions = 0;

      for (var entry in history) {
        if (entry.timestamp
                .isAfter(monthStart.subtract(const Duration(days: 1))) &&
            entry.timestamp.isBefore(monthEnd.add(const Duration(days: 1)))) {
          hours += entry.duration / 60; // Convert minutes to hours
          sessions++;
        }
      }

      monthlyData.add(ChartData(
        date: monthStart,
        hours: hours,
        sessions: sessions.toDouble(),
        isCurrentPeriod: i == 0,
      ));
    }

    return monthlyData;
  }
}
