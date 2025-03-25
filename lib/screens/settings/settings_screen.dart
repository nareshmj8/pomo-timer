import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/timer_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/session_cycle_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/appearance_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/notifications_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/data_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/about_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/reset_section.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/widgets/sync_status_indicator.dart';

/// Settings screen that displays all settings sections
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    // Responsive font sizes
    final titleFontSize = isTablet ? 18.0 : (isSmallScreen ? 16.0 : 17.0);
    final buttonFontSize = isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0);

    // Responsive padding
    final horizontalPadding = isTablet ? 20.0 : (isSmallScreen ? 12.0 : 16.0);

    return CupertinoPageScaffold(
      backgroundColor: settings.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
              ),
            ),
            // Add sync status badge next to title
            const SizedBox(width: 6),
            const SyncStatusBadge(
              showDetails: true,
              size: 16,
            ),
          ],
        ),
        // Add leading button if this is a pushed screen
        leading: Navigator.canPop(context)
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    color: settings.isDarkTheme
                        ? CupertinoColors.activeBlue.darkColor
                        : CupertinoColors.activeBlue,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        backgroundColor: settings.backgroundColor,
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer section
              const TimerSection(),

              // Session Cycle section
              const SessionCycleSection(),

              // Appearance section
              const AppearanceSection(),

              // Notifications section
              const NotificationsSection(),

              // Data section
              const DataSection(),

              // About section
              const AboutSection(),

              // Reset section
              const ResetSection(),
            ],
          ),
        ),
      ),
    );
  }
}
