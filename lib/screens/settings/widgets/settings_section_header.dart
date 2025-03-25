import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// A consistent section header for settings screens
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 8.0,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: settings.textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
