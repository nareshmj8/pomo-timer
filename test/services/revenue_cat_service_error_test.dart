import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import '../mocks/mock_revenue_cat_service.dart';

void main() {
  group('RevenueCatService Error Handling Tests', () {
    late MockRevenueCatService mockRevenueCatService;

    setUp(() {
      mockRevenueCatService = MockRevenueCatService();
      mockRevenueCatService.reset(); // Reset state between tests
    });

    test('should handle initialization errors gracefully', () async {
      // Arrange
      mockRevenueCatService.shouldFailInitialization = true;

      // Act
      await mockRevenueCatService.initialize();

      // Assert
      expect(mockRevenueCatService.errorMessage, isNotEmpty);
      expect(mockRevenueCatService.isLoading,
          isFalse); // Should not be stuck in loading
    });

    test('should provide detailed error message for purchase failures',
        () async {
      // Arrange
      mockRevenueCatService.shouldFailPurchase = true;
      mockRevenueCatService.purchaseErrorMessage = 'Network connection failed';

      // Act
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert
      expect(
          mockRevenueCatService.purchaseStatus, equals(PurchaseStatus.error));
      expect(mockRevenueCatService.errorMessage,
          equals('Network connection failed'));
    });

    test('should handle multiple consecutive errors', () async {
      // Arrange
      mockRevenueCatService.shouldFailPurchase = true;
      mockRevenueCatService.purchaseErrorMessage = 'First error';

      // Act - first failure
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert first error
      expect(mockRevenueCatService.errorMessage, equals('First error'));

      // Change error message
      mockRevenueCatService.purchaseErrorMessage = 'Second error';

      // Act - second failure
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.yearly');

      // Assert second error
      expect(mockRevenueCatService.errorMessage, equals('Second error'));
    });

    test('should handle error state and successful operations', () async {
      // Arrange - set up for failure
      mockRevenueCatService.shouldFailPurchase = true;
      mockRevenueCatService.purchaseErrorMessage = 'Test error';

      // Act - trigger failure
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');
      expect(mockRevenueCatService.errorMessage, equals('Test error'));

      // Now make it succeed
      mockRevenueCatService.shouldFailPurchase = false;

      // Act - trigger success
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert success indicators
      expect(mockRevenueCatService.purchasedProductIds.isNotEmpty, isTrue);
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.purchased));
    });

    test('should handle failed restore attempt', () async {
      // Arrange
      mockRevenueCatService.shouldFailRestore = true;

      // Act
      final result = await mockRevenueCatService.restorePurchases();

      // Assert
      expect(result, isFalse);
      expect(mockRevenueCatService.isLoading,
          isFalse); // Should not be stuck in loading
    });

    test('should remain usable after errors', () async {
      // Arrange - set up for failure
      mockRevenueCatService.shouldFailPurchase = true;

      // Act - trigger failure
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Now make it succeed
      mockRevenueCatService.shouldFailPurchase = false;

      // Act - try again
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');

      // Assert successful purchase
      expect(mockRevenueCatService.purchasedProductIds,
          contains('com.naresh.pomodorotimemaster.premium.monthly'));
      expect(mockRevenueCatService.isPremium, isTrue);
    });

    test('should load offerings despite initialization issues', () async {
      // Arrange
      mockRevenueCatService.shouldFailInitialization = true;

      // Act - initialization fails
      await mockRevenueCatService.initialize();

      // But offerings can still be loaded
      mockRevenueCatService.shouldFailInitialization = false;
      await mockRevenueCatService.forceReloadOfferings();

      // Assert
      expect(mockRevenueCatService.forceReloadOfferingsCallCount, equals(1));
    });

    test('should reset errors when service is reset', () async {
      // Arrange - set up error state
      mockRevenueCatService.shouldFailPurchase = true;
      await mockRevenueCatService
          .purchaseProduct('com.naresh.pomodorotimemaster.premium.monthly');
      expect(mockRevenueCatService.errorMessage, isNotEmpty);

      // Act
      mockRevenueCatService.reset();

      // Assert
      expect(mockRevenueCatService.errorMessage, isEmpty);
      expect(mockRevenueCatService.purchaseStatus,
          equals(PurchaseStatus.notPurchased));
    });
  });
}
