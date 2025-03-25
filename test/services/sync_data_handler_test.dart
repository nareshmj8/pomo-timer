import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/sync/sync_data_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncDataHandler Tests', () {
    late SyncDataHandler syncDataHandler;

    setUp(() {
      syncDataHandler = SyncDataHandler();
    });

    test(
        'getLocalData should retrieve all relevant data from SharedPreferences',
        () async {
      // Setup mock SharedPreferences with test data
      SharedPreferences.setMockInitialValues({
        'session_duration': 25.0,
        'short_break_duration': 5.0,
        'long_break_duration': 15.0,
        'sessions_before_long_break': 4,
        'auto_start_breaks': true,
        'auto_start_pomodoros': false,
        'vibration_enabled': true,
        'notifications_enabled': true,
        'keep_screen_on': true,
        'selected_theme': 'Dark',
        'sound_enabled': true,
        'selected_sound': 'Bell',
        'sound_volume': 0.8,
        'session_history': ['2023-03-19T10:00:00Z', '2023-03-19T11:00:00Z'],
        'daily_completed_sessions': 5,
        'weekly_completed_sessions': 20,
        'monthly_completed_sessions': 80,
        'total_completed_sessions': 500,
        'daily_focus_minutes': 125,
        'weekly_focus_minutes': 500,
        'monthly_focus_minutes': 2000,
        'total_focus_minutes': 12500,
        'current_streak': 7,
        'best_streak': 14,
        'last_completed_date': '2023-03-19',
        'subscription_type': 1,
        'expiry_date': '2024-03-19T00:00:00Z',
      });

      // Get local data
      final data = await syncDataHandler.getLocalData();

      // Verify all expected keys are present with correct values
      expect(data['sessionDuration'], equals(25.0));
      expect(data['shortBreakDuration'], equals(5.0));
      expect(data['longBreakDuration'], equals(15.0));
      expect(data['sessionsBeforeLongBreak'], equals(4));
      expect(data['autoStartBreaks'], isTrue);
      expect(data['autoStartPomodoros'], isFalse);
      expect(data['vibrationEnabled'], isTrue);
      expect(data['notificationsEnabled'], isTrue);
      expect(data['keepScreenOn'], isTrue);
      expect(data['selectedTheme'], equals('Dark'));
      expect(data['soundEnabled'], isTrue);
      expect(data['selectedSound'], equals('Bell'));
      expect(data['soundVolume'], equals(0.8));
      expect(data['sessionHistory'], isA<List<String>>());
      expect(data['sessionHistory'].length, equals(2));
      expect(data['dailyCompletedSessions'], equals(5));
      expect(data['weeklyCompletedSessions'], equals(20));
      expect(data['monthlyCompletedSessions'], equals(80));
      expect(data['totalCompletedSessions'], equals(500));
      expect(data['dailyFocusMinutes'], equals(125));
      expect(data['weeklyFocusMinutes'], equals(500));
      expect(data['monthlyFocusMinutes'], equals(2000));
      expect(data['totalFocusMinutes'], equals(12500));
      expect(data['currentStreak'], equals(7));
      expect(data['bestStreak'], equals(14));
      expect(data['lastCompletedDate'], equals('2023-03-19'));
      expect(data['subscriptionType'], equals(1));
      expect(data['expiryDate'], equals('2024-03-19T00:00:00Z'));
      expect(data['lastModified'], isA<int>());
    });

    test('getLocalData should handle missing values with defaults', () async {
      // Setup SharedPreferences with minimal data
      SharedPreferences.setMockInitialValues({});

      // Get local data
      final data = await syncDataHandler.getLocalData();

      // Verify defaults are used
      expect(data['sessionDuration'], equals(25.0));
      expect(data['shortBreakDuration'], equals(5.0));
      expect(data['longBreakDuration'], equals(15.0));
      expect(data['sessionsBeforeLongBreak'], equals(4));
      expect(data['autoStartBreaks'], isTrue);
      expect(data['autoStartPomodoros'], isFalse);
      expect(data['vibrationEnabled'], isTrue);
      expect(data['notificationsEnabled'], isTrue);
      expect(data['keepScreenOn'], isFalse);
      expect(data['selectedTheme'], equals('Light'));
      expect(data['soundEnabled'], isTrue);
      expect(data['selectedSound'], equals('Bell'));
      expect(data['soundVolume'], equals(0.5));
      expect(data.containsKey('sessionHistory'), isFalse);
      expect(data['dailyCompletedSessions'], equals(0));
      expect(data['weeklyCompletedSessions'], equals(0));
      expect(data['monthlyCompletedSessions'], equals(0));
      expect(data['totalCompletedSessions'], equals(0));
      expect(data['dailyFocusMinutes'], equals(0));
      expect(data['weeklyFocusMinutes'], equals(0));
      expect(data['monthlyFocusMinutes'], equals(0));
      expect(data['totalFocusMinutes'], equals(0));
      expect(data['currentStreak'], equals(0));
      expect(data['bestStreak'], equals(0));
      expect(data.containsKey('lastCompletedDate'), isTrue);
      expect(data['lastCompletedDate'], isNull);
      expect(data['subscriptionType'], equals(0));
      expect(data.containsKey('expiryDate'), isTrue);
      expect(data['expiryDate'], isNull);
      expect(data['lastModified'], isA<int>());
    });

    test('updateLocalData should only update if cloud data is newer', () async {
      // Setup SharedPreferences with initial data
      SharedPreferences.setMockInitialValues({
        'session_duration': 25.0,
        'short_break_duration': 5.0,
        'long_break_duration': 15.0,
        'last_modified':
            DateTime.now().millisecondsSinceEpoch - 100000, // 100 seconds ago
      });

      // Create cloud data that is newer
      final cloudData = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 10.0,
        'longBreakDuration': 20.0,
        'lastModified': DateTime.now().millisecondsSinceEpoch, // Now
      };

      // Update local data
      await syncDataHandler.updateLocalData(cloudData);

      // Verify data was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('session_duration'), equals(30.0));
      expect(prefs.getDouble('short_break_duration'), equals(10.0));
      expect(prefs.getDouble('long_break_duration'), equals(20.0));
    });

    test('updateLocalData should not update if local data is newer', () async {
      // Setup SharedPreferences with initial data
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'session_duration': 25.0,
        'short_break_duration': 5.0,
        'long_break_duration': 15.0,
        'last_modified': nowTimestamp, // Now
      });

      // Create cloud data that is older
      final cloudData = {
        'sessionDuration': 30.0,
        'shortBreakDuration': 10.0,
        'longBreakDuration': 20.0,
        'lastModified': nowTimestamp - 100000, // 100 seconds ago
      };

      // Update local data
      await syncDataHandler.updateLocalData(cloudData);

      // Verify data was NOT updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('session_duration'), equals(25.0));
      expect(prefs.getDouble('short_break_duration'), equals(5.0));
      expect(prefs.getDouble('long_break_duration'), equals(15.0));
    });

    test('updateLocalData should handle missing values', () async {
      // Setup SharedPreferences with initial data
      SharedPreferences.setMockInitialValues({
        'session_duration': 25.0,
        'short_break_duration': 5.0,
        'long_break_duration': 15.0,
        'last_modified':
            DateTime.now().millisecondsSinceEpoch - 100000, // 100 seconds ago
      });

      // Create cloud data with only some keys
      final cloudData = {
        'sessionDuration': 30.0,
        // shortBreakDuration missing
        'longBreakDuration': 20.0,
        'lastModified': DateTime.now().millisecondsSinceEpoch, // Now
      };

      // Update local data
      await syncDataHandler.updateLocalData(cloudData);

      // Verify partial update
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('session_duration'), equals(30.0));
      expect(prefs.getDouble('short_break_duration'), equals(5.0)); // Unchanged
      expect(prefs.getDouble('long_break_duration'), equals(20.0));
    });

    test('updateLocalData should update complex types', () async {
      // Setup SharedPreferences with initial data
      SharedPreferences.setMockInitialValues({
        'session_history': ['2023-03-18T10:00:00Z'],
        'last_modified':
            DateTime.now().millisecondsSinceEpoch - 100000, // 100 seconds ago
      });

      // Create cloud data with complex types
      final cloudData = {
        'sessionHistory': ['2023-03-18T10:00:00Z', '2023-03-19T10:00:00Z'],
        'lastModified': DateTime.now().millisecondsSinceEpoch, // Now
      };

      // Update local data
      await syncDataHandler.updateLocalData(cloudData);

      // Verify complex types updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('session_history'),
          equals(['2023-03-18T10:00:00Z', '2023-03-19T10:00:00Z']));
    });
  });
}
