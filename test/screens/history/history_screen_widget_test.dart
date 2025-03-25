import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/history/history_screen.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

// Create a simplified test that doesn't rely on mocks
void main() {
  testWidgets('History Screen shows history entries correctly',
      (WidgetTester tester) async {
    // Create test entries
    final testEntries = [
      HistoryEntry(
        category: 'Work',
        duration: 25,
        timestamp: DateTime(2023, 3, 22, 10, 0),
      ),
      HistoryEntry(
        category: 'Study',
        duration: 30,
        timestamp: DateTime(2023, 3, 22, 11, 30),
      ),
    ];

    // Create a simplified settings provider that returns our test entries
    final settingsProvider = TestSettingsProvider(testEntries);

    // Create a theme provider with the default theme
    final themeProvider = TestThemeProvider();

    // Build our app with the test providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
              value: settingsProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const CupertinoApp(
          home: HistoryScreen(),
        ),
      ),
    );

    // Allow animations to complete
    await tester.pumpAndSettle();

    // Verify the navigation bar title
    expect(find.text('History'), findsOneWidget);

    // Verify that entries are displayed
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);

    // Test empty state
    settingsProvider.clearHistory();
    await tester.pumpAndSettle();

    // Verify empty state is shown
    expect(find.text('No history yet'), findsOneWidget);
    expect(find.text('Complete sessions to see them here'), findsOneWidget);
  });
}

// Test implementation of SettingsProvider
class TestSettingsProvider extends ChangeNotifier implements SettingsProvider {
  List<HistoryEntry> _history;

  TestSettingsProvider(this._history);

  @override
  List<HistoryEntry> get history => _history;

  void clearHistory() {
    _history = [];
    notifyListeners();
  }

  // Implement only the methods used in the test
  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Test implementation of ThemeProvider
class TestThemeProvider extends ChangeNotifier implements ThemeProvider {
  final _theme = AppTheme.light;

  @override
  AppTheme get currentTheme => _theme;

  @override
  Color get backgroundColor => _theme.backgroundColor;

  @override
  bool get isDarkTheme => _theme.isDark;

  @override
  Color get listTileBackgroundColor => _theme.listTileBackgroundColor;

  @override
  Color get secondaryTextColor => _theme.secondaryTextColor;

  @override
  Color get separatorColor => _theme.separatorColor;

  @override
  Color get textColor => _theme.textColor;

  // Implement only the methods used in the test
  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
