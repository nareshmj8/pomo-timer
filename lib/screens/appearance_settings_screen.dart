import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return CupertinoPageScaffold(
      backgroundColor: settings.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Appearance',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: settings.textColor,
          ),
        ),
        backgroundColor: settings.backgroundColor,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Theme'),
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildThemeTile('Light', CupertinoColors.systemBackground),
                    _buildThemeTile('Dark', CupertinoColors.black),
                    _buildThemeTile('Calm', const Color(0xFF7CA5B8)),
                    _buildThemeTile('Forest', const Color(0xFF2D5A27)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeTile(String name, Color color) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isSelected = settings.selectedTheme == name;
        return GestureDetector(
          onTap: () => settings.setTheme(name),
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: CupertinoColors.activeBlue, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: color.computeLuminance() > 0.5
                      ? CupertinoColors.black
                      : CupertinoColors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
