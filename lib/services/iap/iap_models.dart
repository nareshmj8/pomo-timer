/// Enum representing the current purchase status
enum PurchaseStatus {
  notPurchased,
  pending,
  purchased,
  error,
}

/// Enum representing the type of subscription
enum SubscriptionType {
  none,
  monthly,
  yearly,
  lifetime,
}

/// Constants for product IDs
class IAPProductIds {
  static const String monthlyId =
      'com.naresh.pomodorotimemaster.premium.monthly';
  static const String yearlyId = 'com.naresh.pomodorotimemaster.premium.yearly';
  static const String lifetimeId =
      'com.naresh.pomodorotimemaster.premium.lifetime';
  static const List<String> productIds = [monthlyId, yearlyId, lifetimeId];
}
