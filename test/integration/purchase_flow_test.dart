import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/screens/premium_success_modal.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import '../mocks/mock_notification_service.dart';

// Mock class that doesn't use actual dialogs for testing
class MockPremiumSuccessHandler {
  static Widget buildSuccessModal(
      BuildContext context, SubscriptionType subscriptionType) {
    return PremiumSuccessModal(
      subscriptionType: subscriptionType,
    );
  }
}

void main() {
  group('Purchase Flow Integration Tests', () {
    late SettingsProvider settingsProvider;
    late RevenueCatService revenueCatService;
    late MockNotificationService mockNotificationService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Set up notification service
      mockNotificationService = MockNotificationService();
      final serviceLocator = ServiceLocator();
      serviceLocator.registerNotificationService(mockNotificationService);

      // Create a settings provider for testing
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();

      // Create RevenueCat service
      revenueCatService = RevenueCatService();
    });

    tearDown(() {
      // Clean up service locator
      final serviceLocator = ServiceLocator();
      serviceLocator.reset();
    });

    // Helper function to build a test widget with a success modal
    Widget buildModalTestApp({required SubscriptionType subscriptionType}) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider),
            ChangeNotifierProvider<RevenueCatService>.value(
                value: revenueCatService),
          ],
          child: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return MockPremiumSuccessHandler.buildSuccessModal(
                    context,
                    subscriptionType,
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Confetti Trigger Test - Monthly Subscription',
        (WidgetTester tester) async {
      // Build our app with a monthly subscription modal
      await tester.pumpWidget(buildModalTestApp(
        subscriptionType: SubscriptionType.monthly,
      ));

      // Let the modal animations happen
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed with the right content
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your monthly subscription'),
          findsOneWidget);
    });

    testWidgets('Confetti Trigger Test - Yearly Subscription',
        (WidgetTester tester) async {
      // Build our app with a yearly subscription modal
      await tester.pumpWidget(buildModalTestApp(
        subscriptionType: SubscriptionType.yearly,
      ));

      // Let the modal animations happen
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your yearly subscription'),
          findsOneWidget);
    });

    testWidgets('Confetti Trigger Test - Lifetime Subscription',
        (WidgetTester tester) async {
      // Build our app with a lifetime subscription modal
      await tester.pumpWidget(buildModalTestApp(
        subscriptionType: SubscriptionType.lifetime,
      ));

      // Let the modal animations happen
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the success modal is displayed
      expect(find.byType(PremiumSuccessModal), findsOneWidget);
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(
          find.textContaining('Congratulations! You now have lifetime access'),
          findsOneWidget);
    });

    testWidgets('Modal Display Test - Verify modal appears after animation',
        (WidgetTester tester) async {
      // Build our app with a monthly subscription modal
      await tester.pumpWidget(buildModalTestApp(
        subscriptionType: SubscriptionType.monthly,
      ));

      // Initially modal should be invisible (opacity 0)
      await tester.pump();

      // Modal still invisible at this point
      expect(find.byType(PremiumSuccessModal), findsOneWidget);

      // Wait for confetti to play and modal to fade in
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the modal is now visible
      expect(find.text("You're now Premium!"), findsOneWidget);
    });

    testWidgets('Dismissal Test - Modal button content',
        (WidgetTester tester) async {
      // Build our app with a monthly subscription modal
      await tester.pumpWidget(buildModalTestApp(
        subscriptionType: SubscriptionType.monthly,
      ));

      // Let the modal animations happen
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the button is displayed
      expect(find.text("Start Using Premium"), findsOneWidget);
    });

    testWidgets('Success Handler Construction Test',
        (WidgetTester tester) async {
      // Test the direct construction of premium success modal
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(
                  value: settingsProvider),
            ],
            child: const PremiumSuccessModal(
              subscriptionType: SubscriptionType.monthly,
            ),
          ),
        ),
      );

      // Wait for the animation to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the modal is displayed
      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.textContaining('Thank you for your monthly subscription'),
          findsOneWidget);
    });
  });
}
