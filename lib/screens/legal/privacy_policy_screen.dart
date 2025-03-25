import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: settings.backgroundColor.withAlpha(217),
            middle: Text(
              'Privacy Policy',
              style: TextStyle(
                color: settings.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            border: Border(
              bottom: BorderSide(
                color: settings.separatorColor,
                width: ThemeConstants.thinBorder,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Updated: ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Introduction',
                    'Welcome to Pomodoro TimeManager ("we," "our," or "us"). We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
                    settings,
                  ),
                  _buildSection(
                    'Information We Collect',
                    'We collect the following types of information:\n\n'
                        '• Usage Data: We collect information about how you use the app, including session durations, break times, and completion rates.\n\n'
                        '• Device Information: We collect information about your device, including device type, operating system, and unique device identifiers.\n\n'
                        '• iCloud Data: If you enable iCloud sync (premium feature), your app data is stored in your personal iCloud account.',
                    settings,
                  ),
                  _buildSection(
                    'How We Use Your Information',
                    'We use your information to:\n\n'
                        '• Provide and improve our services\n'
                        '• Personalize your experience\n'
                        '• Process transactions\n'
                        '• Respond to your inquiries\n'
                        '• Analyze usage patterns to improve functionality',
                    settings,
                  ),
                  _buildSection(
                    'Data Storage and Security',
                    'Your data is primarily stored locally on your device. If you enable iCloud sync (premium feature), your data is also stored in your personal iCloud account, which is managed by Apple.\n\n'
                        'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.',
                    settings,
                  ),
                  _buildSection(
                    'Third-Party Services',
                    'Our app uses the following third-party services:\n\n'
                        '• RevenueCat: For managing in-app purchases and subscriptions\n'
                        '• Apple iCloud: For data synchronization (premium feature)\n\n'
                        'Each third-party service has its own Privacy Policy governing how they handle your data.',
                    settings,
                  ),
                  _buildSection(
                    'Your Rights',
                    'Depending on your location, you may have rights regarding your personal data, including:\n\n'
                        '• Access to your data\n'
                        '• Correction of inaccurate data\n'
                        '• Deletion of your data\n'
                        '• Restriction of processing\n'
                        '• Data portability\n\n'
                        'To exercise these rights, please contact us using the information provided below.',
                    settings,
                  ),
                  _buildSection(
                    'Children\'s Privacy',
                    'Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
                    settings,
                  ),
                  _buildSection(
                    'Changes to This Privacy Policy',
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
                    settings,
                  ),
                  _buildSection(
                    'Contact Us',
                    'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                        'Email: pomodorotimemaster@gmail.com',
                    settings,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
      String title, String content, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: settings.textColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
