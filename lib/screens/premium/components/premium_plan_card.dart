import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../models/pricing_plan.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/theme_constants.dart';

class PremiumPlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final String description;
  final bool isHighlighted;
  final String? badge;
  final bool showBorder;
  final PricingPlan plan;
  final PricingPlan? selectedPlan;
  final void Function(PricingPlan) onSelectPlan;

  // Pricing constants for fallback - only used if App Store prices can't be loaded
  // These should be generic placeholders that make sense in any currency
  static const String _monthlyPrice = '0.99/month';
  static const String _yearlyPrice = '5.99/year';
  static const String _lifetimePrice = '14.99';

  const PremiumPlanCard({
    super.key,
    required this.icon,
    required this.title,
    required this.price,
    required this.description,
    required this.isHighlighted,
    this.badge,
    required this.showBorder,
    required this.plan,
    required this.selectedPlan,
    required this.onSelectPlan,
  });

  static String formatPrice(String? priceString, PricingPlan plan) {
    debugPrint('Formatting price for plan: $plan, price: $priceString');

    // If price is null or empty, use fallback values with generic currency symbol
    if (priceString == null || priceString.isEmpty) {
      debugPrint('Price is null or empty, using fallback value for $plan');
      switch (plan) {
        case PricingPlan.monthly:
          return _monthlyPrice;
        case PricingPlan.yearly:
          return _yearlyPrice;
        case PricingPlan.lifetime:
          return _lifetimePrice;
      }
    }

    // Use actual product price from RevenueCat - this already includes the currency symbol
    switch (plan) {
      case PricingPlan.monthly:
        debugPrint('Monthly plan: $priceString/month');
        return '$priceString/month';
      case PricingPlan.yearly:
        debugPrint('Yearly plan: $priceString/year');
        return '$priceString/year';
      case PricingPlan.lifetime:
        debugPrint('Lifetime plan: $priceString');
        return priceString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSelected = selectedPlan == plan;
    final isTablet = ResponsiveUtils.isTablet(context);

    final highlightColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;
    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey
            .withAlpha((ThemeConstants.highOpacity * 255).toInt())
        : CupertinoColors.systemGrey.darkColor;

    // Responsive sizes
    final titleFontSize = isTablet
        ? ThemeConstants.mediumFontSize + 2
        : ThemeConstants.mediumFontSize;

    final descriptionFontSize = isTablet
        ? ThemeConstants.smallFontSize + 1
        : ThemeConstants.smallFontSize;

    final priceFontSize = isTablet
        ? ThemeConstants.largeFontSize
        : ThemeConstants.mediumFontSize + 3;

    final iconSize = isTablet
        ? ThemeConstants.mediumIconSize
        : ThemeConstants.smallIconSize + 4;

    final contentPadding = isTablet
        ? ThemeConstants.mediumSpacing
        : ThemeConstants.mediumSpacing - 4;

    final borderRadius = showBorder
        ? BorderRadius.zero
        : const BorderRadius.only(
            bottomLeft: Radius.circular(ThemeConstants.mediumRadius),
            bottomRight: Radius.circular(ThemeConstants.mediumRadius),
          );

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted
            ? (settings.isDarkTheme
                ? const Color(0xFF2C2C2E)
                : CupertinoColors.systemGrey6)
            : CupertinoColors.systemBackground.withAlpha(0),
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: settings.separatorColor,
                  width: ThemeConstants.thinBorder,
                ),
              )
            : null,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onSelectPlan(plan),
        child: AnimatedContainer(
          duration: ThemeConstants.mediumAnimation,
          padding: EdgeInsets.all(contentPadding),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: highlightColor.withAlpha(
                        ((ThemeConstants.highOpacity - 0.1) * 255).toInt()),
                    width: ThemeConstants.thickBorder,
                  )
                : null,
            borderRadius: borderRadius,
            color: isSelected
                ? (settings.isDarkTheme
                    ? highlightColor.withAlpha(
                        ((ThemeConstants.veryLowOpacity + 0.03) * 255).toInt())
                    : highlightColor.withAlpha(
                        (ThemeConstants.veryLowOpacity * 255).toInt()))
                : CupertinoColors.systemBackground.withAlpha(0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.smallSpacing),
                decoration: BoxDecoration(
                  color: isSelected
                      ? highlightColor
                          .withAlpha((ThemeConstants.lowOpacity * 255).toInt())
                      : (settings.isDarkTheme
                          ? const Color(0xFF38383A)
                          : CupertinoColors.systemGrey6),
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.smallRadius),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isSelected ? highlightColor : settings.textColor,
                ),
              ),
              SizedBox(
                  width: isTablet
                      ? ThemeConstants.mediumSpacing
                      : ThemeConstants.smallSpacing + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? highlightColor
                                : settings.textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: ThemeConstants.smallSpacing),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ThemeConstants.smallSpacing,
                              vertical: ThemeConstants.tinySpacing,
                            ),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.mediumRadius - 4),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: isTablet
                                    ? ThemeConstants.smallFontSize
                                    : ThemeConstants.smallFontSize - 1,
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: ThemeConstants.tinySpacing),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: descriptionFontSize,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  width: isTablet
                      ? ThemeConstants.mediumSpacing
                      : ThemeConstants.smallSpacing + 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? highlightColor : settings.textColor,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: ThemeConstants.tinySpacing),
                      padding: const EdgeInsets.all(ThemeConstants.tinySpacing),
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(
                            ThemeConstants.mediumRadius - 4),
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark,
                        size: isTablet
                            ? ThemeConstants.smallIconSize - 4
                            : ThemeConstants.smallIconSize - 8,
                        color: CupertinoColors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
