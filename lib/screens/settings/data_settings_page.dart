import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        CircularProgressIndicator,
        AlwaysStoppedAnimation,
        ScaffoldMessenger,
        SnackBar,
        SnackBarBehavior;
import '../../services/sync_service.dart';

class DataSettingsPage extends StatefulWidget {
  const DataSettingsPage({Key? key}) : super(key: key);

  @override
  DataSettingsPageState createState() => DataSettingsPageState();
}

class DataSettingsPageState extends State<DataSettingsPage> {
  final SyncService _syncService = SyncService();
  bool _iCloudSyncEnabled = false;
  bool _isSyncing = false;
  String _lastSyncedTime = 'Not synced yet';
  bool _isPremium = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  // Load saved preferences
  Future<void> _loadSyncPreferences() async {
    final syncEnabled = await _syncService.isSyncEnabled();
    final lastSynced = await _syncService.getLastSyncedTime();
    final isPremium = _syncService.isPremium;
    final errorMessage = _syncService.errorMessage;

    setState(() {
      _iCloudSyncEnabled = syncEnabled;
      _lastSyncedTime = lastSynced;
      _isPremium = isPremium;
      _errorMessage = errorMessage;
    });

    // Listen for changes in sync status
    _syncService.addListener(_onSyncServiceChanged);
  }

  // Handle sync service changes
  void _onSyncServiceChanged() {
    setState(() {
      _iCloudSyncEnabled = _syncService.iCloudSyncEnabled;
      _isSyncing = _syncService.isSyncing;
      _lastSyncedTime = _syncService.lastSyncedTime;
      _isPremium = _syncService.isPremium;
      _errorMessage = _syncService.errorMessage;
    });
  }

  // Simulate sync process
  Future<void> _syncNow() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    // Use sync service to sync data
    final success = await _syncService.syncData();

    if (success) {
      // Get updated last synced time
      final lastSynced = await _syncService.getLastSyncedTime();

      setState(() {
        _lastSyncedTime = lastSynced;
        _isSyncing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync successful!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        _isSyncing = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage.isNotEmpty
                ? _errorMessage
                : 'Sync failed. Please try again.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show premium upgrade dialog
  void _showPremiumUpgradeDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Premium Feature'),
          content: const Text(
              'iCloud Sync is a premium feature. Upgrade to Premium to sync your data across devices.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Data Settings'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // iCloud Sync Toggle
              Container(
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'iCloud Sync',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (!_isPremium)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemYellow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: _iCloudSyncEnabled,
                        onChanged: (value) async {
                          if (value && !_isPremium) {
                            _showPremiumUpgradeDialog();
                          } else {
                            await _syncService.setSyncEnabled(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Premium required message
              if (!_isPremium)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'iCloud Sync is a premium feature. Upgrade to Premium to sync your data across devices.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Sync Now Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoButton.filled(
                        onPressed:
                            _isPremium && _iCloudSyncEnabled && !_isSyncing
                                ? _syncNow
                                : _isPremium
                                    ? null
                                    : _showPremiumUpgradeDialog,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _isPremium ? 'Sync Now' : 'Upgrade to Premium'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Last Synced: $_lastSyncedTime',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncServiceChanged);
    super.dispose();
  }
}
