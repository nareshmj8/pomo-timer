import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/widgets/premium_feature_blur.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/widgets/sync_status_indicator.dart';

/// Data section of the settings screen
class DataSection extends StatefulWidget {
  const DataSection({Key? key}) : super(key: key);

  @override
  State<DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<DataSection> {
  bool _iCloudSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  // Load saved preferences for iCloud sync
  Future<void> _loadSyncPreferences() async {
    final syncService = Provider.of<SyncService>(context, listen: false);
    final syncEnabled = await syncService.isSyncEnabled();

    setState(() {
      _iCloudSyncEnabled = syncEnabled;
    });
  }

  // Sync data with iCloud
  Future<void> _syncNow() async {
    final syncService = Provider.of<SyncService>(context, listen: false);
    await syncService.syncData();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Data'),
        SettingsUIComponents.buildListTileContainer(
          child: PremiumFeatureBlur(
            featureName: 'iCloud Sync',
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

                      // Check if user is premium before enabling
                      final revenueCatService = Provider.of<RevenueCatService>(
                          context,
                          listen: false);

                      if (value && !revenueCatService.isPremium) {
                        // Show premium upgrade dialog
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Premium Feature'),
                            content: const Text(
                                'iCloud Sync is a premium feature. Upgrade to Premium to sync your data across devices.'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Not Now'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: const Text('Upgrade'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate to premium screen
                                  Navigator.of(context).pushNamed('/premium');
                                },
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      await syncService.setSyncEnabled(value);
                      setState(() {
                        _iCloudSyncEnabled = value;
                      });

                      // Show confirmation
                      if (context.mounted) {
                        final message = value
                            ? 'iCloud Sync enabled'
                            : 'iCloud Sync disabled';

                        SettingsUIComponents.showToast(context, message);
                      }
                    },
                    activeTrackColor: settings.isDarkTheme
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

                // Sync status and button section (simplified, no test features)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status indicator
                      const SyncStatusIndicator(
                        showProgressBar: true,
                        detailed: true,
                        showBorder: true,
                        borderRadius: 10,
                      ),

                      const SizedBox(height: 16),

                      // Sync button
                      SyncNowButton(
                        onPressed: _syncNow,
                        label: 'Sync Now',
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
        ),
        SettingsUIComponents.buildSectionFooter(
          'Sync your timer data across all your Apple devices.',
        ),
      ],
    );
  }
}
