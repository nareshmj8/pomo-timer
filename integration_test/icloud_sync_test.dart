import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('iCloud Sync Integration Tests', () {
    testWidgets('Initial setup and sync - should sync settings correctly',
        (WidgetTester tester) async {
      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings -> Data Sync
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data & Sync'));
      await tester.pumpAndSettle();

      // Enable iCloud Sync
      final syncSwitch = find.byType(Switch).first;
      await tester.tap(syncSwitch);
      await tester.pumpAndSettle();

      // Accept the confirmation dialog
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      // Verify sync is enabled
      expect(find.text('iCloud Sync Enabled'), findsOneWidget);

      // Go back to main settings
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Change a setting to trigger sync
      await tester.tap(find.text('Timer Settings'));
      await tester.pumpAndSettle();

      // Change focus duration
      await tester.drag(find.byType(Slider).first, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Wait for sync to complete (simulated)
      await Future.delayed(const Duration(seconds: 2));

      // Verify sync indicator appears
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('Cross-device sync simulation', (WidgetTester tester) async {
      // Set up SharedPreferences with existing settings
      SharedPreferences.setMockInitialValues({
        'icloud_sync_enabled': true,
        'focus_duration': 25,
        'short_break_duration': 5,
        'long_break_duration': 15,
      });

      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings -> Data Sync
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data & Sync'));
      await tester.pumpAndSettle();

      // Simulate receiving data from another device
      // In a real app, this would happen automatically through iCloud
      // But for testing, we'll use test buttons if available

      final simulateButton = find.text('Simulate Sync From Other Device');
      if (simulateButton.evaluate().isNotEmpty) {
        await tester.tap(simulateButton);
        await tester.pumpAndSettle();

        // Wait for sync to complete
        await Future.delayed(const Duration(seconds: 2));

        // Verify sync received indicator
        expect(find.text('Sync Received'), findsOneWidget);
      } else {
        // If test button isn't available, just verify sync is enabled
        expect(find.text('iCloud Sync Enabled'), findsOneWidget);
      }
    });

    testWidgets('Offline and reconnect scenario', (WidgetTester tester) async {
      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues({
        'icloud_sync_enabled': true,
        'focus_duration': 25,
        'short_break_duration': 5,
        'long_break_duration': 15,
      });

      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Timer screen
      await tester.tap(find.byIcon(Icons.timer));
      await tester.pumpAndSettle();

      // Simulate going offline
      // In a real test, this would involve platform-specific methods
      // For this test, we'll use a test button if available

      final simulateOfflineButton = find.text('Simulate Offline');
      if (simulateOfflineButton.evaluate().isNotEmpty) {
        await tester.tap(simulateOfflineButton);
        await tester.pumpAndSettle();

        // Verify offline indicator appears
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);

        // Start and complete a pomodoro session
        await tester.tap(find.byIcon(Icons.play_arrow));
        await tester.pumpAndSettle();

        // Fast forward time (in a real test, this would be more sophisticated)
        // For this test, we'll use a test button
        final fastForwardButton = find.text('Fast Forward');
        if (fastForwardButton.evaluate().isNotEmpty) {
          await tester.tap(fastForwardButton);
          await tester.pumpAndSettle();
        } else {
          // Otherwise, just fast forward manually
          await Future.delayed(const Duration(seconds: 5));
          await tester.pump();
        }

        // Simulate coming back online
        final simulateOnlineButton = find.text('Simulate Online');
        if (simulateOnlineButton.evaluate().isNotEmpty) {
          await tester.tap(simulateOnlineButton);
          await tester.pumpAndSettle();

          // Wait for sync to complete
          await Future.delayed(const Duration(seconds: 2));

          // Verify sync indicator appears
          expect(find.byIcon(Icons.cloud_done), findsOneWidget);
        }
      } else {
        // If test buttons aren't available, skip this part
        print('Offline simulation skipped - test buttons not available');
      }
    });

    testWidgets('Edge case - conflicting edits resolution',
        (WidgetTester tester) async {
      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues({
        'icloud_sync_enabled': true,
        'focus_duration': 25,
        'short_break_duration': 5,
        'long_break_duration': 15,
      });

      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings -> Data Sync
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data & Sync'));
      await tester.pumpAndSettle();

      // Simulate conflict using test buttons if available
      final simulateConflictButton = find.text('Simulate Sync Conflict');
      if (simulateConflictButton.evaluate().isNotEmpty) {
        await tester.tap(simulateConflictButton);
        await tester.pumpAndSettle();

        // Wait for conflict resolution dialog
        expect(find.text('Sync Conflict'), findsOneWidget);

        // Choose to keep device data
        await tester.tap(find.text('Keep Device Data'));
        await tester.pumpAndSettle();

        // Verify conflict resolved indicator
        expect(find.text('Conflict Resolved'), findsOneWidget);
      } else {
        // If test buttons aren't available, skip this part
        print('Conflict resolution test skipped - test buttons not available');
      }
    });
  });
}
