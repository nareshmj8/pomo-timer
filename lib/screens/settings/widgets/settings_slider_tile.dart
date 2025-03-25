import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// A slider tile for adjusting numeric settings
class SettingsSliderTile extends StatelessWidget {
  final String title;
  final String value;
  final double sliderValue;
  final double min;
  final double max;
  final Function(double) onChanged;

  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.value,
    required this.sliderValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.isDarkTheme
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: settings.listTileTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: settings.secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CupertinoSlider(
              value: sliderValue,
              min: min,
              max: max,
              onChanged: onChanged,
              activeColor: settings.isDarkTheme
                  ? CupertinoColors.activeBlue.darkColor
                  : CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }
}
