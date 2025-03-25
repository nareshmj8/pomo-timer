import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/animations/purchase_success_handler.dart';
import 'package:pomodoro_timemaster/screens/premium_success_modal.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PurchaseSuccessHandler', () {
    late SettingsProvider settingsProvider;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create a settings provider for testing
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();
    });

    testWidgets('should show success animation with correct subscription type',
        (WidgetTester tester) async {
      // Create a test widget with a navigator and providers
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsProvider>.value(
                    value: settingsProvider),
              ],
              child: child!,
            );
          },
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PurchaseSuccessHandler.showSuccessAnimation(
                    context,
                    SubscriptionType.monthly,
                  );
                },
                child: const Text('Show Success Animation'),
              );
            },
          ),
        ),
      );

      // Trigger the success animation
      await tester.tap(find.text('Show Success Animation'));
      await tester.pumpAndSettle();

      // Wait for the modal to appear (after the delay in initState)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed with the correct subscription type
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your monthly subscription'),
          findsOneWidget);
    });

    testWidgets('should show success animation for yearly subscription',
        (WidgetTester tester) async {
      // Create a test widget with a navigator and providers
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsProvider>.value(
                    value: settingsProvider),
              ],
              child: child!,
            );
          },
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PurchaseSuccessHandler.showSuccessAnimation(
                    context,
                    SubscriptionType.yearly,
                  );
                },
                child: const Text('Show Success Animation'),
              );
            },
          ),
        ),
      );

      // Trigger the success animation
      await tester.tap(find.text('Show Success Animation'));
      await tester.pumpAndSettle();

      // Wait for the modal to appear (after the delay in initState)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed with the correct subscription type
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your yearly subscription'),
          findsOneWidget);
    });

    testWidgets('should show success animation for lifetime subscription',
        (WidgetTester tester) async {
      // Create a test widget with a navigator and providers
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsProvider>.value(
                    value: settingsProvider),
              ],
              child: child!,
            );
          },
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PurchaseSuccessHandler.showSuccessAnimation(
                    context,
                    SubscriptionType.lifetime,
                  );
                },
                child: const Text('Show Success Animation'),
              );
            },
          ),
        ),
      );

      // Trigger the success animation
      await tester.tap(find.text('Show Success Animation'));
      await tester.pumpAndSettle();

      // Wait for the modal to appear (after the delay in initState)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed with the correct subscription type
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(
          find.textContaining('Congratulations! You now have lifetime access'),
          findsOneWidget);
    });

    testWidgets('showSuccessAnimationGlobal should work with navigatorKey',
        (WidgetTester tester) async {
      // Create a test app that uses the same navigator key
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: RevenueCatService.navigatorKey,
          builder: (context, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<SettingsProvider>.value(
                    value: settingsProvider),
              ],
              child: child!,
            );
          },
          home: const Scaffold(
            body: Center(
              child: Text('Test Home'),
            ),
          ),
        ),
      );

      // Call the global method
      PurchaseSuccessHandler.showSuccessAnimationGlobal(
          SubscriptionType.yearly);
      await tester.pumpAndSettle();

      // Wait for the modal to appear (after the delay in initState)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your yearly subscription'),
          findsOneWidget);
    });
  });
}
