// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timemaster/screens/premium/models/pricing_plan.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/screens/premium/components/restore_purchases_handler.dart';

/// Controller for the Premium Screen
class PremiumController {
  // State
  PricingPlan? selectedPlan =
      PricingPlan.yearly; // Pre-select yearly plan as "Best Value"
  bool isRestoring = false;

  // Animation controller for plan selection
  final AnimationController animationController;

  // Callback to notify state changes
  final VoidCallback onStateChanged;

  PremiumController({
    required this.animationController,
    required this.onStateChanged,
  });

  /// Initialize RevenueCat and check premium status
  Future<void> initializeRevenueCat(RevenueCatService revenueCatService) async {
    debugPrint('PremiumController: Initializing RevenueCat with new API key');

    try {
      // Initialize RevenueCat with retry mechanism
      bool isInitialized = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        debugPrint(
            'PremiumController: RevenueCat initialization attempt $attempt');
        try {
          // Initialize RevenueCat
          await revenueCatService.initialize();

          // Force reload offerings to ensure we have the latest data
          if (revenueCatService.offerings == null) {
            debugPrint('PremiumController: Offerings null, forcing reload');
            await revenueCatService.forceReloadOfferings();
          }

          isInitialized = true;
          break;
        } catch (e) {
          debugPrint(
              'PremiumController: Error in initialization attempt $attempt: $e');
          // Check for common API key issues
          if (e.toString().contains('invalid API key') ||
              e.toString().contains('configuration failed') ||
              e.toString().contains('authentication')) {
            debugPrint(
                'PremiumController: Possible API key issue detected: $e');
          }

          if (attempt < 3) {
            // Wait before retry with exponential backoff
            await Future.delayed(Duration(seconds: attempt * 2));
          }
        }
      }

      if (!isInitialized) {
        debugPrint(
            'PremiumController: Failed to initialize RevenueCat after 3 attempts');
      } else {
        debugPrint('PremiumController: RevenueCat successfully initialized');
        debugPrint(
            'PremiumController: Offerings available: ${revenueCatService.offerings != null}');

        if (revenueCatService.offerings != null) {
          debugPrint(
              'PremiumController: Current offering available: ${revenueCatService.offerings!.current != null}');
          if (revenueCatService.offerings!.current != null) {
            debugPrint(
                'PremiumController: Available packages: ${revenueCatService.offerings!.current!.availablePackages.length}');
            for (var package
                in revenueCatService.offerings!.current!.availablePackages) {
              debugPrint(
                  'PremiumController: Package ${package.identifier} - ${package.storeProduct.priceString}');
            }
          }
        }
      }

      // Verify premium entitlements
      final hasPremium = await revenueCatService.verifyPremiumEntitlements();
      debugPrint('PremiumController: Initial premium status: $hasPremium');
    } catch (e) {
      debugPrint(
          'PremiumController: Unexpected error during initialization: $e');
    } finally {
      // Notify state changes regardless of success/failure
      onStateChanged();
    }
  }

  /// Select a pricing plan
  void selectPlan(PricingPlan plan) {
    // If the same plan is selected, don't deselect it
    // This ensures a plan is always selected
    if (selectedPlan != plan) {
      selectedPlan = plan;
      animationController
        ..reset()
        ..forward();
      onStateChanged();
    }
  }

  /// Handle subscription purchase
  Future<void> handleSubscribe(RevenueCatService revenueCatService) async {
    debugPrint('PremiumController: Subscribe button pressed');

    // Verify initial status
    final initialStatus = await revenueCatService.verifyPremiumEntitlements();
    debugPrint(
        'PremiumController: Initial premium status before subscribe: $initialStatus');

    // If user is already premium, show a message and return
    if (initialStatus) {
      final context = _getGlobalContext();
      if (context != null) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Already Subscribed'),
            content:
                const Text('You already have an active premium subscription.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Check if offerings are available
    if (revenueCatService.offerings == null) {
      debugPrint(
          'PremiumController: Offerings not available, showing loading dialog');

      // Show loading dialog
      final context = _getGlobalContext();
      if (context != null) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const CupertinoAlertDialog(
            title: Text('Loading Subscription Options'),
            content: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CupertinoActivityIndicator(),
            ),
          ),
        );
      }

      // Try to load offerings with retry logic
      bool offeringsLoaded = false;
      for (int i = 0; i < 3; i++) {
        // Try up to 3 times
        try {
          await revenueCatService.initialize();
          if (revenueCatService.offerings != null) {
            offeringsLoaded = true;
            break;
          }
          // Wait before retrying
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          debugPrint('PremiumController: Error loading offerings: $e');
          // Continue to next retry
        }
      }

      // Dismiss loading dialog
      final dismissContext = _getGlobalContext();
      if (dismissContext != null && Navigator.canPop(dismissContext)) {
        Navigator.pop(dismissContext);
      }

      // Check if offerings are now available
      if (!offeringsLoaded || revenueCatService.offerings == null) {
        final context = _getGlobalContext();
        if (context != null) {
          showCupertinoDialog(
            context: context,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Unable to load subscription options. Please check your internet connection and try again.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    // Get the current offering
    final offering = revenueCatService.offerings!.current;
    if (offering == null) {
      debugPrint('PremiumController: No current offering available');
      final context = _getGlobalContext();
      if (context != null) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Subscription options are not available at this time. Please try again later.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Find the package that matches the selected plan
    String productId;
    switch (selectedPlan) {
      case PricingPlan.monthly:
        productId = RevenueCatProductIds.monthlyId;
        break;
      case PricingPlan.yearly:
        productId = RevenueCatProductIds.yearlyId;
        break;
      case PricingPlan.lifetime:
        productId = RevenueCatProductIds.lifetimeId;
        break;
      default:
        productId = RevenueCatProductIds.yearlyId; // Default to yearly
    }

    // Find the package in the offering
    final package = offering.availablePackages.firstWhere(
      (p) => p.storeProduct.identifier == productId,
      orElse: () => offering.availablePackages.first,
    );

    debugPrint('PremiumController: Selected package: ${package.identifier}');

    // Show loading dialog
    final context = _getGlobalContext();
    if (context != null) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const CupertinoAlertDialog(
          title: Text('Processing'),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }

    try {
      // Purchase the package
      final purchaseResult = await revenueCatService.purchasePackage(package);

      // Dismiss loading dialog
      final dismissContext = _getGlobalContext();
      if (dismissContext != null && Navigator.canPop(dismissContext)) {
        Navigator.pop(dismissContext);
      }

      if (purchaseResult != null) {
        debugPrint('PremiumController: Purchase successful');

        // Verify premium status after purchase
        final updatedStatus =
            await revenueCatService.verifyPremiumEntitlements();
        debugPrint(
            'PremiumController: User premium status after purchase: $updatedStatus');

        // Show success animation and dialog
        _showPurchaseSuccessAnimation(revenueCatService);
      } else {
        debugPrint('PremiumController: Purchase failed or was cancelled');
        // User likely cancelled, no need to show error
      }
    } catch (e) {
      // Dismiss loading dialog
      final dismissContext = _getGlobalContext();
      if (dismissContext != null && Navigator.canPop(dismissContext)) {
        Navigator.pop(dismissContext);
      }

      debugPrint('PremiumController: Error during purchase: $e');

      // Check if it's a network error
      final isNetworkError = e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('timeout');

      final context2 = _getGlobalContext();
      if (context2 != null) {
        // Show error dialog
        showCupertinoDialog(
          context: context2,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: Text(isNetworkError ? 'Network Error' : 'Purchase Failed'),
            content: Text(isNetworkError
                ? 'Please check your internet connection and try again.'
                : _getSanitizedErrorMessage(e)),
            actions: [
              if (isNetworkError)
                CupertinoDialogAction(
                  child: const Text('Retry'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    handleSubscribe(revenueCatService);
                  },
                ),
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        );
      }
    }

    onStateChanged(); // Refresh UI to reflect any changes
  }

  /// Show purchase success animation and dialog
  void _showPurchaseSuccessAnimation(RevenueCatService revenueCatService) {
    final context = _getGlobalContext();
    if (context == null) return;

    // Show success dialog with animation
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Purchase Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: CupertinoColors.activeGreen,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text('Thank you for your purchase!'),
            const SizedBox(height: 8),
            const Text('You now have access to all premium features.'),
            const SizedBox(height: 16),
            Text(
              'Subscription Type: ${revenueCatService.activeSubscription.toString().split('.').last}',
              style: const TextStyle(fontSize: 14),
            ),
            if (revenueCatService.expiryDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: ${_formatDate(revenueCatService.expiryDate!)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  /// Format a date
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Restore purchases
  Future<void> restorePurchases(
      BuildContext context, RevenueCatService revenueCatService) async {
    // Update restoring state
    isRestoring = true;
    onStateChanged();

    // Use the RestorePurchasesHandler to handle the restore process
    final result = await RestorePurchasesHandler.handleRestorePurchases(
      context,
      revenueCatService,
    );

    // Update restoring state when complete
    isRestoring = false;
    onStateChanged();

    // Handle the result if needed
    debugPrint('PremiumController: Restore result: $result');
  }

  /// Get the global context from the navigator key
  BuildContext? _getGlobalContext() {
    return RevenueCatService.navigatorKey.currentContext;
  }

  /// Returns a user-friendly error message for purchase failures
  String _getSanitizedErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Common purchase error patterns and user-friendly messages
    if (errorString.contains('already owned') ||
        errorString.contains('already purchased')) {
      return 'You already own this subscription. Please restore your purchases.';
    } else if (errorString.contains('canceled') ||
        errorString.contains('cancelled')) {
      return 'Purchase was cancelled.';
    } else if (errorString.contains('not allowed') ||
        errorString.contains('not permitted')) {
      return 'Purchases are not allowed on this device.';
    } else if (errorString.contains('payment') &&
        errorString.contains('invalid')) {
      return 'There was an issue with your payment method. Please check your payment settings.';
    } else if (errorString.contains('store') &&
        errorString.contains('unavailable')) {
      return 'The App Store is currently unavailable. Please try again later.';
    } else if (errorString.contains('not finish') ||
        errorString.contains('pending')) {
      return 'Your previous transaction is still processing. Please wait a moment and try again.';
    } else if (kDebugMode) {
      // Only show raw error in debug mode
      return 'There was an error processing your purchase: $error';
    } else {
      // Generic message for production
      return 'There was an unexpected error processing your purchase. Please try again later.';
    }
  }
}
