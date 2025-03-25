import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

/// Section for timer-related settings
class TimerSettingsSection extends StatelessWidget {
  const TimerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Timer'),
            SettingsListTileContainer(
              child: Column(
                children: [
                  _buildSliderTile(
                    context: context,
                    title: 'Focus Duration',
                    value: settings.sessionDuration,
                    min: 1.0,
                    max: 60.0,
                    onChanged: (value) {
                      // Update session duration
                    },
                  ),
                  _buildDivider(settings),
                  _buildSliderTile(
                    context: context,
                    title: 'Short Break',
                    value: settings.shortBreakDuration,
                    min: 1.0,
                    max: 30.0,
                    onChanged: (value) {
                      // Update short break duration
                    },
                  ),
                  _buildDivider(settings),
                  _buildSliderTile(
                    context: context,
                    title: 'Long Break',
                    value: settings.longBreakDuration,
                    min: 1.0,
                    max: 60.0,
                    onChanged: (value) {
                      // Update long break duration
                    },
                  ),
                ],
              ),
            ),
            const SettingsSectionFooter(
              text: 'Adjust the duration of focus sessions and breaks.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider(SettingsProvider settings) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: settings.isDarkTheme
          ? const Color(0xFF38383A)
          : const Color(0xFFC6C6C8),
    );
  }

  Widget _buildSliderTile({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              Text(
                '${value.round()} min',
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
