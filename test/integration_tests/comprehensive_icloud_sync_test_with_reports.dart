import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/test_runner.dart';

/// A comprehensive test suite for verifying iCloud sync functionality in the Pomodoro Timer app.
/// This test suite covers all aspects of iCloud sync including:
/// - Initial data sync
/// - Offline mode sync
/// - Conflict resolution
/// - Settings sync
/// - Data integrity
/// - Background sync
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize test runner
  final testRunner = TestRunner();
  await testRunner.initialize();

  late CloudKitService cloudKitService;
  late SyncService syncService;
  late Map<String, dynamic> mockCloudData;
  late bool isOnline;
  late bool iCloudAvailable;

  // Mock channel for CloudKit operations
  const MethodChannel channel =
      MethodChannel('com.naresh.pomodorotimemaster/cloudkit');

  // Test data with explicit types
  final testSessionData = <String, dynamic>{
    'sessionDuration': 25.0,
    'shortBreakDuration': 5.0,
    'longBreakDuration': 15.0,
    'sessionsBeforeLongBreak': 4,
    'selectedTheme': 'Light',
    'soundEnabled': true,
    'selectedSound': 'Bell',
    'soundVolume': 0.5,
    'vibrationEnabled': true,
    'notificationsEnabled': true,
    'keepScreenOn': false,
    'autoStartBreaks': true,
    'autoStartPomodoros': false,
    'sessionHistory': <String>['2023-05-01T10:00:00Z'],
    'lastModified': DateTime.now().millisecondsSinceEpoch,
  };

  // Mock CloudKit method channel handler
  Future<dynamic> mockMethodCallHandler(MethodCall methodCall) async {
    // Add a small delay to simulate network latency
    await Future.delayed(const Duration(milliseconds: 50));

    switch (methodCall.method) {
      case 'isICloudAvailable':
        return true;
      case 'saveData':
        // Store the data in our mock cloud
        final args = methodCall.arguments as Map<dynamic, dynamic>;
        mockCloudData = Map<String, dynamic>.from(args['data']);
        return true;
      case 'fetchData':
        // Return the mock cloud data
        return mockCloudData.isNotEmpty
            ? Map<String, dynamic>.from(mockCloudData)
            : null;
      case 'subscribeToChanges':
        return true;
      case 'processPendingOperations':
        return true;
      default:
        return null;
    }
  }

  setUp(() async {
    // Set up mock shared preferences
    SharedPreferences.setMockInitialValues({});

    // Set up mock method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, mockMethodCallHandler);

    // Initialize mock cloud data
    mockCloudData = {};

    // Set default states
    isOnline = true;
    iCloudAvailable = true;

    // Create services
    cloudKitService = CloudKitService();
    await cloudKitService.initialize();

    syncService = SyncService(cloudKitService: cloudKitService);
    await syncService.initialize();
  });

  tearDown(() {
    // Clear mock method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('1. Initial Data Sync Tests', () {
    testRunner.reportingTest(
        '1.1 Should save timer data to iCloud and verify sync', () async {
      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);
      await prefs.setDouble('short_break_duration',
          testSessionData['shortBreakDuration'] as double);
      await prefs.setDouble('long_break_duration',
          testSessionData['longBreakDuration'] as double);
      await prefs.setInt('sessions_before_long_break',
          testSessionData['sessionsBeforeLongBreak'] as int);
      await prefs.setStringList('session_history',
          (testSessionData['sessionHistory'] as List<String>));

      // Trigger sync
      final success = await syncService.syncData();

      // Verify sync was successful
      expect(success, isTrue);

      // Verify data was saved to mock cloud
      expect(mockCloudData['sessionDuration'],
          equals(testSessionData['sessionDuration']));
      expect(mockCloudData['shortBreakDuration'],
          equals(testSessionData['shortBreakDuration']));
      expect(mockCloudData['longBreakDuration'],
          equals(testSessionData['longBreakDuration']));
      expect(mockCloudData['sessionsBeforeLongBreak'],
          equals(testSessionData['sessionsBeforeLongBreak']));
      expect(mockCloudData['sessionHistory'],
          equals(testSessionData['sessionHistory']));
      expect(mockCloudData['lastModified'], isNotNull);
    });

    testRunner.reportingTest(
        '1.2 Should fetch data from iCloud and update local storage', () async {
      // Simulate data already in iCloud (from another device)
      mockCloudData = Map<String, dynamic>.from(testSessionData);

      // Fetch data
      final cloudData = await cloudKitService.fetchData('session', '1');

      // Verify fetched data matches the expected data
      expect(cloudData, isNotNull);
      expect(cloudData!['sessionDuration'],
          equals(testSessionData['sessionDuration']));
      expect(cloudData['shortBreakDuration'],
          equals(testSessionData['shortBreakDuration']));
      expect(cloudData['longBreakDuration'],
          equals(testSessionData['longBreakDuration']));
      expect(cloudData['sessionsBeforeLongBreak'],
          equals(testSessionData['sessionsBeforeLongBreak']));
      expect(cloudData['sessionHistory'],
          equals(testSessionData['sessionHistory']));
    });

    testRunner.reportingTest('1.3 Should persist data after app restart',
        () async {
      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);
      await prefs.setStringList('session_history',
          (testSessionData['sessionHistory'] as List<String>));

      // Sync data
      await syncService.syncData();

      // Simulate app restart by creating new instances
      final newCloudKitService = CloudKitService();
      await newCloudKitService.initialize();

      final newSyncService = SyncService(cloudKitService: newCloudKitService);
      await newSyncService.initialize();

      // Verify data persists
      final newPrefs = await SharedPreferences.getInstance();
      expect(newPrefs.getDouble('session_duration'),
          equals(testSessionData['sessionDuration']));
      expect(newPrefs.getStringList('session_history'),
          equals(testSessionData['sessionHistory']));
    });
  });

  group('2. Offline Mode Sync Tests', () {
    testRunner.reportingTest('2.1 Should queue operations when offline',
        () async {
      // Set device to offline
      isOnline = false;
      syncService.setOnlineStatus(false);

      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0); // Different from default

      // Try to sync while offline
      final offlineSuccess = await syncService.syncData();

      // Verify sync was not successful but operation was queued
      expect(offlineSuccess, isFalse);
      expect(prefs.getBool('pending_sync'), isTrue);
      expect(mockCloudData.isEmpty, isTrue); // Cloud data should not be updated
    });

    testRunner.reportingTest(
        '2.2 Should sync queued operations when coming back online', () async {
      // Set up local data while offline
      isOnline = false;
      syncService.setOnlineStatus(false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setBool('pending_sync', true);

      // Verify sync fails while offline
      final offlineSuccess = await syncService.syncData();
      expect(offlineSuccess, isFalse);

      // Come back online
      isOnline = true;
      syncService.setOnlineStatus(true);

      // Sync again
      final onlineSuccess = await syncService.syncData();

      // Verify sync was successful
      expect(onlineSuccess, isTrue);
      expect(prefs.getBool('pending_sync'), isFalse);
      expect(mockCloudData['sessionDuration'], equals(30.0));
    });

    testRunner.reportingTest(
        '2.3 Should handle multiple offline changes correctly', () async {
      // Set device to offline
      isOnline = false;
      syncService.setOnlineStatus(false);

      // Make multiple changes while offline
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setDouble('short_break_duration', 8.0);
      await prefs.setDouble('long_break_duration', 20.0);

      // Try to sync (should fail but queue)
      await syncService.syncData();

      // Come back online
      isOnline = true;
      syncService.setOnlineStatus(true);

      // Sync again
      await syncService.syncData();

      // Verify all changes were synced
      expect(mockCloudData['sessionDuration'], equals(30.0));
      expect(mockCloudData['shortBreakDuration'], equals(8.0));
      expect(mockCloudData['longBreakDuration'], equals(20.0));
    });
  });

  group('3. Conflict Resolution Tests', () {
    testRunner.reportingTest(
        '3.1 Should resolve conflicts with latest timestamp winning', () async {
      // Set up older data in cloud
      final olderData = Map<String, dynamic>.from(testSessionData);
      olderData['sessionDuration'] = 20.0;
      olderData['lastModified'] = DateTime.now().millisecondsSinceEpoch - 10000;
      mockCloudData = olderData;

      // Set up newer local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setInt(
          'last_modified', DateTime.now().millisecondsSinceEpoch);

      // Sync data
      await syncService.syncData();

      // Verify newer data won
      expect(mockCloudData['sessionDuration'], equals(30.0));
    });

    testRunner.reportingTest(
        '3.2 Should handle concurrent edits from multiple devices', () async {
      // Simulate Device A (this device)
      final prefs = await SharedPreferences.getInstance();

      // First, sync initial data
      await prefs.setDouble('session_duration', 25.0);
      await prefs.setInt(
          'last_modified', DateTime.now().millisecondsSinceEpoch - 5000);
      await syncService.syncData();

      // Simulate Device B updating data with newer timestamp
      final deviceBData = Map<String, dynamic>.from(testSessionData);
      deviceBData['sessionDuration'] = 35.0;
      deviceBData['lastModified'] = DateTime.now().millisecondsSinceEpoch;
      mockCloudData = deviceBData;

      // Device A makes a local change
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setInt('last_modified',
          DateTime.now().millisecondsSinceEpoch - 2000); // Older than Device B

      // Device A syncs
      await syncService.syncData();

      // Verify Device B's data won (had newer timestamp)
      expect(mockCloudData['sessionDuration'], equals(35.0));

      // Verify local data was updated with cloud data
      expect(prefs.getDouble('session_duration'), equals(35.0));
    });

    testRunner.reportingTest(
        '3.3 Should merge non-conflicting changes correctly', () async {
      // Set up initial data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 25.0);
      await prefs.setDouble('short_break_duration', 5.0);
      await prefs.setInt(
          'last_modified', DateTime.now().millisecondsSinceEpoch - 10000);
      await syncService.syncData();

      // Simulate another device changing different settings
      final otherDeviceData = Map<String, dynamic>.from(mockCloudData);
      otherDeviceData['longBreakDuration'] = 20.0; // Changed only this
      otherDeviceData['lastModified'] =
          DateTime.now().millisecondsSinceEpoch - 5000;
      mockCloudData = otherDeviceData;

      // This device changes different settings
      await prefs.setDouble('session_duration', 30.0); // Changed only this
      await prefs.setInt(
          'last_modified', DateTime.now().millisecondsSinceEpoch);

      // Sync
      await syncService.syncData();

      // Verify this device's changes won (newer timestamp)
      expect(mockCloudData['sessionDuration'], equals(30.0));
      expect(mockCloudData['longBreakDuration'],
          equals(20.0)); // Preserved from other device
    });
  });

  group('4. Settings Sync Tests', () {
    testRunner.reportingTest('4.1 Should sync all app settings correctly',
        () async {
      // Set up various settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setDouble('short_break_duration', 8.0);
      await prefs.setDouble('long_break_duration', 20.0);
      await prefs.setInt('sessions_before_long_break', 5);
      await prefs.setBool('auto_start_breaks', false);
      await prefs.setBool('auto_start_pomodoros', true);
      await prefs.setBool('vibration_enabled', false);
      await prefs.setBool('notifications_enabled', true);
      await prefs.setBool('keep_screen_on', true);
      await prefs.setString('selected_theme', 'Dark');
      await prefs.setBool('sound_enabled', false);
      await prefs.setString('selected_sound', 'Chime');
      await prefs.setDouble('sound_volume', 0.8);

      // Sync data
      await syncService.syncData();

      // Verify all settings were synced
      expect(mockCloudData['sessionDuration'], equals(30.0));
      expect(mockCloudData['shortBreakDuration'], equals(8.0));
      expect(mockCloudData['longBreakDuration'], equals(20.0));
      expect(mockCloudData['sessionsBeforeLongBreak'], equals(5));
      expect(mockCloudData['autoStartBreaks'], equals(false));
      expect(mockCloudData['autoStartPomodoros'], equals(true));
      expect(mockCloudData['vibrationEnabled'], equals(false));
      expect(mockCloudData['notificationsEnabled'], equals(true));
      expect(mockCloudData['keepScreenOn'], equals(true));
      expect(mockCloudData['selectedTheme'], equals('Dark'));
      expect(mockCloudData['soundEnabled'], equals(false));
      expect(mockCloudData['selectedSound'], equals('Chime'));
      expect(mockCloudData['soundVolume'], equals(0.8));
    });

    testRunner.reportingTest('4.2 Should apply synced settings immediately',
        () async {
      // Simulate settings from another device
      final deviceBSettings = Map<String, dynamic>.from(testSessionData);
      deviceBSettings['selectedTheme'] = 'Dark';
      deviceBSettings['soundEnabled'] = false;
      deviceBSettings['selectedSound'] = 'Chime';
      deviceBSettings['lastModified'] = DateTime.now().millisecondsSinceEpoch;
      mockCloudData = deviceBSettings;

      // Sync to pull settings
      await syncService.syncData();

      // Verify local settings were updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_theme'), equals('Dark'));
      expect(prefs.getBool('sound_enabled'), equals(false));
      expect(prefs.getString('selected_sound'), equals('Chime'));
    });
  });

  group('5. Data Integrity Tests', () {
    testRunner.reportingTest(
        '5.1 Should maintain data integrity after multiple sync cycles',
        () async {
      // Set up initial data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 25.0);
      await prefs.setStringList('session_history', ['2023-05-01T10:00:00Z']);
      await syncService.syncData();

      // Perform multiple sync cycles with changes
      for (int i = 0; i < 5; i++) {
        // Update data
        final currentHistory = prefs.getStringList('session_history') ?? [];
        final newHistory = List<String>.from(currentHistory);
        newHistory.add('2023-05-01T${11 + i}:00:00Z');

        await prefs.setStringList('session_history', newHistory);
        await prefs.setInt(
            'last_modified', DateTime.now().millisecondsSinceEpoch);

        // Sync
        await syncService.syncData();
      }

      // Verify data integrity
      final finalHistory = prefs.getStringList('session_history') ?? [];
      expect(finalHistory.length, equals(6)); // Initial + 5 additions
      expect(
          finalHistory, contains('2023-05-01T10:00:00Z')); // Contains initial
      expect(finalHistory,
          contains('2023-05-01T15:00:00Z')); // Contains last addition

      // Verify cloud data matches
      final cloudHistory = mockCloudData['sessionHistory'] as List<dynamic>;
      expect(cloudHistory.length, equals(6));
      expect(cloudHistory, contains('2023-05-01T10:00:00Z'));
      expect(cloudHistory, contains('2023-05-01T15:00:00Z'));
    });

    testRunner.reportingTest('5.2 Should handle empty or null values correctly',
        () async {
      // Set up data with some null or empty values
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 25.0);
      await prefs.setStringList('session_history', []);

      // Sync
      await syncService.syncData();

      // Verify empty list was synced correctly
      expect(mockCloudData['sessionHistory'], isEmpty);

      // Clear some values
      await prefs.remove('session_duration');
      await syncService.syncData();

      // Fetch from cloud to local
      mockCloudData.remove('sessionDuration');
      await syncService.syncData();

      // Verify handling of missing values
      expect(prefs.getDouble('session_duration'), isNull);
    });
  });

  group('6. Background Sync Tests', () {
    testRunner.reportingTest('6.1 Should sync data when app becomes active',
        () async {
      // Set up local data with pending sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setBool('pending_sync', true);

      // Simulate app becoming active by creating new sync service
      final newSyncService = SyncService(cloudKitService: cloudKitService);
      await newSyncService.initialize();

      // Verify data was synced
      expect(mockCloudData['sessionDuration'], equals(30.0));
      expect(prefs.getBool('pending_sync'), isFalse);
    });

    testRunner.reportingTest(
        '6.2 Should process pending operations in background', () async {
      // Set up local data with pending sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setBool('pending_sync', true);

      // Simulate background sync by directly calling processPendingOperations
      final success = await cloudKitService.processPendingOperations();

      // Verify background sync was successful
      expect(success, isTrue);
      expect(mockCloudData['sessionDuration'], equals(30.0));
    });

    testRunner.reportingTest(
        '6.3 Should handle background sync failures gracefully', () async {
      // Set up local data with pending sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);
      await prefs.setBool('pending_sync', true);

      // Simulate network failure
      isOnline = false;

      // Try background sync
      final success = await cloudKitService.processPendingOperations();

      // Verify sync failed but pending flag remains
      expect(success, isFalse);
      expect(prefs.getBool('pending_sync'), isTrue);

      // Restore network and try again
      isOnline = true;
      final retrySuccess = await cloudKitService.processPendingOperations();

      // Verify retry succeeded
      expect(retrySuccess, isTrue);
      expect(mockCloudData['sessionDuration'], equals(30.0));
    });
  });

  group('7. iCloud Availability Tests', () {
    testRunner.reportingTest('7.1 Should handle iCloud becoming unavailable',
        () async {
      // Start with iCloud available
      iCloudAvailable = true;

      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 30.0);

      // Sync successfully
      final initialSuccess = await syncService.syncData();
      expect(initialSuccess, isTrue);

      // Make iCloud unavailable
      iCloudAvailable = false;
      cloudKitService.updateAvailability(false);

      // Try to sync
      final unavailableSuccess = await syncService.syncData();

      // Verify sync failed
      expect(unavailableSuccess, isFalse);

      // Make iCloud available again
      iCloudAvailable = true;
      cloudKitService.updateAvailability(true);

      // Try to sync again
      final retrySuccess = await syncService.syncData();

      // Verify sync succeeded
      expect(retrySuccess, isTrue);
    });

    testRunner.reportingTest('7.2 Should handle iCloud account changes',
        () async {
      // Simulate initial sync with first account
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', 25.0);
      await syncService.syncData();

      // Simulate iCloud account change by clearing cloud data
      mockCloudData = {};

      // Trigger account change notification
      const methodCall =
          MethodCall('onICloudAccountChanged', {'available': true});
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(methodCall),
        (ByteData? data) {},
      );

      // Set new data for new account
      await prefs.setDouble('session_duration', 30.0);
      await syncService.syncData();

      // Verify new account data was synced
      expect(mockCloudData['sessionDuration'], equals(30.0));
    });
  });

  // Generate test reports
  await testRunner.generateReports();
}
