import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RevenueCatService revenueCatService;

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create the service
    revenueCatService = RevenueCatService();
  });

  group('RevenueCatService Tests', () {
    test('Initial state should be not purchased', () {
      expect(revenueCatService.isPremium, equals(false));
      expect(
          revenueCatService.activeSubscription, equals(SubscriptionType.none));
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
}
