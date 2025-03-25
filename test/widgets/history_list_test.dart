import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/screens/history/components/history_list.dart';
import 'package:pomodoro_timemaster/screens/history/components/history_card.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';

class MockThemeProvider extends ChangeNotifier implements ThemeProvider {
  bool _isDarkTheme;

  MockThemeProvider({bool isDarkTheme = false}) : _isDarkTheme = isDarkTheme;

  @override
  bool get isDarkTheme => _isDarkTheme;

  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  @override
  Color get textColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  Color get listTileBackgroundColor =>
      isDarkTheme ? const Color(0xFF1C1C1E) : CupertinoColors.white;

  @override
  Color get separatorColor =>
      isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200;

  @override
  Gradient? get backgroundGradient => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockThemeProvider themeProvider;
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.toString().split(' ')[0]} • ${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  setUp(() {
    themeProvider = MockThemeProvider();
  });

  testWidgets('HistoryList displays entries correctly',
      (WidgetTester tester) async {
    // Create test history entries
    final entries = [
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: DateTime(2023, 5, 15, 14, 30),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 45,
        timestamp: DateTime(2023, 5, 15, 16, 0),
      ),
      HistoryEntry(
        category: 'Meditation',
        duration: 10,
        timestamp: DateTime(2023, 5, 15, 18, 15),
      ),
    ];

    // Build widget with phone form factor
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)), // Phone size
        child: MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ThemeProvider>.value(
              value: themeProvider,
              child: HistoryList(
                entries: entries,
                searchQuery: '',
                formatDateTime: formatDateTime,
              ),
            ),
          ),
        ),
      ),
    );

    // Verify all entries are displayed in list view
    expect(find.byType(HistoryCard), findsNWidgets(3));
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Meditation'), findsOneWidget);

    // Verify ListView is used for phone layout
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('HistoryList displays entries in grid for tablet',
      (WidgetTester tester) async {
    // Create test history entries
    final entries = [
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: DateTime(2023, 5, 15, 14, 30),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 45,
        timestamp: DateTime(2023, 5, 15, 16, 0),
      ),
      HistoryEntry(
        category: 'Meditation',
        duration: 10,
        timestamp: DateTime(2023, 5, 15, 18, 15),
      ),
    ];

    // Build widget with tablet form factor
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)), // Tablet size
        child: MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ThemeProvider>.value(
              value: themeProvider,
              child: HistoryList(
                entries: entries,
                searchQuery: '',
                formatDateTime: formatDateTime,
              ),
            ),
          ),
        ),
      ),
    );

    // Verify GridView is used for tablet layout
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    // Verify all entries are displayed in grid
    expect(find.byType(HistoryCard), findsNWidgets(3));
  });

  testWidgets('HistoryList shows empty state when no entries',
      (WidgetTester tester) async {
    // Build widget with empty entries list
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryList(
              entries: const [],
              searchQuery: '',
              formatDateTime: formatDateTime,
            ),
          ),
        ),
      ),
    );

    // Verify empty state is displayed
    expect(find.text('No history yet'), findsOneWidget);
    expect(find.text('Complete sessions to see them here'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);

    // Verify history cards are not displayed
    expect(find.byType(HistoryCard), findsNothing);
  });

  testWidgets('HistoryList filters entries based on search query',
      (WidgetTester tester) async {
    // Create test history entries
    final entries = [
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: DateTime(2023, 5, 15, 14, 30),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 45,
        timestamp: DateTime(2023, 5, 15, 16, 0),
      ),
      HistoryEntry(
        category: 'Meditation',
        duration: 10,
        timestamp: DateTime(2023, 5, 15, 18, 15),
      ),
    ];

    // Build widget with search query that matches only one entry
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)), // Phone size
        child: MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ThemeProvider>.value(
              value: themeProvider,
              child: HistoryList(
                entries: entries,
                searchQuery: 'work',
                formatDateTime: formatDateTime,
              ),
            ),
          ),
        ),
      ),
    );

    // Only items that match the search query should be visible
    // but all items are technically in the widget tree, just some are SizedBox.shrink()
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Study'), findsNothing);
    expect(find.text('Meditation'), findsNothing);

    // Update search query to match different entry
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)), // Phone size
        child: MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ThemeProvider>.value(
              value: themeProvider,
              child: HistoryList(
                entries: entries,
                searchQuery: 'study',
                formatDateTime: formatDateTime,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    // Only the Study entry should be visible
    expect(find.text('Work'), findsNothing);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Meditation'), findsNothing);
  });

  testWidgets('HistoryList adapts to theme changes',
      (WidgetTester tester) async {
    // Create test history entries
    final entries = [
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: DateTime(2023, 5, 15, 14, 30),
      ),
    ];

    // Set up for empty state test with dark theme
    themeProvider.isDarkTheme = true;

    // Build widget with empty entries list
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryList(
              entries: const [],
              searchQuery: '',
              formatDateTime: formatDateTime,
            ),
          ),
        ),
      ),
    );

    // Get the text widget for the empty state message
    final textFinder = find.text('No history yet');
    final text = tester.widget<Text>(textFinder);

    // Verify text color matches dark theme
    expect(text.style?.color, equals(CupertinoColors.white));

    // Change to light theme
    themeProvider.isDarkTheme = false;

    // Rebuild with light theme
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryList(
              entries: const [],
              searchQuery: '',
              formatDateTime: formatDateTime,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    // Get text again and verify color changed to light theme
    final updatedTextFinder = find.text('No history yet');
    final updatedText = tester.widget<Text>(updatedTextFinder);

    // Expect black for light theme
    expect(updatedText.style?.color, equals(CupertinoColors.black));
  });
}
