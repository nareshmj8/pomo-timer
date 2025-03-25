// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';

/// Result of the restore purchases operation
enum RestoreResult {
  success,
  cancelled,
  networkError,
  error,
}

/// Helper class for handling restore purchases
class RestorePurchasesHandler {
  /// Handle restore purchases with enhanced UI feedback
  static Future<RestoreResult> handleRestorePurchases(
    BuildContext context,
    RevenueCatService revenueCatService, {
    bool isRetry = false,
  }) async {
    LoggingService.logEvent(
        'RestorePurchasesHandler', 'Initiating restore purchases');

    // Check initial premium status
    final initialIsPremium = revenueCatService.isPremium;
    LoggingService.logEvent('RestorePurchasesHandler',
        'Initial premium status: ${initialIsPremium ? 'Premium' : 'Not Premium'}');

    // Show loading dialog
    final completer = Completer<RestoreResult>();

    // Reference to the dialog context for dismissal
    BuildContext? dialogContext;

    // Show loading dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return const CupertinoAlertDialog(
          title: Text('Restoring Purchases'),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CupertinoActivityIndicator(),
          ),
        );
      },
    );

    try {
      // Attempt to restore purchases
      await revenueCatService.restorePurchases();

      // Check if premium status changed
      final newIsPremium = revenueCatService.isPremium;
      LoggingService.logEvent('RestorePurchasesHandler',
          'New premium status: ${newIsPremium ? 'Premium' : 'Not Premium'}');

      // Dismiss loading dialog
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      // Show success dialog
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Restore Complete'),
          content: Text(
            newIsPremium
                ? 'Your premium features have been restored successfully!'
                : 'No previous purchases were found to restore.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                completer.complete(RestoreResult.success);
              },
            ),
          ],
        ),
      );
    } catch (e) {
      LoggingService.logEvent('RestorePurchasesHandler', 'ERROR: $e');

      // Always dismiss loading dialog, even on error
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      // Check if user cancelled
      if (e.toString().toLowerCase().contains('cancel') ||
          e.toString().toLowerCase().contains('user canceled')) {
        LoggingService.logEvent(
            'RestorePurchasesHandler', 'User cancelled restore');
        completer.complete(RestoreResult.cancelled);
        return completer.future;
      }

      // Check if network error
      final isNetworkError = e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('internet') ||
          e.toString().toLowerCase().contains('offline');

      if (isNetworkError) {
        // Show network error dialog with retry option
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Network Error'),
            content: const Text(
              'Unable to restore purchases due to a network connection issue. '
              'Please check your internet connection and try again.',
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                  completer.complete(RestoreResult.networkError);
                },
              ),
              CupertinoDialogAction(
                child: const Text('Retry'),
                onPressed: () {
                  Navigator.pop(context);
                  // Retry the restore process
                  handleRestorePurchases(context, revenueCatService,
                          isRetry: true)
                      .then((result) => completer.complete(result));
                },
              ),
            ],
          ),
        );
      } else {
        // Show general error dialog
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Restore Failed'),
            content: Text(
              'An error occurred while restoring purchases: ${e.toString()}',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  completer.complete(RestoreResult.error);
                },
              ),
            ],
          ),
        );
      }
    }

    return completer.future;
  }
}
