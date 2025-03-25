import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';
import 'package:pomodoro_timemaster/screens/legal/privacy_policy_screen.dart';
import 'package:pomodoro_timemaster/screens/legal/terms_conditions_screen.dart';

/// About section of the settings screen
class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('About'),
        SettingsUIComponents.buildListTileContainer(
          child: Column(
            children: [
              CupertinoListTile(
                title: const Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    color: settings.secondaryTextColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  height: 0.5,
                  color: settings.separatorColor,
                ),
              ),
              CupertinoListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  height: 0.5,
                  color: settings.separatorColor,
                ),
              ),
              CupertinoListTile(
                title: const Text('Terms & Conditions'),
                trailing: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Pomodoro TimeMaster helps you stay focused and productive.',
        ),
      ],
    );
  }
}
