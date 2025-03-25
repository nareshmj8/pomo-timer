import 'package:flutter/cupertino.dart';
import '../../providers/settings_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/theme_constants.dart';

class CategorySelector extends StatelessWidget {
  final SettingsProvider settings;
  final List<String> categories;

  const CategorySelector({
    super.key,
    required this.settings,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Responsive font sizes
    final labelFontSize = isSmallScreen
        ? ThemeConstants.mediumFontSize - 1
        : isTablet
            ? ThemeConstants.mediumFontSize + 2
            : ThemeConstants.mediumFontSize;

    final categoryFontSize = isSmallScreen
        ? ThemeConstants.mediumFontSize - 1
        : isTablet
            ? ThemeConstants.mediumFontSize + 1
            : ThemeConstants.mediumFontSize;

    // Responsive padding
    final buttonPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0)
        : isTablet
            ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)
            : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

    // Responsive border radius
    final borderRadius =
        isTablet ? ThemeConstants.mediumRadius : ThemeConstants.smallRadius;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category:',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: settings.textColor,
            letterSpacing: -0.5,
          ),
        ),
        CupertinoButton(
          padding: buttonPadding,
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          onPressed: () => showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text(
                  'Select Category',
                  style: TextStyle(
                    color: settings.textColor,
                    fontSize: isTablet
                        ? ThemeConstants.mediumFontSize
                        : ThemeConstants.smallFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                message: Text(
                  'Choose a category for your focus session',
                  style: TextStyle(
                    color: settings.secondaryTextColor,
                    fontSize: isTablet
                        ? ThemeConstants.smallFontSize
                        : ThemeConstants.smallFontSize - 1,
                    letterSpacing: -0.2,
                  ),
                ),
                actions: categories
                    .map(
                      (category) => CupertinoActionSheetAction(
                        onPressed: () {
                          settings.setSelectedCategory(category);
                          Navigator.pop(context);
                        },
                        isDefaultAction: category == settings.selectedCategory,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: category == settings.selectedCategory
                                ? CupertinoColors.activeBlue
                                : settings.textColor,
                            fontSize: isTablet
                                ? ThemeConstants.mediumFontSize + 1
                                : ThemeConstants.mediumFontSize,
                            fontWeight: category == settings.selectedCategory
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: settings.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet
                          ? ThemeConstants.mediumFontSize
                          : ThemeConstants.mediumFontSize - 1,
                    ),
                  ),
                ),
              );
            },
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.selectedCategory,
                style: TextStyle(
                  fontSize: categoryFontSize,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(
                  width: isTablet
                      ? ThemeConstants.smallSpacing
                      : ThemeConstants.tinySpacing + 2),
              Container(
                padding: EdgeInsets.all(isTablet
                    ? ThemeConstants.smallSpacing
                    : ThemeConstants.tinySpacing),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withAlpha(
                      ThemeConstants.opacityToAlpha(
                          ThemeConstants.veryLowOpacity)),
                  borderRadius: BorderRadius.circular(isTablet
                      ? ThemeConstants.smallSpacing
                      : ThemeConstants.tinySpacing + 2),
                ),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  size: isTablet
                      ? ThemeConstants.smallIconSize
                      : ThemeConstants.smallIconSize - 2,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
