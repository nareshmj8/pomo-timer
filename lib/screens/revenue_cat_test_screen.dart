import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';

class RevenueCatTestScreen extends StatefulWidget {
  const RevenueCatTestScreen({Key? key}) : super(key: key);

  @override
  State<RevenueCatTestScreen> createState() => _RevenueCatTestScreenState();
}

class _RevenueCatTestScreenState extends State<RevenueCatTestScreen> {
  String _testResults = '';
  bool _isLoading = false;

  void _addTestResult(String result) {
    setState(() {
      _testResults = '$result\n\n$_testResults';
    });
    LoggingService.logEvent('RevenueCat Test', result);
  }

  Future<void> _testInitialization(RevenueCatService revenueCatService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addTestResult('Testing RevenueCat initialization...');
      await revenueCatService.initialize();
      _addTestResult('RevenueCat initialized successfully');
      _addTestResult(
          'Customer Info: ${revenueCatService.customerInfo != null ? 'Available' : 'Not available'}');
      _addTestResult(
          'Offerings: ${revenueCatService.offerings != null ? 'Available' : 'Not available'}');

      if (revenueCatService.offerings != null &&
          revenueCatService.offerings!.current != null) {
        final packages =
            revenueCatService.offerings!.current!.availablePackages;
        _addTestResult('Available packages: ${packages.length}');

        for (var package in packages) {
          _addTestResult(
              'Package: ${package.identifier}, Price: ${package.storeProduct.priceString}');
        }
      }
    } catch (e) {
      _addTestResult('Error during initialization: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPurchase(
      RevenueCatService revenueCatService, String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addTestResult('Testing purchase for product: $productId');
      await revenueCatService.purchaseProduct(productId);
      _addTestResult('Purchase completed');
    } catch (e) {
      _addTestResult('Error during purchase: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRestore(RevenueCatService revenueCatService) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _addTestResult('Testing restore purchases...');
      final result = await revenueCatService.restorePurchases();
      _addTestResult(
          'Restore completed: ${result ? 'Purchases restored' : 'No purchases found'}');
    } catch (e) {
      _addTestResult('Error during restore: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenueCatService = Provider.of<RevenueCatService>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('RevenueCat Testing'),
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
                      'RevenueCat Status',
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
                    Text('Initialized: ${!revenueCatService.isLoading}'),
                    Text(
                        'Offerings: ${revenueCatService.offerings != null ? 'Available' : 'Not available'}'),
                    Text(
                        'Customer Info: ${revenueCatService.customerInfo != null ? 'Available' : 'Not available'}'),
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

                    // Initialize RevenueCat
                    CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _testInitialization(revenueCatService),
                      child: const Text('Initialize RevenueCat'),
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Monthly
                    CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _testPurchase(revenueCatService,
                              RevenueCatProductIds.monthlyId),
                      child: const Text('Purchase Monthly'),
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Yearly
                    CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _testPurchase(
                              revenueCatService, RevenueCatProductIds.yearlyId),
                      child: const Text('Purchase Yearly'),
                    ),

                    const SizedBox(height: 8.0),

                    // Purchase Lifetime
                    CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _testPurchase(revenueCatService,
                              RevenueCatProductIds.lifetimeId),
                      child: const Text('Purchase Lifetime'),
                    ),

                    const SizedBox(height: 8.0),

                    // Restore Purchases
                    CupertinoButton.filled(
                      onPressed: _isLoading
                          ? null
                          : () => _testRestore(revenueCatService),
                      child: const Text('Restore Purchases'),
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
                    if (_isLoading)
                      const CupertinoActivityIndicator()
                    else
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
