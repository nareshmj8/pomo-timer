import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class PremiumFooter extends StatelessWidget {
  final bool isLoading;
  final bool isPremium;
  final VoidCallback onSubscribe;
  final VoidCallback? onRestore;
  final VoidCallback? onManageSubscription;

  const PremiumFooter({
    Key? key,
    required this.isLoading,
    required this.isPremium,
    required this.onSubscribe,
    required this.onRestore,
    this.onManageSubscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      children: [
        if (!isPremium)
          _buildSubscribeButton(settings, context)
        else if (onManageSubscription != null)
          _buildManageSubscriptionButton(settings, context),
        if (!isPremium && onRestore != null)
          _buildRestoreLink(settings, context)
      ],
    );
  }

  Widget _buildSubscribeButton(
      SettingsProvider settings, BuildContext context) {
    // Button is only disabled when loading
    final buttonColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;
    final disabledColor = settings.isDarkTheme
        ? const Color(0xFF1C1C1E)
        : CupertinoColors.systemGrey6;
    final secondaryTextColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey
            .withAlpha(ThemeConstants.opacityToAlpha(0.9))
        : CupertinoColors.systemGrey.darkColor;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enhanced subscribe button with subtle shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: buttonColor.withAlpha((0.3 * 255).toInt()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
              border: isLoading
                  ? Border.all(
                      color: settings.separatorColor,
                      width: 0.5,
                    )
                  : null,
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: isLoading ? disabledColor : buttonColor,
              borderRadius: BorderRadius.circular(12),
              onPressed: isLoading ? null : onSubscribe,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLoading)
                    const Icon(
                      CupertinoIcons.sparkles,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                  if (!isLoading) const SizedBox(width: 8),
                  Text(
                    isLoading ? 'Loading...' : 'Subscribe Now',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isLoading
                          ? secondaryTextColor
                          : CupertinoColors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    size: 12,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'You can cancel anytime',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
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

  Widget _buildManageSubscriptionButton(
      SettingsProvider settings, BuildContext context) {
    final buttonColor = settings.isDarkTheme
        ? CupertinoColors.systemGrey5
        : CupertinoColors.systemGrey6;
    final textColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.separatorColor,
            width: 0.5,
          ),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          onPressed: onManageSubscription,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.gear,
                color: textColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreLink(SettingsProvider settings, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onRestore,
          child: Text(
            'Restore Purchases',
            style: TextStyle(
              fontSize: 15,
              color: settings.isDarkTheme
                  ? CupertinoColors.activeBlue.darkColor
                  : CupertinoColors.activeBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
