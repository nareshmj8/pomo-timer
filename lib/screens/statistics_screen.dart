import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedCategory = 'All Categories';
  final List<String> categories = ['All Categories', 'Work', 'Study', 'Life'];
  bool showHours = true;

  // Consolidated data for both blocks and charts
  final Map<String, Map<String, List<double>>> statsData = {
    'Daily': {
      'hours': [2.5, 3.0, 2.8, 3.5, 2.0, 1.5, 4.0],
      'sessions': [3.0, 2.0, 3.0, 4.0, 2.0, 1.0, 5.0],
    },
    'Weekly': {
      'hours': [15.0, 14.5, 16.0, 13.5, 15.5, 14.0, 16.5],
      'sessions': [12.0, 11.0, 13.0, 10.0, 12.0, 11.0, 14.0],
    },
    'Monthly': {
      'hours': [45.5, 48.0, 42.5, 50.0, 47.5, 46.0, 49.0],
      'sessions': [35.0, 38.0, 33.0, 40.0, 37.0, 36.0, 39.0],
    },
    'Total': {
      'hours': [120.0], // Single value for total
      'sessions': [90.0],
    },
  };

  void _showCategoryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Category'),
          actions: categories
              .map(
                (category) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(category),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Statistics'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Category:',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showCategoryPicker(context),
                      child: Row(
                        children: [
                          Text(
                            selectedCategory,
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: CupertinoColors.activeBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
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
                              : CupertinoColors.inactiveGray,
                          fontWeight:
                              showHours ? FontWeight.bold : FontWeight.normal,
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
                              : CupertinoColors.inactiveGray,
                          fontWeight:
                              !showHours ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard('Today', showHours),
                        _buildStatCard('This Week', showHours),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('This Month', showHours),
                        _buildStatCard('Total', showHours),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildChartCard(
                      'Daily',
                      statsData['Daily']![showHours ? 'hours' : 'sessions']!,
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    ),
                    const SizedBox(height: 8),
                    _buildChartCard(
                      'Weekly',
                      statsData['Weekly']![showHours ? 'hours' : 'sessions']!,
                      ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
                    ),
                    const SizedBox(height: 8),
                    _buildChartCard(
                      'Monthly',
                      statsData['Monthly']![showHours ? 'hours' : 'sessions']!,
                      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, bool showHours) {
    double value;
    if (title == 'Today') {
      value = statsData['Daily']![showHours ? 'hours' : 'sessions']!.last;
    } else if (title == 'This Week') {
      value = statsData['Weekly']![showHours ? 'hours' : 'sessions']!.last;
    } else if (title == 'This Month') {
      value = statsData['Monthly']![showHours ? 'hours' : 'sessions']!.last;
    } else {
      value = statsData['Total']![showHours ? 'hours' : 'sessions']!.first;
    }

    String displayTitle;
    if (title == 'Today') {
      displayTitle = showHours ? "TODAY" : "TODAY";
    } else if (title == 'This Week') {
      displayTitle = showHours ? "THIS WEEK" : "THIS WEEK";
    } else if (title == 'This Month') {
      displayTitle = showHours ? "THIS MONTH" : "THIS MONTH";
    } else {
      displayTitle = showHours ? "TOTAL" : "TOTAL";
    }

    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey6.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.5,
                color: CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showHours
                  ? '${value.toStringAsFixed(1)}h'
                  : value.round().toString(),
              style: const TextStyle(
                fontSize: 30,
                color: CupertinoColors.label,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, List<double> data, List<String> titles) {
    String displayType = showHours ? 'HOURS' : 'SESSIONS';
    String displayTitle = '$title $displayType';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 0.5,
              color: CupertinoColors.label,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (data.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: CupertinoColors.activeBlue.withOpacity(0.8),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                          bottom: Radius.circular(0),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          showHours
                              ? value.toStringAsFixed(1)
                              : value.toInt().toString(),
                          style: const TextStyle(
                            color: CupertinoColors.label,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: CupertinoColors.separator.withOpacity(0.5),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
