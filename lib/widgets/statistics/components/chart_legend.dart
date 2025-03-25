import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../utils/chart_formatting.dart';

class ChartLegend extends StatelessWidget {
  final bool isTablet;

  const ChartLegend({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final legendFontSize = isTablet
        ? ThemeConstants.smallFontSize
        : ThemeConstants.smallFontSize - 1;

    return Row(
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
            color: theme.secondaryTextColor,
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
            gradient: ChartFormatting.barGradient,
            borderRadius: BorderRadius.circular(isTablet ? 6 : 5),
          ),
        ),
        const SizedBox(width: ThemeConstants.smallSpacing),
        Text(
          'Previous',
          style: TextStyle(
            fontSize: legendFontSize,
            color: theme.secondaryTextColor,
            letterSpacing: -0.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
