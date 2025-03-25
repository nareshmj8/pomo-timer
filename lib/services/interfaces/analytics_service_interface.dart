/// Interface for analytics services
///
/// This interface allows for dependency injection and easier testing
/// by decoupling the implementation from the code that uses it.
abstract class AnalyticsServiceInterface {
  /// Initialize the analytics service
  Future<void> initialize();

  /// Log an event with optional parameters
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);

  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties);

  /// Log a purchase completed event
  Future<void> logPurchaseCompleted({
    required String productId,
    required double price,
    required String currency,
    required String paymentMethod,
    required bool success,
  });

  /// Log a premium screen viewed event
  Future<void> logPremiumScreenViewed();

  /// Log a premium feature tapped event
  Future<void> logPremiumFeatureTapped(String featureName);

  /// Log a subscription updated event
  Future<void> logSubscriptionUpdated({
    required String productId,
    required String subscriptionType,
    required bool isRenewal,
  });

  /// Log a subscription expired event
  Future<void> logSubscriptionExpired(String subscriptionType);

  /// Log a purchases restored event
  Future<void> logPurchasesRestored(bool success);
}
