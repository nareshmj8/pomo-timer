import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_cloudkit_service.dart';
import '../mocks/mock_notification_service.dart';
import '../mocks/mock_revenue_cat_service.dart';
import '../mocks/mock_sync_service.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final MockRevenueCatService revenueCatService;
  final MockCloudKitService cloudKitService;
  final MockSyncService syncService;
  final SharedPreferences prefs;

  const TestApp({
    Key? key,
    required this.child,
    required this.revenueCatService,
    required this.cloudKitService,
    required this.syncService,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockRevenueCatService>.value(
          value: revenueCatService,
        ),
        ChangeNotifierProvider<MockCloudKitService>.value(
          value: cloudKitService,
        ),
        ChangeNotifierProvider<MockSyncService>.value(
          value: syncService,
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

class ICloudSyncTestWidget extends StatelessWidget {
  const ICloudSyncTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<MockSyncService>(context);
    final revenueCatService = Provider.of<MockRevenueCatService>(context);
    final cloudKitService = Provider.of<MockCloudKitService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('iCloud Sync Test')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('iCloud Sync Enabled'),
            subtitle: Text(syncService.iCloudSyncEnabled.toString()),
            trailing: Switch(
              value: syncService.iCloudSyncEnabled,
              onChanged: (value) async {
                if (!revenueCatService.isPremium && value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium required for iCloud sync'),
                    ),
                  );
                  return;
                }
                await syncService.setSyncEnabled(value);
              },
            ),
          ),
          ListTile(
            title: const Text('Premium Status'),
            subtitle: Text(revenueCatService.isPremium.toString()),
            trailing: Switch(
              value: revenueCatService.isPremium,
              onChanged: (value) {
                if (value) {
                  revenueCatService.enableDevPremiumAccess();
                } else {
                  revenueCatService.disableDevPremiumAccess();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('iCloud Available'),
            subtitle: Text(cloudKitService.isAvailable.toString()),
            trailing: Switch(
              value: cloudKitService.isAvailable,
              onChanged: (value) {
                cloudKitService.setAvailability(value);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await syncService.syncData();
            },
            child: const Text('Sync Data'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sync Status: ${syncService.syncStatus}'),
                Text('Last Synced: ${syncService.lastSyncedTime}'),
                Text('Error: ${syncService.errorMessage}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRevenueCatService revenueCatService;
  late MockCloudKitService cloudKitService;
  late MockSyncService syncService;
  late MockNotificationService notificationService;
  late SharedPreferences prefs;

  setUp(() async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Initialize mocks
    cloudKitService = MockCloudKitService();
    await cloudKitService.initialize();

    revenueCatService = MockRevenueCatService();
    await revenueCatService.initialize();

    notificationService = MockNotificationService();
    await notificationService.initialize();

    // Initialize sync service with revenue cat service
    syncService =
        MockSyncService(cloudKitService, revenueCatService: revenueCatService);
    await syncService.initialize();

    // Initialize service locator with mocks
    final serviceLocator = ServiceLocator();
    serviceLocator.registerNotificationService(notificationService);
    serviceLocator.registerRevenueCatService(revenueCatService);
    // Note: CloudKitService doesn't have a registration method in ServiceLocator
  });

  tearDown(() {
    // Reset service locator
    final serviceLocator = ServiceLocator();
    serviceLocator.reset();
  });

  group('iCloud Sync Basic Tests', () {
    testWidgets('iCloud sync is disabled by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Verify iCloud sync is disabled by default
      expect(syncService.iCloudSyncEnabled, isFalse);
      expect(find.text('iCloud Sync Enabled'), findsOneWidget);
      expect(find.text('false'), findsAtLeastNWidgets(1));
    });

    testWidgets('Non-premium users cannot enable iCloud sync',
        (WidgetTester tester) async {
      // Ensure user is not premium
      revenueCatService.disableDevPremiumAccess();

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Try to enable iCloud sync by tapping the switch
      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      // Verify iCloud sync remains disabled
      expect(syncService.iCloudSyncEnabled, isFalse);
      expect(find.text('Premium required for iCloud sync'), findsOneWidget);
    });

    testWidgets('Premium users can enable iCloud sync',
        (WidgetTester tester) async {
      // Make user premium
      revenueCatService.enableDevPremiumAccess();

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Verify user is premium
      expect(revenueCatService.isPremium, isTrue);

      // Try to enable iCloud sync by tapping the switch
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Verify iCloud sync is enabled
      expect(syncService.iCloudSyncEnabled, isTrue);
    });
  });

  group('iCloud Availability Tests', () {
    testWidgets('Should handle iCloud becoming unavailable',
        (WidgetTester tester) async {
      // Make user premium and enable sync
      revenueCatService.enableDevPremiumAccess();
      await syncService.setSyncEnabled(true);

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Verify sync is enabled
      expect(syncService.iCloudSyncEnabled, isTrue);

      // Make iCloud unavailable
      await tester.tap(find
          .byType(Switch)
          .at(2)); // Third switch controls iCloud availability
      await tester.pumpAndSettle();

      // Verify iCloud is unavailable
      expect(cloudKitService.isAvailable, isFalse);

      // Try to sync
      await tester.tap(find.text('Sync Data'));
      await tester.pumpAndSettle();

      // Verify sync status reflects unavailability
      expect(syncService.syncStatus, equals(SyncStatus.failed));
      expect(syncService.errorMessage.isNotEmpty, isTrue);
      expect(syncService.errorMessage, contains('iCloud is not available'));
    });

    testWidgets('Should sync when iCloud becomes available again',
        (WidgetTester tester) async {
      // Make user premium and enable sync but iCloud unavailable
      revenueCatService.enableDevPremiumAccess();
      await syncService.setSyncEnabled(true);
      cloudKitService.setAvailability(false);

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Verify iCloud is unavailable
      expect(cloudKitService.isAvailable, isFalse);

      // Try to sync
      await tester.tap(find.text('Sync Data'));
      await tester.pumpAndSettle();

      // Verify sync failed
      expect(syncService.syncStatus, equals(SyncStatus.failed));

      // Make iCloud available again
      await tester.tap(find.byType(Switch).at(2));
      await tester.pumpAndSettle();

      // Verify iCloud is available
      expect(cloudKitService.isAvailable, isTrue);

      // Try to sync again
      await tester.tap(find.text('Sync Data'));
      await tester.pumpAndSettle();

      // Verify sync succeeded
      expect(syncService.syncStatus, equals(SyncStatus.synced));
    });
  });

  group('Premium Status Change Tests', () {
    testWidgets('iCloud sync is disabled when premium subscription expires',
        (WidgetTester tester) async {
      // Make user premium and enable sync
      revenueCatService.enableDevPremiumAccess();
      await syncService.setSyncEnabled(true);

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          cloudKitService: cloudKitService,
          syncService: syncService,
          prefs: prefs,
          child: const ICloudSyncTestWidget(),
        ),
      );

      // Verify sync is enabled
      expect(syncService.iCloudSyncEnabled, isTrue);

      // Make premium expire
      await tester.tap(
          find.byType(Switch).at(1)); // Second switch controls premium status
      await tester.pumpAndSettle();

      // Verify premium is now false
      expect(revenueCatService.isPremium, isFalse);

      // Try to sync - this should trigger a check and disable sync
      await tester.tap(find.text('Sync Data'));
      await tester.pumpAndSettle();

      // Verify sync is now disabled or marked as failed
      expect(syncService.syncStatus, equals(SyncStatus.failed));
      expect(
          syncService.errorMessage, contains('Premium subscription required'));
    });
  });
}
