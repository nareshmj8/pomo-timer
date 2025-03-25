import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/screens/history/history_screen.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/screens/history/components/history_list.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

// Mock implementation of SettingsProvider
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  List<HistoryEntry> _history = [];

  @override
  List<HistoryEntry> get history => _history;

  void addHistoryEntry(HistoryEntry entry) {
    _history.add(entry);
    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    notifyListeners();
  }

  // Implement other required members with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock implementation of ThemeProvider
class MockThemeProvider extends ChangeNotifier implements ThemeProvider {
  bool _isDarkTheme = false;

  @override
  bool get isDarkTheme => _isDarkTheme;

  void setDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  // Implement required properties for ThemedContainer
  @override
  AppTheme get currentTheme => _isDarkTheme ? AppTheme.dark : AppTheme.light;

  @override
  Color get backgroundColor => currentTheme.backgroundColor;

  @override
  Color get textColor => currentTheme.textColor;

  @override
  Color get secondaryTextColor => currentTheme.secondaryTextColor;

  @override
  Color get listTileBackgroundColor => currentTheme.listTileBackgroundColor;

  @override
  Color get listTileTextColor => currentTheme.listTileTextColor;

  @override
  Color get separatorColor => currentTheme.separatorColor;

  @override
  Gradient? get backgroundGradient => currentTheme.backgroundGradient;

  @override
  String get selectedThemeName => currentTheme.name;

  // Implement other required members with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
}

void main() {
  group('HistoryScreen UI Tests', () {
    testWidgets('should display search field', (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    });

    testWidgets('should display history list with entries',
        (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      // Add sample history entries
      mockSettings.addHistoryEntry(
        HistoryEntry(
          category: 'Work',
          duration: 25 * 60,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.byType(HistoryList), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should filter entries when searching',
        (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      // Add sample history entries
      mockSettings.addHistoryEntry(
        HistoryEntry(
          category: 'Work',
          duration: 25 * 60,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      mockSettings.addHistoryEntry(
        HistoryEntry(
          category: 'Study',
          duration: 30 * 60,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      // Enter search query
      await tester.enterText(find.byType(CupertinoSearchTextField), 'work');
      await tester.pump();

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Study'), findsNothing);
    });

    testWidgets('should display empty state when no entries',
        (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      expect(find.text('No history yet'), findsOneWidget);
      expect(find.text('Complete sessions to see them here'), findsOneWidget);
    });

    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      // Set dark theme
      mockTheme.setDarkTheme(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      // Verify dark theme is applied
      expect(mockTheme.currentTheme.isDark, isTrue);
      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    });

    testWidgets('should navigate back using the navigation bar',
        (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      // Setup navigation with a TabController to test back navigation
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: CupertinoApp(
            home: CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.time),
                    label: 'Timer',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chart_bar),
                    label: 'History',
                  ),
                ],
              ),
              tabBuilder: (context, index) {
                if (index == 0) {
                  return const Center(child: Text('Timer Screen'));
                } else {
                  return const HistoryScreen();
                }
              },
            ),
          ),
        ),
      );

      // Switch to history tab
      await tester.tap(find.text('History'));
      await tester.pump();

      // Verify we're on history screen
      expect(find.byType(HistoryScreen), findsOneWidget);

      // Tap on Timer tab to go back
      await tester.tap(find.text('Timer'));
      await tester.pump();

      // Verify we're back on timer screen
      expect(find.text('Timer Screen'), findsOneWidget);
      expect(find.byType(HistoryScreen), findsNothing);
    });
  });

  group('HistoryScreen Interaction Tests', () {
    testWidgets('should update when new entries are added',
        (WidgetTester tester) async {
      final mockSettings = MockSettingsProvider();
      final mockTheme = MockThemeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
            ChangeNotifierProvider<ThemeProvider>.value(value: mockTheme),
          ],
          child: const CupertinoApp(
            home: HistoryScreen(),
          ),
        ),
      );

      // Verify empty state
      expect(find.text('No history yet'), findsOneWidget);

      // Add an entry
      mockSettings.addHistoryEntry(
        HistoryEntry(
          category: 'Work',
          duration: 25 * 60,
          timestamp: DateTime.now(),
        ),
      );

      // Rebuild widget
      await tester.pump();

      // Verify the entry appears
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('No history yet'), findsNothing);
    });
  });
}
