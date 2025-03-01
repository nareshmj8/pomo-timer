import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:pomo_timer/services/backup_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: settings.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: settings.textColor,
          ),
        ),
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
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoListTile(
                  title: const Text(
                    'Sessions before long break',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                      letterSpacing: -0.3,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: CupertinoColors.systemGrey,
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
                  children: [
                    _buildThemeTile(
                      'Light',
                      CupertinoColors.systemBackground,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CupertinoColors.systemBackground,
                          CupertinoColors.secondarySystemBackground,
                        ],
                      ),
                    ),
                    _buildThemeTile('Citrus Orange', const Color(0xFFFFD9A6)),
                    _buildThemeTile('Rose Quartz', const Color(0xFFF8C8D7)),
                    _buildThemeTile('Seafoam Green', const Color(0xFFD9F2E6)),
                    _buildThemeTile('Lavender Mist', const Color(0xFFE6D9F2)),
                  ],
                ),
              ),
              _buildSectionHeader('Notifications'),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoListTile(
                  title: const Text(
                    'Sound',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    value: settings.soundEnabled,
                    onChanged: (value) => settings.setSoundEnabled(value),
                  ),
                ),
              ),
              _buildSectionHeader('Data'),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    CupertinoListTile(
                      title: const Text(
                        'Export Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      trailing: const Icon(
                        CupertinoIcons.cloud_upload,
                        color: CupertinoColors.activeBlue,
                      ),
                      onTap: () => BackupService.exportData(context, settings),
                    ),
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 16),
                      color: CupertinoColors.separator,
                    ),
                    CupertinoListTile(
                      title: const Text(
                        'Import Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      trailing: const Icon(
                        CupertinoIcons.cloud_download,
                        color: CupertinoColors.activeBlue,
                      ),
                      onTap: () => BackupService.importData(context, settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 4.0,
                  bottom: bottomPadding + 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () => _showResetConfirmation(context),
                    child: const Text(
                      'Reset App Data',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: -0.4,
                      ),
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
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black,
          letterSpacing: -0.5,
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
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.black,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
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
            activeColor: CupertinoColors.activeBlue,
          ),
        ],
      ),
    );
  }

  // Builds a theme selection tile with animation and haptic feedback
  Widget _buildThemeTile(String name, Color color, {LinearGradient? gradient}) {
    return _AnimatedThemeTile(
      name: name,
      color: color,
      gradient: gradient,
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
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Are you sure you want to reset all app data? This action cannot be undone.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'This will reset:\n• Timer settings\n• Break durations\n• Session counts\n• Theme preferences\n• Sound settings\n• History data',
              style: TextStyle(color: CupertinoColors.systemGrey),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              final settings =
                  Provider.of<SettingsProvider>(context, listen: false);

              // Clear all saved data
              await settings.clearAllData();

              // Show confirmation toast
              Navigator.pop(context);
              if (context.mounted) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    message:
                        const Text('All app data has been reset successfully'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Reset',
                style: TextStyle(color: CupertinoColors.systemRed)),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
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
                        style: const TextStyle(fontSize: 20),
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

// Stateful widget for animated theme tile
class _AnimatedThemeTile extends StatefulWidget {
  final String name;
  final Color color;
  final LinearGradient? gradient;

  const _AnimatedThemeTile({
    required this.name,
    required this.color,
    this.gradient,
  });

  @override
  State<_AnimatedThemeTile> createState() => _AnimatedThemeTileState();
}

class _AnimatedThemeTileState extends State<_AnimatedThemeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSelected = settings.selectedTheme == widget.name;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        settings.setTheme(widget.name);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: widget.gradient == null ? widget.color : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey6.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
            border: isSelected
                ? Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.black,
                    letterSpacing: -0.3,
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
                      color: CupertinoColors.activeBlue,
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
      ),
    );
  }
}
