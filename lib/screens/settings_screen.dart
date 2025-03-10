import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:pomo_timer/services/backup_service.dart';
import 'settings/data_settings_page.dart';
import '../../services/sync_service.dart';

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
  bool _iCloudSyncEnabled = true;
  bool _isSyncing = false;
  String _lastSyncedTime = 'Not synced yet';

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  // Load saved preferences for iCloud sync
  Future<void> _loadSyncPreferences() async {
    final syncService = Provider.of<SyncService>(context, listen: false);
    final syncEnabled = await syncService.isSyncEnabled();
    final lastSynced = await syncService.getLastSyncedTime();

    setState(() {
      _iCloudSyncEnabled = syncEnabled;
      _lastSyncedTime = lastSynced;
    });
  }

  // Simulate sync process
  Future<void> _syncNow() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    // Use sync service to sync data
    final syncService = Provider.of<SyncService>(context, listen: false);
    final success = await syncService.syncData();

    if (success) {
      // Get updated last synced time
      final lastSynced = await syncService.getLastSyncedTime();

      setState(() {
        _lastSyncedTime = lastSynced;
        _isSyncing = false;
      });

      // Show success message
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Sync Successful'),
            content: const Text('Your data has been synced to iCloud.'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        _isSyncing = false;
      });

      // Show error message
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('Sync Failed'),
            content:
                const Text('Unable to sync your data. Please try again later.'),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

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
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: settings.textColor,
          ),
        ),
        // Add leading button if this is a pushed screen
        leading: Navigator.canPop(context)
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  'Done',
                  style: TextStyle(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timer section
              _buildSectionHeader('Timer'),
              _buildSliderTile(
                'Focus Session',
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
              _buildSectionFooter(
                  'Adjust the duration of your focus sessions and breaks.'),

              // Session Cycle section
              _buildSectionHeader('Session Cycle'),
              _buildListTileContainer(
                child: CupertinoListTile(
                  title: Text(
                    'Sessions before long break',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: settings.listTileTextColor,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: settings.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: settings.isDarkTheme
                              ? CupertinoColors.activeBlue.darkColor
                              : CupertinoColors.activeBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSectionFooter(
                  'Number of focus sessions to complete before taking a long break.'),

              // Theme section with improved UI
              _buildSectionHeader('Appearance'),
              _buildListTileContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Choose a theme for your app',
                        style: TextStyle(
                          fontSize: 14,
                          color: settings.secondaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        children: [
                          _buildThemeTile(
                            'Light',
                            CupertinoColors.white,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CupertinoColors.white,
                                CupertinoColors.systemGrey6,
                              ],
                            ),
                            textColor: CupertinoColors.label,
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey5
                                    .withOpacity(0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          _buildThemeTile(
                            'Dark',
                            const Color(0xFF1C1C1E),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1C1C1E),
                                const Color(0xFF2C2C2E),
                              ],
                            ),
                            textColor: CupertinoColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1C1C1E).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          _buildThemeTile(
                            'Citrus Orange',
                            const Color(0xFFFFD9A6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD9A6).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          _buildThemeTile(
                            'Rose Quartz',
                            const Color(0xFFF8C8D7),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF8C8D7).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          _buildThemeTile(
                            'Seafoam Green',
                            const Color(0xFFD9F2E6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD9F2E6).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          _buildThemeTile(
                            'Lavender Mist',
                            const Color(0xFFE6D9F2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE6D9F2).withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _buildSectionFooter('Choose a theme that matches your style.'),

              // Notifications section
              _buildSectionHeader('Notifications'),
              _buildListTileContainer(
                child: Column(
                  children: [
                    CupertinoListTile(
                      title: Text(
                        'Sound',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: settings.listTileTextColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: settings.soundEnabled,
                        onChanged: (value) => settings.setSoundEnabled(value),
                        activeColor: settings.isDarkTheme
                            ? CupertinoColors.activeBlue.darkColor
                            : CupertinoColors.activeBlue,
                      ),
                    ),
                    // Add more notification options here with dividers between them
                  ],
                ),
              ),
              _buildSectionFooter('Control sound alerts when sessions end.'),

              // Data section
              _buildSectionHeader('Data'),
              _buildListTileContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // iCloud Sync Toggle with explanation
                    CupertinoListTile(
                      leading: Icon(
                        CupertinoIcons.cloud,
                        color: settings.isDarkTheme
                            ? CupertinoColors.activeBlue.darkColor
                            : CupertinoColors.activeBlue,
                      ),
                      title: Text(
                        'iCloud Sync',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: settings.listTileTextColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      subtitle: Text(
                        'Keep your timer data in sync across devices',
                        style: TextStyle(
                          fontSize: 13,
                          color: settings.secondaryTextColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: _iCloudSyncEnabled,
                        onChanged: (value) async {
                          final syncService =
                              Provider.of<SyncService>(context, listen: false);
                          await syncService.setSyncEnabled(value);
                          setState(() {
                            _iCloudSyncEnabled = value;
                          });

                          // Show confirmation
                          if (mounted) {
                            final message = value
                                ? 'iCloud Sync enabled'
                                : 'iCloud Sync disabled';

                            _showToast(context, message);
                          }
                        },
                        activeColor: settings.isDarkTheme
                            ? CupertinoColors.activeBlue.darkColor
                            : CupertinoColors.activeBlue,
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        height: 0.5,
                        color: settings.separatorColor,
                      ),
                    ),

                    // Sync status and button section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status indicator
                          Row(
                            children: [
                              Icon(
                                _iCloudSyncEnabled
                                    ? CupertinoIcons.check_mark_circled
                                    : CupertinoIcons.exclamationmark_circle,
                                color: _iCloudSyncEnabled
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.systemGrey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _iCloudSyncEnabled
                                    ? 'Sync is active'
                                    : 'Sync is disabled',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _iCloudSyncEnabled
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Last synced info
                          Text(
                            'Last Synced: $_lastSyncedTime',
                            style: TextStyle(
                              fontSize: 14,
                              color: settings.secondaryTextColor,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sync Now Button
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: _iCloudSyncEnabled
                                  ? (settings.isDarkTheme
                                      ? CupertinoColors.activeBlue.darkColor
                                      : CupertinoColors.activeBlue)
                                  : CupertinoColors.systemGrey4,
                              disabledColor: CupertinoColors.systemGrey4,
                              borderRadius: BorderRadius.circular(10),
                              onPressed: _iCloudSyncEnabled && !_isSyncing
                                  ? _syncNow
                                  : null,
                              child: _isSyncing
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        CupertinoActivityIndicator(
                                          color: CupertinoColors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Syncing...',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          CupertinoIcons.arrow_2_circlepath,
                                          color: CupertinoColors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sync Now',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          if (!_iCloudSyncEnabled)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Enable iCloud Sync to use this feature',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: settings.secondaryTextColor,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // About section
              _buildSectionHeader('About'),
              _buildListTileContainer(
                child: Column(
                  children: [
                    CupertinoListTile(
                      title: const Text('Version'),
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          color: settings.secondaryTextColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        height: 0.5,
                        color: settings.separatorColor,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                      ),
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                  ],
                ),
              ),

              // Reset section
              _buildSectionHeader('Reset'),
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
                    color: settings.isDarkTheme
                        ? const Color(0xFF3B3B3D)
                        : CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () => _showResetConfirmation(context),
                    child: Text(
                      'Reset App Data',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: settings.isDarkTheme
                            ? CupertinoColors.systemRed
                            : CupertinoColors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
              _buildSectionFooter(
                  'This will reset all settings and data to default values.'),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a consistent section header
  Widget _buildSectionHeader(String title) {
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

  // Creates a section footer with explanation text
  Widget _buildSectionFooter(String text) {
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

  // Builds a slider tile for duration settings
  Widget _buildSliderTile(String title, String value, double sliderValue,
      double min, double max, Function(double) onChanged) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.isDarkTheme
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey5,
            width: 0.5,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: settings.listTileTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: settings.secondaryTextColor,
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
              activeColor: settings.isDarkTheme
                  ? CupertinoColors.activeBlue.darkColor
                  : CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }

  // Builds a theme selection tile with animation and haptic feedback
  Widget _buildThemeTile(String name, Color color,
      {LinearGradient? gradient,
      Color? textColor,
      List<BoxShadow>? boxShadow}) {
    return _AnimatedThemeTile(
      name: name,
      color: color,
      gradient: gradient,
      textColor: textColor,
      boxShadow: boxShadow,
    );
  }

  // Shows a confirmation dialog for resetting app data
  void _showResetConfirmation(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Reset All Settings?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: settings.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'This will reset all settings to their default values. Your data will be permanently deleted and cannot be recovered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settings.textColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: settings.isDarkTheme
                    ? const Color(0xFF2C2C2E)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResetItem('Timer settings'),
                  _buildResetItem('Break durations'),
                  _buildResetItem('Session counts'),
                  _buildResetItem('Theme preferences'),
                  _buildResetItem('Sound settings'),
                  _buildResetItem('History data'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.activeBlue.darkColor
                    : CupertinoColors.activeBlue,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              // Clear all saved data
              await settings.clearAllData();

              // Show confirmation toast
              Navigator.pop(context);
              if (context.mounted) {
                _showToast(context, 'All settings have been reset');
              }
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.systemRed.darkColor
                    : CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for reset dialog items
  Widget _buildResetItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.circle_fill,
            size: 6,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
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
          height: 250,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          color: settings.isDarkTheme
              ? CupertinoColors.systemBackground.darkColor
              : CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: settings.isDarkTheme
                      ? const Color(0xFF1C1C1E)
                      : CupertinoColors.systemGrey6,
                  border: Border(
                    bottom: BorderSide(
                      color: settings.separatorColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: settings.isDarkTheme
                              ? CupertinoColors.activeBlue.darkColor
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
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
                          color: settings.textColor,
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

  Widget _buildListTileContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Container(
        margin: margin ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: settings.isDarkTheme
                ? const Color(0xFF38383A)
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }

  // Show a toast notification
  void _showToast(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () {
      overlay.remove();
    });
  }
}

// Stateful widget for animated theme tile
class _AnimatedThemeTile extends StatefulWidget {
  final String name;
  final Color color;
  final LinearGradient? gradient;
  final Color? textColor;
  final List<BoxShadow>? boxShadow;

  const _AnimatedThemeTile({
    required this.name,
    required this.color,
    this.gradient,
    this.textColor,
    this.boxShadow,
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
            boxShadow: widget.boxShadow,
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
                    color: widget.textColor ??
                        (widget.color.computeLuminance() > 0.5
                            ? CupertinoColors.black
                            : CupertinoColors.white),
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
