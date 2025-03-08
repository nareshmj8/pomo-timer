import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/statistics/stat_card.dart';
import '../widgets/statistics/chart_card.dart';
import '../models/chart_data.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedCategory = 'All Categories';
  final List<String> categories = ['All Categories', 'Work', 'Study', 'Life'];
  bool showHours = true;

  // Add dummy data
  List<ChartData> get dummyDailyData => [
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 6)),
            hours: 2.5,
            sessions: 6,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 5)),
            hours: 3.8,
            sessions: 9,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 4)),
            hours: 1.5,
            sessions: 4,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 3)),
            hours: 4.2,
            sessions: 10,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 2)),
            hours: 3.0,
            sessions: 7,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 1)),
            hours: 2.8,
            sessions: 6,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now(),
            hours: 3.5,
            sessions: 8,
            isCurrentPeriod: true),
      ];

  List<ChartData> get dummyWeeklyData => [
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 42)),
            hours: 12.5,
            sessions: 30,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 35)),
            hours: 15.8,
            sessions: 38,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 28)),
            hours: 10.5,
            sessions: 25,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 21)),
            hours: 18.2,
            sessions: 44,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 14)),
            hours: 14.0,
            sessions: 34,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now().subtract(const Duration(days: 7)),
            hours: 16.8,
            sessions: 40,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime.now(),
            hours: 20.5,
            sessions: 49,
            isCurrentPeriod: true),
      ];

  List<ChartData> get dummyMonthlyData => [
        ChartData(
            date: DateTime(2024, 1),
            hours: 45.5,
            sessions: 109,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 2),
            hours: 52.8,
            sessions: 127,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 3),
            hours: 38.5,
            sessions: 92,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 4),
            hours: 60.2,
            sessions: 144,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 5),
            hours: 48.0,
            sessions: 115,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 6),
            hours: 55.8,
            sessions: 134,
            isCurrentPeriod: false),
        ChartData(
            date: DateTime(2024, 7),
            hours: 65.5,
            sessions: 157,
            isCurrentPeriod: true),
      ];

  Map<String, double> get dummyStats => {
        'today': 3.5,
        'week': 20.5,
        'month': 65.5,
        'total': 366.3,
      };

  void _showCategoryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return CupertinoActionSheet(
              title: Text(
                'Select Category',
                style: TextStyle(
                  color: settings.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              message: Text(
                'Choose a category to filter your statistics',
                style: TextStyle(
                  color: settings.secondaryTextColor,
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
              actions: categories
                  .map(
                    (category) => CupertinoActionSheetAction(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                      isDefaultAction: category == selectedCategory,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: category == selectedCategory
                              ? CupertinoColors.activeBlue
                              : settings.textColor,
                          fontSize: 17,
                          fontWeight: category == selectedCategory
                              ? FontWeight.w600
                              : FontWeight.w400,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: settings.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final dailyData = settings.getDailyData(selectedCategory);
        final weeklyData = settings.getWeeklyData(selectedCategory);
        final monthlyData = settings.getMonthlyData(selectedCategory);
        final stats =
            settings.getCategoryStats(selectedCategory, showHours: showHours);

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Statistics',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
              ),
            ),
            backgroundColor: settings.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.separator.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySelector(),
                  _buildToggleButtons(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: settings.textColor,
                      ),
                    ),
                  ),
                  _buildStatCards(stats),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 24.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Trends',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: settings.textColor,
                      ),
                    ),
                  ),
                  _buildCharts(dailyData, weeklyData, monthlyData),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category:',
                style: TextStyle(
                  fontSize: 17,
                  color: settings.textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                color: settings.listTileBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                onPressed: () => _showCategoryPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCategory,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: () => setState(() => showHours = true),
                child: Text(
                  'Hours',
                  style: TextStyle(
                    fontSize: 16,
                    color: showHours
                        ? CupertinoColors.activeBlue
                        : settings.secondaryTextColor,
                    fontWeight: showHours ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: () => setState(() => showHours = false),
                child: Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 16,
                    color: !showHours
                        ? CupertinoColors.activeBlue
                        : settings.secondaryTextColor,
                    fontWeight: !showHours ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCards(Map<String, double> stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              StatCard(
                title: 'Today',
                value: stats['today'] ?? 0,
                showHours: showHours,
              ),
              StatCard(
                title: 'This Week',
                value: stats['week'] ?? 0,
                showHours: showHours,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StatCard(
                title: 'This Month',
                value: stats['month'] ?? 0,
                showHours: showHours,
              ),
              StatCard(
                title: 'Total',
                value: stats['total'] ?? 0,
                showHours: showHours,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(List<ChartData> dailyData, List<ChartData> weeklyData,
      List<ChartData> monthlyData) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = screenWidth * 0.04;

        // Reverse the data lists to show latest on the right
        final reversedDailyData = dailyData.reversed.toList();
        final reversedWeeklyData = weeklyData.reversed.toList();
        final reversedMonthlyData = monthlyData.reversed.toList();

        // Three-letter day names for daily chart
        final List<String> dayNames =
            ['Sun', 'Sat', 'Fri', 'Thu', 'Wed', 'Tue', 'Mon'].reversed.toList();

        // Generate simple week numbers (W1-W7) for display
        final List<String> weekLabels = List.generate(7, (i) => 'W${7 - i}');

        return Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: settings.separatorColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ChartCard(
                  title: 'Daily',
                  data: reversedDailyData
                      .map((d) => showHours ? d.hours : d.sessions.toDouble())
                      .toList(),
                  titles: dayNames,
                  showHours: showHours,
                  isLatest: (index) => reversedDailyData[index].isCurrentPeriod,
                  emptyBarColor: settings.separatorColor,
                  showEmptyBars: true,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: settings.separatorColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ChartCard(
                  title: 'Weekly',
                  data: reversedWeeklyData
                      .map((d) => showHours ? d.hours : d.sessions.toDouble())
                      .toList(),
                  titles: weekLabels,
                  showHours: showHours,
                  isLatest: (index) =>
                      reversedWeeklyData[index].isCurrentPeriod,
                  emptyBarColor: settings.separatorColor,
                  showEmptyBars: true,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: settings.separatorColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ChartCard(
                  title: 'Monthly',
                  data: reversedMonthlyData
                      .map((d) => showHours ? d.hours : d.sessions.toDouble())
                      .toList(),
                  titles: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']
                      .reversed
                      .toList(),
                  showHours: showHours,
                  isLatest: (index) =>
                      reversedMonthlyData[index].isCurrentPeriod,
                  emptyBarColor: settings.separatorColor,
                  showEmptyBars: true,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
