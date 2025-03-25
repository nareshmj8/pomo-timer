import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock class for testing data synchronization
class CloudKitDataSyncTester extends CloudKitService {
  // Mock data for the cloud
  Map<String, dynamic> _mockCloudData = {};
  // Mock data specifically for timer settings
  Map<String, dynamic> _mockTimerSettings = {};
  // Mock data specifically for statistics
  Map<String, dynamic> _mockStatistics = {};
  // Mock data specifically for session history
  List<Map<String, dynamic>> _mockSessionHistory = [];

  // Variables to control test behavior
  bool syncSuccessful = true;
  bool _isCurrentlyAvailable = true;
  final bool _isInitialized = true;

  // Variables to track method calls for test verification
  bool _saveDataCalled = false;
  bool _fetchDataCalled = false;
  Map<String, dynamic> _lastSavedData = {};
  int _pendingChangesCount = 0;

  // Stream controller for data changes
  final StreamController<void> _dataChangeStreamController =
      StreamController<void>.broadcast();

  // Constructor to initialize with test data
  CloudKitDataSyncTester() {
    // Initialize with some default values
    _mockTimerSettings = {
      'sessionDuration': 25.0,
      'shortBreakDuration': 5.0,
      'longBreakDuration': 15.0,
      'sessionsBeforeLongBreak': 4,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };

    _mockStatistics = {
      'totalSessions': 0,
      'totalFocusTime': 0,
      'lastWeekSessions': [0, 0, 0, 0, 0, 0, 0],
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };

    _mockSessionHistory = [];

    _mockCloudData['timerSettings'] = _mockTimerSettings;
    _mockCloudData['statistics'] = _mockStatistics;
    _mockCloudData['sessionHistory'] = _mockSessionHistory;
  }

  // Helper to save timer settings
  Future<bool> saveTimerSettings(Map<String, dynamic> settings) async {
    _mockTimerSettings = Map<String, dynamic>.from(settings);
    _mockCloudData['timerSettings'] = _mockTimerSettings;
    return await saveData('timerSettings', 'userSettings', _mockCloudData);
  }

  // Helper to save statistics
  Future<bool> saveStatistics(Map<String, dynamic> statistics) async {
    _mockStatistics = Map<String, dynamic>.from(statistics);
    _mockCloudData['statistics'] = _mockStatistics;
    return await saveData('statistics', 'userStats', _mockCloudData);
  }

  // Helper to save session history
  Future<bool> saveSessionHistory(List<Map<String, dynamic>> history) async {
    _mockSessionHistory = List<Map<String, dynamic>>.from(history);
    _mockCloudData['sessionHistory'] = _mockSessionHistory;
    return await saveData('sessionHistory', 'userHistory', _mockCloudData);
  }

  // Fetch timer settings
  Future<Map<String, dynamic>?> fetchTimerSettings() async {
    final data = await fetchData('timerSettings', 'userSettings');
    if (data == null) return null;
    return data['timerSettings'];
  }

  // Fetch statistics
  Future<Map<String, dynamic>?> fetchStatistics() async {
    final data = await fetchData('statistics', 'userStats');
    if (data == null) return null;
    return data['statistics'];
  }

  // Fetch session history
  Future<List<Map<String, dynamic>>?> fetchSessionHistory() async {
    final data = await fetchData('sessionHistory', 'userHistory');
    if (data == null) return null;
    if (data['sessionHistory'] is List) {
      return List<Map<String, dynamic>>.from(data['sessionHistory']);
    }
    return [];
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    if (!syncSuccessful) return false;

    // Record that data was saved for test verification
    _saveDataCalled = true;
    _lastSavedData = Map<String, dynamic>.from(data);

    // Update mock data
    _mockCloudData = Map<String, dynamic>.from(data);
    _mockCloudData['lastModified'] = DateTime.now().millisecondsSinceEpoch;

    // Notify listeners
    _dataChangeStreamController.add(null);
    _pendingChangesCount++;

    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    if (!syncSuccessful) return null;

    // Record that fetch was called for test verification
    _fetchDataCalled = true;

    return Map<String, dynamic>.from(_mockCloudData);
  }

  @override
  Stream<void> get dataChangedStream => _dataChangeStreamController.stream;

  @override
  Future<bool> initialize() async {
    return _isInitialized;
  }

  @override
  bool get isAvailable => _isCurrentlyAvailable;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> processPendingOperations() async {
    // Simulate processing pending operations
    if (_pendingChangesCount > 0) {
      _pendingChangesCount = 0;
      return true;
    }
    return false;
  }

  @override
  void addPendingOperationForTest(Map<String, dynamic> data) {
    // Add a pending operation to the queue for testing
    _pendingChangesCount++;
  }

