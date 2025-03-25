import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/theme_constants.dart';

class ChartCard extends StatefulWidget {
  final String title;
  final List<double> data;
  final List<String> titles;
  final bool showHours;
  final bool Function(int) isLatest;
  final Color? emptyBarColor;
  final bool showEmptyBars;

  const ChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.titles,
    required this.showHours,
    required this.isLatest,
    this.emptyBarColor,
    this.showEmptyBars = false,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  int? touchedIndex;

  String _formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();
    int displayHours = totalMinutes ~/ 60;
    int displayMinutes = totalMinutes % 60;

    if (displayHours == 0) {
      return '${displayMinutes}m';
    } else if (displayMinutes == 0) {
      return '${displayHours}h';
    } else {
      return '${displayHours}h ${displayMinutes}m';
    }
  }

  String _formatValue(double value, {bool forTooltip = false}) {
    if (widget.showHours) {
      return _formatDuration(value);
    }
    return forTooltip ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
  }

  double get maxY {
    if (widget.data.isEmpty) return 5.0;
    final maxValue = widget.data.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 10) return (maxValue * 1.2).ceilToDouble();
    return ((maxValue * 1.2) / 5).ceil() * 5.0;
  }

  double calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 4;
    if (maxY <= 50) return 10;
    return (maxY / 5).ceil().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isTablet = ResponsiveUtils.isTablet(context);
        final isLargeTablet = ResponsiveUtils.isLargeTablet(context);

        // Responsive sizing
        final cardPadding = isTablet
            ? ThemeConstants.largeSpacing - 4
            : ThemeConstants.mediumSpacing;

        final titleFontSize = isTablet
            ? ThemeConstants.largeFontSize
            : ThemeConstants.mediumFontSize + 2;

        final labelFontSize = isTablet
            ? ThemeConstants.smallFontSize + 1
            : ThemeConstants.smallFontSize;

        final legendFontSize = isTablet
            ? ThemeConstants.smallFontSize
            : ThemeConstants.smallFontSize - 1;

        final chartHeight = isLargeTablet
            ? 280.0
            : isTablet
                ? 250.0
                : 220.0;

        final barWidth = isTablet ? 18.0 : 14.0;
        final selectedBarWidth = isTablet ? 22.0 : 18.0;

        final borderRadius =
            isTablet ? ThemeConstants.largeRadius : ThemeConstants.mediumRadius;

        final barGradient = LinearGradient(
          colors: [
            CupertinoColors.systemBlue,
            CupertinoColors.systemBlue.withAlpha((0.8 * 255).toInt()),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

        // Use data as-is without reversing (latest should already be on the right)
        final List<double> displayData = widget.data.toList();
        final List<String> displayTitles = widget.titles.toList();

        bool isLatestReversed(int index) {
          return widget.isLatest(index);
        }

        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: settings.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: ThemeConstants.getShadow(settings.separatorColor),
            border: Border.all(
              color: settings.separatorColor
                  .withAlpha(((ThemeConstants.lowOpacity / 2) * 255).toInt()),
              width: ThemeConstants.standardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: settings.textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? ThemeConstants.smallSpacing + 2
                          : ThemeConstants.smallSpacing,
                      vertical: isTablet
                          ? ThemeConstants.tinySpacing + 1
                          : ThemeConstants.tinySpacing,
                    ),
                    decoration: BoxDecoration(
                      color: settings.secondaryBackgroundColor.withAlpha(
                          ((ThemeConstants.lowOpacity + 0.2) * 255).toInt()),
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.smallRadius),
                      border: Border.all(
                        color: settings.separatorColor.withAlpha(
                            (ThemeConstants.veryLowOpacity * 255).toInt()),
                        width: ThemeConstants.thinBorder,
                      ),
                    ),
                    child: Text(
                      widget.showHours ? 'Duration' : 'Sessions',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        color: settings.secondaryTextColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: isTablet
                      ? ThemeConstants.largeSpacing
                      : ThemeConstants.mediumSpacing),
              Row(
                children: [
                  Container(
                    width: isTablet ? 12 : 10,
                    height: isTablet ? 12 : 10,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.smallSpacing),
                  Text(
                    'Current',
                    style: TextStyle(
                      fontSize: legendFontSize,
                      color: settings.secondaryTextColor,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                      width: isTablet
                          ? ThemeConstants.mediumSpacing
                          : ThemeConstants.mediumSpacing - 4),
                  Container(
                    width: isTablet ? 12 : 10,
                    height: isTablet ? 12 : 10,
                    decoration: BoxDecoration(
                      gradient: barGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.smallSpacing),
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: legendFontSize,
                      color: settings.secondaryTextColor,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: isTablet
                      ? ThemeConstants.mediumSpacing
                      : ThemeConstants.mediumSpacing - 4),
              SizedBox(
                height: chartHeight,
                child: Padding(
                  padding: const EdgeInsets.only(right: ThemeConstants.smallSpacing),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      groupsSpace: isTablet ? 24 : 20,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipBorder: BorderSide(
                            color: settings.separatorColor.withAlpha(
                                (ThemeConstants.veryLowOpacity * 255).toInt()),
                            width: ThemeConstants.thinBorder,
                          ),
                          tooltipPadding:
                              const EdgeInsets.all(ThemeConstants.smallSpacing),
                          tooltipMargin: ThemeConstants.smallSpacing,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              _formatValue(displayData[group.x.toInt()],
                                  forTooltip: true),
                              TextStyle(
                                color: settings.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet
                                    ? ThemeConstants.smallFontSize + 2
                                    : ThemeConstants.smallFontSize + 1,
                              ),
                            );
                          },
                        ),
                        touchCallback: (event, response) {
                          if (response == null || response.spot == null) {
                            setState(() => touchedIndex = null);
                            return;
                          }
                          setState(() => touchedIndex =
                              response.spot!.touchedBarGroupIndex);
                        },
                      ),
                      barGroups: displayData.asMap().entries.map((entry) {
                        final value = entry.value;
                        final bool isCurrentBar = isLatestReversed(entry.key);
                        final bool isSelected = touchedIndex == entry.key;

                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              gradient: isCurrentBar ? null : barGradient,
                              color: isCurrentBar
                                  ? CupertinoColors.systemGreen
                                  : null,
                              width: isSelected ? selectedBarWidth : barWidth,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(
                                    ThemeConstants.smallRadius - 2),
                                bottom: Radius.circular(
                                    ThemeConstants.tinySpacing - 2),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: settings.separatorColor.withAlpha(
                                    ((ThemeConstants.veryLowOpacity - 0.07) *
                                            255)
                                        .toInt()),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: calculateInterval(maxY),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: settings.separatorColor.withAlpha(
                                ((ThemeConstants.veryLowOpacity - 0.02) * 255)
                                    .toInt()),
                            strokeWidth: ThemeConstants.thinBorder,
                            dashArray: [6, 4],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: isTablet
                                        ? ThemeConstants.mediumSpacing - 4
                                        : ThemeConstants.smallSpacing + 4),
                                child: Text(
                                  displayTitles[value.toInt()],
                                  style: TextStyle(
                                    color: settings.secondaryTextColor,
                                    fontSize: labelFontSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              );
                            },
                            reservedSize: isTablet ? 40 : 32,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isTablet ? 60 : 52,
                            interval: calculateInterval(maxY),
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: ThemeConstants.smallSpacing),
                                child: Text(
                                  _formatValue(value),
                                  style: TextStyle(
                                    color: settings.secondaryTextColor,
                                    fontSize: labelFontSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    duration: ThemeConstants.mediumAnimation,
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              const SizedBox(height: ThemeConstants.smallSpacing),
            ],
          ),
        );
      },
    );
  }
}
