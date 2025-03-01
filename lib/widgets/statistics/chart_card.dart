import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCard extends StatelessWidget {
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

  String _formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();
    int displayHours = totalMinutes ~/ 60;
    int displayMinutes = totalMinutes % 60;

    if (displayHours == 0) {
      return '${displayMinutes}M';
    } else if (displayMinutes == 0) {
      return '${displayHours}H';
    } else {
      return '${displayHours}H${displayMinutes}M';
    }
  }

  double get maxY {
    if (data.isEmpty) return 5.0;
    return (data.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();
  }

  double calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    return (maxY / 5).ceil().toDouble();
  }

  LinearGradient get barGradient => LinearGradient(
        colors: [
          CupertinoColors.systemBlue.withOpacity(0.8),
          CupertinoColors.systemBlue.withOpacity(0.5),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  showHours ? 'Duration' : 'Sessions',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: barGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Previous',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: data.asMap().entries.map((entry) {
                  final value = entry.value;
                  final bool isEmpty = value == 0;

                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: isEmpty && showEmptyBars ? maxY * 0.1 : value,
                        gradient: isEmpty
                            ? null
                            : (isLatest(entry.key) ? null : barGradient),
                        color: isEmpty
                            ? emptyBarColor
                            : (isLatest(entry.key)
                                ? CupertinoColors.systemGreen
                                : null),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: CupertinoColors.separator.withOpacity(0.2),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
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
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: calculateInterval(maxY),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          showHours
                              ? _formatDuration(value)
                              : value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (rod.toY == 0 && showEmptyBars) return null;
                      final value = showHours
                          ? _formatDuration(rod.toY)
                          : rod.toY.toStringAsFixed(1);
                      return BarTooltipItem(
                        '${titles[group.x]} • ${showHours ? 'Duration: ' : 'Sessions: '}$value',
                        const TextStyle(
                          color: CupertinoColors.label,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
