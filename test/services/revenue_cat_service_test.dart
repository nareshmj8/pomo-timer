import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RevenueCatService revenueCatService;

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create service
    revenueCatService = RevenueCatService();
  });

  group('RevenueCatService Initialization', () {
    test('Should initialize with not purchased state', () {
      expect(revenueCatService.isPremium, isFalse);
      expect(
          revenueCatService.activeSubscription, equals(SubscriptionType.none));
      expect(revenueCatService.purchaseStatus,
          equals(PurchaseStatus.notPurchased));
    });

    test('Should format product IDs correctly', () {
      expect(RevenueCatProductIds.monthlyId,
          equals('com.naresh.pomodorotimemaster.premium.monthly'));
      expect(RevenueCatProductIds.yearlyId,
          equals('com.naresh.pomodorotimemaster.premium.yearly'));
      expect(RevenueCatProductIds.lifetimeId,
          equals('com.naresh.pomodorotimemaster.premium.lifetime'));
    });

    test('Should check premium status correctly', () {
      expect(revenueCatService.isPremium, isFalse);
    });
  });

  group('Developer Premium Access', () {
    test('Should enable developer premium access for testing', () {
      // Initially not premium
      expect(revenueCatService.isPremium, isFalse);

      // Enable developer premium
      revenueCatService.enableDevPremiumAccess();

      // Should be premium now
      expect(revenueCatService.isPremium, isTrue);
      // But active subscription should still be none
      expect(
          revenueCatService.activeSubscription, equals(SubscriptionType.none));
    });

    test('Should disable developer premium access', () {
      // Enable developer premium
      revenueCatService.enableDevPremiumAccess();
      expect(revenueCatService.isPremium, isTrue);

      // Disable developer premium
      revenueCatService.disableDevPremiumAccess();

      // Should not be premium anymore
      expect(revenueCatService.isPremium, isFalse);
    });
  });

  group('Purchase Flow Tests', () {
    // This test was trying to access a private method and is no longer supported
    // test('Should update purchase status during purchase process', () {
    //   // Set initial state
    //   expect(revenueCatService.purchaseStatus,
    //       equals(PurchaseStatus.notPurchased));

    //   // Update to pending
    //   (revenueCatService as dynamic)
    //       ._updatePurchaseStatus(PurchaseStatus.pending);
    //   expect(revenueCatService.purchaseStatus, equals(PurchaseStatus.pending));

    //   // Update to purchased
    //   (revenueCatService as dynamic)
    //       ._updatePurchaseStatus(PurchaseStatus.purchased);
    //   expect(
    //       revenueCatService.purchaseStatus, equals(PurchaseStatus.purchased));
    // });

    // This test was trying to access a private method and is no longer supported
    // test('Should handle purchase error correctly', () {
    //   // Set initial state
    //   expect(revenueCatService.purchaseStatus,
    //       equals(PurchaseStatus.notPurchased));
    //   expect(revenueCatService.errorMessage, isEmpty);

    //   // Update with error
    //   final errorMessage = 'Network error during purchase';
    //   (revenueCatService as dynamic)._updatePurchaseStatus(PurchaseStatus.error,
    //       errorMessage: errorMessage);

    //   // Verify error state
    //   expect(revenueCatService.purchaseStatus, equals(PurchaseStatus.error));
    //   expect(revenueCatService.errorMessage, equals(errorMessage));
    // });
  });
}
