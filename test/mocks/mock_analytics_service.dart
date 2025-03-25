import 'package:pomodoro_timemaster/services/interfaces/analytics_service_interface.dart';

/// A mock implementation of the AnalyticsServiceInterface for testing.
class MockAnalyticsService implements AnalyticsServiceInterface {
  bool isInitialized = false;
  final List<Map<String, dynamic>> loggedEvents = [];
  final Map<String, dynamic> userProperties = {};

  /// Tracks if the initialize method was called
  int initializeCallCount = 0;

  /// Tracks purchase completed events
  final List<Map<String, dynamic>> purchaseCompletedEvents = [];

  /// Tracks premium screen viewed events
  int premiumScreenViewedCount = 0;

  /// Tracks premium feature tapped events
  final List<String> premiumFeaturesTapped = [];

  /// Tracks subscription updated events
  final List<Map<String, dynamic>> subscriptionUpdatedEvents = [];

  /// Tracks subscription expired events
  final List<String> subscriptionExpiredEvents = [];

  /// Tracks purchases restored events
  final List<bool> purchasesRestoredEvents = [];

  @override
  Future<void> initialize() async {
    initializeCallCount++;
    isInitialized = true;
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    // Initialize if not already initialized
    if (!isInitialized) {
      await initialize();
    }

    loggedEvents.add({
      'name': name,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    userProperties.addAll(properties);
  }

  @override
  Future<void> logPurchaseCompleted({
    required String productId,
    required double price,
    required String currency,
    required String paymentMethod,
    required bool success,
  }) async {
    purchaseCompletedEvents.add({
      'product_id': productId,
      'price': price,
      'currency': currency,
      'payment_method': paymentMethod,
      'success': success,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await logEvent('purchase_completed', {
      'product_id': productId,
      'price': price,
      'currency': currency,
      'payment_method': paymentMethod,
      'success': success,
    });
  }

  @override
  Future<void> logPremiumScreenViewed() async {
    premiumScreenViewedCount++;
    await logEvent('premium_screen_viewed');
  }

  @override
  Future<void> logPremiumFeatureTapped(String featureName) async {
    premiumFeaturesTapped.add(featureName);
    await logEvent('premium_feature_tapped', {'feature_name': featureName});
  }

  @override
  Future<void> logSubscriptionUpdated({
    required String productId,
    required String subscriptionType,
    required bool isRenewal,
  }) async {
    subscriptionUpdatedEvents.add({
      'product_id': productId,
      'subscription_type': subscriptionType,
      'is_renewal': isRenewal,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await logEvent('subscription_updated', {
      'product_id': productId,
      'subscription_type': subscriptionType,
      'is_renewal': isRenewal,
    });
  }

  @override
  Future<void> logSubscriptionExpired(String subscriptionType) async {
    subscriptionExpiredEvents.add(subscriptionType);
    await logEvent(
        'subscription_expired', {'subscription_type': subscriptionType});
  }

  @override
  Future<void> logPurchasesRestored(bool success) async {
    purchasesRestoredEvents.add(success);
    await logEvent('purchases_restored', {'success': success});
  }

  /// Resets all tracked events and properties for testing purposes
  void reset() {
    isInitialized = false;
    initializeCallCount = 0;
    loggedEvents.clear();
    userProperties.clear();
    purchaseCompletedEvents.clear();
    premiumScreenViewedCount = 0;
    premiumFeaturesTapped.clear();
    subscriptionUpdatedEvents.clear();
    subscriptionExpiredEvents.clear();
    purchasesRestoredEvents.clear();
  }

  /// Helper method to verify if a specific event was logged
  bool wasEventLogged(String eventName) {
    return loggedEvents.any((event) => event['name'] == eventName);
  }

  /// Helper method to get events by name
  List<Map<String, dynamic>> getEventsByName(String eventName) {
    return loggedEvents.where((event) => event['name'] == eventName).toList();
  }
}
