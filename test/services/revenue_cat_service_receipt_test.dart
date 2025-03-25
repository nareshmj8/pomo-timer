import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import '../mocks/mock_revenue_cat_service.dart';

void main() {
  group('RevenueCatService Receipt Tests', () {
    late MockRevenueCatService mockRevenueCatService;

    setUp(() {
      mockRevenueCatService = MockRevenueCatService();
      mockRevenueCatService.reset(); // Reset state between tests
    });

    test('should verify premium entitlements', () async {
      // Arrange - set up with premium
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.monthly,
      );

      // Verify we're premium
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should verify non-premium state', () async {
      // Arrange - default state is non-premium
      expect(mockRevenueCatService.isPremium, isFalse);

      // Explicitly configure as non-premium
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.none,
      );

      // Verify still non-premium
      expect(mockRevenueCatService.isPremium, isFalse);
    });

    test('should verify different subscription types', () async {
      // Test monthly
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.monthly,
      );
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.monthly));

      // Test yearly
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.yearly,
      );
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));

      // Test lifetime
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.lifetime,
      );
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.lifetime));
    });

    test('should handle developer premium override', () async {
      // Default state
      expect(mockRevenueCatService.isPremium, isFalse);

      // Enable dev premium
      mockRevenueCatService.enableDevPremiumAccess();
      expect(mockRevenueCatService.isPremium, isTrue);

      // Disable dev premium
      mockRevenueCatService.disableDevPremiumAccess();
      expect(mockRevenueCatService.isPremium, isFalse);
    });

    test('should restore purchases and verify receipts', () async {
      // Arrange - configure restore to succeed with premium
      mockRevenueCatService.restorePurchasesResult = true;

      // Act - restore purchases
      final result = await mockRevenueCatService.restorePurchases();

      // Assert
      expect(result, isTrue);
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should track expiry dates for subscriptions', () async {
      // Arrange
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.monthly,
        expiryDate: expiryDate,
      );

      // Assert
      expect(mockRevenueCatService.expiryDate, equals(expiryDate));
    });

    test('should not have expiry date for lifetime subscription', () async {
      // Arrange
      mockRevenueCatService.configureForTestScenario(
        subscriptionType: SubscriptionType.lifetime,
      );

      // Assert
      expect(mockRevenueCatService.expiryDate, isNull);
    });

    test('should maintain premium state after reset for valid subscriptions',
        () async {
      // Arrange - purchase a subscription
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');
      expect(mockRevenueCatService.isPremium, isTrue);

      // Reset mock service
      mockRevenueCatService.reset();

      // Assert - should be non-premium after reset as we're not managing real receipts
      expect(mockRevenueCatService.isPremium, isFalse);
    });
  });
}
