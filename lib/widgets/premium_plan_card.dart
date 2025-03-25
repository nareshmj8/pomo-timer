import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';

/// A card widget for displaying premium plan options
class PremiumPlanCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final bool isSelected;
  final String? tag;
  final VoidCallback onTap;

  const PremiumPlanCard({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.isSelected,
    this.tag,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmallScreen = screenWidth < 350;

    // Responsive adjustments for small screens
    final horizontalPadding =
        isExtraSmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);
    final verticalPadding =
        isExtraSmallScreen ? 8.0 : (isSmallScreen ? 9.0 : 10.0);
    final fontSize = isExtraSmallScreen ? 14.0 : 15.0;
    final descriptionFontSize = isExtraSmallScreen ? 11.0 : 12.0;
    final iconSize = isExtraSmallScreen ? 16.0 : 18.0;

    // Improved colors with better contrast for dark mode
    final backgroundColor = isSelected
        ? (settings.isDarkTheme
            ? const Color(0xFF1C5088) // Darker blue with better contrast
            : const Color(0xFFE3F2FD)) // Light blue for light mode
        : settings.listTileBackgroundColor;

    final textColor = isSelected && settings.isDarkTheme
        ? CupertinoColors.white
        : settings.textColor;

    final secondaryTextColor = isSelected
        ? (settings.isDarkTheme
            ? CupertinoColors.white.withAlpha(ThemeConstants.opacityToAlpha(
                0.9)) // Higher opacity for better contrast
            : CupertinoColors.activeBlue)
        : settings.secondaryTextColor;

    final borderColor = isSelected
        ? (settings.isDarkTheme
            ? CupertinoColors
                .systemBlue.darkColor // Brighter blue for dark mode border
            : CupertinoColors.activeBlue)
        : settings.separatorColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: ThemeConstants.mediumAnimation,
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      color: secondaryTextColor,
                    ),
                    maxLines: isExtraSmallScreen ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: isExtraSmallScreen ? 4 : 8),
            Text(
              price,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: isExtraSmallScreen ? 4 : 8),
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: settings.isDarkTheme
                      ? CupertinoColors.systemBlue.darkColor
                      : CupertinoColors.activeBlue,
                  size: iconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
