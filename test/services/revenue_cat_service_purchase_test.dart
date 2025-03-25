import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import '../mocks/mock_revenue_cat_service.dart';

void main() {
  group('RevenueCatService Purchase Flow Tests', () {
    late MockRevenueCatService mockRevenueCatService;

    setUp(() {
      mockRevenueCatService = MockRevenueCatService();
      mockRevenueCatService.reset(); // Reset state between tests
    });

    test('should purchase monthly product successfully', () async {
      // Act
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert
      expect(mockRevenueCatService.purchasedProductIds,
          contains('com.naresh.pomodorotimemaster.premium.monthly'));
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.purchased));
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.monthly));
      expect(mockRevenueCatService.expiryDate, isNotNull);
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should purchase yearly product successfully', () async {
      // Act
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.yearly');

      // Assert
      expect(mockRevenueCatService.purchasedProductIds,
          contains('com.naresh.pomodorotimemaster.premium.yearly'));
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.purchased));
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      expect(mockRevenueCatService.expiryDate, isNotNull);
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should purchase lifetime product successfully', () async {
      // Act
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.lifetime');

      // Assert
      expect(mockRevenueCatService.purchasedProductIds,
          contains('com.naresh.pomodorotimemaster.premium.lifetime'));
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.purchased));
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.lifetime));
      expect(
          mockRevenueCatService.expiryDate, isNull); // Lifetime has no expiry
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should handle purchase failure', () async {
      // Arrange
      mockRevenueCatService.shouldFailPurchase = true;
      mockRevenueCatService.purchaseErrorMessage = 'Test purchase error';

      // Act
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert
      expect(mockRevenueCatService.purchasedProductIds, isEmpty);
      expect(
          mockRevenueCatService.purchaseStatus, equals(PurchaseStatus.error));
      expect(mockRevenueCatService.errorMessage, equals('Test purchase error'));
      expect(mockRevenueCatService.isPremium, isFalse);
    });

    test('should restore purchases successfully', () async {
      // Arrange
      mockRevenueCatService.restorePurchasesResult = true;

      // Act
      final result = await mockRevenueCatService.restorePurchases();

      // Assert
      expect(result, isTrue);
      expect(mockRevenueCatService.restorePurchasesCallCount, equals(1));
      expect(mockRevenueCatService.isPremium, isTrue);
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.restored));
    });

    test('should handle restore purchases failure', () async {
      // Arrange
      mockRevenueCatService.shouldFailRestore = true;

      // Act
      final result = await mockRevenueCatService.restorePurchases();

      // Assert
      expect(result, isFalse);
      expect(mockRevenueCatService.restorePurchasesCallCount, equals(1));
      expect(mockRevenueCatService.isPremium, isFalse);
    });

    test('should handle multiple purchases', () async {
      // Act - first purchase
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert first purchase
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.monthly));

      // Act - upgrade to yearly
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.yearly');

      // Assert upgrade
      expect(mockRevenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      expect(mockRevenueCatService.purchasedProductIds.length, equals(2));
      expect(
          mockRevenueCatService.purchasedProductIds,
          containsAll([
            'com.naresh.pomodorotimemaster.premium.monthly',
            'com.naresh.pomodorotimemaster.premium.yearly'
          ]));
    });

    test('should track premium status correctly', () async {
      // Initial state
      expect(mockRevenueCatService.isPremium, isFalse);

      // After purchase
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');
      expect(mockRevenueCatService.isPremium, isTrue);

      // Test reset
      mockRevenueCatService.reset();
      expect(mockRevenueCatService.isPremium, isFalse);
    });
  });
}
