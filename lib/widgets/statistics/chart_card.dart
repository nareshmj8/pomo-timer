import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> titles;
  final bool showHours;
  final bool Function(int) isLatest;

  const ChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.titles,
    required this.showHours,
    required this.isLatest,
  });

  double get maxY =>
      (data.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble();

  double calculateInterval(double maxY) {
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    return (maxY / 5).ceil().toDouble();
  }

  LinearGradient get barGradient => LinearGradient(
        colors: [
          CupertinoColors.systemBlue,
          CupertinoColors.systemBlue.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: CupertinoColors.secondaryLabel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      showHours ? 'Hours' : 'Sessions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        gradient: isLatest(entry.key) ? null : barGradient,
                        color: isLatest(entry.key)
                            ? CupertinoColors.systemGreen
                            : null,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: CupertinoColors.systemGrey6,
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
                      color: CupertinoColors.separator.withOpacity(0.3),
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
                      reservedSize: 32,
                      interval: calculateInterval(maxY),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          showHours
                              ? value.toStringAsFixed(1)
                              : value.toInt().toString(),
                          style: TextStyle(
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${showHours ? 'Hours: ' : 'Sessions: '}${rod.toY.toStringAsFixed(showHours ? 1 : 0)}',
                        TextStyle(
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
