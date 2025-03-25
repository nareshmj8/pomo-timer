import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

/// Common UI components for the settings screen
class SettingsUIComponents {
  /// Creates a consistent section header
  static Widget buildSectionHeader(String title) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 8.0,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: settings.textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  /// Creates a section footer with explanation text
  static Widget buildSectionFooter(String text) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: settings.secondaryTextColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  /// Creates a container for list tiles
  static Widget buildListTileContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
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

  /// Creates a slider settings tile
  static Widget buildSliderTile({
    required String title,
    required String value,
    required double currentValue,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: Text(title),
          trailing: Text(
            value,
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CupertinoSlider(
            value: currentValue,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Creates a switch settings tile
  static Widget buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    String? subtitle,
  }) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Shows a toast notification
  static void showToast(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey
                  .withAlpha(ThemeConstants.opacityToAlpha(0.9)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () {
      overlay.remove();
    });
  }
}
