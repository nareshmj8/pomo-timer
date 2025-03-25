import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

/// Section for session cycle settings
class SessionCycleSection extends StatelessWidget {
  const SessionCycleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Session Cycle'),
            SettingsListTileContainer(
              child: Column(
                children: [
                  _buildNumberPickerTile(
                    context: context,
                    title: 'Sessions Before Long Break',
                    value: settings.sessionsBeforeLongBreak,
                    onChanged: (value) {
                      // Update sessions before long break
                    },
                  ),
                ],
              ),
            ),
            const SettingsSectionFooter(
              text:
                  'Set how many focus sessions to complete before taking a long break.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumberPickerTile({
    required BuildContext context,
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                child: const Icon(
                  CupertinoIcons.minus_circle,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: value < 10 ? () => onChanged(value + 1) : null,
                child: const Icon(
                  CupertinoIcons.plus_circle,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
