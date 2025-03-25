import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

/// Section for data synchronization settings
class DataSyncSection extends StatefulWidget {
  const DataSyncSection({super.key});

  @override
  State<DataSyncSection> createState() => _DataSyncSectionState();
}

class _DataSyncSectionState extends State<DataSyncSection> {
  bool _iCloudSyncEnabled = false;
  bool _isSyncing = false;
  String _lastSyncedTime = 'Never';

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  void _loadSyncPreferences() {
    // In a real app, this would load from a sync service
    setState(() {
      _iCloudSyncEnabled = false;
      _lastSyncedTime = 'Never';
    });
  }

  Future<void> _syncNow() async {
    if (!_iCloudSyncEnabled) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sync Not Enabled'),
            content:
                const Text('Please enable iCloud sync to use this feature.'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
      _lastSyncedTime = 'Just now';
    });

    // Show success dialog
    if (mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Sync Complete'),
            content:
                const Text('Your data has been successfully synchronized.'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Data Sync'),
            SettingsListTileContainer(
              child: Column(
                children: [
                  // iCloud Sync Toggle
                  CupertinoListTile(
                    title: const Text(
                      'iCloud Sync',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: _iCloudSyncEnabled,
                      onChanged: (value) {
                        setState(() {
                          _iCloudSyncEnabled = value;
                        });
                      },
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: settings.isDarkTheme
                        ? const Color(0xFF38383A)
                        : const Color(0xFFC6C6C8),
                  ),

                  // Sync Status
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Last Synced',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          _lastSyncedTime,
                          style: const TextStyle(
                            fontSize: 17,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: settings.isDarkTheme
                        ? const Color(0xFF38383A)
                        : const Color(0xFFC6C6C8),
                  ),

                  // Sync Now Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isSyncing ? null : _syncNow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSyncing)
                            const CupertinoActivityIndicator()
                          else
                            const Icon(
                              CupertinoIcons.arrow_2_circlepath,
                              color: CupertinoColors.systemBlue,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _isSyncing ? 'Syncing...' : 'Sync Now',
                            style: const TextStyle(
                              fontSize: 17,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SettingsSectionFooter(
              text: _iCloudSyncEnabled
                  ? 'Your data will be synchronized across all your devices.'
                  : 'Enable iCloud sync to keep your data in sync across devices.',
            ),
          ],
        );
      },
    );
  }
}
