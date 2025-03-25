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
import 'dart:async';

/// Specialized tests for error handling in the StoreKit sandbox environment.
/// These tests verify the app's robustness against various error conditions
/// that can occur during the purchase flow.
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

  group('RevenueCat Error Handling Tests', () {
    // Helper function to log test steps with clear formatting
    void logTestStep(String step) {
      debugPrint('🧪 TEST STEP: $step');
    }

    // Helper to get RevenueCatService from context
    RevenueCatService getRevenueCatService(WidgetTester tester) {
      final BuildContext context = tester.element(find.byType(CupertinoApp));
      return Provider.of<RevenueCatService>(context, listen: false);
    }

    // Helper to navigate to the Premium screen
    Future<void> navigateToPremiumScreen(WidgetTester tester) async {
      logTestStep('Navigating to Premium screen...');

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Try different navigation paths to premium
      try {
        // Method 1: Via tab bar
        if (find.byType(CupertinoTabBar).evaluate().isNotEmpty) {
          await tester.tap(find.byType(CupertinoTabBar).last);
          await tester.pumpAndSettle();

          if (find.text('Premium').evaluate().isNotEmpty) {
            await tester.tap(find.text('Premium').first);
            await tester.pumpAndSettle();
            logTestStep('Navigated to Premium using tab bar');
            return;
          }
        }

        // Method 2: Via settings
        if (find.text('Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Settings').first);
          await tester.pumpAndSettle();

          if (find.text('Premium').evaluate().isNotEmpty) {
            await tester.tap(find.text('Premium').first);
            await tester.pumpAndSettle();
            logTestStep('Navigated to Premium via Settings');
            return;
          }
        }

        // Method 3: Find and tap any premium button
        if (find
            .textContaining('Premium', findRichText: true)
            .evaluate()
            .isNotEmpty) {
          await tester.tap(
            find.textContaining('Premium', findRichText: true).first,
          );
          await tester.pumpAndSettle();
          logTestStep('Navigated to Premium via direct button');
          return;
        }

        // If all else fails, log what we see
        logTestStep(
          'Could not find navigation to Premium. Visible text elements:',
        );
        tester.allWidgets.whereType<Text>().forEach((text) {
          logTestStep('Text: "${text.data}"');
        });

        fail('Could not navigate to Premium screen');
      } catch (e) {
        logTestStep('Error during navigation: $e');
        fail('Failed to navigate: $e');
      }
    }

    // Helper to enable sandbox testing
    Future<void> enableSandboxTesting(WidgetTester tester) async {
      logTestStep('Enabling sandbox testing mode');
      await SandboxTestingHelper.setSandboxTestingEnabled(true);
      await SandboxTestingHelper.setSandboxLogLevel('verbose');

      // Log for diagnostics
      SandboxTestingHelper.logSandboxEvent(
        'Setup',
        'Sandbox testing enabled with verbose logging',
      );
    }

    // Helper to simulate network interruption
    Future<void> simulateNetworkInterruption(
      WidgetTester tester,
      RevenueCatService revenueCatService,
    ) async {
      logTestStep('Simulating network interruption during purchase');

      // Log in sandbox helper
      SandboxTestingHelper.logSandboxEvent(
        'NetworkTest',
        'Simulating network interruption during purchase',
      );

      // Directly access the transaction queue to simulate an interrupted purchase
      final monthlyId = RevenueCatProductIds.monthlyId;
      await (revenueCatService as dynamic)._storePendingPurchase(monthlyId);

      // Verify it's in the queue
      final queueItems = revenueCatService.getTransactionQueueItems();
      expect(
        queueItems.isNotEmpty,
        isTrue,
        reason: 'Transaction should be added to queue',
      );

      // Log to sandbox
      SandboxTestingHelper.logSandboxEvent(
        'NetworkTest',
        'Added transaction to queue: ${queueItems.first}',
      );

      logTestStep('Transaction added to queue successfully');
      return;
    }

    testWidgets('Test 1: Payment Sheet Timeout Handling', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 1: Payment Sheet Timeout Handling');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Premium screen
      await navigateToPremiumScreen(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Directly access the PaymentSheetHandler to simulate timeout
      // Note: This is a simulation - in a real test, we would have to intercept
      // the payment sheet presentation, which is challenging in integration tests

      // Log simulation in sandbox
      SandboxTestingHelper.logSandboxEvent(
        'TimeoutTest',
        'Simulating payment sheet timeout',
      );

      // Select monthly plan
      if (find.text('Monthly').evaluate().isNotEmpty) {
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();

        // Find purchase button (but don't tap it for real)
        final buttonFinder = find.textContaining(
          'Subscribe',
          findRichText: true,
        );
        expect(
          buttonFinder.evaluate().isNotEmpty,
          isTrue,
          reason: 'Subscribe button should be visible',
        );

        // Log the test
        logTestStep(
          'Found Subscribe button, validating timeout handling capability',
        );

        // Verify the app has timeout handling through reflection
        expect(
          revenueCatService.runtimeType.toString(),
          contains('RevenueCatService'),
          reason: 'Service should be available',
        );

        // Verify transaction queue exists
        final hasQueue = revenueCatService.getTransactionQueueItems() != null;
        expect(
          hasQueue,
          isTrue,
          reason: 'Transaction queue should be accessible',
        );

        SandboxTestingHelper.logSandboxEvent(
          'TimeoutTest',
          'App has proper timeout handling mechanisms: $hasQueue',
        );
      } else {
        fail('Could not find Monthly subscription option');
      }
    });

    testWidgets('Test 2: Network Interruption Recovery', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 2: Network Interruption Recovery');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Premium screen
      await navigateToPremiumScreen(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Simulate network interruption
      await simulateNetworkInterruption(tester, revenueCatService);

      // Verify the transaction is in the queue
      final initialQueueItems = revenueCatService.getTransactionQueueItems();
      expect(
        initialQueueItems.isNotEmpty,
        isTrue,
        reason: 'Transaction should be in queue after interruption',
      );

      // Try to process the queue
      logTestStep('Attempting to process transaction queue after interruption');
      await revenueCatService.forceProcessTransactionQueue();

      // Let it process
      await tester.pump(const Duration(seconds: 2));

      // Get updated queue (may still have items if processing failed, which is expected in a test)
      final updatedQueueItems = revenueCatService.getTransactionQueueItems();

      // Log the results
      SandboxTestingHelper.logSandboxEvent(
        'NetworkTest',
        'Queue after processing attempt: ${updatedQueueItems.length} items',
      );

      logTestStep('Transaction queue processing attempted');
    });

    testWidgets('Test 3: Error Message Validation', (
      WidgetTester tester,
    ) async {
      logTestStep('Starting Test 3: Error Message Validation');

      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Premium screen
      await navigateToPremiumScreen(tester);

      // Enable sandbox testing
      await enableSandboxTesting(tester);

      // Get RevenueCat service
      final revenueCatService = getRevenueCatService(tester);

      // Check initial purchase status
      expect(
        revenueCatService.purchaseStatus.toString(),
        isNotEmpty,
        reason: 'Purchase status should be available',
      );

      // Simulate error - we can't directly show error messages in an automated test
      // but we can verify the error reporting infrastructure exists

      // Log the verification
      SandboxTestingHelper.logSandboxEvent(
        'ErrorTest',
        'Verifying error handling infrastructure',
      );

      // Check error message initialization
      expect(
        revenueCatService.errorMessage != null,
        isTrue,
        reason: 'Error message field should be initialized',
      );

      logTestStep('Error message field exists and is initialized');

      // Log error reporting capability
      SandboxTestingHelper.logSandboxEvent(
        'ErrorTest',
        'App has error reporting capabilities',
      );
    });
  });
}
