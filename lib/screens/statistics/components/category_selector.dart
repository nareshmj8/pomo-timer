import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

/// Category selector component for the statistics screen
class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isTablet = ResponsiveUtils.isTablet(context);
        final padding = ResponsiveUtils.getResponsiveHorizontalPadding(context);

        final labelFontSize = isTablet
            ? ThemeConstants.mediumFontSize + 1
            : ThemeConstants.mediumFontSize;

        final categoryFontSize = isTablet
            ? ThemeConstants.mediumFontSize
            : ThemeConstants.mediumFontSize - 1;

        final buttonPadding = isTablet
            ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0)
            : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

        final borderRadius =
            isTablet ? ThemeConstants.mediumRadius : ThemeConstants.smallRadius;

        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: padding.horizontal,
              vertical: ThemeConstants.smallSpacing + 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category:',
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: settings.textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              CupertinoButton(
                padding: buttonPadding,
                color: settings.listTileBackgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                onPressed: () => _showCategoryPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.selectedCategory,
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
                          ? ThemeConstants.smallSpacing - 4
                          : ThemeConstants.tinySpacing),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue.withAlpha(
                            ThemeConstants.opacityToAlpha(
                                ThemeConstants.veryLowOpacity)),
                        borderRadius: BorderRadius.circular(isTablet
                            ? ThemeConstants.smallSpacing - 2
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
          ),
        );
      },
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isTablet = ResponsiveUtils.isTablet(context);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: settings.backgroundColor,
          child: SafeArea(
            top: false,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              scrollController: FixedExtentScrollController(
                initialItem: widget.categories.indexOf(widget.selectedCategory),
              ),
              onSelectedItemChanged: (int selectedItem) {
                widget.onCategoryChanged(widget.categories[selectedItem]);
              },
              children:
                  List<Widget>.generate(widget.categories.length, (int index) {
                return Center(
                  child: Text(
                    widget.categories[index],
                    style: TextStyle(
                      fontSize: isTablet ? 22.0 : 20.0,
                      color: settings.textColor,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
