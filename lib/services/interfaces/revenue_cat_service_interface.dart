import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';

/// Interface for RevenueCatService to allow for testing and dependency injection
abstract class RevenueCatServiceInterface extends ChangeNotifier {
  /// RevenueCat offerings
  Offerings? get offerings;

  /// RevenueCat customer info
  CustomerInfo? get customerInfo;

  /// Current purchase status
  PurchaseStatus get purchaseStatus;

  /// Current active subscription type
  SubscriptionType get activeSubscription;

  /// Error message if purchase fails
  String get errorMessage;

  /// Whether the service is currently loading
  bool get isLoading;

  /// Expiry date of current subscription (null for lifetime or no subscription)
  DateTime? get expiryDate;

  /// Whether user has premium access
  bool get isPremium;

  /// Initialize the service
  Future<void> initialize();

  /// Force reload offerings
  Future<void> forceReloadOfferings();

  /// Purchase a product by its ID
  Future<void> purchaseProduct(String productId);

  /// Purchase a specific package
  Future<CustomerInfo?> purchasePackage(Package package);

  /// Restore purchases from the store
  Future<bool> restorePurchases();

  /// Show current subscription plans
  Future<void> showSubscriptionPlans(BuildContext context);

  /// Show premium benefits UI
  Future<void> showPremiumBenefits(BuildContext context);

  /// Enable developer premium access for testing (non-production use only)
  void enableDevPremiumAccess();

  /// Disable developer premium access
  void disableDevPremiumAccess();

  /// Open the manage subscriptions page on App Store or Google Play
  Future<void> openManageSubscriptionsPage();
}
