import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:provider/provider.dart';
import '../../../services/sync_service.dart';
import '../../../services/revenue_cat_service.dart';
import '../../../widgets/sync_status_indicator.dart';
import 'icloud_sync_test_helper.dart';

class ICloudSyncTestScreen extends StatefulWidget {
  const ICloudSyncTestScreen({Key? key}) : super(key: key);

  @override
  ICloudSyncTestScreenState createState() => ICloudSyncTestScreenState();
}

class ICloudSyncTestScreenState extends State<ICloudSyncTestScreen> {
  bool _isRunningTests = false;
  final List<String> _testLogs = [];

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<SyncService>(context);
    final revenueCatService = Provider.of<RevenueCatService>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('iCloud Sync Tests'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(syncService, revenueCatService),
              const SizedBox(height: 16),
              _buildTestButtons(),
              const SizedBox(height: 16),
              _buildTestLogs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      SyncService syncService, RevenueCatService revenueCatService) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'iCloud Sync Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const SyncStatusIndicator(
              showProgressBar: true,
              detailed: true,
              showBorder: true,
              borderRadius: 10,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatusRow('Premium Status',
                revenueCatService.isPremium ? 'Premium' : 'Free'),
            _buildStatusRow('Sync Enabled',
                syncService.iCloudSyncEnabled ? 'Enabled' : 'Disabled'),
            if (syncService.progressPercentage > 0)
              _buildStatusRow('Progress',
                  '${(syncService.progressPercentage * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _isRunningTests ? null : _runAutomatedTests,
                child: const Text('Run All Tests'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _isRunningTests
                    ? null
                    : () => _testSpecificFeature('premium'),
                child: const Text('Test Premium Check'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SyncNowButton(
                onPressed: () => _testSpecificFeature('sync'),
                label: 'Test Sync',
                height: 42,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _isRunningTests
                    ? null
                    : () => _testSpecificFeature('offline'),
                child: const Text('Test Offline Mode'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _isRunningTests
                    ? null
                    : () => _testSpecificFeature('reset'),
                child: const Text('Reset Status'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestLogs() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Test Logs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _testLogs.clear();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _testLogs.isEmpty
                  ? const Center(
                      child: Text(
                        'No test logs yet',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _testLogs.length,
                      itemBuilder: (context, index) {
                        final log = _testLogs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: log.contains('PASS')
                                  ? CupertinoColors.activeGreen
                                  : log.contains('FAIL')
                                      ? CupertinoColors.systemRed
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAutomatedTests() async {
    setState(() {
      _isRunningTests = true;
      _testLogs
          .add('[${DateTime.now().toString()}] Starting automated tests...');
    });

    try {
      final testHelper = ICloudSyncTestHelper(context);
      await testHelper.runAutomatedTests();

      setState(() {
        _testLogs
            .add('[${DateTime.now().toString()}] Automated tests completed');
      });
    } catch (e) {
      setState(() {
        _testLogs.add('[${DateTime.now().toString()}] ERROR: $e');
      });
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  Future<void> _testSpecificFeature(String feature) async {
    setState(() {
      _isRunningTests = true;
      _testLogs.add('[${DateTime.now().toString()}] Testing $feature...');
    });

    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      final revenueCatService =
          Provider.of<RevenueCatService>(context, listen: false);

      switch (feature) {
        case 'premium':
          final isPremium = revenueCatService.isPremium;
          await syncService.setSyncEnabled(true);
          final syncEnabled = syncService.iCloudSyncEnabled;

          final result = isPremium ? syncEnabled : !syncEnabled;

          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Premium check: ${result ? 'PASS' : 'FAIL'}');
            _testLogs.add('  - Premium status: $isPremium');
            _testLogs.add('  - Sync enabled: $syncEnabled');
          });
          break;

        case 'sync':
          if (!syncService.iCloudSyncEnabled) {
            await syncService.setSyncEnabled(true);
          }

          final syncResult = await syncService.syncData();

          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Sync test: ${syncResult ? 'PASS' : 'FAIL'}');
            _testLogs.add(
                '  - Sync status: ${_getSyncStatusText(syncService.syncStatus)}');
            _testLogs.add('  - Last synced: ${syncService.lastSyncedTime}');
          });
          break;

        case 'offline':
          // Test offline mode by temporarily setting offline status
          if (!syncService.iCloudSyncEnabled) {
            await syncService.setSyncEnabled(true);
            await Future.delayed(const Duration(milliseconds: 300));
          }

          // Set to offline mode
          syncService.setOnlineStatus(false);

          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Setting device to offline mode');
          });

          // Try to sync, should fail gracefully
          await syncService.syncData();
          final waitingStatus =
              syncService.syncStatus == SyncStatus.waitingForConnection;

          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Offline mode test: ${waitingStatus ? 'PASS' : 'FAIL'}');
            _testLogs.add(
                '  - Sync status: ${_getSyncStatusText(syncService.syncStatus)}');
            _testLogs.add('  - Waiting for connection: $waitingStatus');
          });

          // Return to online mode after delay
          await Future.delayed(const Duration(seconds: 2));
          syncService.setOnlineStatus(true);

          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Returning device to online mode');
          });
          break;

        case 'reset':
          // Reset by toggling sync off then on again
          final wasEnabled = syncService.iCloudSyncEnabled;

          if (wasEnabled) {
            await syncService.setSyncEnabled(false);
            await Future.delayed(const Duration(milliseconds: 300));
            await syncService.setSyncEnabled(true);

            setState(() {
              _testLogs.add(
                  '[${DateTime.now().toString()}] Reset sync status: DONE');
              _testLogs.add('  - Sync status reset by toggling off/on');
              _testLogs.add(
                  '  - New status: ${_getSyncStatusText(syncService.syncStatus)}');
            });
          } else {
            setState(() {
              _testLogs.add(
                  '[${DateTime.now().toString()}] Reset sync status: SKIPPED');
              _testLogs.add('  - Sync is currently disabled');
            });
          }
          break;

        default:
          setState(() {
            _testLogs.add(
                '[${DateTime.now().toString()}] Unknown feature: $feature');
          });
      }
    } catch (e) {
      setState(() {
        _testLogs.add('[${DateTime.now().toString()}] ERROR: $e');
      });
    } finally {
      setState(() {
        _isRunningTests = false;
      });
    }
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.notSynced:
        return 'Not Synced';
      case SyncStatus.preparing:
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.merging:
      case SyncStatus.finalizing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.waitingForConnection:
        return 'Waiting for Connection';
    }
  }
}
