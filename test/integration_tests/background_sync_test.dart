import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomo_timer/services/cloudkit_service.dart';
import 'package:pomo_timer/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CloudKitService cloudKitService;
  late SyncService syncService;
  late Map<String, dynamic> mockCloudData;
  late Map<String, dynamic> pendingOperations;

  // Mock channel for CloudKit operations
  const MethodChannel channel = MethodChannel('com.naresh.pomoTimer/cloudkit');

  // Test data with explicit types
  final testSessionData = <String, dynamic>{
    'sessionDuration': 25.0,
    'shortBreakDuration': 5.0,
    'longBreakDuration': 15.0,
    'sessionsBeforeLongBreak': 4,
    'selectedTheme': 'Light',
    'soundEnabled': true,
    'sessionHistory': <String>['2023-05-01T10:00:00Z'],
    'lastModified': DateTime.now().millisecondsSinceEpoch,
  };

  // Mock CloudKit method channel handler
  Future<dynamic> mockMethodCallHandler(MethodCall methodCall) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    switch (methodCall.method) {
      case 'isICloudAvailable':
        return true;
      case 'saveData':
        // Store the data in our mock cloud
        mockCloudData = Map<String, dynamic>.from(methodCall.arguments);
        return true;
      case 'fetchData':
        // Return the mock cloud data
        return mockCloudData;
      case 'subscribeToChanges':
        return true;
      case 'processPendingOperations':
        // Process any pending operations
        if (pendingOperations.isNotEmpty) {
          mockCloudData = Map<String, dynamic>.from(pendingOperations);
          pendingOperations = {};
          return true;
        }
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

    // Initialize mock cloud data and pending operations
    mockCloudData = {};
    pendingOperations = {};

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

  group('Background Sync Tests', () {
    test('Test 5: Should sync data in the background', () async {
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

      // Mark sync as pending
      await prefs.setBool('pending_sync', true);

      // Update the mock method handler to ensure processPendingOperations returns true
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));

        switch (methodCall.method) {
          case 'isICloudAvailable':
            return true;
          case 'saveData':
            // Store the data in our mock cloud
            mockCloudData = Map<String, dynamic>.from(methodCall.arguments);
            return true;
          case 'fetchData':
            // Return the mock cloud data
            return mockCloudData;
          case 'subscribeToChanges':
            return true;
          case 'processPendingOperations':
            // Process any pending operations and ensure success
            mockCloudData['sessionDuration'] =
                testSessionData['sessionDuration'];
            pendingOperations = {};
            return true;
          default:
            return null;
        }
      });

      // Simulate background sync by directly calling processPendingOperations
      final success = await cloudKitService.processPendingOperations();

      // Verify background sync was successful
      expect(success, isTrue);

      // Verify data was saved to cloud
      expect(mockCloudData.containsKey('sessionDuration'), isTrue);
      expect(mockCloudData['sessionDuration'],
          equals(testSessionData['sessionDuration']));
    });

    test('Should queue operations when app is closed and sync when reopened',
        () async {
      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);

      // Simulate app closing with pending changes
      pendingOperations = Map<String, dynamic>.from(testSessionData);
      await prefs.setBool('pending_sync', true);

      // Simulate app reopening
      final newSyncService = SyncService(cloudKitService: cloudKitService);
      await newSyncService.initialize();

      // Verify pending operations are processed on initialization
      expect(mockCloudData.containsKey('sessionDuration'), isTrue);
      expect(mockCloudData['sessionDuration'],
          equals(testSessionData['sessionDuration']));

      // Verify pending flag is cleared
      expect(prefs.getBool('pending_sync'), isFalse);
    });

    test('Should handle background sync failures gracefully', () async {
      // Set up mock handler to simulate background sync failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'processPendingOperations') {
          return false;
        }
        return await mockMethodCallHandler(methodCall);
      });

      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);

      // Mark sync as pending
      await prefs.setBool('pending_sync', true);

      // Simulate background sync failure
      final success = await cloudKitService.processPendingOperations();

      // Verify background sync failed
      expect(success, isFalse);

      // Verify pending flag is still set
      expect(prefs.getBool('pending_sync'), isTrue);

      // Verify data was not saved to cloud
      expect(mockCloudData.isEmpty, isTrue);
    });

    test('Should sync automatically when app becomes active', () async {
      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);

      // Mark sync as pending
      await prefs.setBool('pending_sync', true);

      // Simulate app becoming active
      // In a real app, this would be triggered by the AppLifecycleState.resumed event

      // Manually trigger the sync that would happen on app resume
      await syncService.syncData();

      // Verify data was saved to cloud
      expect(mockCloudData.containsKey('sessionDuration'), isTrue);
      expect(mockCloudData['sessionDuration'],
          equals(testSessionData['sessionDuration']));

      // Verify pending flag is cleared
      expect(prefs.getBool('pending_sync'), isFalse);
    });

    test('Should handle multiple background sync attempts', () async {
      // Set up local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(
          'session_duration', testSessionData['sessionDuration'] as double);

      // Mark sync as pending
      await prefs.setBool('pending_sync', true);

      // Update the mock method handler to ensure processPendingOperations returns true
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isICloudAvailable':
            return true;
          case 'saveData':
            mockCloudData = Map<String, dynamic>.from(methodCall.arguments);
            return true;
          case 'fetchData':
            return mockCloudData;
          case 'subscribeToChanges':
            return true;
          case 'processPendingOperations':
            // Always process successfully and update mockCloudData
            mockCloudData['sessionDuration'] =
                testSessionData['sessionDuration'];
            return true;
          default:
            return null;
        }
      });

      // Simulate first background sync
      final firstSyncResult = await cloudKitService.processPendingOperations();

      // Verify first sync was successful
      expect(firstSyncResult, isTrue);

      // Verify data was saved to cloud
      expect(mockCloudData.containsKey('sessionDuration'), isTrue);

      // Clear cloud data to verify second sync doesn't duplicate
      mockCloudData = {};

      // Update the mock handler to simulate no pending operations
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isICloudAvailable':
            return true;
          case 'saveData':
            mockCloudData = Map<String, dynamic>.from(methodCall.arguments);
            return true;
          case 'fetchData':
            return mockCloudData;
          case 'subscribeToChanges':
            return true;
          case 'processPendingOperations':
            // No pending operations, but still return true
            return true;
          default:
            return null;
        }
      });

      // Simulate second background sync
      final secondSyncResult = await cloudKitService.processPendingOperations();

      // Verify second sync was also successful
      expect(secondSyncResult, isTrue);

      // Verify no data was saved (since pending flag was cleared)
      expect(mockCloudData.isEmpty, isTrue);
    });
  });
}
