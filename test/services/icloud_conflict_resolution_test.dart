import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Test implementation of CloudKitService for conflict resolution testing
class CloudKitConflictTester extends CloudKitService {
  Map<String, dynamic> mockLocalData = {
    'sessionDuration': 25.0,
    'shortBreakDuration': 5.0,
    'longBreakDuration': 15.0,
    'sessionsBeforeLongBreak': 4,
    'lastUpdated':
        DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch,
  };

  Map<String, dynamic> mockCloudData = {
    'sessionDuration': 30.0,
    'shortBreakDuration': 5.0,
    'longBreakDuration': 20.0,
    'sessionsBeforeLongBreak': 3,
    'lastUpdated':
        DateTime.now().subtract(Duration(hours: 2)).millisecondsSinceEpoch,
  };

  // Controls whether we simulate a more recent cloud update
  bool cloudHasNewerData = false;

  // Flag to track if merging non-conflicting changes should be active
  bool enablePartialMerging = false;

  // To track the last saved data
  Map<String, dynamic> _lastSavedData = {};

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    debugPrint('Saving data: $data');
    mockLocalData = Map.from(data);
    mockLocalData['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
    _lastSavedData = Map<String, dynamic>.from(data);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    // If cloud has newer data is enabled, update the cloud data timestamp
    if (cloudHasNewerData) {
      mockCloudData['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
    }
    return mockCloudData;
  }

  // Method to simulate fetching local data
  Map<String, dynamic> getLocalData() {
    return mockLocalData;
  }

  // Method to simulate setting cloud data (as if another device updated it)
  void setCloudData(Map<String, dynamic> data) {
    mockCloudData = Map.from(data);
  }

  // Simulate cloud conflict resolution
  Future<Map<String, dynamic>> resolveConflict() async {
    final localData = getLocalData();
    final cloudData = await fetchData('settings', 'userSettings') ?? {};

    // Default strategy: latest timestamp wins
    if ((cloudData['lastUpdated'] ?? 0) > (localData['lastUpdated'] ?? 0)) {
      debugPrint('Cloud data is newer, using cloud data');
      return cloudData;
    } else if (enablePartialMerging) {
      // Merge non-conflicting fields if partial merging is enabled
      final mergedData = Map<String, dynamic>.from(localData);

      // Find fields that exist in cloud but not changed locally
      for (final key in cloudData.keys) {
        if (!localData.containsKey(key)) {
          // If local doesn't have this field, take it from cloud
          mergedData[key] = cloudData[key];
        }
      }

      // Keep the local lastUpdated timestamp as it's newer
      mergedData['lastUpdated'] = localData['lastUpdated'];
      debugPrint('Merged non-conflicting data: $mergedData');
      return mergedData;
    }

    // Local data is newer or equal, prefer local data
    debugPrint('Local data is newer, using local data');
    return localData;
  }
}

@GenerateMocks([])
void main() {
  late CloudKitConflictTester cloudService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cloudService = CloudKitConflictTester();
  });

  group('CloudKit Conflict Resolution Tests', () {
    test('Latest timestamp wins - local data newer', () async {
      // Local data is already newer by default

      // Resolve conflict
      final result = await cloudService.resolveConflict();

      // Verify local data was chosen
      expect(result['sessionDuration'], equals(25.0));
      expect(result['longBreakDuration'], equals(15.0));
      expect(result['sessionsBeforeLongBreak'], equals(4));
    });

    test('Latest timestamp wins - cloud data newer', () async {
      // Set cloud data to be newer
      cloudService.cloudHasNewerData = true;

      // Update some cloud values to be different
      cloudService.mockCloudData = {
        'sessionDuration': 35.0,
        'shortBreakDuration': 6.0,
        'longBreakDuration': 25.0,
        'sessionsBeforeLongBreak': 2,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      // Resolve conflict
      final result = await cloudService.resolveConflict();

      // Verify cloud data was chosen
      expect(result['sessionDuration'], equals(35.0));
      expect(result['shortBreakDuration'], equals(6.0));
      expect(result['longBreakDuration'], equals(25.0));
      expect(result['sessionsBeforeLongBreak'], equals(2));
    });

    test('Merging non-conflicting changes', () async {
      // Set up partial merging
      cloudService.enablePartialMerging = true;

      // Local data has newer timestamp but is missing some fields
      cloudService.mockLocalData = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 7.0,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      // Cloud data has some different fields
      cloudService.mockCloudData = {
        'sessionDuration': 25.0, // Conflicting with local, should keep local
        'shortBreakDuration': 5.0, // Conflicting with local, should keep local
        'longBreakDuration': 20.0, // Not in local, should be merged
        'sessionsBeforeLongBreak': 3, // Not in local, should be merged
        'soundEnabled': true, // Not in local, should be merged
        'lastUpdated':
            DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch,
      };

      // Resolve conflict
      final result = await cloudService.resolveConflict();

      // Verify local data was preferred for conflicting fields
      expect(result['sessionDuration'], equals(30.0)); // Local value
      expect(result['shortBreakDuration'], equals(7.0)); // Local value

      // Verify cloud-only fields were merged
      expect(result['longBreakDuration'], equals(20.0)); // From cloud
      expect(result['sessionsBeforeLongBreak'], equals(3)); // From cloud
      expect(result['soundEnabled'], equals(true)); // From cloud

      // Timestamp should be from local data
      expect(result['lastUpdated'],
          equals(cloudService.mockLocalData['lastUpdated']));
    });

    test('Empty cloud data uses local data', () async {
      // Set cloud data to be empty
      cloudService.mockCloudData = {};

      // Resolve conflict
      final result = await cloudService.resolveConflict();

      // Verify local data was chosen
      expect(result['sessionDuration'], equals(25.0));
      expect(result['shortBreakDuration'], equals(5.0));
      expect(result['longBreakDuration'], equals(15.0));
      expect(result['sessionsBeforeLongBreak'], equals(4));
    });

    test('New field in cloud data gets merged with local data', () async {
      // Enable partial merging
      cloudService.enablePartialMerging = true;

      // Reset to default values for this test
      cloudService.mockLocalData = {
        'sessionDuration': 25.0,
        'shortBreakDuration': 5.0,
        'longBreakDuration': 15.0,
        'sessionsBeforeLongBreak': 4,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      // Add a new field to cloud data
      cloudService.mockCloudData['vibrationEnabled'] = true;

      // Resolve conflict with local data being newer
      final result = await cloudService.resolveConflict();

      // Verify new field was merged
      expect(result['vibrationEnabled'], equals(true));
      // Verify other local fields were preserved
      expect(result['sessionDuration'], equals(25.0));
    });
  });
}
