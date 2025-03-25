import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import 'package:pomodoro_timemaster/widgets/statistics/stat_card.dart';

/// Stat cards component for the statistics screen
class StatCards extends StatelessWidget {
  final Map<String, double> stats;
  final bool showHours;

  const StatCards({
    Key? key,
    required this.stats,
    required this.showHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveUtils.getResponsiveHorizontalPadding(context).horizontal -
                4,
      ),
      child: isTablet
          ? Column(
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
                const SizedBox(height: ThemeConstants.smallSpacing - 4),
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
            )
          : Column(
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
                const SizedBox(height: ThemeConstants.smallSpacing - 4),
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
}
