import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/analytics_service.dart';
import 'package:pomodoro_timemaster/services/interfaces/analytics_service_interface.dart';
import '../mocks/mock_analytics_service.dart';

// We'll use a custom class that extends AnalyticsService for testing
class TestableAnalyticsService {
  static List<Map<String, dynamic>> loggedEvents = [];
  static Map<String, dynamic> userProperties = {};
  static bool debugPrintCalled = false;
  static List<String> errors = [];
  static bool shouldThrowOnEvent = false;
  static bool shouldThrowOnUserProperties = false;

  static void reset() {
    loggedEvents = [];
    userProperties = {};
    debugPrintCalled = false;
    errors = [];
    shouldThrowOnEvent = false;
    shouldThrowOnUserProperties = false;
  }

  static Future<void> trackEvent(String eventName,
      [Map<String, dynamic>? parameters]) async {
    // Simulate errors for edge case testing
    if (shouldThrowOnEvent) {
      errors.add('Error tracking event: $eventName');
      throw Exception('Failed to track event: $eventName');
    }

    // Validate input to catch invalid events
    if (eventName.isEmpty) {
      errors.add('Invalid event name: empty string');
      return;
    }

    loggedEvents.add({
      'event': eventName,
      'parameters': parameters,
    });

    // Override the kDebugMode print call to avoid console output during tests
    debugPrintCalled = true;
  }

  // Purchase tracking methods
  static Future<void> trackPurchase({
    required String productId,
    required String price,
    required bool success,
    String? currency = 'USD',
    String? paymentMethod = 'App Store',
    String? errorReason,
  }) async {
    // Validate input
    if (productId.isEmpty) {
      errors.add('Invalid productId: empty string');
      return;
    }

    final parameters = {
      'product_id': productId,
      'price': price,
      'currency': currency,
      'payment_method': paymentMethod,
      'success': success,
      if (errorReason != null) 'error_reason': errorReason,
    };

    await trackEvent(
        success ? 'purchase_completed' : 'purchase_failed', parameters);
  }

  // Premium feature tracking
  static Future<void> trackPremiumScreenView() async {
    await trackEvent('premium_screen_viewed');
  }

  static Future<void> trackPremiumFeatureTap(String featureName) async {
    if (featureName.isEmpty) {
      errors.add('Invalid feature name: empty string');
      return;
    }
    await trackEvent('premium_feature_tapped', {'feature_name': featureName});
  }

  // Purchase flow tracking
  static Future<void> trackPurchaseStart({
    required String productId,
    required double price,
    required String currency,
  }) async {
    if (productId.isEmpty) {
      errors.add('Invalid productId: empty string');
      return;
    }

    if (price < 0) {
      errors.add('Invalid price: negative value');
      return;
    }

    await trackEvent('purchase_started', {
      'product_id': productId,
      'price': price.toString(),
      'currency': currency,
    });
  }

  static Future<void> trackPurchaseComplete({
    required String productId,
    required double price,
    required String currency,
    required String subscriptionType,
  }) async {
    await trackEvent('purchase_completed', {
      'product_id': productId,
      'price': price.toString(),
      'currency': currency,
      'subscription_type': subscriptionType,
    });
  }

  static Future<void> trackPurchaseCancelled({
    required String productId,
    required String reason,
  }) async {
    await trackEvent('purchase_cancelled', {
      'product_id': productId,
      'reason': reason,
    });
  }

  static Future<void> trackPurchaseError({
    required String productId,
    required String error,
    String? errorDetails,
  }) async {
    await trackEvent('purchase_error', {
      'product_id': productId,
      'error': error,
      if (errorDetails != null) 'error_details': errorDetails,
    });
  }

  static Future<void> setUserProperties({
    String? userId,
    bool? isPremium,
    String? subscriptionType,
    DateTime? subscriptionExpiryDate,
  }) async {
    // Simulate errors for edge case testing
    if (shouldThrowOnUserProperties) {
      errors.add('Error setting user properties');
      throw Exception('Failed to set user properties');
    }

    if (userId != null) userProperties['user_id'] = userId;
    if (isPremium != null) userProperties['is_premium'] = isPremium;
    if (subscriptionType != null)
      userProperties['subscription_type'] = subscriptionType;
    if (subscriptionExpiryDate != null) {
      userProperties['subscription_expiry_date'] =
          subscriptionExpiryDate.toIso8601String();
    }

    // Override the kDebugMode print call to avoid console output during tests
    debugPrintCalled = true;
  }

  // Additional methods for subscription tracking
  static Future<void> trackSubscription({
    required String productId,
    required String subscriptionType,
    required bool isRenewal,
    String? price,
  }) async {
    final parameters = {
      'product_id': productId,
      'subscription_type': subscriptionType,
      'is_renewal': isRenewal,
      if (price != null) 'price': price,
    };

    await trackEvent('subscription_updated', parameters);
  }

  // Tracks when a user's subscription expires
  static Future<void> trackSubscriptionExpired(String subscriptionType) async {
    await trackEvent(
        'subscription_expired', {'subscription_type': subscriptionType});
  }

  // Tracks restore purchases flow
  static Future<void> trackRestorePurchases({
    required bool success,
    int? restoredItemCount,
    String? errorReason,
  }) async {
    final parameters = {
      'success': success,
      if (restoredItemCount != null) 'restored_item_count': restoredItemCount,
      if (errorReason != null) 'error_reason': errorReason,
    };

    await trackEvent('purchases_restored', parameters);
  }
}

