import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/chart_data.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import 'package:pomodoro_timemaster/widgets/premium_feature_blur.dart';
import 'package:pomodoro_timemaster/widgets/statistics/chart_card.dart';

/// Statistics charts component for the statistics screen
class StatisticsCharts extends StatelessWidget {
  final List<ChartData> dailyData;
  final List<ChartData> weeklyData;
  final List<ChartData> monthlyData;
  final bool showHours;

  const StatisticsCharts({
    Key? key,
    required this.dailyData,
    required this.weeklyData,
    required this.monthlyData,
    required this.showHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isTablet = ResponsiveUtils.isTablet(context);
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = screenWidth * (isTablet ? 0.05 : 0.04);

        // Reverse the data lists to show latest on the right
        final reversedDailyData = dailyData.reversed.toList();
        final reversedWeeklyData = weeklyData.reversed.toList();
        final reversedMonthlyData = monthlyData.reversed.toList();

        // Three-letter day names for daily chart
        final List<String> dayNames =
            ['Sun', 'Sat', 'Fri', 'Thu', 'Wed', 'Tue', 'Mon'].reversed.toList();

        // Generate simple week numbers (W1-W7) for display
        final List<String> weekLabels = List.generate(7, (i) => 'W${7 - i}');

        // Create the charts widget
        Widget chartsWidget;

        // For tablets, we can use a grid layout for charts
        if (isTablet) {
          chartsWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.mediumRadius),
                          boxShadow:
                              ThemeConstants.getShadow(settings.separatorColor),
                        ),
                        child: ChartCard(
                          title: 'Daily',
                          data: reversedDailyData
                              .map((d) =>
                                  showHours ? d.hours : d.sessions.toDouble())
                              .toList(),
                          titles: dayNames,
                          showHours: showHours,
                          isLatest: (index) =>
                              reversedDailyData[index].isCurrentPeriod,
                          emptyBarColor: settings.separatorColor,
                          showEmptyBars: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.mediumSpacing),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.mediumRadius),
                          boxShadow:
                              ThemeConstants.getShadow(settings.separatorColor),
                        ),
                        child: ChartCard(
                          title: 'Weekly',
                          data: reversedWeeklyData
                              .map((d) =>
                                  showHours ? d.hours : d.sessions.toDouble())
                              .toList(),
                          titles: weekLabels,
                          showHours: showHours,
                          isLatest: (index) =>
                              reversedWeeklyData[index].isCurrentPeriod,
                          emptyBarColor: settings.separatorColor,
                          showEmptyBars: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
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
              ],
            ),
          );
        } else {
          // For phones, we use a column layout
          chartsWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
                  ),
                  child: ChartCard(
                    title: 'Daily',
                    data: reversedDailyData
                        .map((d) => showHours ? d.hours : d.sessions.toDouble())
                        .toList(),
                    titles: dayNames,
                    showHours: showHours,
                    isLatest: (index) =>
                        reversedDailyData[index].isCurrentPeriod,
                    emptyBarColor: settings.separatorColor,
                    showEmptyBars: true,
                  ),
                ),
                const SizedBox(height: ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
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
                const SizedBox(height: ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
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
              ],
            ),
          );
        }

        // Wrap the charts with the premium feature blur
        return PremiumFeatureBlur(
          featureName: 'Detailed Charts',
          child: chartsWidget,
        );
      },
    );
  }
}
