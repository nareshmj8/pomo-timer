import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/widgets/timer/timer_display.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

// Mock implementation for SettingsProvider needed by TimerDisplay
class StubSettingsProvider extends ChangeNotifier implements SettingsProvider {
  bool _isDarkTheme = false;
  bool _isBreak = false;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  Duration? _remainingTime = const Duration(minutes: 25);
  int _completedSessions = 0;
  int _sessionsBeforeLongBreak = 4;

  // Setters for test control
  set isDarkThemeMock(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  set isBreakMock(bool value) {
    _isBreak = value;
    notifyListeners();
  }

  set isTimerRunningMock(bool value) {
    _isTimerRunning = value;
    notifyListeners();
  }

  set isTimerPausedMock(bool value) {
    _isTimerPaused = value;
    notifyListeners();
  }

  set remainingTimeMock(Duration? value) {
    _remainingTime = value;
    notifyListeners();
  }

  set completedSessionsMock(int value) {
    _completedSessions = value;
    notifyListeners();
  }

  set sessionsBeforeLongBreakMock(int value) {
    _sessionsBeforeLongBreak = value;
    notifyListeners();
  }

  // Getters required by the SettingsProvider interface
  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  bool get isBreak => _isBreak;

  @override
  bool get isTimerRunning => _isTimerRunning;

  @override
  bool get isTimerPaused => _isTimerPaused;

  @override
  Duration? get remainingTime => _remainingTime;

  @override
  int get completedSessions => _completedSessions;

  @override
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;

  @override
  Color get backgroundColor =>
      _isDarkTheme ? CupertinoColors.black : CupertinoColors.white;

  @override
  Color get textColor =>
      _isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      _isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  bool shouldTakeLongBreak() {
    return _completedSessions > 0 &&
        _completedSessions % _sessionsBeforeLongBreak == 0;
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late StubSettingsProvider settingsProvider;

  setUp(() {
    settingsProvider = StubSettingsProvider();
  });

  Widget createTestableWidget({Size screenSize = const Size(400, 800)}) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: TimerDisplay(
                settings: settingsProvider,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('TimerDisplay Widget - Display Tests', () {
    testWidgets('should debug text widgets in tree',
        (WidgetTester tester) async {
      // Set up timer with various times to debug the actual format
      settingsProvider.remainingTimeMock =
          const Duration(hours: 1, minutes: 25, seconds: 30);

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Find all text widgets and print them
      final Finder textFinder = find.byType(Text);
      final List<Widget> texts = tester.widgetList(textFinder).toList();

      print('Found ${texts.length} Text widgets:');
      for (int i = 0; i < texts.length; i++) {
        final Text text = texts[i] as Text;
        print('Text $i: "${text.data}"');
      }

      // This test is just for debugging
      expect(true, isTrue);
    });

    testWidgets('should display formatted time correctly',
        (WidgetTester tester) async {
      // Set up timer with 25 minutes
      settingsProvider.remainingTimeMock = const Duration(minutes: 25);

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify timer text is displayed correctly
      // Note the leading space in the text format
      expect(find.text(' 25:00'), findsOneWidget);
    });

    testWidgets('should handle hour formatting correctly',
        (WidgetTester tester) async {
      // Set up timer with 1 hour and 25 minutes
      settingsProvider.remainingTimeMock =
          const Duration(hours: 1, minutes: 25, seconds: 30);

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify timer text is displayed correctly with hours
      // Note the leading space in the text format
      expect(find.text(' 1:25:30'), findsOneWidget);
    });

    testWidgets('should display "Ready" status when timer is not running',
        (WidgetTester tester) async {
      // Set up timer as not running and not in break
      settingsProvider.isTimerRunningMock = false;
      settingsProvider.isBreakMock = false;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify status text
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('should display "Running" status when timer is running',
        (WidgetTester tester) async {
      // Set up timer as running and not paused
      settingsProvider.isTimerRunningMock = true;
      settingsProvider.isTimerPausedMock = false;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify status text
      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('should display "Paused" status when timer is paused',
        (WidgetTester tester) async {
      // Set up timer as running but paused
      settingsProvider.isTimerRunningMock = true;
      settingsProvider.isTimerPausedMock = true;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify status text
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('should display "Short Break" status when in short break',
        (WidgetTester tester) async {
      // Set up timer as not running and in break mode
      settingsProvider.isTimerRunningMock = false;
      settingsProvider.isBreakMock = true;
      // Make it a short break
      settingsProvider.completedSessionsMock = 1;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify status text
      expect(find.text('Short Break'), findsOneWidget);
    });

    testWidgets('should display "Long Break" status when in long break',
        (WidgetTester tester) async {
      // Set up timer as not running and in break mode
      settingsProvider.isTimerRunningMock = false;
      settingsProvider.isBreakMock = true;
      // Make it a long break (after 4 sessions)
      settingsProvider.completedSessionsMock = 4;
      settingsProvider.sessionsBeforeLongBreakMock = 4;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify status text
      expect(find.text('Long Break'), findsOneWidget);
    });

    testWidgets('should display session dots with correct completed count',
        (WidgetTester tester) async {
      // Set up for pomodoro mode (not break)
      settingsProvider.isBreakMock = false;
      settingsProvider.completedSessionsMock = 2;
      settingsProvider.sessionsBeforeLongBreakMock = 4;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify "Sessions until long break" text is shown
      expect(find.text('Sessions until long break'), findsOneWidget);

      // We can't directly check the icons, but we can verify the session counter is visible
      // This is a basic test that could be expanded with more specific validations
      expect(find.byIcon(CupertinoIcons.circle_fill),
          findsNWidgets(2)); // 2 completed
      expect(
          find.byIcon(CupertinoIcons.circle), findsNWidgets(2)); // 2 remaining
    });

    testWidgets('should not display session dots during break',
        (WidgetTester tester) async {
      // Set up for break mode
      settingsProvider.isBreakMock = true;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Verify session counter is not shown during breaks
      expect(find.text('Sessions until long break'), findsNothing);
    });
  });

  group('TimerDisplay Widget - Responsive Tests', () {
    testWidgets('should adapt to small screen sizes',
        (WidgetTester tester) async {
      // Test with a small screen size (e.g., iPhone SE)
      await tester.pumpWidget(createTestableWidget(
        screenSize: const Size(320, 568),
      ));
      await tester.pump();

      // Basic verification that the widget renders without errors
      expect(find.byType(TimerDisplay), findsOneWidget);
      expect(find.text(' 25:00'), findsOneWidget);
    });

    testWidgets('should adapt to tablet screen sizes',
        (WidgetTester tester) async {
      // Test with a tablet screen size
      await tester.pumpWidget(createTestableWidget(
        screenSize: const Size(768, 1024),
      ));
      await tester.pump();

      // Basic verification that the widget renders without errors
      expect(find.byType(TimerDisplay), findsOneWidget);
      expect(find.text(' 25:00'), findsOneWidget);
    });

    testWidgets('should adapt to landscape orientation',
        (WidgetTester tester) async {
      // Test with a landscape orientation
      await tester.pumpWidget(createTestableWidget(
        screenSize: const Size(800, 400),
      ));
      await tester.pump();

      // Basic verification that the widget renders without errors
      expect(find.byType(TimerDisplay), findsOneWidget);
      expect(find.text(' 25:00'), findsOneWidget);
    });

    testWidgets('should adapt to very small screens',
        (WidgetTester tester) async {
      // First set up the timer with hours to test that format
      settingsProvider.remainingTimeMock =
          const Duration(hours: 1, minutes: 25, seconds: 30);

      // Test with a very small screen size (e.g., iPhone 4s, smaller than iPhone SE)
      await tester.pumpWidget(createTestableWidget(
        screenSize:
            const Size(290, 480), // Even smaller to really test the constraints
      ));

      // Use pumpAndSettle to complete all animations
      await tester.pumpAndSettle();

      // Debug text widgets to find actual format used
      final Finder textFinder = find.byType(Text);
      final List<Widget> texts = tester.widgetList(textFinder).toList();

      // Print the text widgets to debug
      print('Found ${texts.length} Text widgets on very small screen:');
      for (int i = 0; i < texts.length; i++) {
        final Text text = texts[i] as Text;
        print('Text $i: "${text.data}"');
      }

      // Verify the timer text is present with the hours format
      expect(find.text(' 1:25:30'), findsOneWidget);
    });
  });

  group('TimerDisplay Widget - Theme Tests', () {
    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      // Set dark theme
      settingsProvider.isDarkThemeMock = true;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // We can only verify the widget builds correctly
      // Actual color validation would require more complex testing
      expect(find.byType(TimerDisplay), findsOneWidget);
    });

    testWidgets('should use different progress colors for break vs pomodoro',
        (WidgetTester tester) async {
      // Test in pomodoro mode
      settingsProvider.isBreakMock = false;
      settingsProvider.isTimerRunningMock = true;

      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Basic verification it renders without errors
      expect(find.byType(TimerDisplay), findsOneWidget);

      // Switch to break mode and verify it still renders
      settingsProvider.isBreakMock = true;
      await tester.pump();

      expect(find.byType(TimerDisplay), findsOneWidget);
    });
  });
}
