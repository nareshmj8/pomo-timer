import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/premium/models/pricing_plan.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/screens/premium/components/premium_plan_card.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class PricingContainer extends StatelessWidget {
  final PricingPlan? selectedPlan;
  final Function(PricingPlan) onSelectPlan;
  final RevenueCatService revenueCatService;

  const PricingContainer({
    Key? key,
    required this.selectedPlan,
    required this.onSelectPlan,
    required this.revenueCatService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Responsive sizing
    const borderRadius = ThemeConstants.largeRadius;
    final shadowBlurRadius = isTablet ? 20.0 : 15.0;
    final shadowOffset = isTablet ? const Offset(0, 6) : const Offset(0, 4);

    // Get available packages from RevenueCat
    final offerings = revenueCatService.offerings;
    final currentOffering = offerings?.current;
    final hasOfferings =
        currentOffering != null && currentOffering.availablePackages.isNotEmpty;

    return AnimatedContainer(
      duration: ThemeConstants.mediumAnimation,
      decoration: BoxDecoration(
        color: settings.listTileBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: settings.separatorColor,
          width: ThemeConstants.thinBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: settings.isDarkTheme
                ? const Color(0xFF000000).withAlpha(
                    ((ThemeConstants.lowOpacity - 0.05) * 255).toInt())
                : CupertinoColors.systemGrey
                    .withAlpha(((ThemeConstants.lowOpacity / 2) * 255).toInt()),
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: !hasOfferings
          ? _buildLoadingOrError(settings)
          : Column(
              children: _buildSubscriptionPlans(currentOffering),
            ),
    );
  }

  Widget _buildLoadingOrError(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.mediumSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(height: ThemeConstants.mediumSpacing),
          Text(
            'Loading subscription options...',
            style: TextStyle(
              color: settings.textColor,
              fontSize: ThemeConstants.mediumFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubscriptionPlans(Offering offering) {
    // Find packages for each subscription type
    Package? monthlyPackage =
        _findPackageForProductId(offering, RevenueCatProductIds.monthlyId);
    Package? yearlyPackage =
        _findPackageForProductId(offering, RevenueCatProductIds.yearlyId);
    Package? lifetimePackage =
        _findPackageForProductId(offering, RevenueCatProductIds.lifetimeId);

    // If specific packages aren't found, try to find by package type
    monthlyPackage ??= _findPackageByType(offering, PackageType.monthly);
    yearlyPackage ??= _findPackageByType(offering, PackageType.annual);
    lifetimePackage ??= _findPackageByType(offering, PackageType.lifetime);

    final plans = <Widget>[];

    // Add monthly plan if available
    if (monthlyPackage != null) {
      plans.add(
        PremiumPlanCard(
          icon: CupertinoIcons.moon_stars_fill,
          title: 'Monthly',
          price: PremiumPlanCard.formatPrice(
              monthlyPackage.storeProduct.priceString, PricingPlan.monthly),
          description: 'Billed monthly',
          isHighlighted: false,
          showBorder: true,
          plan: PricingPlan.monthly,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
      );
    }

    // Add yearly plan if available
    if (yearlyPackage != null) {
      plans.add(
        PremiumPlanCard(
          icon: CupertinoIcons.star_fill,
          title: 'Yearly',
          price: PremiumPlanCard.formatPrice(
              yearlyPackage.storeProduct.priceString, PricingPlan.yearly),
          description: _calculateYearlySavings(monthlyPackage, yearlyPackage),
          isHighlighted: true,
          badge: 'Best Value',
          showBorder: plans.isNotEmpty,
          plan: PricingPlan.yearly,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
      );
    }

    // Add lifetime plan if available
    if (lifetimePackage != null) {
      plans.add(
        PremiumPlanCard(
          icon: CupertinoIcons.circle_grid_hex_fill,
          title: 'Lifetime',
          price: PremiumPlanCard.formatPrice(
              lifetimePackage.storeProduct.priceString, PricingPlan.lifetime),
          description: 'One-time payment',
          isHighlighted: false,
          showBorder: plans.isNotEmpty,
          plan: PricingPlan.lifetime,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
      );
    }

    // If no plans were found, use fallback with price from RevenueCatService
    if (plans.isEmpty) {
      plans.addAll([
        PremiumPlanCard(
          icon: CupertinoIcons.moon_stars_fill,
          title: 'Monthly',
          price: PremiumPlanCard.formatPrice(
              revenueCatService
                  .getPriceForProduct(RevenueCatProductIds.monthlyId),
              PricingPlan.monthly),
          description: 'Billed monthly',
          isHighlighted: false,
          showBorder: true,
          plan: PricingPlan.monthly,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
        PremiumPlanCard(
          icon: CupertinoIcons.star_fill,
          title: 'Yearly',
          price: PremiumPlanCard.formatPrice(
              revenueCatService
                  .getPriceForProduct(RevenueCatProductIds.yearlyId),
              PricingPlan.yearly),
          description: 'Save 50% annually',
          isHighlighted: true,
          badge: 'Best Value',
          showBorder: true,
          plan: PricingPlan.yearly,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
        PremiumPlanCard(
          icon: CupertinoIcons.circle_grid_hex_fill,
          title: 'Lifetime',
          price: PremiumPlanCard.formatPrice(
              revenueCatService
                  .getPriceForProduct(RevenueCatProductIds.lifetimeId),
              PricingPlan.lifetime),
          description: 'One-time payment',
          isHighlighted: false,
          showBorder: false,
          plan: PricingPlan.lifetime,
          selectedPlan: selectedPlan,
          onSelectPlan: onSelectPlan,
        ),
      ]);
    }

    return plans;
  }

  Package? _findPackageForProductId(Offering offering, String productId) {
    try {
      return offering.availablePackages.firstWhere(
        (package) => package.storeProduct.identifier == productId,
      );
    } catch (e) {
      return null;
    }
  }

  Package? _findPackageByType(Offering offering, PackageType packageType) {
    try {
      return offering.availablePackages.firstWhere(
        (package) => package.packageType == packageType,
      );
    } catch (e) {
      return null;
    }
  }

  String _calculateYearlySavings(
      Package? monthlyPackage, Package? yearlyPackage) {
    if (monthlyPackage == null || yearlyPackage == null) {
      return 'Save 50% annually';
    }

    try {
      final monthlyPrice = monthlyPackage.storeProduct.price;
      final yearlyPrice = yearlyPackage.storeProduct.price;
      final monthlyCost = monthlyPrice * 12;
      final savings = ((monthlyCost - yearlyPrice) / monthlyCost * 100).round();

      if (savings > 0) {
        return 'Save $savings% annually';
      } else {
        return 'Annual subscription';
      }
    } catch (e) {
      return 'Annual subscription';
    }
  }
}
