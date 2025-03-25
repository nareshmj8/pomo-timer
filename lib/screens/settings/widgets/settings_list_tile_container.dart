import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// A consistent container for list tiles in settings screens
class SettingsListTileContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const SettingsListTileContainer({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Container(
        margin: margin ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: settings.isDarkTheme
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
