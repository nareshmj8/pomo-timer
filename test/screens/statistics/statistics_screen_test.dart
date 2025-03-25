import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/history_provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/providers/statistics_provider.dart';
import 'package:pomodoro_timemaster/screens/statistics/statistics_screen.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

class MockRevenueCatService extends RevenueCatService {
  final bool _isPremium;

  MockRevenueCatService({bool isPremium = false}) : _isPremium = isPremium;

  @override
  bool get isPremium => _isPremium;

  Future<bool> get isSubscribed async => _isPremium;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  final bool _isDarkTheme;

  MockSettingsProvider({bool isDarkTheme = false}) : _isDarkTheme = isDarkTheme;

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  Color get textColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get listTileTextColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  Color get listTileBackgroundColor =>
      isDarkTheme ? const Color(0xFF1C1C1E) : CupertinoColors.white;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockStatisticsProvider extends ChangeNotifier
    implements StatisticsProvider {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _tasks = [];

  MockStatisticsProvider({
    List<Map<String, dynamic>>? sessions,
    List<Map<String, dynamic>>? tasks,
  }) {
    if (sessions != null) _sessions = sessions;
    if (tasks != null) _tasks = tasks;
  }

  List<Map<String, dynamic>> get pomodoroSessions => _sessions;

  List<Map<String, dynamic>> get taskEntries => _tasks;

  Map<String, int> get taskCounts => {'Work': 5, 'Study': 3, 'Personal': 2};

  int get totalFocusTime => 7200; // 2 hours in seconds

  int get totalSessions => 10;

  double get averageSessionLength => 720.0; // 12 minutes in seconds

  String get mostProductiveDay => 'Monday';

  String get mostProductiveTime => '9:00 AM';

  List<Map<String, dynamic>> get focusTimeByDayData => [
        {'label': 'Mon', 'value': 3600},
        {'label': 'Tue', 'value': 1800},
        {'label': 'Wed', 'value': 2700},
        {'label': 'Thu', 'value': 900},
        {'label': 'Fri', 'value': 1200},
        {'label': 'Sat', 'value': 300},
        {'label': 'Sun', 'value': 600},
      ];

  List<Map<String, dynamic>> get sessionsCompletedByDayData => [
        {'label': 'Mon', 'value': 4},
        {'label': 'Tue', 'value': 2},
        {'label': 'Wed', 'value': 3},
        {'label': 'Thu', 'value': 1},
        {'label': 'Fri', 'value': 2},
        {'label': 'Sat', 'value': 0},
        {'label': 'Sun', 'value': 1},
      ];

  List<Map<String, dynamic>> get taskCategoryData => [
        {'label': 'Work', 'value': 5},
        {'label': 'Study', 'value': 3},
        {'label': 'Personal', 'value': 2},
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHistoryProvider extends ChangeNotifier implements HistoryProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestWidget({
    bool isDarkTheme = false,
    bool isPremium = false,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => MockSettingsProvider(isDarkTheme: isDarkTheme),
          ),
          ChangeNotifierProvider<StatisticsProvider>(
            create: (_) => MockStatisticsProvider(),
          ),
          ChangeNotifierProvider<HistoryProvider>(
            create: (_) => MockHistoryProvider(),
          ),
          Provider<RevenueCatService>(
            create: (_) => MockRevenueCatService(isPremium: isPremium),
          ),
        ],
        child: const StatisticsScreen(),
      ),
    );
  }

  group('StatisticsScreen - UI Tests', () {
    testWidgets('should display the Statistics screen title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('should display overview statistics',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('2:00'), findsOneWidget); // Total focus time
      expect(find.text('10'), findsOneWidget); // Total sessions
      expect(find.text('12:00'), findsOneWidget); // Average session
    });

    testWidgets('should display productivity insights',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Productivity Insights'), findsOneWidget);
      expect(find.text('Most Productive Day'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Most Productive Time'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
    });

    testWidgets('should display a premium banner for non-premium users',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isPremium: false));
      await tester.pump();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('should not display a premium banner for premium users',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isPremium: true));
      await tester.pump();

      expect(find.text('Upgrade to Premium'), findsNothing);
    });
  });

  group('StatisticsScreen - Interaction Tests', () {
    testWidgets('should allow tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Default should be on the Overview tab
      expect(find.text('Overview').hitTestable(), findsOneWidget);

      // Switch to Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // Should now show task distribution
      expect(find.text('Task Distribution'), findsOneWidget);
    });

    testWidgets('should show date range selector in History tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Should show date range selector
      expect(find.text('This Week'), findsOneWidget);
    });

    testWidgets('should adapt to tablet mode', (WidgetTester tester) async {
      // Set a tablet-sized screen
      tester.view.physicalSize = const Size(1024 * 3, 768 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      addTearDown(tester.view.resetPhysicalSize);

      // Should display the Statistics screen properly
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Overview').hitTestable(), findsOneWidget);
    });
  });

  group('StatisticsScreen - Chart Tests', () {
    testWidgets('should display Focus Time by Day chart',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Focus Time by Day'), findsOneWidget);
    });

    testWidgets('should display Sessions by Day chart',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Sessions by Day'), findsOneWidget);
    });

    testWidgets('should display Task Distribution chart in Tasks tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Switch to Tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      expect(find.text('Task Distribution'), findsOneWidget);
    });
  });

  group('StatisticsScreen - Theme Tests', () {
    testWidgets('should use light theme colors when in light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isDarkTheme: false));
      await tester.pump();

      // Verify that we're in light mode
      final context = tester.element(find.byType(StatisticsScreen));
      expect(
        Theme.of(context).brightness,
        equals(Brightness.light),
      );
    });

    testWidgets('should use dark theme colors when in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isDarkTheme: true));
      await tester.pump();

      // Verify that we're in dark mode
      final context = tester.element(find.byType(StatisticsScreen));
      expect(
        Theme.of(context).brightness,
        equals(Brightness.dark),
      );
    });
  });
}