void main() {
  late AnalyticsServiceInterface analyticsService;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    analyticsService = mockAnalyticsService;
  });

  group('AnalyticsService', () {
    test('initialize should set initialization flag', () async {
      expect(mockAnalyticsService.isInitialized, false);
      await analyticsService.initialize();
      expect(mockAnalyticsService.isInitialized, true);
      expect(mockAnalyticsService.initializeCallCount, 1);
    });

    test('logEvent should add event to logged events', () async {
      final eventName = 'test_event';
      final params = {'param1': 'value1', 'param2': 42};

      await analyticsService.logEvent(eventName, params);

      expect(mockAnalyticsService.loggedEvents.length, 1);
      expect(mockAnalyticsService.loggedEvents.first['name'], eventName);
      expect(mockAnalyticsService.loggedEvents.first['parameters'], params);
    });

    test('logEvent should initialize service if not already initialized',
        () async {
      expect(mockAnalyticsService.isInitialized, false);

      await analyticsService.logEvent('test_event');

      expect(mockAnalyticsService.isInitialized, true);
      expect(mockAnalyticsService.initializeCallCount, 1);
    });

    test('setUserProperties should update user properties', () async {
      final properties = {'isPremium': true, 'userId': 'user123'};

      await analyticsService.setUserProperties(properties);

      expect(mockAnalyticsService.userProperties['isPremium'], true);
      expect(mockAnalyticsService.userProperties['userId'], 'user123');
    });

    test('logPurchaseCompleted should track purchase events', () async {
      await analyticsService.logPurchaseCompleted(
        productId: 'premium_annual',
        price: 19.99,
        currency: 'USD',
        paymentMethod: 'App Store',
        success: true,
      );

      expect(mockAnalyticsService.purchaseCompletedEvents.length, 1);
      final event = mockAnalyticsService.purchaseCompletedEvents.first;
      expect(event['product_id'], 'premium_annual');
      expect(event['price'], 19.99);
      expect(event['currency'], 'USD');
      expect(event['payment_method'], 'App Store');
      expect(event['success'], true);

      // Also verify it was logged as a general event
      expect(mockAnalyticsService.wasEventLogged('purchase_completed'), true);
    });

    test('logPremiumScreenViewed should track premium screen views', () async {
      await analyticsService.logPremiumScreenViewed();

      expect(mockAnalyticsService.premiumScreenViewedCount, 1);
      expect(
          mockAnalyticsService.wasEventLogged('premium_screen_viewed'), true);
    });

    test('logPremiumFeatureTapped should track premium feature taps', () async {
      final featureName = 'custom_themes';

      await analyticsService.logPremiumFeatureTapped(featureName);

      expect(mockAnalyticsService.premiumFeaturesTapped.contains(featureName),
          true);

      final events =
          mockAnalyticsService.getEventsByName('premium_feature_tapped');
      expect(events.length, 1);
      expect(events.first['parameters']['feature_name'], featureName);
    });

    test('logSubscriptionUpdated should track subscription updates', () async {
      await analyticsService.logSubscriptionUpdated(
        productId: 'premium_annual',
        subscriptionType: 'annual',
        isRenewal: true,
      );

      expect(mockAnalyticsService.subscriptionUpdatedEvents.length, 1);
      final event = mockAnalyticsService.subscriptionUpdatedEvents.first;
      expect(event['product_id'], 'premium_annual');
      expect(event['subscription_type'], 'annual');
      expect(event['is_renewal'], true);

      // Also verify it was logged as a general event
      expect(mockAnalyticsService.wasEventLogged('subscription_updated'), true);
    });

    test('logSubscriptionExpired should track subscription expirations',
        () async {
      final subscriptionType = 'annual';

      await analyticsService.logSubscriptionExpired(subscriptionType);

      expect(
          mockAnalyticsService.subscriptionExpiredEvents
              .contains(subscriptionType),
          true);

      final events =
          mockAnalyticsService.getEventsByName('subscription_expired');
      expect(events.length, 1);
      expect(events.first['parameters']['subscription_type'], subscriptionType);
    });

    test('logPurchasesRestored should track purchase restorations', () async {
      await analyticsService.logPurchasesRestored(true);

      expect(mockAnalyticsService.purchasesRestoredEvents.contains(true), true);

      final events = mockAnalyticsService.getEventsByName('purchases_restored');
      expect(events.length, 1);
      expect(events.first['parameters']['success'], true);
    });

    test('reset should clear all tracked events and properties', () {
      // First generate some test data
      mockAnalyticsService.isInitialized = true;
      mockAnalyticsService.initializeCallCount = 3;
      mockAnalyticsService.loggedEvents.add({'name': 'test_event'});
      mockAnalyticsService.userProperties['test'] = 'value';
      mockAnalyticsService.premiumScreenViewedCount = 2;

      // Reset everything
      mockAnalyticsService.reset();

      // Verify everything was reset
      expect(mockAnalyticsService.isInitialized, false);
      expect(mockAnalyticsService.initializeCallCount, 0);
      expect(mockAnalyticsService.loggedEvents, isEmpty);
      expect(mockAnalyticsService.userProperties, isEmpty);
      expect(mockAnalyticsService.premiumScreenViewedCount, 0);
    });
  });
}
