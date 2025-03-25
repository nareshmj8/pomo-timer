import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/screens/premium_success_modal.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

/// A helper class to handle purchase success animations and modals
class PurchaseSuccessHandler {
  /// Shows the purchase success modal with confetti animation
  static void showSuccessAnimation(
      BuildContext context, SubscriptionType subscriptionType) {
    // Show the success modal as a dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PremiumSuccessModal(
          subscriptionType: subscriptionType,
        );
      },
    );
  }

  /// Shows the purchase success modal using the navigator key
  /// This is useful when showing the modal from a service
  static void showSuccessAnimationGlobal(SubscriptionType subscriptionType) {
    // Get the navigator context
    final context = RevenueCatService.navigatorKey.currentContext;
    if (context != null) {
      showSuccessAnimation(context, subscriptionType);
    }
  }
}
