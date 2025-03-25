import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/screens/premium/models/pricing_plan.dart';

void main() {
  group('PricingPlan', () {
    test('should have the correct number of plans', () {
      expect(PricingPlan.values.length, equals(3));
      expect(PricingPlan.values, contains(PricingPlan.monthly));
      expect(PricingPlan.values, contains(PricingPlan.yearly));
      expect(PricingPlan.values, contains(PricingPlan.lifetime));
    });

    test('displayName should return the correct display name for each plan',
        () {
      expect(PricingPlan.monthly.displayName, equals('Monthly'));
      expect(PricingPlan.yearly.displayName, equals('Yearly'));
      expect(PricingPlan.lifetime.displayName, equals('Lifetime'));
    });

    test('description should return the correct description for each plan', () {
      expect(PricingPlan.monthly.description, equals('Billed monthly'));
      expect(PricingPlan.yearly.description, equals('Best value! Save 50%'));
      expect(PricingPlan.lifetime.description, equals('One-time payment'));
    });

    test('tag should return the correct tag for each plan', () {
      expect(PricingPlan.monthly.tag, isNull);
      expect(PricingPlan.yearly.tag, isNull);
      expect(PricingPlan.lifetime.tag, isNull);
    });
  });
}
