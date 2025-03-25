import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';

@GenerateMocks([CloudKitService])
import 'icloud_sync_test.mocks.dart';

// Create a simplified version of SyncService for testing
class TestSyncService {
  final MockCloudKitService cloudKitService;
  bool isSyncing = false;
  bool isOnline = true;

  TestSyncService(this.cloudKitService);

  Future<bool> syncData() async {
    if (!isOnline) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pending_sync', true);
      return false;
    }

    isSyncing = true;

    try {
      // Get cloud data
      final cloudData = await cloudKitService.fetchData('session', '1');

      if (cloudData == null) {
        isSyncing = false;
        return false;
      }

      // Update local data with cloud data
      final prefs = await SharedPreferences.getInstance();

      if (cloudData.containsKey('sessionDuration')) {
        await prefs.setDouble('session_duration', cloudData['sessionDuration']);
      }

      if (cloudData.containsKey('selectedTheme')) {
        await prefs.setString('selected_theme', cloudData['selectedTheme']);
      }

      // Clear pending sync flag
      await prefs.setBool('pending_sync', false);

      isSyncing = false;
      return true;
    } catch (e) {
      isSyncing = false;
      return false;
    }
  }

  void setOnlineStatus(bool online) {
    isOnline = online;
  }
}

void main() {
  late MockCloudKitService mockCloudKitService;
  late TestSyncService syncService;

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({
      'session_duration': 25.0,
      'short_break_duration': 5.0,
      'long_break_duration': 15.0,
      'sessions_before_long_break': 4,
      'selected_theme': 'Light',
      'sound_enabled': true,
      'session_history': ['2023-03-10T10:00:00Z|25|Completed'],
      'daily_completed_sessions': 5,
      'weekly_completed_sessions': 15,
      'monthly_completed_sessions': 50,
      'total_completed_sessions': 100,
      'subscription_type': 2, // Lifetime
    });

    // Create mock CloudKit service
    mockCloudKitService = MockCloudKitService();

    // Create test sync service with mock CloudKit service
    syncService = TestSyncService(mockCloudKitService);
  });

  test('TestSyncService initializes correctly', () {
    expect(syncService.isSyncing, isFalse);
    expect(syncService.isOnline, isTrue);
  });

  test('TestSyncService handles conflict resolution correctly', () async {
    // Set up cloud data with newer values
    final cloudData = {
      'sessionDuration': 30.0,
      'selectedTheme': 'Dark',
    };

    // Set up mocks
    when(mockCloudKitService.fetchData('session', '1'))
        .thenAnswer((_) async => cloudData);

    // Trigger sync
    await syncService.syncData();

    // Verify local preferences were updated with cloud data
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('session_duration'), equals(30.0));
    expect(prefs.getString('selected_theme'), equals('Dark'));
  });

  test('TestSyncService handles offline mode gracefully', () async {
    // Set up sync service with offline mode
    syncService.setOnlineStatus(false);

    // Trigger sync
    final result = await syncService.syncData();

    // Verify sync was not successful but didn't crash
    expect(result, isFalse);

    // Verify pending sync flag was set
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pending_sync'), isTrue);
  });

  test('TestSyncService processes pending operations when coming online',
      () async {
    // Set up mock to verify sync is triggered
    when(mockCloudKitService.fetchData('session', '1'))
        .thenAnswer((_) async => <String, dynamic>{});

    // Set pending sync flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pending_sync', true);

    // Set to offline mode
    syncService.setOnlineStatus(false);

    // Simulate coming online and trigger sync manually
    syncService.setOnlineStatus(true);
    await syncService.syncData();

    // Verify pending sync flag was cleared
    expect(prefs.getBool('pending_sync'), isFalse);
  });

  test('syncData returns false when offline', () async {
    SharedPreferences.setMockInitialValues({});
    final mockCloudKit = MockCloudKitService();
    final syncService = TestSyncService(mockCloudKit);
    syncService.isOnline = false;

    final result = await syncService.syncData();

    expect(result, false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('pending_sync'), true);
    verifyNever(mockCloudKit.fetchData('session', '1'));
  });

  test('syncData returns false when cloud data is null', () async {
    final mockCloudKit = MockCloudKitService();
    when(mockCloudKit.fetchData('session', '1')).thenAnswer((_) async => null);

    final syncService = TestSyncService(mockCloudKit);
    final result = await syncService.syncData();

    expect(result, false);
    verify(mockCloudKit.fetchData('session', '1')).called(1);
  });

  test('syncData returns true when data syncs successfully', () async {
    final mockCloudKit = MockCloudKitService();
    when(mockCloudKit.fetchData('session', '1'))
        .thenAnswer((_) async => {'test': 'data'});

    final syncService = TestSyncService(mockCloudKit);
    final result = await syncService.syncData();

    expect(result, true);
    verify(mockCloudKit.fetchData('session', '1')).called(1);
  });
}
