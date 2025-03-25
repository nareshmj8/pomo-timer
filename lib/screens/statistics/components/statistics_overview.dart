import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import '../../../theme/theme_provider.dart';
import '../../../widgets/statistics/stat_card.dart';

class StatisticsOverview extends StatelessWidget {
  final Map<String, double> stats;
  final bool showHours;

  const StatisticsOverview({
    super.key,
    required this.stats,
    required this.showHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isLargeTablet = ResponsiveUtils.isLargeTablet(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeConstants.mediumSpacing,
        right: ThemeConstants.mediumSpacing,
        top: ThemeConstants.mediumSpacing,
        bottom: ThemeConstants.smallSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: ThemeConstants.smallSpacing,
              bottom: ThemeConstants.smallSpacing,
            ),
            child: Text(
              'Overview',
              style: TextStyle(
                fontSize: isTablet
                    ? ThemeConstants.largeFontSize + 2
                    : ThemeConstants.largeFontSize,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
            ),
          ),
          isTablet ? _buildTabletLayout(isLargeTablet) : _buildPhoneLayout(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(bool isLargeTablet) {
    // Calculate aspect ratio and spacing for consistent card sizes
    final cardAspectRatio = isLargeTablet ? 2.2 : 2.0;
    final spacing = isLargeTablet
        ? ThemeConstants.mediumSpacing
        : ThemeConstants.smallSpacing + 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLargeTablet ? 4 : 2,
      childAspectRatio: cardAspectRatio,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
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
    );
  }

  Widget _buildPhoneLayout() {
    // Improved spacing for consistent appearance
    const spacing = ThemeConstants.smallSpacing - 4;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Today',
                value: stats['today'] ?? 0,
                showHours: showHours,
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: StatCard(
                title: 'This Week',
                value: stats['week'] ?? 0,
                showHours: showHours,
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'This Month',
                value: stats['month'] ?? 0,
                showHours: showHours,
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: StatCard(
                title: 'Total',
                value: stats['total'] ?? 0,
                showHours: showHours,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
