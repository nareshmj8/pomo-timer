import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../providers/settings_provider.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              _buildNotificationToggle(
                context,
                'Enable Notifications',
                'Receive notifications when timer ends',
                settings.notificationsEnabled,
                theme,
                onChanged: (value) {
                  settings.setNotificationsEnabled(value);
                },
              ),
              _buildNotificationToggle(
                context,
                'Sound',
                'Play sound with notifications',
                settings.soundEnabled,
                theme,
                onChanged: (value) {
                  settings.setSoundEnabled(value);
                  // Optionally play a test sound when enabled
                  if (value) {
                    settings.testNotificationSound();
                  }
                },
              ),
              _buildNotificationToggle(
                context,
                'Vibration',
                'Vibrate with notifications',
                settings.vibrationEnabled,
                theme,
                isLast: true,
                onChanged: (value) {
                  settings.setVibrationEnabled(value);
                  // Optionally test vibration when enabled
                  // This would require implementing a vibration test in the settings provider
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ThemeProvider theme, {
    bool isLast = false,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: !isLast
              ? BorderSide(
                  color: theme.separatorColor,
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.listTileTextColor,
                      fontSize: ThemeConstants.bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: ThemeConstants.captionFontSize,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }
}
