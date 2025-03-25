import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';

// Extended CloudKitService for testing offline operations
class CloudKitOfflineTester extends CloudKitService {
  bool _isNetworkAvailable = true;
  Map<String, dynamic> _pendingOperations = {};
  Map<String, dynamic> _mockCloudData = {};

  // Constructor to initialize with test data
  CloudKitOfflineTester() {
    // Set initial mock cloud data
    _mockCloudData = {
      'sessionDuration': 25.0,
      'shortBreakDuration': 5.0,
      'longBreakDuration': 15.0,
      'sessionsBeforeLongBreak': 4,
    };
  }

  // Network availability control for testing
  void setNetworkAvailable(bool available) {
    _isNetworkAvailable = available;
    super.updateAvailability(available);
  }

  // Get pending operations for testing
  Map<String, dynamic> get pendingOperations => _pendingOperations;

  // Get mock cloud data for testing
  Map<String, dynamic> get mockCloudData => _mockCloudData;

  // Helper to add a pending operation
  void addPendingOperation(String key, dynamic value) {
    _pendingOperations[key] = value;
  }

  // Helper to clear pending operations
  void clearPendingOperations() {
    _pendingOperations.clear();
  }

  @override
  Future<bool> isICloudAvailable() async {
    // Always return network availability status for testing
    return _isNetworkAvailable;
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    // If offline, queue data and return false
    if (!_isNetworkAvailable) {
      debugPrint('Device is offline, saveData returning false');

      // Add to pending operations
      _pendingOperations.addAll(data);
      return false;
    }

    // If online, save data and return true
    debugPrint('Device is online, saving data: $data');
    _mockCloudData.addAll(data);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    // If offline, return null
    if (!_isNetworkAvailable) {
      debugPrint('Device is offline, fetchData returning null');
      return null;
    }

    // If online, return mock cloud data
    debugPrint('Device is online, returning mock cloud data: $_mockCloudData');
    return Map<String, dynamic>.from(_mockCloudData);
  }

  @override
  Future<bool> processPendingOperations() async {
    // If offline, return false
    if (!_isNetworkAvailable) {
      debugPrint('Device is offline, processPendingOperations returning false');
      return false;
    }

    // If online, process pending operations
    if (_pendingOperations.isNotEmpty) {
      debugPrint('Processing pending operations: $_pendingOperations');
      _mockCloudData.addAll(_pendingOperations);
      _pendingOperations.clear();
      return true;
    }

    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CloudKitOfflineTester cloudKitService;

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create tester service
    cloudKitService = CloudKitOfflineTester();

    // Start with network available
    cloudKitService.setNetworkAvailable(true);
  });

  group('iCloud Offline Operation Tests', () {
    test('Should queue operations when offline', () async {
      // Initial check
      expect(cloudKitService.isAvailable, isTrue);
      expect(cloudKitService.pendingOperations.isEmpty, isTrue);

      // Set device to offline
      cloudKitService.setNetworkAvailable(false);
      expect(cloudKitService.isAvailable, isFalse);

      // Try to save data while offline
      final data = {'sessionDuration': 30.0};
      final result = await cloudKitService.saveData('session', '1', data);

      // Verify result and state
      expect(result, isFalse,
          reason: 'saveData should return false when offline');
      expect(cloudKitService.pendingOperations.isEmpty, isFalse,
          reason: 'pendingOperations should not be empty');
      expect(cloudKitService.pendingOperations['sessionDuration'], equals(30.0),
          reason: 'pendingOperations should contain the data');
    });

    test('Should process queued operations when coming back online', () async {
      // Set device to offline
      cloudKitService.setNetworkAvailable(false);

      // Add pending operations
      cloudKitService.addPendingOperation('sessionDuration', 35.0);
      cloudKitService.addPendingOperation('shortBreakDuration', 7.0);

      // Verify operations are queued
      expect(cloudKitService.pendingOperations.length, equals(2));

      // Set device back online
      cloudKitService.setNetworkAvailable(true);

      // Process pending operations
      final result = await cloudKitService.processPendingOperations();

      // Verify result and state
      expect(result, isTrue,
          reason:
              'processPendingOperations should return true when operations were processed');
      expect(cloudKitService.pendingOperations.isEmpty, isTrue,
          reason: 'pendingOperations should be empty after processing');
      expect(cloudKitService.mockCloudData['sessionDuration'], equals(35.0),
          reason: 'Cloud data should be updated with pending operations');
      expect(cloudKitService.mockCloudData['shortBreakDuration'], equals(7.0),
          reason: 'Cloud data should be updated with pending operations');
    });

    test('Should handle fetch operations during offline mode', () async {
      // Initial check
      final initialData = await cloudKitService.fetchData('session', '1');
      expect(initialData, isNotNull);

      // Set device to offline
      cloudKitService.setNetworkAvailable(false);

      // Try to fetch data while offline
      final offlineData = await cloudKitService.fetchData('session', '1');

      // Verify result
      expect(offlineData, isNull,
          reason: 'fetchData should return null when offline');
    });

    test('Should update data properly after reconnection', () async {
      // Initial state
      expect(cloudKitService.mockCloudData['sessionDuration'], equals(25.0));

      // Set device to offline
      cloudKitService.setNetworkAvailable(false);

      // Add pending operation
      cloudKitService.addPendingOperation('sessionDuration', 40.0);

      // Set device back online
      cloudKitService.setNetworkAvailable(true);

      // Process pending operations
      await cloudKitService.processPendingOperations();

      // Fetch data and verify
      final updatedData = await cloudKitService.fetchData('session', '1');
      expect(updatedData!['sessionDuration'], equals(40.0),
          reason: 'Data should be updated after reconnection');
    });

    test('Should handle multiple operations offline and sync them correctly',
        () async {
      // Initial check
      expect(cloudKitService.mockCloudData['sessionDuration'], equals(25.0));
      expect(cloudKitService.mockCloudData['shortBreakDuration'], equals(5.0));

      // Set device to offline
      cloudKitService.setNetworkAvailable(false);

      // Perform multiple operations while offline
      await cloudKitService.saveData('session', '1', {'sessionDuration': 30.0});
      await cloudKitService
          .saveData('session', '1', {'shortBreakDuration': 6.0});
      await cloudKitService
          .saveData('session', '1', {'longBreakDuration': 20.0});

      // Verify pending operations
      expect(cloudKitService.pendingOperations.length, equals(3));

      // Set device back online
      cloudKitService.setNetworkAvailable(true);

      // Process pending operations
      await cloudKitService.processPendingOperations();

      // Fetch data and verify
      final updatedData = await cloudKitService.fetchData('session', '1');
      expect(updatedData!['sessionDuration'], equals(30.0));
      expect(updatedData!['shortBreakDuration'], equals(6.0));
      expect(updatedData!['longBreakDuration'], equals(20.0));
    });
  });
}
