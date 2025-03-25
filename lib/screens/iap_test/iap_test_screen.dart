import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

class IAPTestScreen extends StatelessWidget {
  const IAPTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RevenueCatService>(
      builder: (context, revenueCatService, child) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('RevenueCat Test'),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status section
                  _buildSection(
                    title: 'Status',
                    children: [
                      _buildInfoRow(
                          'Loading', revenueCatService.isLoading.toString()),
                      _buildInfoRow(
                          'Premium', revenueCatService.isPremium.toString()),
                      _buildInfoRow('Status',
                          revenueCatService.purchaseStatus.toString()),
                      _buildInfoRow('Subscription',
                          revenueCatService.activeSubscription.toString()),
                      if (revenueCatService.expiryDate != null)
                        _buildInfoRow('Expiry Date',
                            revenueCatService.expiryDate.toString()),
                      if (revenueCatService.errorMessage.isNotEmpty)
                        _buildInfoRow('Error', revenueCatService.errorMessage),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Products section
                  _buildSection(
                    title: 'Products',
                    children: [
                      _buildInfoRow(
                          'Monthly Price',
                          revenueCatService.getPriceForProduct(
                              RevenueCatProductIds.monthlyId)),
                      _buildInfoRow(
                          'Yearly Price',
                          revenueCatService.getPriceForProduct(
                              RevenueCatProductIds.yearlyId)),
                      _buildInfoRow(
                          'Lifetime Price',
                          revenueCatService.getPriceForProduct(
                              RevenueCatProductIds.lifetimeId)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Actions section
                  _buildSection(
                    title: 'Actions',
                    children: [
                      CupertinoButton.filled(
                        child: const Text('Refresh Offerings'),
                        onPressed: () => revenueCatService.initialize(),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton.filled(
                        child: const Text('Purchase Monthly'),
                        onPressed: () => revenueCatService
                            .purchaseProduct(RevenueCatProductIds.monthlyId),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton.filled(
                        child: const Text('Purchase Yearly'),
                        onPressed: () => revenueCatService
                            .purchaseProduct(RevenueCatProductIds.yearlyId),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton.filled(
                        child: const Text('Purchase Lifetime'),
                        onPressed: () => revenueCatService
                            .purchaseProduct(RevenueCatProductIds.lifetimeId),
                      ),
                      const SizedBox(height: 10),
                      CupertinoButton(
                        child: const Text('Restore Purchases'),
                        onPressed: () => revenueCatService.restorePurchases(),
                      ),
                      if (revenueCatService.isPremium)
                        CupertinoButton(
                          child: const Text('Manage Subscription'),
                          onPressed: () => revenueCatService
                              .openSubscriptionManagementPage(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: CupertinoColors.systemGrey),
            ),
          ),
        ],
      ),
    );
  }
}
