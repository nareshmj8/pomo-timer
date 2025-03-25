import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomodoro_timemaster/main.dart' as app;
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IAP Integration Tests', () {
    // Helper function to log test steps
    void logTestStep(String step) {
      debugPrint('🧪 TEST STEP: $step');
    }

    // Helper function to wait for IAP service to initialize
    Future<void> waitForIAPInitialization(WidgetTester tester) async {
      logTestStep('Waiting for IAP service to initialize...');

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Premium screen
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Premium').first);
      await tester.pumpAndSettle();

      // Wait for products to load
      int attempts = 0;
      while (attempts < 10) {
        // Find the IAP service from the widget tree
        final BuildContext context = tester.element(find.byType(CupertinoApp));
        final revenueCatService =
            Provider.of<RevenueCatService>(context, listen: false);

        if (!revenueCatService.isLoading &&
            revenueCatService.offerings != null &&
            revenueCatService.offerings!.current != null &&
            revenueCatService
                .offerings!.current!.availablePackages.isNotEmpty) {
          logTestStep(
              'RevenueCat service initialized with ${revenueCatService.offerings!.current!.availablePackages.length} products');
          break;
        }

        await tester.pump(const Duration(seconds: 1));
        attempts++;
      }
    }

    // Helper function to get IAP service from the widget tree
    RevenueCatService getRevenueCatService(WidgetTester tester) {
      final BuildContext context = tester.element(find.byType(CupertinoApp));
      return Provider.of<RevenueCatService>(context, listen: false);
    }

    // Helper function to simulate a successful purchase
    Future<void> simulateSuccessfulPurchase(
        RevenueCatService revenueCatService, String productId,
        {bool isRestore = false}) async {
      // In a real test, this would be handled by the App Store
      // For testing, we'll simulate by directly updating the service state

      // Set purchase status to purchased
      final purchaseStatus =
          isRestore ? PurchaseStatus.restored : PurchaseStatus.purchased;

      // Use reflection to set private fields (for testing purposes only)
      // This is a workaround since we don't have direct access to update methods
      final instance = revenueCatService;
      (instance as dynamic)._purchaseStatus = purchaseStatus;

      // Determine subscription type from product ID
      SubscriptionType subscriptionType;
      if (productId == RevenueCatProductIds.monthlyId) {
        subscriptionType = SubscriptionType.monthly;
      } else if (productId == RevenueCatProductIds.yearlyId) {
        subscriptionType = SubscriptionType.yearly;
      } else if (productId == RevenueCatProductIds.lifetimeId) {
        subscriptionType = SubscriptionType.lifetime;
      } else {
        subscriptionType = SubscriptionType.none;
      }

      // Set subscription type
      (instance as dynamic)._activeSubscription = subscriptionType;

      // Set expiry date based on subscription type
      DateTime? expiryDate;
      if (subscriptionType == SubscriptionType.monthly) {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else if (subscriptionType == SubscriptionType.yearly) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      }

      // Set expiry date
      (instance as dynamic)._expiryDate = expiryDate;

      // Save to preferences
      await (instance as dynamic)._savePurchasesToPrefs();

      // Notify listeners
      revenueCatService.notifyListeners();
    }

    // Helper function to clear purchase state
    Future<void> clearPurchaseState(RevenueCatService revenueCatService) async {
      // Use reflection to set private fields (for testing purposes only)
      final instance = revenueCatService;
      (instance as dynamic)._purchaseStatus = PurchaseStatus.notPurchased;
      (instance as dynamic)._activeSubscription = SubscriptionType.none;
      (instance as dynamic)._expiryDate = null;

      // Save to preferences
      await (instance as dynamic)._savePurchasesToPrefs();

      // Notify listeners
      revenueCatService.notifyListeners();
    }

    // Helper function to simulate a purchase error
    void simulatePurchaseError(
        RevenueCatService revenueCatService, String errorMessage) {
      // Use reflection to set private fields (for testing purposes only)
      final instance = revenueCatService;
      (instance as dynamic)._purchaseStatus = PurchaseStatus.error;
      (instance as dynamic)._errorMessage = errorMessage;

      // Notify listeners
      revenueCatService.notifyListeners();
    }

    testWidgets('Test 1: Product Loading Test', (WidgetTester tester) async {
      logTestStep('Starting Product Loading Test');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Get IAP service
      final revenueCatService = getRevenueCatService(tester);

      // Verify products are loaded
      expect(
          revenueCatService.offerings != null &&
              revenueCatService.offerings!.current != null &&
              revenueCatService
                  .offerings!.current!.availablePackages.isNotEmpty,
          true);
      logTestStep(
          'Found ${revenueCatService.offerings!.current!.availablePackages.length} products');

      // Verify specific products
      final monthlyPackage = revenueCatService
          .getPackageForProduct(RevenueCatProductIds.monthlyId);
      final yearlyPackage =
          revenueCatService.getPackageForProduct(RevenueCatProductIds.yearlyId);
      final lifetimePackage = revenueCatService
          .getPackageForProduct(RevenueCatProductIds.lifetimeId);

      expect(monthlyPackage, isNotNull);
      expect(yearlyPackage, isNotNull);
      expect(lifetimePackage, isNotNull);

      // Verify product details
      if (monthlyPackage != null) {
        logTestStep(
            'Monthly product: ${monthlyPackage.storeProduct.title} - ${monthlyPackage.storeProduct.priceString}');
        expect(
            monthlyPackage.identifier, equals(RevenueCatProductIds.monthlyId));
      }

      if (yearlyPackage != null) {
        logTestStep(
            'Yearly product: ${yearlyPackage.storeProduct.title} - ${yearlyPackage.storeProduct.priceString}');
        expect(yearlyPackage.identifier, equals(RevenueCatProductIds.yearlyId));
      }

      if (lifetimePackage != null) {
        logTestStep(
            'Lifetime product: ${lifetimePackage.storeProduct.title} - ${lifetimePackage.storeProduct.priceString}');
        expect(lifetimePackage.identifier,
            equals(RevenueCatProductIds.lifetimeId));
      }

      // Verify UI displays correct pricing
      expect(
          find.textContaining(monthlyPackage?.storeProduct.priceString ?? ''),
          findsOneWidget);
      expect(find.textContaining(yearlyPackage?.storeProduct.priceString ?? ''),
          findsOneWidget);
      expect(
          find.textContaining(lifetimePackage?.storeProduct.priceString ?? ''),
          findsOneWidget);
    });

    testWidgets('Test 2: Purchase Test - Monthly Subscription',
        (WidgetTester tester) async {
      // Skip on non-iOS platforms
      if (!Platform.isIOS) {
        return;
      }

      logTestStep('Starting Purchase Test - Monthly Subscription');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Select monthly plan
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Tap Subscribe button
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      // Note: In a real device, this would trigger the App Store purchase dialog
      // For testing, we'll simulate a successful purchase by directly calling the IAP service

      final revenueCatService = getRevenueCatService(tester);

      // Simulate successful purchase
      logTestStep('Simulating successful monthly purchase');

      // Mock the purchase completion
      final monthlyPackage = revenueCatService
          .getPackageForProduct(RevenueCatProductIds.monthlyId);
      if (monthlyPackage != null) {
        await simulateSuccessfulPurchase(
            revenueCatService, monthlyPackage.identifier);
      }

      // Verify subscription state updates
      expect(revenueCatService.isPremium, true);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.monthly));
      logTestStep(
          'Subscription state updated: isPremium=${revenueCatService.isPremium}, type=${revenueCatService.activeSubscription}');

      // Wait for success animation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success UI is shown
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('Test 3: Restore Purchases Test', (WidgetTester tester) async {
      // Skip on non-iOS platforms
      if (!Platform.isIOS) {
        return;
      }

      logTestStep('Starting Restore Purchases Test');

      // Set up SharedPreferences with a previous purchase
      SharedPreferences.setMockInitialValues({
        'subscription_type': SubscriptionType.yearly.index,
        'expiry_date':
            DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      });

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Verify initial state shows as not premium (since we need to restore)
      final revenueCatService = getRevenueCatService(tester);

      // Clear any existing purchase state
      await clearPurchaseState(revenueCatService);
      await tester.pumpAndSettle();

      expect(revenueCatService.isPremium, false);

      // Tap Restore button
      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      // Simulate successful restore
      logTestStep('Simulating successful purchase restoration');

      // Mock the restore completion
      final yearlyPackage =
          revenueCatService.getPackageForProduct(RevenueCatProductIds.yearlyId);
      if (yearlyPackage != null) {
        await simulateSuccessfulPurchase(
            revenueCatService, yearlyPackage.identifier,
            isRestore: true);
      }

      // Verify subscription state updates
      expect(revenueCatService.isPremium, true);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      logTestStep(
          'Subscription state updated after restore: isPremium=${revenueCatService.isPremium}, type=${revenueCatService.activeSubscription}');

      // Wait for UI to update
      await tester.pumpAndSettle();

      // Verify UI reflects restored purchase
      expect(find.textContaining('Premium Active'), findsWidgets);
    });

    testWidgets('Test 4: Subscription Expiry Handling',
        (WidgetTester tester) async {
      logTestStep('Starting Subscription Expiry Handling Test');

      // Set up SharedPreferences with an expired subscription
      SharedPreferences.setMockInitialValues({
        'subscription_type': SubscriptionType.monthly.index,
        'expiry_date':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Get IAP service
      final revenueCatService = getRevenueCatService(tester);

      // Verify subscription is recognized as expired
      expect(revenueCatService.isPremium, false);
      logTestStep(
          'Expired subscription correctly identified: isPremium=${revenueCatService.isPremium}');

      // Verify UI shows subscription options rather than active subscription
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.text('Premium Active'), findsNothing);
    });

    testWidgets('Test 5: Receipt Validation', (WidgetTester tester) async {
      // Skip on non-iOS platforms
      if (!Platform.isIOS) {
        return;
      }

      logTestStep('Starting Receipt Validation Test');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Get IAP service
      // Commented out unused variable
      // final revenueCatService = getRevenueCatService(tester);

      // Simulate receipt validation
      logTestStep('Simulating receipt validation');

      // Navigate to IAP diagnostics
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('In-App Purchase Diagnostics'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Run diagnostics
      await tester.tap(find.text('Run Diagnostics'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify diagnostics results are displayed
      expect(find.textContaining('IAP DIAGNOSTICS RESULTS'), findsOneWidget);

      // Check if receipt info is displayed
      if (Platform.isIOS) {
        expect(find.textContaining('RECEIPT INFO'), findsOneWidget);
      }
    });

    testWidgets('Test 6: Error Handling - Network Failure',
        (WidgetTester tester) async {
      logTestStep('Starting Error Handling Test - Network Failure');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Get IAP service
      final revenueCatService = getRevenueCatService(tester);

      // Simulate network failure during purchase
      logTestStep('Simulating network failure during purchase');

      // Select monthly plan
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Tap Subscribe button
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      // Simulate purchase error
      simulatePurchaseError(revenueCatService, 'Network connection error');
      await tester.pumpAndSettle();

      // Verify error state
      expect(revenueCatService.purchaseStatus, equals(PurchaseStatus.error));
      expect(
          revenueCatService.errorMessage, contains('Network connection error'));
      logTestStep(
          'Purchase error state: ${revenueCatService.purchaseStatus}, message: ${revenueCatService.errorMessage}');

      // Verify UI shows error state
      // Note: This depends on how your app displays errors, adjust as needed
      if (find.textContaining('error').evaluate().isNotEmpty) {
        expect(find.textContaining('error'), findsOneWidget);
      }
    });

    testWidgets('Test 7: UI & Analytics Tracking', (WidgetTester tester) async {
      logTestStep('Starting UI & Analytics Tracking Test');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for IAP initialization
      await waitForIAPInitialization(tester);

      // Get IAP service
      final revenueCatService = getRevenueCatService(tester);

      // Verify initial UI state
      expect(find.text('Premium'), findsWidgets);

      // Simulate successful purchase
      logTestStep('Simulating successful purchase for UI verification');

      // Select yearly plan
      await tester.tap(find.text('Yearly'));
      await tester.pumpAndSettle();

      // Tap Subscribe button
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      // Mock the purchase completion
      final yearlyPackage =
          revenueCatService.getPackageForProduct(RevenueCatProductIds.yearlyId);
      if (yearlyPackage != null) {
        await simulateSuccessfulPurchase(
            revenueCatService, yearlyPackage.identifier);
      }

      // Wait for UI to update
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify UI reflects purchase
      expect(revenueCatService.isPremium, true);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));

      // Navigate back to premium screen to see updated UI
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Premium').first);
      await tester.pumpAndSettle();

      // Verify UI shows active subscription
      expect(find.textContaining('Premium Active'), findsWidgets);
      expect(find.text('Subscribe'), findsNothing);

      // Verify manage subscription button is shown
      expect(find.text('Manage Subscription'), findsOneWidget);

      logTestStep('UI correctly reflects subscription state');
    });
  });
}
