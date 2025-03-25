import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: settings.backgroundColor.withAlpha(217),
            middle: Text(
              'Terms & Conditions',
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
                    'Agreement to Terms',
                    'By downloading, installing, or using Pomodoro TimeManager ("the App"), you agree to be bound by these Terms and Conditions. If you do not agree to these Terms, you should not use the App.',
                    settings,
                  ),
                  _buildSection(
                    'Description of Service',
                    'Pomodoro TimeManager is a productivity application that helps users manage their time using the Pomodoro Technique. The App offers both free and premium features.',
                    settings,
                  ),
                  _buildSection(
                    'User Accounts',
                    'The App may store your preferences and usage data locally on your device. If you enable iCloud sync (premium feature), your data will be stored in your personal iCloud account.',
                    settings,
                  ),
                  _buildSection(
                    'Premium Features and Subscriptions',
                    'The App offers premium features available through in-app purchases, including monthly, yearly, and lifetime subscription options.\n\n'
                        '• Payment for subscriptions will be charged to your Apple ID account at confirmation of purchase.\n'
                        '• Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.\n'
                        '• Your account will be charged for renewal within 24 hours prior to the end of the current period.\n'
                        '• You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.\n'
                        '• If a free trial is offered, the unused portion will be forfeited when you purchase a subscription.',
                    settings,
                  ),
                  _buildSection(
                    'Refund Policy',
                    'We cannot process refunds directly. Refund requests must be submitted to Apple through the App Store according to their refund policy.',
                    settings,
                  ),
                  _buildSection(
                    'Intellectual Property',
                    'The App, including all content, features, and functionality, is owned by us and is protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
                    settings,
                  ),
                  _buildSection(
                    'User Conduct',
                    'You agree not to:\n\n'
                        '• Use the App in any way that violates any applicable law or regulation\n'
                        '• Attempt to interfere with, compromise the system integrity or security, or decipher any transmissions to or from the servers running the App\n'
                        '• Use the App for any purpose that is harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable',
                    settings,
                  ),
                  _buildSection(
                    'Limitation of Liability',
                    'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or use, arising out of or in connection with these Terms or your use of the App.',
                    settings,
                  ),
                  _buildSection(
                    'Disclaimer of Warranties',
                    'The App is provided "as is" and "as available" without any warranties of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.',
                    settings,
                  ),
                  _buildSection(
                    'Changes to Terms',
                    'We reserve the right to modify these Terms at any time. If we make changes, we will provide notice by updating the "Last Updated" date at the top of these Terms and/or by other means. Your continued use of the App after any changes indicates your acceptance of the new Terms.',
                    settings,
                  ),
                  _buildSection(
                    'Governing Law',
                    'These Terms shall be governed by and construed in accordance with the laws of the United States, without regard to its conflict of law provisions.',
                    settings,
                  ),
                  _buildSection(
                    'Contact Us',
                    'If you have any questions about these Terms, please contact us at:\n\n'
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
