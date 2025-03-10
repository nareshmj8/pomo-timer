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
  _DataSettingsPageState createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends State<DataSettingsPage> {
  final SyncService _syncService = SyncService();
  bool _iCloudSyncEnabled = true;
  bool _isSyncing = false;
  String _lastSyncedTime = 'Not synced yet';

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  // Load saved preferences
  Future<void> _loadSyncPreferences() async {
    final syncEnabled = await _syncService.isSyncEnabled();
    final lastSynced = await _syncService.getLastSyncedTime();

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
          const SnackBar(
            content: Text('Sync failed. Please try again.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                      const Text(
                        'iCloud Sync',
                        style: TextStyle(fontSize: 16),
                      ),
                      CupertinoSwitch(
                        value: _iCloudSyncEnabled,
                        onChanged: (value) async {
                          await _syncService.setSyncEnabled(value);
                          setState(() {
                            _iCloudSyncEnabled = value;
                          });
                        },
                      ),
                    ],
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
                            _iCloudSyncEnabled && !_isSyncing ? _syncNow : null,
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
                            : const Text('Sync Now'),
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
}
