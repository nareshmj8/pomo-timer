import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

enum PricingPlan { monthly, yearly, lifetime }

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  PricingPlan? _selectedPlan;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectPlan(PricingPlan plan) {
    setState(() {
      if (_selectedPlan == plan) {
        _selectedPlan = null;
      } else {
        _selectedPlan = plan;
      }
    });
    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) => CupertinoPageScaffold(
        backgroundColor: settings.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Premium',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: settings.textColor,
              letterSpacing: -0.3,
            ),
          ),
          backgroundColor: settings.backgroundColor.withOpacity(0.85),
          border: Border(
            bottom: BorderSide(
              color: settings.separatorColor,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        settings.backgroundColor,
                        settings.isDarkTheme
                            ? settings.backgroundColor
                            : settings.backgroundColor.withOpacity(0.97),
                      ],
                      stops: const [0.0, 0.8],
                    ),
                  ),
                ),
              ),
              // Main content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: settings.textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock all features and enhance your focus',
                        style: TextStyle(
                          fontSize: 17,
                          color: settings.isDarkTheme
                              ? CupertinoColors.systemGrey.withOpacity(0.9)
                              : CupertinoColors.systemGrey.darkColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Combined Pricing Container
                      Container(
                        decoration: BoxDecoration(
                          color: settings.listTileBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: settings.separatorColor,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: settings.isDarkTheme
                                  ? const Color(0xFF000000).withOpacity(0.2)
                                  : CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildPricingOption(
                              context,
                              settings,
                              icon: CupertinoIcons.moon_stars_fill,
                              title: 'Monthly',
                              price: '\$0.99',
                              description: 'Billed monthly',
                              isHighlighted: false,
                              showBorder: true,
                              plan: PricingPlan.monthly,
                            ),
                            _buildPricingOption(
                              context,
                              settings,
                              icon: CupertinoIcons.star_fill,
                              title: 'Yearly',
                              price: '\$5.99',
                              description: 'Save 50% annually',
                              isHighlighted: true,
                              badge: 'Best Value',
                              showBorder: true,
                              plan: PricingPlan.yearly,
                            ),
                            _buildPricingOption(
                              context,
                              settings,
                              icon: CupertinoIcons.circle_grid_hex_fill,
                              title: 'Lifetime',
                              price: '\$14.99',
                              description: 'One-time payment',
                              isHighlighted: false,
                              showBorder: false,
                              plan: PricingPlan.lifetime,
                            ),
                          ],
                        ),
                      ),

                      _buildSubscribeButton(settings),

                      // Features List Title
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 16),
                        child: Text(
                          'Premium Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: settings.textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      // Feature cards with consistent spacing
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.chart_bar_alt_fill,
                        'Advanced Statistics',
                        'Get detailed insights into your productivity patterns',
                        settings.isDarkTheme
                            ? CupertinoColors.systemBlue.darkColor
                            : CupertinoColors.systemBlue,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.paintbrush_fill,
                        'Custom Themes',
                        'Access beautiful custom themes',
                        settings.isDarkTheme
                            ? CupertinoColors.systemPink.darkColor
                            : CupertinoColors.systemPink,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.cloud_upload_fill,
                        'Backup',
                        'Import and export your data',
                        settings.isDarkTheme
                            ? CupertinoColors.systemGreen.darkColor
                            : CupertinoColors.systemGreen,
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.checkmark_shield_fill,
                        'Ad-Free Experience',
                        'Enjoy uninterrupted focus sessions without ads',
                        settings.isDarkTheme
                            ? CupertinoColors.systemOrange.darkColor
                            : CupertinoColors.systemOrange,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingOption(
    BuildContext context,
    SettingsProvider settings, {
    required IconData icon,
    required String title,
    required String price,
    required String description,
    required bool isHighlighted,
    String? badge,
    required bool showBorder,
    required PricingPlan plan,
  }) {
    final isSelected = _selectedPlan == plan;
    final highlightColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;
    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey.withOpacity(0.9)
        : CupertinoColors.systemGrey.darkColor;

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted
            ? (settings.isDarkTheme
                ? const Color(0xFF2C2C2E)
                : CupertinoColors.systemGrey6)
            : Colors.transparent,
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: settings.separatorColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _selectPlan(plan),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: highlightColor.withOpacity(0.8),
                    width: 1.5,
                  )
                : null,
            borderRadius: showBorder
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? highlightColor.withOpacity(0.15)
                      : (settings.isDarkTheme
                          ? const Color(0xFF38383A)
                          : CupertinoColors.systemGrey6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? highlightColor : settings.textColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: settings.textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? highlightColor : settings.textColor,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 12,
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

  Widget _buildSubscribeButton(SettingsProvider settings) {
    final isDisabled = _selectedPlan == null;
    final buttonColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;
    final disabledColor = settings.isDarkTheme
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.systemGrey6;
    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey.withOpacity(0.9)
        : CupertinoColors.systemGrey.darkColor;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isDisabled
                  ? Border.all(
                      color: settings.separatorColor,
                      width: 0.5,
                    )
                  : null,
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: isDisabled ? disabledColor : buttonColor,
              borderRadius: BorderRadius.circular(12),
              onPressed: isDisabled
                  ? null
                  : () {
                      // TODO: Implement subscription logic
                    },
              child: Text(
                isDisabled ? 'Select a Plan' : 'Subscribe Now',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color:
                      isDisabled ? secondaryTextColor : CupertinoColors.white,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          if (!isDisabled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'You can cancel anytime',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    SettingsProvider settings,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey.withOpacity(0.9)
        : CupertinoColors.systemGrey.darkColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: settings.listTileBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: settings.separatorColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: settings.isDarkTheme
                  ? color.withOpacity(0.2)
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: settings.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
