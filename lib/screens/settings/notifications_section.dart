import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

/// Section for notification settings
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Notifications'),
            SettingsListTileContainer(
              child: CupertinoListTile(
                title: const Text(
                  'Sound Alerts',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: settings.soundEnabled,
                  onChanged: (value) {
                    // Update sound enabled
                  },
                ),
              ),
            ),
            const SettingsSectionFooter(
              text: 'Enable sound alerts when timer completes.',
            ),
          ],
        );
      },
    );
  }
}
