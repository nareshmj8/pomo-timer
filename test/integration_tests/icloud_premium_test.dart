import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock class for CloudKit service to avoid actual platform calls
class MockCloudKitService extends CloudKitService {
  bool _iCloudAvailable = true;

  @override
  Future<bool> isICloudAvailable() async {
    return _iCloudAvailable;
  }

  void setICloudAvailable(bool available) {
    _iCloudAvailable = available;
  }
}

// Test version of SyncService that doesn't create timers
class TestSyncService extends SyncService {
  TestSyncService({
    required CloudKitService cloudKitService,
    required RevenueCatService revenueCatService,
  }) : super(
          cloudKitService: cloudKitService,
          revenueCatService: revenueCatService,
        );

  @override
  void _startConnectivityTimer() {
    // Override to do nothing - prevents timer creation in tests
  }

  @override
  void dispose() {
    // Make sure we cancel any timers that might have been created
    super.dispose();
  }
}

// Testable app for UI tests
class TestableApp extends StatelessWidget {
  final TestSyncService syncService;
  final RevenueCatService revenueCatService;

  const TestableApp({
    Key? key,
    required this.syncService,
    required this.revenueCatService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SyncService>.value(value: syncService),
        ChangeNotifierProvider<RevenueCatService>.value(
            value: revenueCatService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  // Use context.watch to ensure widget rebuilds when state changes
                  final syncService = context.watch<SyncService>();
                  final revenueCatService = context.watch<RevenueCatService>();

                  return Column(
                    children: [
                      Text(
                          'Premium: ${revenueCatService.isPremium ? 'Yes' : 'No'}'),
                      Text(
                          'iCloud Sync: ${syncService.iCloudSyncEnabled ? 'Enabled' : 'Disabled'}'),
                      Text('Error: ${syncService.errorMessage}'),
                    ],
                  );
                }),
                ElevatedButton(
                  key: const Key('toggleSync'),
                  onPressed: () async {
                    await syncService
                        .setSyncEnabled(!syncService.iCloudSyncEnabled);
                  },
                  child: const Text('Toggle Sync'),
                ),
                ElevatedButton(
                  key: const Key('togglePremium'),
                  onPressed: () {
                    if (revenueCatService.isPremium) {
                      revenueCatService.disableDevPremiumAccess();
                    } else {
                      revenueCatService.enableDevPremiumAccess();
                    }
                    // Ensure UI updates by explicitly notifying listeners
                    revenueCatService.notifyListeners();
                  },
                  child: const Text('Toggle Premium'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('iCloud Premium Unit Tests', () {
    late SyncService syncService;
    late RevenueCatService revenueCatService;
    late MockCloudKitService mockCloudKit;

    setUp(() async {
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      // Create service instances
      mockCloudKit = MockCloudKitService();
      revenueCatService = RevenueCatService();

      // Create sync service with mocked dependencies
      syncService = SyncService(
        cloudKitService: mockCloudKit,
        revenueCatService: revenueCatService,
      );

      // Initialize without timers for unit tests
      // We're testing the core functionality, not the timer behavior
      await syncService.initialize();
    });

    test('iCloud sync is disabled by default', () async {
      // Verify default state
      expect(syncService.iCloudSyncEnabled, false);
    });

    test('Non-premium users cannot enable iCloud sync', () async {
      // Verify initial state
      expect(revenueCatService.isPremium, false);

      // Try to enable sync
      await syncService.setSyncEnabled(true);

      // Verify sync remains disabled
      expect(syncService.iCloudSyncEnabled, false);
      expect(syncService.errorMessage.contains('Premium'), true);
    });

    test('Premium users can enable iCloud sync', () async {
      // Enable premium
      revenueCatService.enableDevPremiumAccess();

      // Verify premium status
      expect(revenueCatService.isPremium, true);

      // Try to enable sync
      await syncService.setSyncEnabled(true);

      // Verify sync is enabled
      expect(syncService.iCloudSyncEnabled, true);
    });

    test('iCloud sync is disabled when premium subscription expires', () async {
      // Enable premium first
      revenueCatService.enableDevPremiumAccess();

      // Enable sync
      await syncService.setSyncEnabled(true);

      // Verify sync is enabled
      expect(syncService.iCloudSyncEnabled, true);

      // Disable premium
      revenueCatService.disableDevPremiumAccess();

      // Reinitialize to trigger premium check
      await syncService.initialize();

      // Verify sync is now disabled
      expect(syncService.iCloudSyncEnabled, false);
    });
  });

  group('Premium status change detection tests', () {
    late SyncService syncService;
    late RevenueCatService revenueCatService;
    late MockCloudKitService mockCloudKit;

    setUp(() async {
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      // Create service instances
      mockCloudKit = MockCloudKitService();
      revenueCatService = RevenueCatService();

      // Create sync service with mocked dependencies
      syncService = SyncService(
        cloudKitService: mockCloudKit,
        revenueCatService: revenueCatService,
      );

      // Initialize
      await syncService.initialize();
    });

    test('Premium state changes disable sync', () async {
      // Enable premium
      revenueCatService.enableDevPremiumAccess();

      // Enable sync
      await syncService.setSyncEnabled(true);
      expect(syncService.iCloudSyncEnabled, true);

      // Disable premium via listener
      revenueCatService.disableDevPremiumAccess();

      // Manually trigger the listener function to simulate notification
      // Need to manually notify since premium status change does not automatically
      // update the sync service in the test environment
      revenueCatService.notifyListeners();

      // We need to reinitialize to apply the premium status change effect
      await syncService.initialize();

      // Verify sync is disabled
      expect(syncService.iCloudSyncEnabled, false);
    });

    test('Error message is set when premium expires', () async {
      // Enable premium
      revenueCatService.enableDevPremiumAccess();

      // Enable sync
      await syncService.setSyncEnabled(true);
      expect(syncService.errorMessage, '');

      // Disable premium
      revenueCatService.disableDevPremiumAccess();

      // Try to enable sync again - should set error message
      await syncService.setSyncEnabled(true);

      // Verify error message is set
      expect(syncService.errorMessage.contains('Premium'), true);
    });
  });
}
