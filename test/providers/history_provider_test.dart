import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/history_provider.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HistoryProvider historyProvider;
  late SharedPreferences prefs;
  final testTime1 = DateTime(2023, 5, 15, 10, 0); // May 15, 2023, 10:00 AM
  final testTime2 = DateTime(2023, 5, 15, 14, 0); // May 15, 2023, 2:00 PM
  final testTime3 = DateTime(2023, 5, 16, 9, 0); // May 16, 2023, 9:00 AM

  setUp(() async {
    // Set up shared preferences with mock data
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    historyProvider = HistoryProvider(prefs);
  });

  group('HistoryProvider Initialization', () {
    test('should initialize with empty history when no data exists', () {
      expect(historyProvider.history, isEmpty);
    });

    test(
        'should load history from SharedPreferences when available (string list format)',
        () async {
      // Prepare test data
      final entries = [
        HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1),
        HistoryEntry(category: 'Study', duration: 30, timestamp: testTime2),
      ];

      // Save entries to SharedPreferences as a string list
      final encodedEntries =
          entries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('history', encodedEntries);

      // Create a new provider instance to trigger loading from prefs
      final newProvider = HistoryProvider(prefs);

      // Wait for async loading to complete
      await Future.delayed(Duration.zero);

      // Verify entries were loaded correctly
      expect(newProvider.history.length, equals(2));
      expect(newProvider.history[0].category, equals('Work'));
      expect(newProvider.history[0].duration, equals(25));
      expect(newProvider.history[0].timestamp, equals(testTime1));
      expect(newProvider.history[1].category, equals('Study'));
      expect(newProvider.history[1].duration, equals(30));
      expect(newProvider.history[1].timestamp, equals(testTime2));
    });

    test('should handle error in JSON parsing gracefully', () async {
      // Set invalid JSON in the current format (string list)
      await prefs.setStringList('history', ['invalid json data']);

      // Create a new provider to trigger loading
      final newProvider = HistoryProvider(prefs);

      // Wait for async loading to complete
      await Future.delayed(Duration.zero);

      // Should handle error by setting empty history
      expect(newProvider.history, isEmpty);
    });
  });

  group('HistoryProvider Add/Delete Operations', () {
    test('should add a new history entry correctly', () async {
      // Add a new entry
      final newEntry = HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: testTime1,
      );

      historyProvider.addHistoryEntry(newEntry);

      // Verify the entry was added to the provider
      expect(historyProvider.history.length, equals(1));
      expect(historyProvider.history[0].category, equals('Work'));

      // Verify it was saved to SharedPreferences
      final savedEntries = prefs.getStringList('history');
      expect(savedEntries, isNotNull);
      expect(savedEntries!.length, equals(1));

      // Decode and verify the saved entry
      final decodedEntry = HistoryEntry.fromJson(jsonDecode(savedEntries[0]));
      expect(decodedEntry.category, equals('Work'));
      expect(decodedEntry.duration, equals(25));
      expect(decodedEntry.timestamp, equals(testTime1));
    });

    test('should delete a specific history entry correctly', () async {
      // Add multiple entries
      final entry1 =
          HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1);
      final entry2 =
          HistoryEntry(category: 'Study', duration: 30, timestamp: testTime2);

      historyProvider.addHistoryEntry(entry1);
      historyProvider.addHistoryEntry(entry2);

      // Verify both entries were added
      expect(historyProvider.history.length, equals(2));

      // Delete the first entry
      historyProvider.deleteHistoryEntry(entry1);

      // Verify only one entry remains
      expect(historyProvider.history.length, equals(1));
      expect(historyProvider.history[0].category, equals('Study'));

      // Verify SharedPreferences was updated
      final savedEntries = prefs.getStringList('history');
      expect(savedEntries, isNotNull);
      expect(savedEntries!.length, equals(1));

      final decodedEntry = HistoryEntry.fromJson(jsonDecode(savedEntries[0]));
      expect(decodedEntry.category, equals('Study'));
    });

    test('should clear all history entries correctly', () async {
      // Add multiple entries
      final entry1 =
          HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1);
      final entry2 =
          HistoryEntry(category: 'Study', duration: 30, timestamp: testTime2);

      historyProvider.addHistoryEntry(entry1);
      historyProvider.addHistoryEntry(entry2);

      // Verify entries were added
      expect(historyProvider.history.length, equals(2));

      // Clear all history
      historyProvider.clearHistory();

      // Verify history is empty
      expect(historyProvider.history, isEmpty);

      // Verify SharedPreferences was updated
      final savedEntries = prefs.getStringList('history');
      expect(savedEntries, isNotNull);
      expect(savedEntries, isEmpty);
    });
  });

  group('HistoryProvider Query Methods', () {
    setUp(() async {
      // Add test entries for query tests
      final entries = [
        HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1),
        HistoryEntry(category: 'Study', duration: 30, timestamp: testTime2),
        HistoryEntry(category: 'Work', duration: 40, timestamp: testTime3),
      ];

      for (final entry in entries) {
        historyProvider.addHistoryEntry(entry);
      }
    });

    test('should get history entries by category correctly', () {
      // Test getting 'Work' category
      final workEntries = historyProvider.getHistoryByCategory('Work');
      expect(workEntries.length, equals(2));
      expect(workEntries[0].category, equals('Work'));
      expect(workEntries[1].category, equals('Work'));

      // Test getting 'Study' category
      final studyEntries = historyProvider.getHistoryByCategory('Study');
      expect(studyEntries.length, equals(1));
      expect(studyEntries[0].category, equals('Study'));

      // Test getting 'All Categories'
      final allEntries = historyProvider.getHistoryByCategory('All Categories');
      expect(allEntries.length, equals(3));
    });

    test('should get history entries by date range correctly', () {
      // Get entries for May 15 only
      final day1Start = DateTime(2023, 5, 15);
      final day1End = DateTime(2023, 5, 16);

      final day1Entries =
          historyProvider.getHistoryByDateRange(day1Start, day1End);
      expect(day1Entries.length, equals(2));

      // Get entries for May 16 only
      final day2Start = DateTime(2023, 5, 16);
      final day2End = DateTime(2023, 5, 17);

      final day2Entries =
          historyProvider.getHistoryByDateRange(day2Start, day2End);
      expect(day2Entries.length, equals(1));
      expect(day2Entries[0].duration, equals(40));
    });

    test('should calculate total duration by category correctly', () {
      // Test 'Work' category (25 + 40 = 65)
      final workDuration = historyProvider.getTotalDurationByCategory('Work');
      expect(workDuration, equals(65));

      // Test 'Study' category (30)
      final studyDuration = historyProvider.getTotalDurationByCategory('Study');
      expect(studyDuration, equals(30));

      // Test 'All Categories' (25 + 30 + 40 = 95)
      final allDuration =
          historyProvider.getTotalDurationByCategory('All Categories');
      expect(allDuration, equals(95));
    });

    test('should count total sessions by category correctly', () {
      // Test 'Work' category (2 sessions)
      final workSessions = historyProvider.getTotalSessionsByCategory('Work');
      expect(workSessions, equals(2));

      // Test 'Study' category (1 session)
      final studySessions = historyProvider.getTotalSessionsByCategory('Study');
      expect(studySessions, equals(1));

      // Test 'All Categories' (3 sessions)
      final allSessions =
          historyProvider.getTotalSessionsByCategory('All Categories');
      expect(allSessions, equals(3));
    });
  });

  group('HistoryProvider Reload and Notification', () {
    test('should reload history data when requested', () async {
      // Add an entry
      final entry =
          HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1);
      historyProvider.addHistoryEntry(entry);

      // Modify data directly in SharedPreferences to simulate external change
      final modifiedEntries = [
        HistoryEntry(category: 'Study', duration: 35, timestamp: testTime2),
        HistoryEntry(category: 'Personal', duration: 20, timestamp: testTime3),
      ];

      final encodedEntries =
          modifiedEntries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('history', encodedEntries);

      // Reload history
      await historyProvider.reloadHistory();

      // Verify updated data was loaded
      expect(historyProvider.history.length, equals(2));
      expect(historyProvider.history[0].category, equals('Study'));
      expect(historyProvider.history[1].category, equals('Personal'));
    });

    test('should notify listeners when history changes', () async {
      int notificationCount = 0;

      // Subscribe to provider changes
      historyProvider.addListener(() {
        notificationCount++;
      });

      // Initial count should be zero
      expect(notificationCount, equals(0));

      // Add an entry should trigger notification
      final entry =
          HistoryEntry(category: 'Work', duration: 25, timestamp: testTime1);
      historyProvider.addHistoryEntry(entry);
      expect(notificationCount, equals(1));

      // Delete the entry should trigger another notification
      historyProvider.deleteHistoryEntry(entry);
      expect(notificationCount, equals(2));

      // Reload should trigger notification even if no changes
      await historyProvider.reloadHistory();
      expect(notificationCount, equals(3));
    });
  });
}
