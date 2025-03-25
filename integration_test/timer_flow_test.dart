import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomodoro_timemaster/main.dart' as app;
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Timer Flow Integration Tests', () {
    // Clear shared preferences before each test
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
    });

    testWidgets('Start, pause, resume and reset timer session',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to the timer screen (if not already on it)
      final timerNavItem = find.byIcon(Icons.timer);
      if (timerNavItem.evaluate().isNotEmpty) {
        await tester.tap(timerNavItem);
        await tester.pumpAndSettle();
      }

      // Find and tap the start button
      final startButton = find.byIcon(Icons.play_arrow);
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify the timer is running
      final TimerSettingsProvider timerProvider =
          Provider.of<TimerSettingsProvider>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );
      expect(timerProvider.isTimerRunning, isTrue);
      expect(timerProvider.isTimerPaused, isFalse);

      // Wait a moment to let the timer run
      await tester.pump(const Duration(seconds: 2));

      // Pause the timer
      final pauseButton = find.byIcon(Icons.pause);
      expect(pauseButton, findsOneWidget);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // Verify the timer is paused
      expect(timerProvider.isTimerRunning, isTrue);
      expect(timerProvider.isTimerPaused, isTrue);

      // Resume the timer
      final resumeButton = find.byIcon(Icons.play_arrow);
      expect(resumeButton, findsOneWidget);
      await tester.tap(resumeButton);
      await tester.pumpAndSettle();

      // Verify the timer is running again
      expect(timerProvider.isTimerRunning, isTrue);
      expect(timerProvider.isTimerPaused, isFalse);

      // Reset the timer
      final resetButton = find.byIcon(Icons.refresh);
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify the timer is reset
      expect(timerProvider.isTimerRunning, isFalse);
      expect(timerProvider.isTimerPaused, isFalse);
    });

    testWidgets('Timer state persists across app restarts',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to the timer screen (if not already on it)
      final timerNavItem = find.byIcon(Icons.timer);
      if (timerNavItem.evaluate().isNotEmpty) {
        await tester.tap(timerNavItem);
        await tester.pumpAndSettle();
      }

      // Set a custom session duration
      TimerSettingsProvider timerProvider = Provider.of<TimerSettingsProvider>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );
      timerProvider.setSessionDuration(30);
      await tester.pumpAndSettle();

      // Start the timer
      final startButton = find.byIcon(Icons.play_arrow);
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify the timer is running
      expect(timerProvider.isTimerRunning, isTrue);
      expect(timerProvider.sessionDuration, 30);

      // "Restart" the app by reinitializing
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Navigate to the timer screen (if not already on it)
      final timerNavItemAgain = find.byIcon(Icons.timer);
      if (timerNavItemAgain.evaluate().isNotEmpty) {
        await tester.tap(timerNavItemAgain);
        await tester.pumpAndSettle();
      }

      // Get provider state after restart
      timerProvider = Provider.of<TimerSettingsProvider>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );

      // Verify the timer state persisted
      expect(timerProvider.sessionDuration, 30);
      // Note: Timer running state may or may not persist depending on implementation
      // Some apps intentionally pause timers on app close
    });
  });
}
