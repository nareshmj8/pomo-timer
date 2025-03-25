import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/models/statistics_data.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class StatisticsCards extends StatelessWidget {
  final StatisticsData statsData;
  final bool showHours;

  const StatisticsCards({
    super.key,
    required this.statsData,
    required this.showHours,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildStatCard(String title, bool showHours) {
    double value;
    if (title == 'Today') {
      value = statsData.data['Daily']![showHours ? 'hours' : 'sessions']!.last;
    } else if (title == 'This Week') {
      value = statsData.data['Weekly']![showHours ? 'hours' : 'sessions']!.last;
    } else if (title == 'This Month') {
      value =
          statsData.data['Monthly']![showHours ? 'hours' : 'sessions']!.last;
    } else {
      value = statsData.data['Total']![showHours ? 'hours' : 'sessions']!.first;
    }

    String displayTitle = title.toUpperCase();

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
              color: CupertinoColors.systemGrey6
                  .withAlpha(ThemeConstants.opacityToAlpha(0.2)),
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
}
