import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/settings_dialogs.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';

/// Section for resetting app data
class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Reset'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                color: settings.isDarkTheme
                    ? const Color(0xFF1C1C1E)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(8.0),
                onPressed: () async {
                  final shouldReset =
                      await SettingsDialogs.showResetConfirmation(context);
                  if (shouldReset) {
                    // Reset all settings to default
                    settings.resetSettingsToDefault();
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.refresh_bold,
                      color: CupertinoColors.destructiveRed,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Reset All Data',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SettingsSectionFooter(
              text:
                  'Resetting will revert all settings and data to their default values.',
            ),
          ],
        );
      },
    );
  }
}
