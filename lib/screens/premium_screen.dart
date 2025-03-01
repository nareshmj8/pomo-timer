import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

// StatelessWidget for a static premium features screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen(
      {super.key}); // Constructor with optional key, marked const for optimization

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) => CupertinoPageScaffold(
        backgroundColor: settings.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Premium',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: settings.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: settings.selectedTheme == 'Light'
                  ? CupertinoColors.separator
                  : settings.backgroundColor.withAlpha(77),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background design elements
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.systemYellow.withAlpha(30),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.activeBlue.withAlpha(20),
                  ),
                ),
              ),
              // Main content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Premium badge with glow effect
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CupertinoColors.systemYellow.withAlpha(30),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  CupertinoColors.systemYellow.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.star_fill,
                          size: 60,
                          color: CupertinoColors.systemYellow,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: settings.textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock all features and enhance your productivity',
                        style: TextStyle(
                          fontSize: 16,
                          color: settings.textColor.withAlpha(180),
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Premium features list
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.chart_bar_alt_fill,
                        'Advanced Statistics',
                        'Get detailed insights into your productivity patterns',
                        CupertinoColors.systemBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.paintbrush_fill,
                        'Custom Themes',
                        'Access beautiful custom themes',
                        CupertinoColors.systemPink,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.cloud_upload_fill,
                        'Backup',
                        'Import and export your data',
                        CupertinoColors.systemGreen,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        context,
                        settings,
                        CupertinoIcons.checkmark_shield_fill,
                        'Ad-Free Experience',
                        'Enjoy uninterrupted focus sessions without ads',
                        CupertinoColors.systemOrange,
                      ),
                      const SizedBox(height: 40),
                      // Price section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CupertinoColors.systemGrey5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withAlpha(20),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '\$4.99',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label,
                              ),
                            ),
                            Text(
                              'per month',
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label.withAlpha(180),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: CupertinoColors.activeBlue,
                                borderRadius: BorderRadius.circular(12),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                onPressed: () {
                                  // TODO: Implement purchase
                                },
                                child: const Text(
                                  'Start Free Trial',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '7-day free trial, cancel anytime',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.label.withAlpha(150),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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

  Widget _buildFeatureCard(
    BuildContext context,
    SettingsProvider settings,
    IconData icon,
    String title,
    String description,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label.withAlpha(180),
                    letterSpacing: -0.2,
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
