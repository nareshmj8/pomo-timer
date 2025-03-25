import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// A consistent section footer with explanation text for settings screens
class SettingsSectionFooter extends StatelessWidget {
  final String text;

  const SettingsSectionFooter({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: settings.secondaryTextColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
