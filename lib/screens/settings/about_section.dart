import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

/// Section for app information
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'About'),
            SettingsListTileContainer(
              child: Column(
                children: [
                  // App Version
                  const CupertinoListTile(
                    title: Text(
                      'Version',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: settings.isDarkTheme
                        ? const Color(0xFF38383A)
                        : const Color(0xFFC6C6C8),
                  ),

                  // Privacy Policy
                  CupertinoListTile(
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                    onTap: () {
                      // Open privacy policy
                    },
                  ),
                ],
              ),
            ),
            const SettingsSectionFooter(
              text:
                  'Pomodoro TimeMaster - A simple and effective Pomodoro timer app.',
            ),
          ],
        );
      },
    );
  }
}
