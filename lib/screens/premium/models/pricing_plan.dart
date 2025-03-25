/// Enum representing the available pricing plans
enum PricingPlan {
  monthly,
  yearly,
  lifetime,
}

/// Extension methods for PricingPlan
extension PricingPlanExtension on PricingPlan {
  /// Get the display name of the pricing plan
  String get displayName {
    switch (this) {
      case PricingPlan.monthly:
        return 'Monthly';
      case PricingPlan.yearly:
        return 'Yearly';
      case PricingPlan.lifetime:
        return 'Lifetime';
    }
  }

  /// Get the description of the pricing plan
  String get description {
    switch (this) {
      case PricingPlan.monthly:
        return 'Billed monthly';
      case PricingPlan.yearly:
        return 'Best value! Save 50%';
      case PricingPlan.lifetime:
        return 'One-time payment';
    }
  }

  /// Get the tag for the pricing plan (e.g., "POPULAR")
  String? get tag {
    switch (this) {
      case PricingPlan.yearly:
        return null;
      case PricingPlan.monthly:
      case PricingPlan.lifetime:
        return null;
    }
  }
}
