import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/sync_service.dart';
import '../../../services/revenue_cat_service.dart';
import '../../../services/cloudkit_service.dart';

/// Helper class for testing iCloud sync functionality
class ICloudSyncTestHelper {
  final BuildContext context;

  ICloudSyncTestHelper(this.context);

  /// Run automated tests for iCloud sync
  Future<void> runAutomatedTests() async {
    final syncService = Provider.of<SyncService>(context, listen: false);
    final revenueCatService =
        Provider.of<RevenueCatService>(context, listen: false);

    // Show test progress dialog
    final testResults = await _showTestProgressDialog(() async {
      final results = <String, bool>{};

      // Test 1: Verify premium status check
      results['Premium Status Check'] =
          await _testPremiumStatusCheck(revenueCatService, syncService);

      // Test 2: Verify sync enable/disable
      results['Sync Enable/Disable'] =
          await _testSyncEnableDisable(syncService, revenueCatService);

      // Test 3: Verify data sync
      results['Data Sync'] = await _testDataSync(syncService);

      // Test 4: Verify network error handling
      results['Network Error Handling'] =
          await _testNetworkErrorHandling(syncService);

      // Test 5: Verify sync persistence
      results['Sync Persistence'] = await _testSyncPersistence(syncService);

      return results;
    });

    // Show test results
    _showTestResultsDialog(testResults);
  }

  /// Test premium status check
  Future<bool> _testPremiumStatusCheck(
      RevenueCatService revenueCatService, SyncService syncService) async {
    try {
      // Check if user is premium
      final isPremium = revenueCatService.isPremium;

      // Try to enable sync
      await syncService.setSyncEnabled(true);

      // Verify sync is enabled only if user is premium
      if (isPremium) {
        return syncService.iCloudSyncEnabled;
      } else {
        return !syncService.iCloudSyncEnabled;
      }
    } catch (e) {
      debugPrint('Error testing premium status check: $e');
      return false;
    }
  }

  /// Test sync enable/disable
  Future<bool> _testSyncEnableDisable(
      SyncService syncService, RevenueCatService revenueCatService) async {
    try {
      // Skip test if user is not premium
      if (!revenueCatService.isPremium) {
        return true;
      }

      // Enable sync
      await syncService.setSyncEnabled(true);
      final enabledResult = syncService.iCloudSyncEnabled;

      // Disable sync
      await syncService.setSyncEnabled(false);
      final disabledResult = !syncService.iCloudSyncEnabled;

      return enabledResult && disabledResult;
    } catch (e) {
      debugPrint('Error testing sync enable/disable: $e');
      return false;
    }
  }

  /// Test data sync
  Future<bool> _testDataSync(SyncService syncService) async {
    try {
      // Skip test if sync is not enabled
      if (!syncService.iCloudSyncEnabled) {
        return true;
      }

      // Add test data to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('icloud_sync_test_key',
          'test_value_${DateTime.now().millisecondsSinceEpoch}');

      // Sync data
      final syncResult = await syncService.syncData();

      return syncResult;
    } catch (e) {
      debugPrint('Error testing data sync: $e');
      return false;
    }
  }

  /// Test network error handling
  Future<bool> _testNetworkErrorHandling(SyncService syncService) async {
    try {
      // Skip test if sync is not enabled
      if (!syncService.iCloudSyncEnabled) {
        return true;
      }

      // Temporarily force the service into offline mode
      syncService.setOnlineStatus(false);

      // Try to sync, which should queue the operation due to being offline
      await syncService.syncData();

      // Check if sync service shows waiting for connection status
      final waitingStatus =
          syncService.syncStatus == SyncStatus.waitingForConnection;

      // Return to online mode
      syncService.setOnlineStatus(true);

      // Allow time for connection change to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if sync service handles the error and waiting state gracefully
      return waitingStatus;
    } catch (e) {
      debugPrint('Error testing network error handling: $e');
      return false;
    }
  }

  /// Test sync persistence
  Future<bool> _testSyncPersistence(SyncService syncService) async {
    try {
      // Get current sync enabled state
      final currentState = syncService.iCloudSyncEnabled;

      // Toggle sync state
      await syncService.setSyncEnabled(!currentState);

      // Create a new instance of SyncService to verify persistence
      final newSyncService = SyncService(
        cloudKitService: CloudKitService(),
        revenueCatService:
            Provider.of<RevenueCatService>(context, listen: false),
      );
      await newSyncService.initialize();

      // Check if the new instance has the same state
      final persistedState = newSyncService.iCloudSyncEnabled;

      // Restore original state
      await syncService.setSyncEnabled(currentState);

      return persistedState == !currentState;
    } catch (e) {
      debugPrint('Error testing sync persistence: $e');
      return false;
    }
  }

  /// Show test progress dialog
  Future<Map<String, bool>> _showTestProgressDialog(
      Future<Map<String, bool>> Function() testFunction) async {
    // Unused variable
    // final completer = Completer<Map<String, bool>>();

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text('Running iCloud Sync Tests'),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );

    // Run tests
    final results = await testFunction();

    // Close dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    return results;
  }

  /// Show test results dialog
  void _showTestResultsDialog(Map<String, bool> results) {
    final passedTests = results.values.where((result) => result).length;
    final totalTests = results.length;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Test Results: $passedTests/$totalTests Passed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: results.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Icon(
                      entry.value
                          ? CupertinoIcons.check_mark_circled
                          : CupertinoIcons.xmark_circle,
                      color: entry.value
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemRed,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
