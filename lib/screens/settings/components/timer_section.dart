import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';

/// Timer section of the settings screen
class TimerSection extends StatelessWidget {
  const TimerSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Timer'),
        _buildSliderTile(
          title: 'Focus Session',
          value: '${settings.sessionDuration.round()} min',
          sliderValue: settings.sessionDuration,
          min: 1.0,
          max: 120.0,
          onChanged: (value) => settings.setSessionDuration(value),
        ),
        _buildSliderTile(
          title: 'Short Break',
          value: '${settings.shortBreakDuration.round()} min',
          sliderValue: settings.shortBreakDuration,
          min: 1.0,
          max: 30.0,
          onChanged: (value) => settings.setShortBreakDuration(value),
        ),
        _buildSliderTile(
          title: 'Long Break',
          value: '${settings.longBreakDuration.round()} min',
          sliderValue: settings.longBreakDuration,
          min: 5.0,
          max: 45.0,
          onChanged: (value) => settings.setLongBreakDuration(value),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Adjust the duration of your focus sessions and breaks.',
        ),
      ],
    );
  }

  /// Builds a slider tile for duration settings
  Widget _buildSliderTile({
    required String title,
    required String value,
    required double sliderValue,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
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
