import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

class ActiveSubscriptionInfo extends StatelessWidget {
  final SubscriptionType activeSubscription;
  final DateTime? expiryDate;
  final VoidCallback? onManageSubscription;

  const ActiveSubscriptionInfo({
    Key? key,
    required this.activeSubscription,
    this.expiryDate,
    this.onManageSubscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final highlightColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: settings.isDarkTheme
            ? CupertinoColors.systemGrey6
                .withAlpha(105) // 0.41 opacity = 105 alpha
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    highlightColor.r.toInt(),
                    highlightColor.g.toInt(),
                    highlightColor.b.toInt(),
                    0.15,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 24,
                  color: highlightColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSubscriptionTypeText(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: settings.textColor,
                      ),
                    ),
                    if (expiryDate != null &&
                        activeSubscription != SubscriptionType.lifetime)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Renews on ${_formatDate(expiryDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(
                              highlightColor.r.toInt(),
                              highlightColor.g.toInt(),
                              highlightColor.b.toInt(),
                              0.8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Thank you for supporting Pomodoro TimeMaster! You have full access to all premium features.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(
                settings.textColor.r.toInt(),
                settings.textColor.g.toInt(),
                settings.textColor.b.toInt(),
                0.8,
              ),
              height: 1.4,
            ),
          ),
          if (onManageSubscription != null &&
              (activeSubscription == SubscriptionType.monthly ||
                  activeSubscription == SubscriptionType.yearly))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onManageSubscription,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.gear,
                      size: 14,
                      color: highlightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Manage Subscription',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: highlightColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSubscriptionTypeText() {
    switch (activeSubscription) {
      case SubscriptionType.monthly:
        return 'Monthly Subscription';
      case SubscriptionType.yearly:
        return 'Yearly Subscription';
      case SubscriptionType.lifetime:
        return 'Lifetime Access';
      default:
        return 'Premium Active';
    }
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
