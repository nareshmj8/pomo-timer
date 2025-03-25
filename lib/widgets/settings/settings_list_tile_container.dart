import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// Container for settings list tiles with consistent styling
class SettingsListTileContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showTopSeparator;
  final bool showBottomSeparator;

  const SettingsListTileContainer({
    super.key,
    required this.child,
    this.padding,
    this.showTopSeparator = true,
    this.showBottomSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final separatorColor = settings.isDarkTheme
        ? const Color(0xFF38383A)
        : const Color(0xFFC6C6C8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: settings.isDarkTheme
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: settings.isDarkTheme
              ? const Color(0xFF38383A)
              : const Color(0xFFE5E5EA),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          if (showTopSeparator)
            Container(
              height: 0.5,
              color: separatorColor,
            ),
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
          if (showBottomSeparator)
            Container(
              height: 0.5,
              color: separatorColor,
            ),
        ],
      ),
    );
  }
}
