import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/interfaces/analytics_service_interface.dart';
import '../mocks/mock_analytics_service.dart';

void main() {
  late AnalyticsServiceInterface analyticsService;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    analyticsService = mockAnalyticsService;
  });

  group('MockAnalyticsService', () {
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

    test('logEvent should track timestamp', () async {
      final before = DateTime.now().millisecondsSinceEpoch;
      await analyticsService.logEvent('test_event');
      final after = DateTime.now().millisecondsSinceEpoch;

      final timestamp =
          mockAnalyticsService.loggedEvents.first['timestamp'] as int;
      expect(timestamp >= before, isTrue);
      expect(timestamp <= after, isTrue);
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

    test('wasEventLogged helper method should verify event logging', () async {
      expect(mockAnalyticsService.wasEventLogged('test_event'), false);

      await analyticsService.logEvent('test_event');

      expect(mockAnalyticsService.wasEventLogged('test_event'), true);
      expect(mockAnalyticsService.wasEventLogged('other_event'), false);
    });

    test('getEventsByName helper method should return events by name',
        () async {
      await analyticsService.logEvent('test_event', {'param': 'value1'});
      await analyticsService.logEvent('other_event');
      await analyticsService.logEvent('test_event', {'param': 'value2'});

      final events = mockAnalyticsService.getEventsByName('test_event');

      expect(events.length, 2);
      expect(events[0]['parameters']['param'], 'value1');
      expect(events[1]['parameters']['param'], 'value2');
    });
  });
}
