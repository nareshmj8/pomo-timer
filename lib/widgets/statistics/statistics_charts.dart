import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pomo_timer/models/statistics_data.dart';

class StatisticsCharts extends StatelessWidget {
  final StatisticsData statsData;
  final bool showHours;

  const StatisticsCharts({
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
          _buildChartCard(
            'Daily',
            statsData.data['Daily']![showHours ? 'hours' : 'sessions']!,
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          ),
          const SizedBox(height: 8),
          _buildChartCard(
            'Weekly',
            statsData.data['Weekly']![showHours ? 'hours' : 'sessions']!,
            ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
          ),
          const SizedBox(height: 8),
          _buildChartCard(
            'Monthly',
            statsData.data['Monthly']![showHours ? 'hours' : 'sessions']!,
            ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, List<double> data, List<String> titles) {
    String displayType = showHours ? 'HOURS' : 'SESSIONS';
    String displayTitle = '$title $displayType';

    return Container(
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
            child: _buildBarChart(data, titles),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data, List<String> titles) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(),
        barGroups: _createBarGroups(data),
        titlesData: _createTitlesData(titles),
        gridData: _createGridData(),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<double> data) {
    return data.asMap().entries.map((entry) {
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
    }).toList();
  }

  FlTitlesData _createTitlesData(List<String> titles) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              showHours ? value.toStringAsFixed(1) : value.toInt().toString(),
              style: const TextStyle(
                color: CupertinoColors.label,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _createGridData() {
    return FlGridData(
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
    );
  }
}
