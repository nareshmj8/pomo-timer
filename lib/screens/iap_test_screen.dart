import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

class IAPTestScreen extends StatefulWidget {
  const IAPTestScreen({Key? key}) : super(key: key);

  @override
  State<IAPTestScreen> createState() => _IAPTestScreenState();
}

class _IAPTestScreenState extends State<IAPTestScreen> {
  String _testResults = '';

  void _addTestResult(String result) {
    setState(() {
      _testResults = '$result\n\n$_testResults';
    });
    LoggingService.logEvent('IAP Test', result);
  }

  @override
  Widget build(BuildContext context) {
    final revenueCatService = Provider.of<RevenueCatService>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('IAP Testing'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subscription Status
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Status',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text('Premium: ${revenueCatService.isPremium}'),
                    Text(
                        'Type: ${revenueCatService.activeSubscription.toString().split('.').last}'),
                    Text(
                        'Expiry: ${revenueCatService.expiryDate?.toString() ?? 'N/A'}'),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Test Actions
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Actions',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Reset Subscription
                    CupertinoButton.filled(
                      child: const Text('Reset Subscription State'),
                      onPressed: () async {
                        // Clear preferences manually since RevenueCatService doesn't have a reset method
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('subscription_type');
                        await prefs.remove('expiry_date');
                        // Reinitialize the service
                        await revenueCatService.initialize();
                        _addTestResult('Subscription state reset');
                      },
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Monthly
                    CupertinoButton.filled(
                      child: const Text('Purchase Monthly'),
                      onPressed: () async {
                        _addTestResult('Initiating Monthly purchase');
                        await revenueCatService
                            .purchaseProduct(RevenueCatProductIds.monthlyId);
                      },
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Yearly
                    CupertinoButton.filled(
                      child: const Text('Purchase Yearly'),
                      onPressed: () async {
                        _addTestResult('Initiating Yearly purchase');
                        await revenueCatService
                            .purchaseProduct(RevenueCatProductIds.yearlyId);
                      },
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Lifetime
                    CupertinoButton.filled(
                      child: const Text('Purchase Lifetime'),
                      onPressed: () async {
                        _addTestResult('Initiating Lifetime purchase');
                        await revenueCatService
                            .purchaseProduct(RevenueCatProductIds.lifetimeId);
                      },
                    ),

                    const SizedBox(height: 8.0),

                    // Restore Purchases
                    CupertinoButton.filled(
                      child: const Text('Restore Purchases'),
                      onPressed: () async {
                        _addTestResult('Restoring purchases...');
                        await revenueCatService.restorePurchases();
                      },
                    ),

                    const SizedBox(height: 8.0),

                    // Simulate Expiration
                    CupertinoButton.filled(
                      child: const Text('Simulate Expiration'),
                      onPressed: () async {
                        if (revenueCatService.expiryDate != null &&
                            revenueCatService.activeSubscription !=
                                SubscriptionType.lifetime) {
                          final prefs = await SharedPreferences.getInstance();
                          // Set expiry date to 1 minute ago
                          final expiredDate = DateTime.now()
                              .subtract(const Duration(minutes: 1));
                          await prefs.setString(
                              'expiry_date', expiredDate.toIso8601String());
                          _addTestResult(
                              'Simulated expiration. Restart app to see effect.');
                        } else {
                          _addTestResult('No active subscription to expire');
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // Test Results
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(_testResults.isEmpty
                        ? 'No test results yet'
                        : _testResults),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
