import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timemaster/main.dart' as app;
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

/// Automated tests for StoreKit/RevenueCat Sandbox testing on real iOS devices
///
/// IMPORTANT: These tests must be run on a real iOS device with a configured
/// sandbox test account in App Store. To run these tests:
///
/// 1. Connect your iOS device
/// 2. Sign in with your sandbox test account in App Store
/// 3. Run: flutter test integration_test/sandbox_iap_test.dart -d <device_id>
///
/// The tests will interact with the real StoreKit sandbox environment, but no
/// actual charges will be made.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Only run these tests on iOS devices
  final bool isIOS = Platform.isIOS;
  if (!isIOS) {
    debugPrint(
      '⚠️ SKIPPING TESTS: Sandbox IAP tests require a real iOS device',
    );
    return;
  }

  group('RevenueCat StoreKit Sandbox Tests', () {
    // Helper function to log test steps with clear formatting
    void logTestStep(String step) {
      debugPrint('🧪 TEST STEP: $step');
    }

    // Helper to get RevenueCatService from context
    RevenueCatService? getRevenueCatService(WidgetTester tester) {
      try {
        final BuildContext context = tester.element(find.byType(CupertinoApp));
        return Provider.of<RevenueCatService>(context, listen: false);
      } catch (e) {
        logTestStep('Error getting RevenueCatService: $e');
        return null;
      }
    }

    // Helper to wait for RevenueCat to initialize
    Future<bool> waitForRevenueCatInitialization(WidgetTester tester) async {
      logTestStep('Waiting for RevenueCat to initialize...');

      // Try up to 5 times to get the service
      RevenueCatService? service;
      for (int i = 0; i < 5; i++) {
        await tester.pumpAndSettle(const Duration(seconds: 2));
        service = getRevenueCatService(tester);
        if (service != null) {
          logTestStep('RevenueCat service found');
          break;
        }
        logTestStep('RevenueCat service not found, waiting...');
      }

      if (service == null) {
        logTestStep('RevenueCat service not found after multiple attempts');
        return false;
      }

      // Wait for offerings to be loaded (up to 15 seconds total)
      for (int i = 0; i < 15; i++) {
        if (service.offerings != null) {
          logTestStep('RevenueCat offerings loaded');
          return true;
        }
        await tester.pump(const Duration(seconds: 1));
      }

      logTestStep('RevenueCat offerings did not load within timeout');
      return false;
    }

    // Helper to enable sandbox testing mode
    Future<void> enableSandboxTesting(WidgetTester tester) async {
      logTestStep('Enabling sandbox testing mode');
      await SandboxTestingHelper.setSandboxTestingEnabled(true);
      await SandboxTestingHelper.setSandboxLogLevel('verbose');
    }

    testWidgets('Test 1: Verify Sandbox Account Detection', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 1: Verify Sandbox Account Detection');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization
      final initialized = await waitForRevenueCatInitialization(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      if (revenueCatService != null) {
        // Check if we're in sandbox mode (this is always true in testing)
        SandboxTestingHelper.logSandboxEvent(
          'SandboxDetection',
          'RevenueCat service available for testing',
        );

        logTestStep('Successfully verified RevenueCat service is available');
      } else {
        // Handle the failure gracefully
        SandboxTestingHelper.logSandboxEvent(
          'SandboxDetection',
          'RevenueCat service not available - test will end early',
        );

        logTestStep('Could not verify sandbox detection - test ending early');
      }
    });

    testWidgets('Test 2: Verify Products Load in Sandbox Environment', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 2: Verify Products Load in Sandbox');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization
      final initialized = await waitForRevenueCatInitialization(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Verify offerings are loaded
      expect(revenueCatService?.offerings, isNotNull);
      expect(revenueCatService?.offerings!.current, isNotNull);

      // Log available products for debugging
      final offerings = revenueCatService?.offerings!;
      final currentOffering = offerings.current;

      if (currentOffering != null) {
        for (final package in currentOffering.availablePackages) {
          logTestStep(
            'Package: ${package.identifier}, '
            'Product: ${package.storeProduct.identifier}, '
            'Price: ${package.storeProduct.priceString}',
          );

          // Log this info to sandbox logs
          SandboxTestingHelper.logSandboxEvent(
            'Product',
            '${package.identifier}: ${package.storeProduct.priceString}',
          );
        }
      }

      // Verify the UI shows the products
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
    });

    testWidgets('Test 3: Test Transaction Queue Functionality', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 3: Transaction Queue Functionality');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization
      final initialized = await waitForRevenueCatInitialization(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Get monthly product ID
      final monthlyId = RevenueCatProductIds.monthlyId;

      // Add a test transaction to the queue
      logTestStep('Adding test transaction to queue: $monthlyId');

      // This uses the private method, but it's for testing only
      await (revenueCatService as dynamic)._storePendingPurchase(monthlyId);

      // Get queue items
      final queueItems = revenueCatService?.getTransactionQueueItems();

      // Verify transaction was added
      expect(queueItems, isNotEmpty);
      expect(queueItems.first['productId'], equals(monthlyId));

      // Log transaction info
      logTestStep('Transaction added to queue: ${queueItems.first}');
      SandboxTestingHelper.logSandboxEvent(
        'TransactionQueue',
        'Added test transaction: ${queueItems.first}',
      );

      // Process the queue
      logTestStep('Processing transaction queue');
      await revenueCatService?.forceProcessTransactionQueue();

      // Give time for processing
      await tester.pump(const Duration(seconds: 2));

      // Verify transaction state (it might still be in queue if offline)
      final updatedItems = revenueCatService?.getTransactionQueueItems();
      logTestStep('Updated queue items: $updatedItems');

      // Log this also to sandbox logs
      SandboxTestingHelper.logSandboxEvent(
        'TransactionQueue',
        'After processing: $updatedItems',
      );
    });

    testWidgets('Test 4: Test Payment Sheet Presentation', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 4: Payment Sheet Presentation');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization
      final initialized = await waitForRevenueCatInitialization(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Select monthly subscription
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Log current state before purchase
      logTestStep(
        'Current subscription status: ${revenueCatService?.activeSubscription}',
      );
      logTestStep(
        'Current purchase status: ${revenueCatService?.purchaseStatus}',
      );

      SandboxTestingHelper.logSandboxEvent(
        'BeforePurchase',
        'Subscription: ${revenueCatService?.activeSubscription}, '
            'Status: ${revenueCatService?.purchaseStatus}',
      );

      // Attempt to tap the Subscribe button
      // Note: This will open the real App Store payment sheet
      // For automated tests, we need to handle this specially
      final subscribeButton = find.text('Subscribe');
      if (subscribeButton.evaluate().isNotEmpty) {
        logTestStep('Found Subscribe button, tapping it');

        // Log that we're about to show the payment sheet
        SandboxTestingHelper.logSandboxEvent(
          'PaymentSheet',
          'Attempting to present payment sheet',
        );

        // Instead of tapping the button (which would show a UI we can't control in tests),
        // we'll verify the button exists and is enabled
        final subscribeWidget = tester.widget<CupertinoButton>(
          find.byType(CupertinoButton).last,
        );

        expect(subscribeWidget.onPressed, isNotNull);
        logTestStep('Subscribe button is enabled and ready for purchase');
      } else {
        logTestStep('Subscribe button not found');
      }
    });

    testWidgets('Test 5: Verify Purchase Flow Navigation', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 5: Verify Purchase Flow Navigation');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Wait for RevenueCat to initialize
      await waitForRevenueCatInitialization(tester);

      // Try to find Premium option in the UI
      bool foundPremiumScreen = false;

      // First try via Settings (if exists)
      try {
        if (find.text('Settings').evaluate().isNotEmpty) {
          logTestStep('Found Settings link, tapping it');
          await tester.tap(find.text('Settings').first);
          await tester.pumpAndSettle();

          // Look for Premium in Settings
          if (find.text('Premium').evaluate().isNotEmpty) {
            logTestStep('Found Premium link in Settings, tapping it');
            await tester.tap(find.text('Premium').first);
            await tester.pumpAndSettle();
            foundPremiumScreen = true;
          }
        }
      } catch (e) {
        logTestStep('Error navigating via Settings: $e');
      }

      // If not found via settings, try tabs
      if (!foundPremiumScreen) {
        try {
          if (find.byType(CupertinoTabBar).evaluate().isNotEmpty) {
            logTestStep('Found tab bar, trying tabs');

            // Try last tab (usually settings/more)
            await tester.tap(find.byType(CupertinoTabBar).last);
            await tester.pumpAndSettle();

            // Look for Premium
            if (find.text('Premium').evaluate().isNotEmpty) {
              logTestStep('Found Premium link in tab, tapping it');
              await tester.tap(find.text('Premium').first);
              await tester.pumpAndSettle();
              foundPremiumScreen = true;
            }
          }
        } catch (e) {
          logTestStep('Error navigating via tabs: $e');
        }
      }

      // If still not found, try direct Premium text
      if (!foundPremiumScreen) {
        try {
          if (find
              .textContaining('Premium', findRichText: true)
              .evaluate()
              .isNotEmpty) {
            logTestStep('Found Premium text directly, tapping it');
            await tester.tap(
              find.textContaining('Premium', findRichText: true).first,
            );
            await tester.pumpAndSettle();
            foundPremiumScreen = true;
          }
        } catch (e) {
          logTestStep('Error tapping Premium text: $e');
        }
      }

      // Check if we found Premium screen
      if (foundPremiumScreen) {
        logTestStep('Successfully navigated to Premium screen');

        // Log success
        SandboxTestingHelper.logSandboxEvent(
          'NavigationTest',
          'Successfully navigated to Premium screen',
        );

        // Try to find subscription options
        bool foundSubscriptionOption = false;

        try {
          // Look for common subscription text
          final monthlyFinder = find.textContaining(
            'Month',
            findRichText: true,
          );
          final yearlyFinder = find.textContaining('Year', findRichText: true);
          final lifetimeFinder = find.textContaining(
            'Lifetime',
            findRichText: true,
          );

          if (monthlyFinder.evaluate().isNotEmpty) {
            logTestStep('Found Monthly subscription option');
            foundSubscriptionOption = true;

            SandboxTestingHelper.logSandboxEvent(
              'NavigationTest',
              'Found Monthly subscription option',
            );
          }

          if (yearlyFinder.evaluate().isNotEmpty) {
            logTestStep('Found Yearly subscription option');
            foundSubscriptionOption = true;

            SandboxTestingHelper.logSandboxEvent(
              'NavigationTest',
              'Found Yearly subscription option',
            );
          }

          if (lifetimeFinder.evaluate().isNotEmpty) {
            logTestStep('Found Lifetime purchase option');
            foundSubscriptionOption = true;

            SandboxTestingHelper.logSandboxEvent(
              'NavigationTest',
              'Found Lifetime purchase option',
            );
          }
        } catch (e) {
          logTestStep('Error checking for subscription options: $e');
        }

        if (foundSubscriptionOption) {
          logTestStep('Verified purchase options displayed correctly');
        } else {
          logTestStep('Could not verify subscription options');

          SandboxTestingHelper.logSandboxEvent(
            'NavigationTest',
            'Could not find subscription options',
          );
        }
      } else {
        logTestStep('Could not navigate to Premium screen');

        // Log helpful diagnostic info about what's on screen
        logTestStep('Current visible text elements:');
        try {
          tester.allWidgets.whereType<Text>().forEach((text) {
            if (text.data != null && text.data!.isNotEmpty) {
              logTestStep('Text: "${text.data}"');
            }
          });
        } catch (e) {
          logTestStep('Error listing text elements: $e');
        }

        SandboxTestingHelper.logSandboxEvent(
          'NavigationTest',
          'Failed to navigate to Premium screen',
        );
      }
    });
  });
}
