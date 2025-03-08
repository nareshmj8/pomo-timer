import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

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
        final barGradient = LinearGradient(
          colors: [
            CupertinoColors.systemBlue,
            CupertinoColors.systemBlue.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

        // Create reversed data for display (latest on right)
        final List<double> displayData = widget.data.reversed.toList();
        final List<String> displayTitles = widget.titles.reversed.toList();
        final bool Function(int) isLatestReversed =
            (index) => widget.isLatest(widget.data.length - 1 - index);

        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: settings.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: settings.separatorColor.withOpacity(0.12),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: settings.separatorColor.withOpacity(0.15),
              width: 1.0,
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
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: settings.textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: settings.secondaryBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: settings.separatorColor.withOpacity(0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      widget.showHours ? 'Duration' : 'Sessions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: settings.secondaryTextColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 13,
                      color: settings.secondaryTextColor,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: barGradient,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 13,
                      color: settings.secondaryTextColor,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      groupsSpace: 20,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          tooltipBorder: BorderSide(
                            color: settings.separatorColor.withOpacity(0.1),
                            width: 1,
                          ),
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              _formatValue(displayData[group.x.toInt()],
                                  forTooltip: true),
                              TextStyle(
                                color: settings.textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
                              width: isSelected ? 18 : 14,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(2),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color:
                                    settings.separatorColor.withOpacity(0.03),
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
                            color: settings.separatorColor.withOpacity(0.08),
                            strokeWidth: 1,
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
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  displayTitles[value.toInt()],
                                  style: TextStyle(
                                    color: settings.secondaryTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            interval: calculateInterval(maxY),
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  _formatValue(value),
                                  style: TextStyle(
                                    color: settings.secondaryTextColor,
                                    fontSize: 13,
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
                    swapAnimationDuration: const Duration(milliseconds: 300),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
