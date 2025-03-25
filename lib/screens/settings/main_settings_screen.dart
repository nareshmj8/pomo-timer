import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/timer_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/session_cycle_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/appearance_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/notifications_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/data_section.dart';

/// Main settings screen that uses all the component sections
class MainSettingsScreen extends StatelessWidget {
  const MainSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor: settings.isDarkTheme
            ? CupertinoColors.black
            : CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: settings.separatorColor,
            width: 0.0,
          ),
        ),
      ),
      backgroundColor: settings.backgroundColor,
      child: SafeArea(
        child: ListView(
          children: const [
            TimerSection(),
            SessionCycleSection(),
            AppearanceSection(),
            NotificationsSection(),
            DataSection(),
            // Add more sections as needed
          ],
        ),
      ),
    );
  }
}
