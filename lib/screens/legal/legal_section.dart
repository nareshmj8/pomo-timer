import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/legal/privacy_policy_screen.dart';
import 'package:pomodoro_timemaster/screens/legal/terms_conditions_screen.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Legal'),
        SettingsUIComponents.buildListTileContainer(
          child: Column(
            children: [
              _buildLegalItem(
                context,
                'Privacy Policy',
                CupertinoIcons.doc_text,
                () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                ),
                settings,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  height: 0.5,
                  color: settings.separatorColor,
                ),
              ),
              _buildLegalItem(
                context,
                'Terms & Conditions',
                CupertinoIcons.doc_plaintext,
                () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const TermsConditionsScreen(),
                  ),
                ),
                settings,
              ),
            ],
          ),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Review our legal documents regarding app usage and data handling.',
        ),
      ],
    );
  }

  Widget _buildLegalItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    SettingsProvider settings,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: settings.textColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: settings.textColor,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: settings.secondaryTextColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
