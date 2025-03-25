import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/analytics_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final revenueCatService = Provider.of<RevenueCatService>(context);
    final analyticsService = AnalyticsService(); // Use singleton instance
    final isPremium = revenueCatService.isPremium;
    final subscriptionType = revenueCatService.activeSubscription;
    final expiryDate = revenueCatService.expiryDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            'Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPremium ? Icons.star : Icons.star_border,
                      color: isPremium ? Colors.amber : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPremium ? 'Premium Active' : 'Premium Inactive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isPremium) ...[
                  Text(
                    'Subscription: ${_getSubscriptionName(subscriptionType)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (expiryDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expires: ${_formatDate(expiryDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Manage subscription button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Subscription'),
                      onPressed: () async {
                        // Track analytics event
                        await analyticsService
                            .logEvent('manage_subscription_button_tapped');
                        // Open subscription management page
                        await revenueCatService
                            .openSubscriptionManagementPage();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Upgrade to Premium to unlock all features',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.star),
                      label: const Text('Upgrade to Premium'),
                      onPressed: () {
                        // Navigate to premium screen
                        Navigator.pushNamed(context, '/premium');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getSubscriptionName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.monthly:
        return 'Monthly';
      case SubscriptionType.yearly:
        return 'Yearly';
      case SubscriptionType.lifetime:
        return 'Lifetime';
      default:
        return 'None';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
