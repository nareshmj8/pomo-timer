import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

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
  String selectedTheme = 'Light'; // Current theme selection

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Get bottom padding to account for system UI (e.g., home indicator)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // CupertinoPageScaffold provides an iOS-style layout
    return CupertinoPageScaffold(
      // Top navigation bar with settings title
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'), // Centered title
        backgroundColor:
            CupertinoColors.systemBackground, // iOS background color
        border: null, // No border for cleaner look
      ),
      // SingleChildScrollView makes content scrollable
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 8.0, // Top padding
          left: 16.0, // Left padding
          right: 16.0, // Right padding
          bottom: bottomPadding + 100, // Extra bottom padding for UX
        ),
        // SafeArea ensures content avoids system UI overlaps
        child: SafeArea(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items to the left
            children: [
              // Timer Durations Section
              _buildSectionHeader('Timer Durations'), // Section title
              _buildSliderTile(
                'Session Duration',
                '${settings.sessionDuration.round()} min',
                settings.sessionDuration,
                1.0, // session duration slider
                120.0,
                (value) => settings.setSessionDuration(value),
              ),
              _buildSliderTile(
                'Short Break Duration',
                '${settings.shortBreakDuration.round()} min',
                settings.shortBreakDuration,
                1,
                30,
                (value) => settings.setShortBreakDuration(value),
              ),
              _buildSliderTile(
                'Long Break Duration',
                '${settings.longBreakDuration.round()} min',
                settings.longBreakDuration,
                5,
                45,
                (value) => settings.setLongBreakDuration(value),
              ),
              const SizedBox(height: 24), // Spacing between sections

              // Session Cycle Section
              _buildSectionHeader('Session Cycle'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sessions before long break'),
                    GestureDetector(
                      onTap: () {
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
                                    height:
                                        50, // Increased height for Done button
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      itemExtent: 44, // Increased item height
                                      onSelectedItemChanged: (int index) {
                                        settings.setSessionsBeforeLongBreak(
                                            index + 1);
                                      },
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem:
                                            settings.sessionsBeforeLongBreak -
                                                1,
                                      ),
                                      children:
                                          List<Widget>.generate(8, (index) {
                                        return Center(
                                          child: Text(
                                            (index + 1).toString(),
                                            style:
                                                const TextStyle(fontSize: 20),
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
                      },
                      child: Row(
                        children: [
                          Text(
                            settings.sessionsBeforeLongBreak.toString(),
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: CupertinoColors.activeBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Themes Section
              _buildSectionHeader('Themes'),
              Container(
                height: 100, // Fixed height for horizontal list
                padding:
                    const EdgeInsets.symmetric(vertical: 8), // Vertical padding
                child: ListView(
                  scrollDirection: Axis.horizontal, // Horizontal scrolling
                  children: [
                    _buildThemeTile(
                        'Light', CupertinoColors.systemGrey5), // Light theme
                    _buildThemeTile(
                        'Dark', CupertinoColors.black), // Dark theme
                    _buildThemeTile(
                        'Calm', const Color(0xFF7CA5B8)), // Custom calm theme
                    _buildThemeTile('Forest',
                        const Color(0xFF2D5A27)), // Custom forest theme
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sound'), // Label
                    CupertinoSwitch(
                      value: soundEnabled, // Current state
                      onChanged: (value) =>
                          setState(() => soundEnabled = value), // Toggle switch
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('Data Management'),
              Container(
                width: double.infinity, // Full width button
                padding: const EdgeInsets.only(
                    bottom:
                        32.0), // Bottom padding (likely a typo, should be 'bottom')
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // Button padding
                  color: CupertinoColors.systemGrey5, // Button background
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  onPressed: () =>
                      _showResetConfirmation(context), // Show reset dialog
                  child: const Text(
                    'Reset App Data',
                    style: TextStyle(
                      color: CupertinoColors.systemRed, // Red text for warning
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
          bottom: 8.0), // Bottom padding (likely a typo, should be 'bottom')
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Builds a slider tile for duration settings
  Widget _buildSliderTile(String title, String value, double sliderValue,
      double min, double max, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16), // Inner padding
      margin: const EdgeInsets.only(
          bottom: 8), // Bottom margin (likely a typo, should be 'bottom')
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // Light gray background
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to left
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space out title and value
            children: [
              Text(title), // Setting name
              Text(value), // Current value (e.g., "25 min")
            ],
          ),
          const SizedBox(height: 8), // Spacing
          CupertinoSlider(
            value: sliderValue, // Current slider position
            min: min, // Minimum value
            max: max, // Maximum value
            onChanged: onChanged, // Update value on slide
          ),
        ],
      ),
    );
  }

  // Builds a theme selection tile
  Widget _buildThemeTile(String name, Color color) {
    final isSelected = selectedTheme == name; // Check if this theme is selected
    return GestureDetector(
      onTap: () =>
          setState(() => selectedTheme = name), // Update selected theme
      child: Container(
        width: 80, // Fixed width
        margin: const EdgeInsets.only(right: 12), // Space between tiles
        decoration: BoxDecoration(
          color: color, // Theme color
          borderRadius: BorderRadius.circular(8), // Rounded corners
          border: isSelected
              ? Border.all(
                  color: CupertinoColors.activeBlue,
                  width: 2) // Highlight if selected
              : null,
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              // Text color adapts to background luminance (light or dark)
              color: color.computeLuminance() > 0.5
                  ? CupertinoColors.black
                  : CupertinoColors.white,
            ),
          ),
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
}
