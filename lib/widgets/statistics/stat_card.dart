import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/theme_constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final bool showHours;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.showHours,
  });

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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
        final isTablet = ResponsiveUtils.isTablet(context);

        // Responsive sizing
        final horizontalPadding = isSmallScreen
            ? ThemeConstants.mediumSpacing - 4
            : isTablet
                ? ThemeConstants.largeSpacing
                : ThemeConstants.mediumSpacing;

        final verticalPadding = isSmallScreen
            ? ThemeConstants.mediumSpacing - 2
            : isTablet
                ? ThemeConstants.largeSpacing
                : ThemeConstants.mediumSpacing;

        final titleFontSize = isSmallScreen
            ? ThemeConstants.smallFontSize - 1
            : isTablet
                ? ThemeConstants.smallFontSize + 2
                : ThemeConstants.smallFontSize;

        final valueFontSize = isSmallScreen
            ? ThemeConstants.extraLargeFontSize - 4
            : isTablet
                ? ThemeConstants.extraLargeFontSize + 4
                : ThemeConstants.extraLargeFontSize;

        final labelFontSize = isSmallScreen
            ? ThemeConstants.smallFontSize - 1
            : isTablet
                ? ThemeConstants.smallFontSize + 1
                : ThemeConstants.smallFontSize;

        final borderRadius =
            isTablet ? ThemeConstants.largeRadius : ThemeConstants.mediumRadius;

        return Expanded(
          child: Container(
            margin: EdgeInsets.all(isTablet
                ? ThemeConstants.smallSpacing
                : ThemeConstants.tinySpacing),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: settings.listTileBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: ThemeConstants.getShadow(settings.separatorColor),
              border: Border.all(
                color: settings.separatorColor.withAlpha(
                    ((ThemeConstants.veryLowOpacity + 0.05) * 255).toInt()),
                width: ThemeConstants.thinBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    letterSpacing: 0.2,
                    color: settings.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                    height: isTablet
                        ? ThemeConstants.mediumSpacing
                        : ThemeConstants.smallSpacing + 6),
                Text(
                  showHours ? _formatDuration(value) : value.round().toString(),
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: settings.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(
                    height: isTablet
                        ? ThemeConstants.smallSpacing
                        : ThemeConstants.tinySpacing + 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet
                        ? ThemeConstants.mediumSpacing - 6
                        : ThemeConstants.smallSpacing + 2,
                    vertical: isTablet
                        ? ThemeConstants.smallSpacing - 3
                        : ThemeConstants.tinySpacing + 1,
                  ),
                  decoration: BoxDecoration(
                    color: (showHours
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGreen)
                        .withAlpha(ThemeConstants.opacityToAlpha(
                            ThemeConstants.veryLowOpacity + 0.02)),
                    borderRadius: BorderRadius.circular(isTablet
                        ? ThemeConstants.smallSpacing
                        : ThemeConstants.smallSpacing - 2),
                    border: Border.all(
                      color: (showHours
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGreen)
                          .withAlpha(ThemeConstants.opacityToAlpha(
                              ThemeConstants.veryLowOpacity + 0.1)),
                      width: ThemeConstants.thinBorder,
                    ),
                  ),
                  child: Text(
                    showHours ? 'Duration' : 'Sessions',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: showHours
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGreen,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
