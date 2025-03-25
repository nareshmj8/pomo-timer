import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:pomodoro_timemaster/screens/premium/controllers/premium_controller.dart';
import 'package:pomodoro_timemaster/screens/premium/models/pricing_plan.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/theme/app_colors.dart';
import 'package:pomodoro_timemaster/widgets/premium_plan_card.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';
import 'package:pomodoro_timemaster/screens/legal/terms_conditions_screen.dart';
import 'package:pomodoro_timemaster/screens/legal/privacy_policy_screen.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';

/// View for the Premium Screen
class PremiumScreenView extends StatelessWidget {
  final PremiumController controller;
  final RevenueCatService revenueCatService;
  final bool isPremium;
  final VoidCallback onClose;
  final VoidCallback onDebugPaywall;
  final List<Widget> bottomWidgets;

  const PremiumScreenView({
    Key? key,
    required this.controller,
    required this.revenueCatService,
    required this.isPremium,
    required this.onClose,
    required this.onDebugPaywall,
    this.bottomWidgets = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: settings.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: settings.backgroundColor,
        middle: Text(
          'Premium',
          style: TextStyle(
            color: settings.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: isPremium
            ? _buildPremiumActiveContent(context)
            : _buildSubscriptionContent(context),
      ),
    );
  }

  /// Build content when user already has premium
  Widget _buildPremiumActiveContent(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.checkmark_seal_fill,
              size: 80,
              color: CupertinoColors.activeGreen,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'Premium Active',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: settings.textColor,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'Subscription Type: ${revenueCatService.activeSubscription.toString().split('.').last}',
              style: TextStyle(
                fontSize: 16,
                color: settings.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (revenueCatService.expiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires: ${_formatDate(revenueCatService.expiryDate!)}',
                style: TextStyle(
                  fontSize: 16,
                  color: settings.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: isSmallScreen ? 24 : 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                child: const Text('Restore Purchases'),
                onPressed: () =>
                    controller.restorePurchases(context, revenueCatService),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                onPressed: onDebugPaywall,
                child: Text(
                  'Debug Paywall',
                  style: TextStyle(
                    color: settings.isDarkTheme
                        ? CupertinoColors.activeBlue
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build subscription content when user doesn't have premium
  Widget _buildSubscriptionContent(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Use ResponsiveUtils for spacing
    final double sectionSpacing = isSmallScreen ? 14.0 : 18.0;

    return Container(
      color: settings.backgroundColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildHeader(settings),
          SizedBox(height: sectionSpacing * 0.8),
          _buildPricingPlans(context),
          SizedBox(height: sectionSpacing),
          _buildFeaturesList(settings),
          SizedBox(height: sectionSpacing),
          _buildSubscribeButton(context),
          SizedBox(height: sectionSpacing * 0.5),
          _buildRestoreButton(context, settings),
          SizedBox(height: sectionSpacing * 0.5),
          _buildTermsAndPrivacy(context, settings),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ...bottomWidgets,
        ],
      ),
    );
  }

  /// Build the header section
  Widget _buildHeader(SettingsProvider settings) {
    return Text(
      'Upgrade to Premium',
      style: TextStyle(
        fontSize: ThemeConstants.headingFontSize - 1,
        fontWeight: FontWeight.bold,
        color: settings.textColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build the pricing plans section
  Widget _buildPricingPlans(BuildContext context) {
    final isLoading =
        revenueCatService.isLoading || revenueCatService.offerings == null;

    if (isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            alignment: Alignment.center,
            child: const CupertinoActivityIndicator(),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading subscription options...',
            style: TextStyle(
              color: Provider.of<SettingsProvider>(context)
                  .textColor
                  .withAlpha(ThemeConstants.opacityToAlpha(0.7)),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              'Reload Offers',
              style: TextStyle(
                fontSize: 15,
                color: Provider.of<SettingsProvider>(context).isDarkTheme
                    ? CupertinoColors.activeBlue
                    : AppColors.primary,
              ),
            ),
            onPressed: () {
              _reloadOfferings(context);
            },
          ),
        ],
      );
    }

    // Default stacked layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PremiumPlanCard(
          title: PricingPlan.monthly.displayName,
          description: PricingPlan.monthly.description,
          price: _getPrice(RevenueCatProductIds.monthlyId),
          isSelected: controller.selectedPlan == PricingPlan.monthly,
          tag: PricingPlan.monthly.tag,
          onTap: () => controller.selectPlan(PricingPlan.monthly),
        ),
        const SizedBox(height: 8),
        PremiumPlanCard(
          title: PricingPlan.yearly.displayName,
          description: PricingPlan.yearly.description,
          price: _getPrice(RevenueCatProductIds.yearlyId),
          isSelected: controller.selectedPlan == PricingPlan.yearly,
          tag: PricingPlan.yearly.tag,
          onTap: () => controller.selectPlan(PricingPlan.yearly),
        ),
        const SizedBox(height: 8),
        PremiumPlanCard(
          title: PricingPlan.lifetime.displayName,
          description: PricingPlan.lifetime.description,
          price: _getPrice(RevenueCatProductIds.lifetimeId),
          isSelected: controller.selectedPlan == PricingPlan.lifetime,
          tag: PricingPlan.lifetime.tag,
          onTap: () => controller.selectPlan(PricingPlan.lifetime),
        ),
      ],
    );
  }

  // Helper method to reload offerings with error handling
  Future<void> _reloadOfferings(BuildContext ctx) async {
    // Store mounted state before async operation
    final bool contextMounted = ctx.mounted;

    try {
      await revenueCatService.forceReloadOfferings();
      if (!contextMounted || !ctx.mounted) return;
      controller.onStateChanged();
    } catch (e) {
      debugPrint('Error reloading offerings: $e');
      // Check if context is still valid
      if (!contextMounted || !ctx.mounted) return;

      // Show error popup
      showCupertinoDialog(
        context: ctx,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Network Error'),
          content: const Text(
            'Unable to load subscription options. Please check your internet connection and try again.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      );
    }
  }

  /// Build the features list section
  Widget _buildFeaturesList(SettingsProvider settings) {
    final features = [
      'Advanced Statistics',
      'Custom Themes',
      'iCloud Sync',
      'Future Updates',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: settings.textColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: settings.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: settings.separatorColor,
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                ...features.asMap().entries.map((entry) {
                  final index = entry.key;
                  final feature = entry.value;

                  return Column(
                    children: [
                      if (index > 0)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: settings.separatorColor,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: CupertinoColors.activeBlue,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              feature,
                              style: TextStyle(
                                fontSize: 14,
                                color: settings.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the subscribe button
  Widget _buildSubscribeButton(BuildContext context) {
    const buttonHeight = 44.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: CupertinoButton.filled(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(10),
        onPressed: controller.isRestoring
            ? null
            : () => controller.handleSubscribe(revenueCatService),
        child: controller.isRestoring
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(color: CupertinoColors.white),
                  SizedBox(width: 6),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Subscribe Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Build the restore purchases button
  Widget _buildRestoreButton(BuildContext context, SettingsProvider settings) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: controller.isRestoring
            ? null
            : () => controller.restorePurchases(context, revenueCatService),
        child: controller.isRestoring
            ? const CupertinoActivityIndicator()
            : const Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  /// Build the terms and privacy section
  Widget _buildTermsAndPrivacy(
      BuildContext context, SettingsProvider settings) {
    return Center(
      child: Column(
        children: [
          Text(
            'By subscribing, you agree to our Terms of Service and Privacy Policy',
            style: TextStyle(
              fontSize: 10,
              color: settings.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                onPressed: () {
                  // Navigate to Terms and Conditions screen
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),
              Text(
                '•',
                style: TextStyle(
                  fontSize: 11,
                  color: settings.secondaryTextColor,
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                onPressed: () {
                  // Navigate to Privacy Policy screen
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get the price for a product ID with improved loading state
  String _getPrice(String productId) {
    final price = revenueCatService.getPriceForProduct(productId);
    if (price.isEmpty && !revenueCatService.isLoading) {
      // If price is empty and not loading, trigger a refresh
      Future.microtask(() => revenueCatService.forceReloadOfferings());
      return 'Loading...';
    }
    return price.isNotEmpty ? price : 'Loading...';
  }

  /// Format a date
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
