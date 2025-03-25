import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../services/revenue_cat_service.dart';
import '../../../utils/theme_constants.dart';
import '../../../models/subscription_type.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final revenueCatService = Provider.of<RevenueCatService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Premium',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              _buildPremiumStatusItem(
                context,
                revenueCatService,
                theme,
              ),
              _buildPremiumActionItem(
                context,
                revenueCatService,
                theme,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatusItem(
    BuildContext context,
    RevenueCatService revenueCatService,
    ThemeProvider theme,
  ) {
    final isPremium = revenueCatService.isPremium;
    final statusText = isPremium ? 'Active' : 'Not Active';
    final subscriptionType = revenueCatService.activeSubscription;

    String subscriptionText = '';
    if (isPremium) {
      switch (subscriptionType) {
        case SubscriptionType.monthly:
          subscriptionText = 'Monthly Subscription';
          break;
        case SubscriptionType.yearly:
          subscriptionText = 'Yearly Subscription';
          break;
        case SubscriptionType.lifetime:
          subscriptionText = 'Lifetime Access';
          break;
        default:
          subscriptionText = 'Premium';
      }
    } else {
      subscriptionText = 'Upgrade to unlock premium features';
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.separatorColor,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isPremium
                  ? CupertinoColors.activeBlue
                      .withAlpha(ThemeConstants.opacityToAlpha(0.1))
                  : CupertinoColors.systemGrey
                      .withAlpha(ThemeConstants.opacityToAlpha(0.1)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              isPremium
                  ? CupertinoIcons.checkmark_seal_fill
                  : CupertinoIcons.star,
              color: isPremium
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Status: $statusText',
                  style: TextStyle(
                    color: theme.listTileTextColor,
                    fontSize: ThemeConstants.bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscriptionText,
                  style: TextStyle(
                    color: theme.secondaryTextColor,
                    fontSize: ThemeConstants.captionFontSize,
                  ),
                ),
                if (isPremium &&
                    revenueCatService.expiryDate != null &&
                    subscriptionType != SubscriptionType.lifetime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Renews on ${_formatDate(revenueCatService.expiryDate!)}',
                      style: const TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontSize: ThemeConstants.captionFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionItem(
    BuildContext context,
    RevenueCatService revenueCatService,
    ThemeProvider theme, {
    bool isLast = false,
  }) {
    final isPremium = revenueCatService.isPremium;
    final buttonText = isPremium ? 'Manage Subscription' : 'Upgrade to Premium';

    return CupertinoButton(
      padding: const EdgeInsets.all(16.0),
      onPressed: () {
        Navigator.of(context).pushNamed('/premium');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            buttonText,
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
              fontSize: ThemeConstants.bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.activeBlue,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
