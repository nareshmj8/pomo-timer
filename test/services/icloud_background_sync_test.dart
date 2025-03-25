import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Mock class for testing background sync
class CloudKitBackgroundSyncTester extends CloudKitService {
  bool _isBackgroundSyncEnabled = true;
  int _backgroundSyncFrequency = 15; // minutes
  DateTime? _lastBackgroundSyncTime;
  int _backgroundSyncAttempts = 0;
  bool _appInForeground = true;
  bool _syncSuccessful = true;
  Map<String, dynamic> _mockCloudData = {};

  // Constructor to initialize with test data
  CloudKitBackgroundSyncTester() {
    // Initialize mock cloud data
    _mockCloudData = {
      'sessionDuration': 25.0,
      'shortBreakDuration': 5.0,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Get/set for background sync enabled status
  bool get isBackgroundSyncEnabled => _isBackgroundSyncEnabled;
  set isBackgroundSyncEnabled(bool value) {
    _isBackgroundSyncEnabled = value;
  }

  // Get/set for background sync frequency
  int get backgroundSyncFrequency => _backgroundSyncFrequency;
  set backgroundSyncFrequency(int minutes) {
    _backgroundSyncFrequency = minutes;
  }

  // Get/set for last background sync time
  DateTime? get lastBackgroundSyncTime => _lastBackgroundSyncTime;
  set lastBackgroundSyncTime(DateTime? value) {
    _lastBackgroundSyncTime = value;
  }

  // Get the number of background sync attempts
  int get backgroundSyncAttempts => _backgroundSyncAttempts;

  // Reset background sync attempts counter
  void resetBackgroundSyncAttempts() {
    _backgroundSyncAttempts = 0;
  }

  // Set the app foreground/background state
  void setAppState(bool inForeground) {
    _appInForeground = inForeground;
  }

  // Set whether sync should succeed or fail
  void setSyncSuccessful(bool successful) {
    _syncSuccessful = successful;
  }

  // Method to check if background sync is due
  bool isBackgroundSyncDue() {
    if (!_isBackgroundSyncEnabled) return false;

    // If never synced, then it's due
    if (_lastBackgroundSyncTime == null) return true;

    // Check if enough time has passed since last sync
    final now = DateTime.now();
    final timeSinceLastSync = now.difference(_lastBackgroundSyncTime!);
    return timeSinceLastSync.inMinutes >= _backgroundSyncFrequency;
  }

  // Method to perform background sync
  Future<bool> performBackgroundSync() async {
    if (!_isBackgroundSyncEnabled) return false;

    // Only sync if app is in background or sync is due
    if (_appInForeground && !isBackgroundSyncDue()) {
      debugPrint('Background sync not due yet, skipping');
      return false;
    }

    debugPrint('Performing background sync...');
    _backgroundSyncAttempts++;

    // Check if sync is successful based on test setting
    if (_syncSuccessful) {
      _lastBackgroundSyncTime = DateTime.now();
      await fetchData('settings', 'userSettings'); // Fetch the latest data
      debugPrint('Background sync completed successfully');
      return true;
    } else {
      debugPrint('Background sync failed');
      return false;
    }
  }

  // Method to perform sync when app resumes
  Future<bool> performResumeSync() async {
    debugPrint('App resumed, checking for sync...');

    // Only sync if background sync is enabled
    if (!_isBackgroundSyncEnabled) return false;

    _appInForeground = true;
    return performBackgroundSync();
  }

  @override
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    if (!_syncSuccessful) return false;

    debugPrint('Saving data: $data');
    _mockCloudData.addAll(data);
    _mockCloudData['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> fetchData(
      String collection, String document) async {
    if (!_syncSuccessful) return null;

    debugPrint('Fetching data: $_mockCloudData');
    return Map<String, dynamic>.from(_mockCloudData);
  }
}

@GenerateMocks([])
void main() {
  late CloudKitBackgroundSyncTester cloudService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cloudService = CloudKitBackgroundSyncTester();
    // Reset the last sync time to null to simulate first launch
    cloudService.lastBackgroundSyncTime = null;
  });

  group('iCloud Background Sync Tests', () {
    test('Should perform initial background sync', () async {
      // First-time sync should be due
      expect(cloudService.isBackgroundSyncDue(), isTrue);

      // Perform background sync
      final result = await cloudService.performBackgroundSync();

      // Verify sync was performed
      expect(result, isTrue);
      expect(cloudService.backgroundSyncAttempts, equals(1));
      expect(cloudService.lastBackgroundSyncTime, isNotNull);
    });

    test('Should respect background sync frequency', () async {
      // Set last sync time to 10 minutes ago
      cloudService.lastBackgroundSyncTime =
          DateTime.now().subtract(Duration(minutes: 10));
      cloudService.backgroundSyncFrequency = 15; // Set to 15 minutes

      // Sync shouldn't be due yet
      expect(cloudService.isBackgroundSyncDue(), isFalse);

      // Try to perform background sync
      final result = await cloudService.performBackgroundSync();

      // Verify sync was not performed (app in foreground)
      expect(result, isFalse);
      expect(cloudService.backgroundSyncAttempts, equals(0));

      // Set last sync time to 20 minutes ago
      cloudService.lastBackgroundSyncTime =
          DateTime.now().subtract(Duration(minutes: 20));

      // Sync should be due now
      expect(cloudService.isBackgroundSyncDue(), isTrue);

      // Perform background sync
      final secondResult = await cloudService.performBackgroundSync();

      // Verify sync was performed
      expect(secondResult, isTrue);
      expect(cloudService.backgroundSyncAttempts, equals(1));
    });

    test('Should not perform background sync when disabled', () async {
      // Disable background sync
      cloudService.isBackgroundSyncEnabled = false;

      // Check if sync is due
      expect(cloudService.isBackgroundSyncDue(), isFalse);

      // Try to perform background sync
      final result = await cloudService.performBackgroundSync();

      // Verify no sync was performed
      expect(result, isFalse);
      expect(cloudService.backgroundSyncAttempts, equals(0));
    });

    test('Should perform sync when app resumes', () async {
      // Set app to background state
      cloudService.setAppState(false);

      // Set last sync time to 20 minutes ago
      cloudService.lastBackgroundSyncTime =
          DateTime.now().subtract(Duration(minutes: 20));

      // Verify sync is due
      expect(cloudService.isBackgroundSyncDue(), isTrue);

      // Simulate app resume
      final result = await cloudService.performResumeSync();

      // Verify sync was performed
      expect(result, isTrue);
      expect(cloudService.backgroundSyncAttempts, equals(1));
      expect(cloudService.lastBackgroundSyncTime, isNotNull);
    });

    test('Should handle sync failure', () async {
      // Set sync to fail
      cloudService.setSyncSuccessful(false);

      // Try to perform background sync
      final result = await cloudService.performBackgroundSync();

      // Verify sync failed
      expect(result, isFalse);
      expect(cloudService.backgroundSyncAttempts, equals(1));

      // Last sync time should not be updated
      expect(cloudService.lastBackgroundSyncTime, isNull);
    });
  });
}
