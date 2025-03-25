import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Responsive text sizes
    final titleFontSize = isTablet
        ? ThemeConstants.mediumFontSize + 1
        : ThemeConstants.mediumFontSize;

    final descriptionFontSize = isTablet
        ? ThemeConstants.mediumFontSize - 1
        : ThemeConstants.smallFontSize + 1;

    // Responsive padding and spacing
    final horizontalPadding = isTablet
        ? ThemeConstants.mediumSpacing
        : ThemeConstants.mediumSpacing - 4;

    final verticalPadding = isTablet
        ? ThemeConstants.mediumSpacing - 2
        : ThemeConstants.smallSpacing + 6;

    final iconContainerSize = isTablet
        ? ThemeConstants.mediumSpacing + 6
        : ThemeConstants.smallSpacing + 10;

    final iconSize = isTablet
        ? ThemeConstants.mediumIconSize - 2
        : ThemeConstants.smallIconSize + 6;

    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey
            .withAlpha((ThemeConstants.highOpacity * 255).toInt())
        : CupertinoColors.systemGrey.darkColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: settings.listTileBackgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        border: Border.all(
          color: settings.separatorColor,
          width: ThemeConstants.thinBorder,
        ),
        boxShadow: ThemeConstants.getShadow(settings.separatorColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconContainerSize / 3),
            decoration: BoxDecoration(
              color: settings.isDarkTheme
                  ? color.withAlpha(
                      ((ThemeConstants.veryLowOpacity * 2) * 255).toInt())
                  : color
                      .withAlpha((ThemeConstants.veryLowOpacity * 255).toInt()),
              borderRadius:
                  BorderRadius.circular(ThemeConstants.smallRadius + 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
          SizedBox(
              width: isTablet
                  ? ThemeConstants.smallSpacing + 6
                  : ThemeConstants.smallSpacing + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: settings.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: ThemeConstants.tinySpacing - 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
