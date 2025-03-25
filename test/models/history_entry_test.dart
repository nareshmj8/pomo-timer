import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';

void main() {
  group('HistoryEntry', () {
    late DateTime testTime;
    late HistoryEntry historyEntry;

    setUp(() {
      // Use a fixed timestamp for testing to ensure consistent results
      testTime = DateTime(2023, 5, 15, 10, 30); // May 15, 2023, 10:30 AM

      historyEntry = HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: testTime,
      );
    });

    test('constructor should set all properties correctly', () {
      expect(historyEntry.category, equals('Work'));
      expect(historyEntry.duration, equals(25));
      expect(historyEntry.timestamp, equals(testTime));
    });

    test('toJson should convert HistoryEntry to JSON correctly', () {
      final json = historyEntry.toJson();

      expect(json['category'], equals('Work'));
      expect(json['duration'], equals(25));
      expect(json['timestamp'], equals(testTime.toIso8601String()));
    });

    test('fromJson should create HistoryEntry from JSON correctly', () {
      final json = {
        'category': 'Study',
        'duration': 30,
        'timestamp': DateTime(2023, 5, 16, 14, 0)
            .toIso8601String(), // May 16, 2023, 2:00 PM
      };

      final entry = HistoryEntry.fromJson(json);

      expect(entry.category, equals('Study'));
      expect(entry.duration, equals(30));
      expect(entry.timestamp, equals(DateTime(2023, 5, 16, 14, 0)));
    });

    test('roundtrip JSON conversion should preserve all properties', () {
      final json = historyEntry.toJson();
      final roundtrippedEntry = HistoryEntry.fromJson(json);

      expect(roundtrippedEntry.category, equals(historyEntry.category));
      expect(roundtrippedEntry.duration, equals(historyEntry.duration));
      expect(roundtrippedEntry.timestamp, equals(historyEntry.timestamp));
    });
  });
}
