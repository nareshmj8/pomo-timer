import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

/// Toggle buttons component for the statistics screen
class ToggleButtons extends StatelessWidget {
  final bool showHours;
  final Function(bool) onToggle;

  const ToggleButtons({
    Key? key,
    required this.showHours,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isTablet = ResponsiveUtils.isTablet(context);
        final toggleFontSize = isTablet
            ? ThemeConstants.mediumFontSize + 1
            : ThemeConstants.mediumFontSize;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveHorizontalPadding(context)
                .horizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet
                      ? ThemeConstants.mediumSpacing - 6
                      : ThemeConstants.smallSpacing + 2,
                ),
                onPressed: () => onToggle(true),
                child: Text(
                  'Hours',
                  style: TextStyle(
                    fontSize: toggleFontSize,
                    color: showHours
                        ? CupertinoColors.activeBlue
                        : settings.secondaryTextColor,
                    fontWeight: showHours ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet
                      ? ThemeConstants.mediumSpacing - 6
                      : ThemeConstants.smallSpacing + 2,
                ),
                onPressed: () => onToggle(false),
                child: Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: toggleFontSize,
                    color: !showHours
                        ? CupertinoColors.activeBlue
                        : settings.secondaryTextColor,
                    fontWeight: !showHours ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
