import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// Footer widget for settings sections with explanatory text
class SettingsSectionFooter extends StatelessWidget {
  final String text;

  const SettingsSectionFooter({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 16.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: settings.isDarkTheme
              ? const Color(0xFF8E8E93)
              : const Color(0xFF6C6C70),
          height: 1.3,
        ),
      ),
    );
  }
}