  // For testing purposes - set availability
  void setAvailability(bool available) {
    _isCurrentlyAvailable = available;
  }

  // Get data for verification
  Map<String, dynamic> get lastSavedData => _lastSavedData;
  bool get wasSaveDataCalled => _saveDataCalled;
  bool get wasFetchDataCalled => _fetchDataCalled;
  int get pendingChangesCount => _pendingChangesCount;

  // Reset counters for new tests
  void resetTestCounters() {
    _saveDataCalled = false;
    _fetchDataCalled = false;
    _lastSavedData = {};
    _pendingChangesCount = 0;
  }
}

@GenerateMocks([])
void main() {
  late CloudKitDataSyncTester cloudService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cloudService = CloudKitDataSyncTester();
  });

  group('iCloud Data Synchronization Tests', () {
    test('Should synchronize timer settings', () async {
      // Update timer settings
      final newSettings = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 8.0,
        'longBreakDuration': 20.0,
        'sessionsBeforeLongBreak': 3,
      };

      // Synchronize settings to cloud
      final saveResult = await cloudService.saveTimerSettings(newSettings);
      expect(saveResult, isTrue);

      // Fetch settings from cloud
      final fetchedSettings = await cloudService.fetchTimerSettings();

      // Verify settings match
      expect(fetchedSettings, isNotNull);
      expect(fetchedSettings!['sessionDuration'], equals(30.0));
      expect(fetchedSettings['shortBreakDuration'], equals(8.0));
      expect(fetchedSettings['longBreakDuration'], equals(20.0));
      expect(fetchedSettings['sessionsBeforeLongBreak'], equals(3));
    });

    test('Should synchronize statistics data', () async {
      // Update statistics
      final newStats = {
        'totalSessions': 10,
        'totalFocusTime': 250,
        'dailyStreak': 3,
        'lastCompletedDate': DateTime.now().toIso8601String(),
      };

      // Synchronize statistics to cloud
      final saveResult = await cloudService.saveStatistics(newStats);
      expect(saveResult, isTrue);

      // Fetch statistics from cloud
      final fetchedStats = await cloudService.fetchStatistics();

      // Verify statistics match
      expect(fetchedStats, isNotNull);
      expect(fetchedStats!['totalSessions'], equals(10));
      expect(fetchedStats['totalFocusTime'], equals(250));
      expect(fetchedStats['dailyStreak'], equals(3));
      expect(fetchedStats['lastCompletedDate'], isNotNull);
    });

    test('Should synchronize session history', () async {
      // Create session history entries
      final sessionHistory = [
        {
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'duration': 25,
          'completed': true,
        },
        {
          'date': DateTime.now().toIso8601String(),
          'duration': 30,
          'completed': true,
        }
      ];

      // Synchronize session history to cloud
      final saveResult = await cloudService.saveSessionHistory(sessionHistory);
      expect(saveResult, isTrue);

      // Fetch session history from cloud
      final fetchedHistory = await cloudService.fetchSessionHistory();

      // Verify history matches
      expect(fetchedHistory, isNotNull);
      expect(fetchedHistory!.length, equals(2));
      expect(fetchedHistory[0]['duration'], equals(25));
      expect(fetchedHistory[1]['duration'], equals(30));
      expect(fetchedHistory[0]['completed'], isTrue);
      expect(fetchedHistory[1]['completed'], isTrue);
    });

    test('Should handle synchronization failure gracefully', () async {
      // Set sync to fail
      cloudService.syncSuccessful = false;

      // Attempt to save timer settings
      final settings = {
        'sessionDuration': 35.0,
        'shortBreakDuration': 10.0,
      };

      // Verify save fails but doesn't throw
      final saveResult = await cloudService.saveTimerSettings(settings);
      expect(saveResult, isFalse);

      // Verify fetch returns null
      final fetchedSettings = await cloudService.fetchTimerSettings();
      expect(fetchedSettings, isNull);
    });

    test('Should handle partial synchronization of data types', () async {
      // Update timer settings and statistics but not session history
      final newSettings = {
        'sessionDuration': 40.0,
        'shortBreakDuration': 7.0,
      };

      final newStats = {
        'totalSessions': 5,
        'totalFocusTime': 120,
      };

      // Save settings and statistics
      await cloudService.saveTimerSettings(newSettings);
      await cloudService.saveStatistics(newStats);

      // Fetch all data
      final settings = await cloudService.fetchTimerSettings();
      final stats = await cloudService.fetchStatistics();
      final history = await cloudService.fetchSessionHistory();

      // Verify settings and stats updated but history remained empty
      expect(settings!['sessionDuration'], equals(40.0));
      expect(stats!['totalSessions'], equals(5));
      expect(history, isEmpty);
    });
  });
}
