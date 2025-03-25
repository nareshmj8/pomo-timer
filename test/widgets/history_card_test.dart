import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
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

  setUp(() {
    themeProvider = MockThemeProvider();
  });

  testWidgets('HistoryCard displays entry details correctly',
      (WidgetTester tester) async {
    // Create test history entry
    final entry = HistoryEntry(
      category: 'Work',
      duration: 25,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );
    const formattedTime = 'May 15, 2023 • 2:30 PM';

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: entry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Verify category is displayed
    expect(find.text('Work'), findsOneWidget);

    // Verify duration is displayed
    expect(find.text('25 min'), findsOneWidget);

    // Verify formatted time is displayed
    expect(find.text(formattedTime), findsOneWidget);
  });

  testWidgets('HistoryCard adapts to light theme', (WidgetTester tester) async {
    // Create test history entry
    final entry = HistoryEntry(
      category: 'Work',
      duration: 25,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );
    const formattedTime = 'May 15, 2023 • 2:30 PM';

    themeProvider.isDarkTheme = false;

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: entry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Find the outermost container
    final containerFinder = find.byType(Container).first;
    final container = tester.widget<Container>(containerFinder);

    // Verify container decoration in light theme
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(CupertinoColors.white));
  });

  testWidgets('HistoryCard adapts to dark theme', (WidgetTester tester) async {
    // Create test history entry
    final entry = HistoryEntry(
      category: 'Work',
      duration: 25,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );
    const formattedTime = 'May 15, 2023 • 2:30 PM';

    themeProvider.isDarkTheme = true;

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: entry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Find the outermost container
    final containerFinder = find.byType(Container).first;
    final container = tester.widget<Container>(containerFinder);

    // Verify container decoration in dark theme
    final BoxDecoration decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(const Color(0xFF1C1C1E)));
  });

  testWidgets('HistoryCard handles long category names',
      (WidgetTester tester) async {
    // Create test history entry with long category name
    final entry = HistoryEntry(
      category: 'Very Long Category Name That Should Be Displayed Properly',
      duration: 25,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );
    const formattedTime = 'May 15, 2023 • 2:30 PM';

    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: entry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Verify the long category is displayed
    expect(
        find.text('Very Long Category Name That Should Be Displayed Properly'),
        findsOneWidget);

    // No error should be thrown for layout overflow
  });

  testWidgets('HistoryCard displays correct duration format',
      (WidgetTester tester) async {
    // Create test history entries with different durations
    final shortEntry = HistoryEntry(
      category: 'Short',
      duration: 5,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );

    final longEntry = HistoryEntry(
      category: 'Long',
      duration: 120,
      timestamp: DateTime(2023, 5, 15, 14, 30),
    );

    const formattedTime = 'May 15, 2023 • 2:30 PM';

    // Build widget with short duration
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: shortEntry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Verify short duration format
    expect(find.text('5 min'), findsOneWidget);

    // Rebuild with long duration
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: HistoryCard(
              entry: longEntry,
              formattedTime: formattedTime,
            ),
          ),
        ),
      ),
    );

    // Verify long duration format
    expect(find.text('120 min'), findsOneWidget);
  });
}
