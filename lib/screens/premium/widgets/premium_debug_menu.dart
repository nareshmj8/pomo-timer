// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/screens/premium/controllers/premium_controller.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/revenue_cat_test_helper.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/revenue_cat_test_screen.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

/// Shows a debug menu for premium features
void showPremiumDebugMenu(
  BuildContext context,
  RevenueCatService revenueCatService,
  PremiumController controller,
) {
  showCupertinoDialog(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Text('Premium Debug Menu'),
      content: const Text('Select a debug action:'),
      actions: [
        CupertinoDialogAction(
          child: const Text('Run Automated Tests'),
          onPressed: () {
            Navigator.pop(dialogContext);
            RevenueCatTestHelper.runAutomatedTests(context, revenueCatService);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Open Test Suite'),
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const RevenueCatTestScreen(),
              ),
            );
          },
        ),
        CupertinoDialogAction(
          child: const Text('Debug Paywall Configuration'),
          onPressed: () {
            Navigator.pop(dialogContext);
            _debugPaywallConfiguration(context, revenueCatService);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Force Reload Offerings'),
          onPressed: () {
            Navigator.pop(dialogContext);
            _forceReloadOfferings(context, revenueCatService);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Verify Premium Status'),
          onPressed: () {
            Navigator.pop(dialogContext);
            _verifyPremiumStatus(context, revenueCatService);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Restore Purchases'),
          onPressed: () {
            Navigator.pop(dialogContext);
            controller.restorePurchases(context, revenueCatService);
          },
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

/// Debug the paywall configuration
void _debugPaywallConfiguration(
  BuildContext context,
  RevenueCatService revenueCatService,
) {
  // Show loading dialog
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const CupertinoAlertDialog(
      title: Text('Debugging Paywall'),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CupertinoActivityIndicator(),
      ),
    ),
  );

  // Debug paywall configuration
  revenueCatService.debugPaywallConfiguration().then((_) {
    // Dismiss loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show completion dialog
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Debug Complete'),
        content: const Text(
          'Paywall configuration debugging complete. Check logs for detailed information.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  });
}

/// Force reload offerings
void _forceReloadOfferings(
  BuildContext context,
  RevenueCatService revenueCatService,
) {
  // Show loading dialog
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const CupertinoAlertDialog(
      title: Text('Reloading Offerings'),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CupertinoActivityIndicator(),
      ),
    ),
  );

  // Force reload offerings
  revenueCatService.forceReloadOfferings().then((_) {
    // Dismiss loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show completion dialog
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reload Complete'),
        content: const Text(
          'Offerings have been reloaded. Check logs for detailed information.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  });
}

/// Verify premium status
void _verifyPremiumStatus(
  BuildContext context,
  RevenueCatService revenueCatService,
) {
  // Show loading dialog
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const CupertinoAlertDialog(
      title: Text('Verifying Premium Status'),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: CupertinoActivityIndicator(),
      ),
    ),
  );

  // Update premium status by forcing a refresh from RevenueCat
  revenueCatService.verifyPremiumEntitlements().then((isPremium) {
    // Dismiss loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show result dialog
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(isPremium ? 'Premium Active' : 'No Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPremium
                  ? 'User has an active premium subscription.'
                  : 'User does not have an active premium subscription.',
            ),
            const SizedBox(height: 8),
            Text(
              'Subscription Type: ${revenueCatService.activeSubscription.toString().split('.').last}',
            ),
            if (revenueCatService.expiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires: ${revenueCatService.expiryDate!.month}/${revenueCatService.expiryDate!.day}/${revenueCatService.expiryDate!.year}',
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
  });
}
