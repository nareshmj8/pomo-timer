import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

/// A utility class to simulate network failures for testing RevenueCat integration
class NetworkFailureSimulator {
  /// Simulate a network failure during offerings retrieval
  static Future<void> simulateOfferingsNetworkFailure(
    BuildContext context,
    RevenueCatService revenueCatService,
    void Function(String) logCallback,
  ) async {
    logCallback('Simulating network failure during offerings retrieval...');

    // Show instructions dialog
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Network Failure Test'),
        content: const Text(
          'This test will simulate a network failure during offerings retrieval.\n\n'
          'Please enable Airplane Mode when prompted, then disable it when prompted again.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Start Test'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Prompt to enable Airplane Mode
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Enable Airplane Mode'),
        content: const Text(
          'Please enable Airplane Mode now, then press Continue.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Try to load offerings with network disabled
    logCallback('Attempting to load offerings with network disabled...');
    try {
      await revenueCatService.forceReloadOfferings();
      logCallback('WARNING: Offerings loaded despite network being disabled');
    } catch (e) {
      logCallback('Expected error occurred: $e');
    }

    // Prompt to disable Airplane Mode
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Disable Airplane Mode'),
        content: const Text(
          'Please disable Airplane Mode now, then press Continue.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Wait for network to reconnect
    await Future.delayed(const Duration(seconds: 2));

    // Try to load offerings again with network enabled
    logCallback('Attempting to load offerings with network enabled...');
    try {
      await revenueCatService.forceReloadOfferings();
      if (revenueCatService.offerings != null) {
        logCallback('SUCCESS: Offerings loaded after network restored');
      } else {
        logCallback('ERROR: Offerings still null after network restored');
      }
    } catch (e) {
      logCallback('ERROR: Failed to load offerings after network restored: $e');
    }
  }

  /// Simulate a network failure during purchase
  static Future<void> simulatePurchaseNetworkFailure(
    BuildContext context,
    RevenueCatService revenueCatService,
    void Function(String) logCallback,
  ) async {
    logCallback('Simulating network failure during purchase...');

    // Show instructions dialog
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Purchase Network Failure Test'),
        content: const Text(
          'This test will simulate a network failure during purchase.\n\n'
          'Please follow these steps:\n'
          '1. Start the purchase process\n'
          '2. When the App Store dialog appears, enable Airplane Mode\n'
          '3. Attempt to complete the purchase\n'
          '4. Observe the error handling\n'
          '5. Disable Airplane Mode when prompted',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Start Test'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Navigate to purchase screen or show purchase dialog
    logCallback('Please initiate a purchase now...');

    // This would typically be handled by the UI flow, not directly here
    // For testing purposes, we're just providing instructions
  }

  /// Simulate a network failure during restore purchases
  static Future<void> simulateRestoreNetworkFailure(
    BuildContext context,
    RevenueCatService revenueCatService,
    void Function(String) logCallback,
  ) async {
    logCallback('Simulating network failure during restore purchases...');

    // Show instructions dialog
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Restore Network Failure Test'),
        content: const Text(
          'This test will simulate a network failure during restore purchases.\n\n'
          'Please enable Airplane Mode when prompted, then disable it when prompted again.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Start Test'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Prompt to enable Airplane Mode
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Enable Airplane Mode'),
        content: const Text(
          'Please enable Airplane Mode now, then press Continue.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Try to restore purchases with network disabled
    logCallback('Attempting to restore purchases with network disabled...');
    try {
      await revenueCatService.restorePurchases();
      logCallback('WARNING: Restore completed despite network being disabled');
    } catch (e) {
      logCallback('Expected error occurred: $e');
    }

    // Prompt to disable Airplane Mode
    await showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Disable Airplane Mode'),
        content: const Text(
          'Please disable Airplane Mode now, then press Continue.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Continue'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    // Wait for network to reconnect
    await Future.delayed(const Duration(seconds: 2));

    // Try to restore purchases again with network enabled
    logCallback('Attempting to restore purchases with network enabled...');
    try {
      await revenueCatService.restorePurchases();
      logCallback('SUCCESS: Restore completed after network restored');
    } catch (e) {
      logCallback('ERROR: Failed to restore after network restored: $e');
    }
  }
}
