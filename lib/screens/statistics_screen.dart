import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/statistics/stat_card.dart';
import '../widgets/statistics/chart_card.dart';
import '../models/chart_data.dart';
import '../utils/responsive_utils.dart';
import '../utils/theme_constants.dart';
import '../widgets/premium_feature_blur.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedCategory = 'All Categories';
  final List<String> categories = ['All Categories', 'Work', 'Study', 'Life'];
  bool showHours = true;

  // Add a key to force refresh when data changes
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Refresh data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // Method to refresh statistics data
  Future<void> _refreshData() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.refreshData();
    setState(() {
      // This will trigger a rebuild with the latest data
    });
  }

  void _showCategoryPicker(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

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
                  fontSize: isTablet
                      ? ThemeConstants.mediumFontSize
                      : ThemeConstants.smallFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              message: Text(
                'Choose a category to filter your statistics',
                style: TextStyle(
                  color: settings.secondaryTextColor,
                  fontSize: isTablet
                      ? ThemeConstants.smallFontSize
                      : ThemeConstants.smallFontSize - 1,
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
                          fontSize: isTablet
                              ? ThemeConstants.mediumFontSize + 1
                              : ThemeConstants.mediumFontSize,
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
                    fontSize: isTablet
                        ? ThemeConstants.mediumFontSize
                        : ThemeConstants.mediumFontSize - 1,
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

        final isTablet = ResponsiveUtils.isTablet(context);
        final screenSize = MediaQuery.of(context).size;
        final isExtraSmallScreen = screenSize.width < 375;

        final padding = ResponsiveUtils.getResponsivePadding(context);

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Statistics',
              style: TextStyle(
                fontSize: isTablet
                    ? ThemeConstants.mediumFontSize + 1
                    : isExtraSmallScreen
                        ? ThemeConstants.mediumFontSize - 1
                        : ThemeConstants.mediumFontSize,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
              ),
            ),
            backgroundColor: settings.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.separator
                    .withAlpha((ThemeConstants.lowOpacity * 255).toInt()),
                width: ThemeConstants.thinBorder,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _refreshData,
              child: Icon(
                CupertinoIcons.refresh,
                color: CupertinoColors.activeBlue,
                size: isTablet ? 22.0 : 20.0,
              ),
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshData,
              color: CupertinoColors.activeBlue,
              backgroundColor: settings.backgroundColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySelector(),
                    _buildToggleButtons(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding.horizontal,
                        vertical: isExtraSmallScreen
                            ? ThemeConstants.smallSpacing - 2
                            : ThemeConstants.smallSpacing,
                      ),
                      child: Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: isTablet
                              ? ThemeConstants.largeFontSize + 2
                              : isExtraSmallScreen
                                  ? ThemeConstants.largeFontSize - 2
                                  : ThemeConstants.largeFontSize,
                          fontWeight: FontWeight.w600,
                          color: settings.textColor,
                        ),
                      ),
                    ),
                    _buildStatCards(stats),
                    Padding(
                      padding: EdgeInsets.only(
                        left: padding.horizontal,
                        right: padding.horizontal,
                        top: isTablet
                            ? ThemeConstants.largeSpacing
                            : isExtraSmallScreen
                                ? ThemeConstants.mediumSpacing
                                : ThemeConstants.mediumSpacing + 8,
                        bottom: isExtraSmallScreen
                            ? ThemeConstants.smallSpacing - 2
                            : ThemeConstants.smallSpacing,
                      ),
                      child: Text(
                        'Trends',
                        style: TextStyle(
                          fontSize: isTablet
                              ? ThemeConstants.largeFontSize + 2
                              : isExtraSmallScreen
                                  ? ThemeConstants.largeFontSize - 2
                                  : ThemeConstants.largeFontSize,
                          fontWeight: FontWeight.w600,
                          color: settings.textColor,
                        ),
                      ),
                    ),
                    _buildCharts(dailyData, weeklyData, monthlyData),
                    SizedBox(
                        height: isTablet
                            ? ThemeConstants.largeSpacing
                            : isExtraSmallScreen
                                ? ThemeConstants.mediumSpacing - 4
                                : ThemeConstants.mediumSpacing),
                  ],
                ),
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
        final isTablet = ResponsiveUtils.isTablet(context);
        final screenSize = MediaQuery.of(context).size;
        final isExtraSmallScreen = screenSize.width < 375;
        final isLandscape = screenSize.width > screenSize.height;

        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);

        final labelFontSize = isTablet
            ? ThemeConstants.mediumFontSize + 1
            : isExtraSmallScreen
                ? ThemeConstants.smallFontSize + 1
                : ThemeConstants.mediumFontSize;

        final categoryFontSize = isTablet
            ? ThemeConstants.mediumFontSize
            : isExtraSmallScreen
                ? ThemeConstants.smallFontSize
                : ThemeConstants.mediumFontSize - 1;

        final buttonPadding = isTablet
            ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0)
            : isExtraSmallScreen
                ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0)
                : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

        final borderRadius = isTablet
            ? ThemeConstants.mediumRadius
            : isExtraSmallScreen
                ? ThemeConstants.smallRadius - 2
                : ThemeConstants.smallRadius;

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: padding.horizontal,
              vertical: isExtraSmallScreen
                  ? ThemeConstants.smallSpacing
                  : ThemeConstants.smallSpacing + 4),
          child: isLandscape && !isTablet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category:',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: settings.textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    CupertinoButton(
                      padding: buttonPadding,
                      color: settings.listTileBackgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      onPressed: () => _showCategoryPicker(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedCategory,
                            style: TextStyle(
                              fontSize: categoryFontSize,
                              color: CupertinoColors.activeBlue,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(
                              width: isTablet
                                  ? ThemeConstants.smallSpacing
                                  : isExtraSmallScreen
                                      ? ThemeConstants.tinySpacing
                                      : ThemeConstants.tinySpacing + 2),
                          Container(
                            padding: EdgeInsets.all(isTablet
                                ? ThemeConstants.smallSpacing - 4
                                : isExtraSmallScreen
                                    ? ThemeConstants.tinySpacing - 1
                                    : ThemeConstants.tinySpacing),
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue.withAlpha(
                                  ThemeConstants.opacityToAlpha(
                                      ThemeConstants.veryLowOpacity)),
                              borderRadius: BorderRadius.circular(isTablet
                                  ? ThemeConstants.smallSpacing - 2
                                  : isExtraSmallScreen
                                      ? ThemeConstants.tinySpacing
                                      : ThemeConstants.tinySpacing + 2),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_down,
                              size: isTablet
                                  ? ThemeConstants.smallIconSize
                                  : isExtraSmallScreen
                                      ? ThemeConstants.smallIconSize - 4
                                      : ThemeConstants.smallIconSize - 2,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category:',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: settings.textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isExtraSmallScreen ? 6.0 : 8.0),
                    CupertinoButton(
                      padding: buttonPadding,
                      color: settings.listTileBackgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      onPressed: () => _showCategoryPicker(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedCategory,
                            style: TextStyle(
                              fontSize: categoryFontSize,
                              color: CupertinoColors.activeBlue,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(
                              width: isTablet
                                  ? ThemeConstants.smallSpacing
                                  : isExtraSmallScreen
                                      ? ThemeConstants.tinySpacing
                                      : ThemeConstants.tinySpacing + 2),
                          Container(
                            padding: EdgeInsets.all(isTablet
                                ? ThemeConstants.smallSpacing - 4
                                : isExtraSmallScreen
                                    ? ThemeConstants.tinySpacing - 1
                                    : ThemeConstants.tinySpacing),
                            decoration: BoxDecoration(
                              color: CupertinoColors.activeBlue.withAlpha(
                                  ThemeConstants.opacityToAlpha(
                                      ThemeConstants.veryLowOpacity)),
                              borderRadius: BorderRadius.circular(isTablet
                                  ? ThemeConstants.smallSpacing - 2
                                  : isExtraSmallScreen
                                      ? ThemeConstants.tinySpacing
                                      : ThemeConstants.tinySpacing + 2),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_down,
                              size: isTablet
                                  ? ThemeConstants.smallIconSize
                                  : isExtraSmallScreen
                                      ? ThemeConstants.smallIconSize - 4
                                      : ThemeConstants.smallIconSize - 2,
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
        final isTablet = ResponsiveUtils.isTablet(context);
        final screenSize = MediaQuery.of(context).size;
        final isExtraSmallScreen = screenSize.width < 375;

        final toggleFontSize = isTablet
            ? ThemeConstants.mediumFontSize + 1
            : isExtraSmallScreen
                ? ThemeConstants.smallFontSize + 1
                : ThemeConstants.mediumFontSize;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveHorizontalPadding(context)
                .horizontal,
            vertical: isExtraSmallScreen ? 4.0 : 8.0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? ThemeConstants.mediumSpacing - 6
                          : isExtraSmallScreen
                              ? ThemeConstants.smallSpacing
                              : ThemeConstants.smallSpacing + 2,
                      vertical: isExtraSmallScreen ? 4.0 : 8.0,
                    ),
                    onPressed: () => setState(() => showHours = true),
                    child: Text(
                      'Hours',
                      style: TextStyle(
                        fontSize: toggleFontSize,
                        color: showHours
                            ? CupertinoColors.activeBlue
                            : settings.secondaryTextColor,
                        fontWeight:
                            showHours ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? ThemeConstants.mediumSpacing - 6
                          : isExtraSmallScreen
                              ? ThemeConstants.smallSpacing
                              : ThemeConstants.smallSpacing + 2,
                      vertical: isExtraSmallScreen ? 4.0 : 8.0,
                    ),
                    onPressed: () => setState(() => showHours = false),
                    child: Text(
                      'Sessions',
                      style: TextStyle(
                        fontSize: toggleFontSize,
                        color: !showHours
                            ? CupertinoColors.activeBlue
                            : settings.secondaryTextColor,
                        fontWeight:
                            !showHours ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              if (!showHours)
                Padding(
                  padding: EdgeInsets.only(top: isExtraSmallScreen ? 2.0 : 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: isExtraSmallScreen ? 2.0 : 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: settings.isDarkTheme
                          ? CupertinoColors.systemGrey6.darkColor
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      '25 min = 1 session',
                      style: TextStyle(
                        fontSize: isTablet
                            ? ThemeConstants.smallFontSize
                            : isExtraSmallScreen
                                ? ThemeConstants.smallFontSize - 1
                                : ThemeConstants.smallFontSize,
                        color: settings.textColor,
                        fontWeight: FontWeight.w600,
                      ),
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
    final isTablet = ResponsiveUtils.isTablet(context);
    final screenSize = MediaQuery.of(context).size;
    final isExtraSmallScreen = screenSize.width < 375;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            ResponsiveUtils.getResponsiveHorizontalPadding(context).horizontal -
                (isExtraSmallScreen ? 2 : 4),
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
                SizedBox(
                    height: isExtraSmallScreen
                        ? ThemeConstants.smallSpacing - 6
                        : ThemeConstants.smallSpacing - 4),
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
                SizedBox(
                    height: isExtraSmallScreen
                        ? ThemeConstants.smallSpacing - 6
                        : ThemeConstants.smallSpacing - 4),
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
        final isTablet = ResponsiveUtils.isTablet(context);
        final screenSize = MediaQuery.of(context).size;
        final isExtraSmallScreen = screenSize.width < 375;
        final horizontalPadding = screenSize.width *
            (isTablet
                ? 0.05
                : isExtraSmallScreen
                    ? 0.03
                    : 0.04);

        // IMPORTANT: The ChartCard widget internally reverses the data for display,
        // so we need to ensure the data is in chronological order (oldest to newest)
        // The StatisticsProvider already returns data in chronological order (oldest first)
        final orderedDailyData = List<ChartData>.from(dailyData);
        final orderedWeeklyData = List<ChartData>.from(weeklyData);
        final orderedMonthlyData = List<ChartData>.from(monthlyData);

        // Generate day labels in chronological order (oldest to newest)
        // These will be reversed by the ChartCard
        final List<String> dayLabels = List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          return [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun'
          ][date.weekday - 1];
        });

        // Generate week labels in chronological order
        final List<String> weekLabels = List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: (6 - index) * 7));
          int weekNumber = _getWeekNumber(date);
          return 'W$weekNumber';
        });

        // Generate month labels in chronological order
        final List<String> monthLabels = List.generate(7, (index) {
          final date =
              DateTime.now().subtract(Duration(days: (6 - index) * 30));
          return [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ][date.month - 1];
        });

        // Create the charts widget
        Widget chartsWidget;

        // For tablets or landscape mode, we can use a grid layout for charts
        if (isTablet ||
            (screenSize.width > screenSize.height && !isExtraSmallScreen)) {
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
                          borderRadius: BorderRadius.circular(isExtraSmallScreen
                              ? ThemeConstants.smallRadius
                              : ThemeConstants.mediumRadius),
                          boxShadow:
                              ThemeConstants.getShadow(settings.separatorColor),
                        ),
                        child: ChartCard(
                          title: 'Daily',
                          data: orderedDailyData
                              .map((d) =>
                                  showHours ? d.hours : d.sessions.toDouble())
                              .toList(),
                          titles: dayLabels,
                          showHours: showHours,
                          isLatest: (index) =>
                              orderedDailyData[index].isCurrentPeriod,
                          emptyBarColor: settings.separatorColor,
                          showEmptyBars: true,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: isExtraSmallScreen
                            ? ThemeConstants.smallSpacing
                            : ThemeConstants.mediumSpacing),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isExtraSmallScreen
                              ? ThemeConstants.smallRadius
                              : ThemeConstants.mediumRadius),
                          boxShadow:
                              ThemeConstants.getShadow(settings.separatorColor),
                        ),
                        child: ChartCard(
                          title: 'Weekly',
                          data: orderedWeeklyData
                              .map((d) =>
                                  showHours ? d.hours : d.sessions.toDouble())
                              .toList(),
                          titles: weekLabels,
                          showHours: showHours,
                          isLatest: (index) =>
                              orderedWeeklyData[index].isCurrentPeriod,
                          emptyBarColor: settings.separatorColor,
                          showEmptyBars: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: isExtraSmallScreen
                        ? ThemeConstants.smallSpacing
                        : ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isExtraSmallScreen
                        ? ThemeConstants.smallRadius
                        : ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
                  ),
                  child: ChartCard(
                    title: 'Monthly',
                    data: orderedMonthlyData
                        .map((d) => showHours ? d.hours : d.sessions.toDouble())
                        .toList(),
                    titles: monthLabels,
                    showHours: showHours,
                    isLatest: (index) =>
                        orderedMonthlyData[index].isCurrentPeriod,
                    emptyBarColor: settings.separatorColor,
                    showEmptyBars: true,
                  ),
                ),
              ],
            ),
          );
        } else {
          // For phones in portrait mode, we use a column layout
          chartsWidget = Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isExtraSmallScreen
                        ? ThemeConstants.smallRadius
                        : ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
                  ),
                  child: ChartCard(
                    title: 'Daily',
                    data: orderedDailyData
                        .map((d) => showHours ? d.hours : d.sessions.toDouble())
                        .toList(),
                    titles: dayLabels,
                    showHours: showHours,
                    isLatest: (index) =>
                        orderedDailyData[index].isCurrentPeriod,
                    emptyBarColor: settings.separatorColor,
                    showEmptyBars: true,
                  ),
                ),
                SizedBox(
                    height: isExtraSmallScreen
                        ? ThemeConstants.smallSpacing
                        : ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isExtraSmallScreen
                        ? ThemeConstants.smallRadius
                        : ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
                  ),
                  child: ChartCard(
                    title: 'Weekly',
                    data: orderedWeeklyData
                        .map((d) => showHours ? d.hours : d.sessions.toDouble())
                        .toList(),
                    titles: weekLabels,
                    showHours: showHours,
                    isLatest: (index) =>
                        orderedWeeklyData[index].isCurrentPeriod,
                    emptyBarColor: settings.separatorColor,
                    showEmptyBars: true,
                  ),
                ),
                SizedBox(
                    height: isExtraSmallScreen
                        ? ThemeConstants.smallSpacing
                        : ThemeConstants.mediumSpacing),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isExtraSmallScreen
                        ? ThemeConstants.smallRadius
                        : ThemeConstants.mediumRadius),
                    boxShadow:
                        ThemeConstants.getShadow(settings.separatorColor),
                  ),
                  child: ChartCard(
                    title: 'Monthly',
                    data: orderedMonthlyData
                        .map((d) => showHours ? d.hours : d.sessions.toDouble())
                        .toList(),
                    titles: monthLabels,
                    showHours: showHours,
                    isLatest: (index) =>
                        orderedMonthlyData[index].isCurrentPeriod,
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

  // Helper method to get ISO week number (1-52/53)
  int _getWeekNumber(DateTime date) {
    // Add 3 days to the date to ensure the week starts on Monday
    final dayOfYear = int.parse(DateFormat('D').format(date));
    // Calculate the day of the week (1 = Monday, 7 = Sunday)
    final dayOfWeek = date.weekday;
    // Calculate the week number
    return ((dayOfYear - dayOfWeek + 10) / 7).floor();
  }
}
