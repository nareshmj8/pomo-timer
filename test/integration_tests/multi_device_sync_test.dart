import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomo_timer/services/cloudkit_service.dart';
import 'package:pomo_timer/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MockDevice {
  final String id;
  late CloudKitService cloudKitService;
  late SyncService syncService;
  late SharedPreferences prefs;

  MockDevice(this.id);

  Future<void> initialize(MethodChannel channel) async {
    // Initialize services
    cloudKitService = CloudKitService();
    await cloudKitService.initialize();

    syncService = SyncService(cloudKitService: cloudKitService);
    await syncService.initialize();

    // Get shared preferences instance
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setSessionData({
    required double sessionDuration,
    required double shortBreakDuration,
    required double longBreakDuration,
    required int sessionsBeforeLongBreak,
    required List<String> sessionHistory,
    required int timestamp,
  }) async {
    await prefs.setDouble('session_duration', sessionDuration);
    await prefs.setDouble('short_break_duration', shortBreakDuration);
    await prefs.setDouble('long_break_duration', longBreakDuration);
    await prefs.setInt('sessions_before_long_break', sessionsBeforeLongBreak);
    await prefs.setStringList('session_history', sessionHistory);
    await prefs.setInt('last_modified', timestamp);
  }

  Future<bool> syncData() async {
    return await syncService.syncData();
  }

  Future<Map<String, dynamic>> getLocalData() async {
    return {
      'sessionDuration': prefs.getDouble('session_duration') ?? 25.0,
      'shortBreakDuration': prefs.getDouble('short_break_duration') ?? 5.0,
      'longBreakDuration': prefs.getDouble('long_break_duration') ?? 15.0,
      'sessionsBeforeLongBreak':
          prefs.getInt('sessions_before_long_break') ?? 4,
      'sessionHistory': prefs.getStringList('session_history') ?? [],
      'lastModified': prefs.getInt('last_modified') ?? 0,
    };
  }

  void setOnlineStatus(bool isOnline) {
    syncService.setOnlineStatus(isOnline);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDevice deviceA;
  late MockDevice deviceB;
  late Map<String, dynamic> mockCloudData;

  // Mock channel for CloudKit operations
  const MethodChannel channel = MethodChannel('com.naresh.pomoTimer/cloudkit');

  // Mock CloudKit method channel handler
  Future<dynamic> mockMethodCallHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'isICloudAvailable':
        return true;
      case 'saveData':
        // Store the data in our mock cloud
        final incomingData = Map<String, dynamic>.from(methodCall.arguments);
        final incomingTimestamp = incomingData['lastModified'] as int;
        final existingTimestamp = mockCloudData['lastModified'] as int? ?? 0;

        // Use timestamp-based conflict resolution
        if (mockCloudData.isEmpty || incomingTimestamp > existingTimestamp) {
          mockCloudData = incomingData;
        }
        return true;
      case 'fetchData':
        // Return the mock cloud data
        return mockCloudData;
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

    // Create mock devices
    deviceA = MockDevice('DeviceA');
    deviceB = MockDevice('DeviceB');

    // Initialize devices
    await deviceA.initialize(channel);
    await deviceB.initialize(channel);
  });

  tearDown(() {
    // Clear mock method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Multi-Device Sync Scenarios', () {
    test('Scenario 1: Data syncs correctly between two devices', () async {
      // Device A creates a session
      final now = DateTime.now().millisecondsSinceEpoch;
      await deviceA.setSessionData(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: ['2023-05-01T10:00:00Z'],
        timestamp: now,
      );

      // Device A syncs data
      final syncSuccessA = await deviceA.syncData();
      expect(syncSuccessA, isTrue);

      // Device B syncs data (fetches from cloud)
      final syncSuccessB = await deviceB.syncData();
      expect(syncSuccessB, isTrue);

      // Verify Device B has the same data as Device A
      final deviceBData = await deviceB.getLocalData();
      expect(deviceBData['sessionDuration'], equals(25.0));
      expect(deviceBData['sessionHistory'], contains('2023-05-01T10:00:00Z'));
    });

    test('Scenario 2: Conflict resolution with newer data winning', () async {
      // Device A sets older data
      final olderTimestamp = DateTime.now().millisecondsSinceEpoch - 10000;
      await deviceA.setSessionData(
        sessionDuration: 20.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: ['2023-05-01T09:00:00Z'],
        timestamp: olderTimestamp,
      );

      // Device A syncs data
      await deviceA.syncData();

      // Device B sets newer data
      final newerTimestamp = DateTime.now().millisecondsSinceEpoch;
      await deviceB.setSessionData(
        sessionDuration: 30.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: ['2023-05-01T10:00:00Z'],
        timestamp: newerTimestamp,
      );

      // Device B syncs data
      await deviceB.syncData();

      // Device A syncs again
      await deviceA.syncData();

      // Verify Device A now has Device B's newer data
      final deviceAData = await deviceA.getLocalData();
      expect(deviceAData['sessionDuration'], equals(30.0));
      expect(deviceAData['sessionHistory'], contains('2023-05-01T10:00:00Z'));
    });

    test('Scenario 3: Offline sync queue and processing', () async {
      // Device A goes offline
      deviceA.setOnlineStatus(false);

      // Device A creates a session while offline
      await deviceA.setSessionData(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: ['2023-05-01T10:00:00Z'],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Device A tries to sync while offline
      final offlineSyncResult = await deviceA.syncData();
      expect(offlineSyncResult, isFalse);

      // Device A comes back online
      deviceA.setOnlineStatus(true);

      // Device A syncs again
      final onlineSyncResult = await deviceA.syncData();
      expect(onlineSyncResult, isTrue);

      // Device B syncs
      await deviceB.syncData();

      // Verify Device B received Device A's data
      final deviceBData = await deviceB.getLocalData();
      expect(deviceBData['sessionDuration'], equals(25.0));
      expect(deviceBData['sessionHistory'], contains('2023-05-01T10:00:00Z'));
    });

    test('Scenario 4: Multiple session updates across devices', () async {
      // Initial sync to ensure both devices are in the same state
      await deviceA.syncData();
      await deviceB.syncData();

      // Device A completes a session
      final timestamp1 = DateTime.now().millisecondsSinceEpoch;
      await deviceA.setSessionData(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: ['2023-05-01T10:00:00Z'],
        timestamp: timestamp1,
      );
      await deviceA.syncData();

      // Device B completes another session
      final timestamp2 = timestamp1 + 5000;
      await deviceB.syncData(); // First get Device A's data
      final deviceBData = await deviceB.getLocalData();

      // Add a new session to the history
      List<String> updatedHistory =
          List<String>.from(deviceBData['sessionHistory']);
      updatedHistory.add('2023-05-01T11:00:00Z');

      await deviceB.setSessionData(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        sessionsBeforeLongBreak: 4,
        sessionHistory: updatedHistory,
        timestamp: timestamp2,
      );
      await deviceB.syncData();

      // Device A syncs again
      await deviceA.syncData();

      // Verify Device A has both sessions
      final finalDeviceAData = await deviceA.getLocalData();
      expect(finalDeviceAData['sessionHistory'], hasLength(2));
      expect(
          finalDeviceAData['sessionHistory'], contains('2023-05-01T10:00:00Z'));
      expect(
          finalDeviceAData['sessionHistory'], contains('2023-05-01T11:00:00Z'));
    });

    test('Scenario 5: Settings changes sync correctly', () async {
      // Device A changes settings
      await deviceA.setSessionData(
        sessionDuration: 30.0, // Changed from default 25
        shortBreakDuration: 7.0, // Changed from default 5
        longBreakDuration: 20.0, // Changed from default 15
        sessionsBeforeLongBreak: 5, // Changed from default 4
        sessionHistory: [],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await deviceA.syncData();

      // Device B syncs
      await deviceB.syncData();

      // Verify Device B has the updated settings
      final deviceBData = await deviceB.getLocalData();
      expect(deviceBData['sessionDuration'], equals(30.0));
      expect(deviceBData['shortBreakDuration'], equals(7.0));
      expect(deviceBData['longBreakDuration'], equals(20.0));
      expect(deviceBData['sessionsBeforeLongBreak'], equals(5));
    });
  });
}
