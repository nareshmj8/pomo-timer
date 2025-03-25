import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/screens/premium_success_modal.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PremiumSuccessModal', () {
    late Widget testWidget;
    late SettingsProvider settingsProvider;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create a settings provider for testing
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();

      // Create the test widget with providers
      testWidget = MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider),
          ],
          child: const PremiumSuccessModal(
            subscriptionType: SubscriptionType.monthly,
          ),
        ),
      );
    });

    testWidgets('should display premium success modal with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Wait for the modal to appear (after the delay in initState)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the title is displayed
      expect(find.text("You're now Premium!"), findsOneWidget);
    });

    testWidgets('should display different messages based on subscription type',
        (WidgetTester tester) async {
      // Test monthly subscription message
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('Thank you for your monthly subscription'),
          findsOneWidget);

      // Test yearly subscription message
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(
                  value: settingsProvider),
            ],
            child: const PremiumSuccessModal(
              subscriptionType: SubscriptionType.yearly,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('Thank you for your yearly subscription'),
          findsOneWidget);

      // Test lifetime subscription message
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(
                  value: settingsProvider),
            ],
            child: const PremiumSuccessModal(
              subscriptionType: SubscriptionType.lifetime,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(
          find.textContaining('Congratulations! You now have lifetime access'),
          findsOneWidget);
    });

    testWidgets('should display the "Start Using Premium" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the button is displayed
      expect(find.text('Start Using Premium'), findsOneWidget);
    });

    testWidgets('should close modal when tapping outside',
        (WidgetTester tester) async {
      // Create a test widget with a navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider<SettingsProvider>.value(
                                    value: settingsProvider),
                              ],
                              child: const PremiumSuccessModal(
                                subscriptionType: SubscriptionType.monthly,
                              ),
                            ),
                          );
                        },
                        child: const Text('Show Modal'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Show the modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the modal is displayed
      expect(find.text("You're now Premium!"), findsOneWidget);

      // Tap outside the modal content (on the semi-transparent background)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify the modal is closed
      expect(find.text("You're now Premium!"), findsNothing);
    });

    testWidgets('should navigate back when tapping the button',
        (WidgetTester tester) async {
      // Create a test widget with a navigator
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider<SettingsProvider>.value(
                                    value: settingsProvider),
                              ],
                              child: const PremiumSuccessModal(
                                subscriptionType: SubscriptionType.monthly,
                              ),
                            ),
                          );
                        },
                        child: const Text('Show Modal'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Show the modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the modal is displayed
      expect(find.text("You're now Premium!"), findsOneWidget);

      // Tap the "Start Using Premium" button
      await tester.tap(find.text('Start Using Premium'));
      await tester.pumpAndSettle();

      // Verify the modal is closed
      expect(find.text("You're now Premium!"), findsNothing);
    });
  });
}
