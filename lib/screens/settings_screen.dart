import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:pomo_timer/providers/theme_provider.dart';

// StatefulWidget for dynamic settings adjustments
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); // Constructor with optional key

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState(); // Creates state object
}

// State class managing settings UI and user preferences
class _SettingsScreenState extends State<SettingsScreen> {
  // User preference variables with default values
  double sessionDuration = 25; // Work session length in minutes
  double shortBreakDuration = 5; // Short break length in minutes
  double longBreakDuration = 15; // Long break length in minutes
  int sessionsBeforeLongBreak = 4; // Sessions before a long break
  bool soundEnabled = true; // Sound notification toggle

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: Provider.of<ThemeProvider>(context).backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Provider.of<ThemeProvider>(context)
            .backgroundColor
            .withValues(alpha: 204),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Timer Durations'),
              _buildSliderTile(
                'Session Duration',
                '${settings.sessionDuration.round()} min',
                settings.sessionDuration,
                1.0,
                120.0,
                (value) => settings.setSessionDuration(value),
              ),
              _buildSliderTile(
                'Short Break',
                '${settings.shortBreakDuration.round()} min',
                settings.shortBreakDuration,
                1,
                30,
                (value) => settings.setShortBreakDuration(value),
              ),
              _buildSliderTile(
                'Long Break',
                '${settings.longBreakDuration.round()} min',
                settings.longBreakDuration,
                5,
                45,
                (value) => settings.setLongBreakDuration(value),
              ),
              _buildSectionHeader('Session Cycle'),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoListTile(
                  title: const Text(
                    'Sessions before long break',
                    style: TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.label,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _showSessionsPicker(context, settings),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          settings.sessionsBeforeLongBreak.toString(),
                          style: const TextStyle(
                            fontSize: 17,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: CupertinoColors.activeBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSectionHeader('Theme'),
              Container(
                height: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ThemeProvider.availableThemes.map((theme) {
                    return _buildThemeTile(
                      theme.name,
                      theme.backgroundColor ?? theme.primaryColor,
                      gradient: theme.gradient,
                    );
                  }).toList(),
                ),
              ),
              _buildSectionHeader('Notifications'),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoListTile(
                  title: const Text(
                    'Sound',
                    style: TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.label,
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    value: soundEnabled,
                    onChanged: (value) => setState(() => soundEnabled = value),
                  ),
                ),
              ),
              _buildSectionHeader('Data'),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 4.0,
                  bottom: bottomPadding + 16.0,
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => _showResetConfirmation(context),
                  child: const Text(
                    'Reset App Data',
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a consistent section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 32.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Provider.of<ThemeProvider>(context).currentTheme.primaryColor,
        ),
      ),
    );
  }

  // Builds a slider tile for duration settings
  Widget _buildSliderTile(String title, String value, double sliderValue,
      double min, double max, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE8F0FE), // Light blue border
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C7BE5), // Vibrant blue
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: const Color(0xFF2C7BE5), // Vibrant blue
          ),
        ],
      ),
    );
  }

  // Builds a theme selection tile
  Widget _buildThemeTile(String name, Color color, {LinearGradient? gradient}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.currentTheme.name == name;
    return GestureDetector(
      onTap: () => themeProvider.setTheme(name),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2C7BE5) // Vibrant blue
                : const Color(0xFFE8F0FE), // Light blue border
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: gradient != null || color.computeLuminance() < 0.5
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7BE5), // Vibrant blue
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Shows a confirmation dialog for resetting app data
  void _showResetConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Reset App Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Minimize dialog height
          children: const [
            Text(
              'Are you sure you want to reset all app data? This action cannot be undone.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16), // Spacing
            Text(
              'This will remove all your preferences and settings.',
              style: TextStyle(color: CupertinoColors.systemGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // Reset button (destructive action)
          CupertinoDialogAction(
            isDestructiveAction: true, // Red styling
            onPressed: () {
              // TODO: Implement reset logic here
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Reset',
                style: TextStyle(color: CupertinoColors.systemRed)),
          ),
          // Cancel button
          CupertinoDialogAction(
            isDefaultAction: true, // Default action styling
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Shows a sessions picker
  void _showSessionsPicker(BuildContext context, SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250, // Increased height
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ), // Add padding for safe area
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50, // Increased height for Done button
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44, // Increased item height
                  onSelectedItemChanged: (int index) {
                    settings.setSessionsBeforeLongBreak(index + 1);
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: settings.sessionsBeforeLongBreak - 1,
                  ),
                  children: List<Widget>.generate(8, (index) {
                    return Center(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Provider.of<ThemeProvider>(context).textColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
