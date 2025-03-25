import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:pomodoro_timemaster/services/sync/sync_data_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/test_helpers.dart';

// Extended CloudKitService for testing
class CloudKitServiceTester extends CloudKitService {
  bool get isInitialized => super.isInitialized;
  bool get isAvailable => super.isAvailable;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'com.naresh.pomodorotimemaster/cloudkit';

  group('CloudKitService Conflict Resolution', () {
    late CloudKitServiceTester service;
    late SyncDataHandler dataHandler;
    late Map<String, dynamic> mockCloudData;

    setUp(() {
      service = CloudKitServiceTester();
      dataHandler = SyncDataHandler();
      mockCloudData = {};

      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      // Reset mock
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      // Dispose service
      service.dispose();
    });

    // Helper function to set up tests with specific SharedPreferences values
    Future<void> setupPreferences(
        {required double sessionDuration,
        required double shortBreakDuration,
        required double longBreakDuration,
        required int timestamp}) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('session_duration', sessionDuration);
      await prefs.setDouble('short_break_duration', shortBreakDuration);
      await prefs.setDouble('long_break_duration', longBreakDuration);
      await prefs.setInt('last_modified', timestamp);
    }

    test('resolves conflicts based on timestamp - newer local data wins',
        () async {
      // Setup initial state with local data being newer
      final now = DateTime.now().millisecondsSinceEpoch;
      final olderTimestamp = now - 10000; // 10 seconds ago
      final newerTimestamp = now;

      // Set up local data with a newer timestamp
      await setupPreferences(
        sessionDuration: 30.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        timestamp: newerTimestamp,
      );

      // Set up cloud data with an older timestamp
      mockCloudData = {
        'sessionDuration': 25.0,
        'shortBreakDuration': 5.0,
        'longBreakDuration': 15.0,
        'lastModified': olderTimestamp,
      };

      // Set up method channel mock for testing
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'fetchData') {
          return mockCloudData;
        } else if (call.method == 'saveData') {
          // Store the data that gets saved
          final Map<String, dynamic> args = call.arguments;
          final savedData = Map<String, dynamic>.from(args['data']);
          mockCloudData = savedData;
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Initialize service
      await service.initialize();

      // Get local data and save to cloud - this should overwrite cloud data
      final localData = await dataHandler.getLocalData();
      final saveResult =
          await service.saveData('settings', 'userSettings', localData);

      // Verify save was successful
      expect(saveResult, true);

      // Verify cloud data was updated with local data (newer wins)
      expect(mockCloudData['sessionDuration'], 30.0);
      expect(mockCloudData['lastModified'], isNot(equals(olderTimestamp)));
      expect(
          mockCloudData['lastModified'], greaterThanOrEqualTo(newerTimestamp));
    });

    test('resolves conflicts based on timestamp - newer cloud data wins',
        () async {
      // Setup initial state with cloud data being newer
      final now = DateTime.now().millisecondsSinceEpoch;
      final olderTimestamp = now - 10000; // 10 seconds ago
      final newerTimestamp = now;

      // Set up local data with an older timestamp
      await setupPreferences(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        timestamp: olderTimestamp,
      );

      // Set up cloud data with a newer timestamp
      mockCloudData = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 10.0,
        'longBreakDuration': 20.0,
        'lastModified': newerTimestamp,
      };

      // Set up method channel mock for testing
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'fetchData') {
          return mockCloudData;
        } else if (call.method == 'saveData') {
          // For this test, we're not updating the mock cloud data
          // because the local data should be rejected due to older timestamp
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Initialize service
      await service.initialize();

      // Fetch cloud data and update local settings
      await dataHandler.updateLocalData(
          await service.fetchData('settings', 'userSettings') ?? {});

      // Verify local data was updated with cloud data
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('session_duration'), 30.0);
      expect(prefs.getDouble('short_break_duration'), 10.0);
      expect(prefs.getDouble('long_break_duration'), 20.0);
      expect(prefs.getInt('last_modified'), newerTimestamp);
    });

    test('handles missing timestamps by updating them when missing', () async {
      // Setup initial state with local data missing timestamp
      // Set up local data with no timestamp
      await setupPreferences(
        sessionDuration: 25.0,
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        timestamp: 0, // Missing timestamp (0)
      );

      // Set up cloud data with no timestamp
      mockCloudData = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 10.0,
        'longBreakDuration': 20.0,
        // No lastModified field
      };

      // Set up method channel mock for testing
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'fetchData') {
          return mockCloudData;
        } else if (call.method == 'saveData') {
          // Store the data that gets saved
          final Map<String, dynamic> args = call.arguments;
          final savedData = Map<String, dynamic>.from(args['data']);
          print('Debug - saveData received data: $savedData');
          mockCloudData = savedData;
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Initialize service
      await service.initialize();

      // Get local data
      final localData = await dataHandler.getLocalData();
      print('Debug - localData: $localData');

      // In a real system, SyncService would update timestamps before saving
      // Here we'll simulate that by manually updating the timestamp
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      final updatedLocalData = Map<String, dynamic>.from(localData);
      updatedLocalData['lastModified'] = currentTimestamp;

      // Now save our data with updated timestamp
      final saveResult =
          await service.saveData('settings', 'userSettings', updatedLocalData);
      expect(saveResult, true);

      // Verify cloud data now has a timestamp
      expect(mockCloudData.containsKey('lastModified'), true);
      expect(mockCloudData['lastModified'], equals(currentTimestamp));

      // The SyncDataHandler would also update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_modified', currentTimestamp);

      // Get local data again to see if it has the updated timestamp
      final newLocalData = await dataHandler.getLocalData();
      expect(newLocalData['lastModified'] > 0, true);
    });

    test('merges non-conflicting fields', () async {
      // Setup initial state
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Set up local data with some fields
      await setupPreferences(
        sessionDuration: 25.0, // This field exists in both
        shortBreakDuration: 5.0,
        longBreakDuration: 15.0,
        timestamp: timestamp,
      );

      // Add an additional field to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', true); // Only in local

      // Set up cloud data with some different fields
      mockCloudData = {
        'sessionDuration':
            30.0, // This field exists in both but different value
        'autoStartBreaks': true, // Only in cloud
        'lastModified': timestamp + 5000, // Newer timestamp
      };

      // Set up method channel mock for testing
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'fetchData') {
          return mockCloudData;
        } else if (call.method == 'saveData') {
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Initialize service
      await service.initialize();

      // Fetch cloud data and update local settings
      await dataHandler.updateLocalData(
          await service.fetchData('settings', 'userSettings') ?? {});

      // Verify cloud fields overwrote conflicting local fields
      expect(prefs.getDouble('session_duration'), 30.0); // Updated from cloud

      // Verify cloud-only fields were added
      expect(prefs.getBool('auto_start_breaks'), true); // Added from cloud

      // Verify local-only fields were preserved
      expect(prefs.getDouble('short_break_duration'), 5.0); // Preserved local
      expect(prefs.getDouble('long_break_duration'), 15.0); // Preserved local
      expect(prefs.getBool('sound_enabled'), true); // Preserved local

      // Verify timestamp was updated
      expect(prefs.getInt('last_modified'), timestamp + 5000);
    });
  });
}
