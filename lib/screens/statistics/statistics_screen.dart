import 'package:flutter/cupertino.dart';
import 'components/category_selector.dart';
import 'components/toggle_buttons.dart';
import '../../models/statistics_data.dart';
import '../../widgets/statistics/statistics_charts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedCategory = 'All Categories';
  final List<String> categories = ['All Categories', 'Work', 'Study', 'Life'];
  bool showHours = true;
  final statsData = StatisticsData.defaultData();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Statistics'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelector(
                selectedCategory: selectedCategory,
                categories: categories,
                onCategoryChanged: (category) =>
                    setState(() => selectedCategory = category),
              ),
              ToggleButtons(
                showHours: showHours,
                onToggle: (value) => setState(() => showHours = value),
              ),
              StatisticsCharts(showHours: showHours, statsData: statsData),
            ],
          ),
        ),
      ),
    );
  }
}
