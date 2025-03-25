import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';

// A test app that doesn't rely on the main app's singletons
class SubscriptionTestApp extends StatefulWidget {
  final RevenueCatService mockService;

  const SubscriptionTestApp({Key? key, required this.mockService})
      : super(key: key);

  @override
  State<SubscriptionTestApp> createState() => _SubscriptionTestAppState();
}

class _SubscriptionTestAppState extends State<SubscriptionTestApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RevenueCatService>.value(
      value: widget.mockService,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Subscription Test')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<RevenueCatService>(
                  builder: (context, service, child) {
                    return Column(
                      children: [
                        Text(
                          service.isPremium ? 'Premium Active' : 'Not Premium',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                service.isPremium ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (service.activeSubscription != SubscriptionType.none)
                          Text(
                            'Type: ${service.activeSubscription.toString().split('.').last}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (service.expiryDate != null)
                          Text(
                            'Expires: ${service.expiryDate.toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        const SizedBox(height: 20),
                        if (service.isLoading)
                          const CircularProgressIndicator()
                        else if (service.errorMessage.isNotEmpty)
                          Text(
                            service.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (service is MockRevenueCatService) {
                              service.mockPurchaseMonthly();
                            }
                          },
                          child: const Text('Monthly Premium - ₹299'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (service is MockRevenueCatService) {
                              service.mockPurchaseYearly();
                            }
                          },
                          child: const Text('Yearly Premium - ₹1,999'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (service is MockRevenueCatService) {
                              service.mockPurchaseLifetime();
                            }
                          },
                          child: const Text('Lifetime Premium - ₹4,999'),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            service.restorePurchases();
                          },
                          child: const Text('Restore Purchases'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple mock without RevenueCat dependencies
class MockRevenueCatService extends RevenueCatService {
  bool _isPremium = false;
  SubscriptionType _activeSubscription = SubscriptionType.none;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _failNextPurchase = false;
  bool _hasPreviousPurchase = false;
  SubscriptionType _previousPurchaseType = SubscriptionType.none;
  DateTime? _expiryDate;
  PurchaseStatus _purchaseStatus = PurchaseStatus.notPurchased;

  // Override getters
  @override
  bool get isPremium => _isPremium;

  @override
  SubscriptionType get activeSubscription => _activeSubscription;

  @override
  DateTime? get expiryDate => _expiryDate;

  @override
  String get errorMessage => _errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  PurchaseStatus get purchaseStatus => _purchaseStatus;

  // Mock purchase methods
  Future<void> mockPurchaseMonthly() async {
    await _mockPurchase(SubscriptionType.monthly);
  }

  Future<void> mockPurchaseYearly() async {
    await _mockPurchase(SubscriptionType.yearly);
  }

  Future<void> mockPurchaseLifetime() async {
    await _mockPurchase(SubscriptionType.lifetime);
  }

  Future<void> _mockPurchase(SubscriptionType type) async {
    _isLoading = true;
    _errorMessage = '';
    _purchaseStatus = PurchaseStatus.pending;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_failNextPurchase) {
      _failNextPurchase = false; // Reset for next attempt
      _isLoading = false;
      _errorMessage = 'Network error occurred';
      _purchaseStatus = PurchaseStatus.error;
      notifyListeners();
      return;
    }

    _isPremium = true;
    _activeSubscription = type;
    _purchaseStatus = PurchaseStatus.purchased;

    switch (type) {
      case SubscriptionType.monthly:
        _expiryDate = DateTime.now().add(const Duration(days: 30));
        break;
      case SubscriptionType.yearly:
        _expiryDate = DateTime.now().add(const Duration(days: 365));
        break;
      case SubscriptionType.lifetime:
        _expiryDate = null; // Lifetime has no expiry
        break;
      default:
        break;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Setup test scenarios
  void setupNetworkFailure() {
    _failNextPurchase = true;
  }

  void setupPreviousPurchase(SubscriptionType type) {
    _hasPreviousPurchase = true;
    _previousPurchaseType = type;
  }

  @override
  Future<bool> restorePurchases() async {
    _isLoading = true;
    _errorMessage = '';
    _purchaseStatus = PurchaseStatus.pending;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_hasPreviousPurchase) {
      _isLoading = false;
      _purchaseStatus = PurchaseStatus.notPurchased;
      notifyListeners();
      return false;
    }

    _isPremium = true;
    _activeSubscription = _previousPurchaseType;
    _purchaseStatus = PurchaseStatus.restored;

    switch (_previousPurchaseType) {
      case SubscriptionType.monthly:
        _expiryDate = DateTime.now().add(const Duration(days: 30));
        break;
      case SubscriptionType.yearly:
        _expiryDate = DateTime.now().add(const Duration(days: 365));
        break;
      case SubscriptionType.lifetime:
        _expiryDate = null;
        break;
      default:
        _isPremium = false;
        _purchaseStatus = PurchaseStatus.notPurchased;
        break;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> verifyPremiumEntitlements() async {
    // Simply return the current premium status
    return _isPremium;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockRevenueCatService mockService;

  group('Subscription Flow Tests', () {
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      // Create a fresh mock service
      mockService = MockRevenueCatService();
    });

    testWidgets('Purchase monthly subscription and verify activation',
        (WidgetTester tester) async {
      // Launch test app with mock service
      await tester.pumpWidget(SubscriptionTestApp(mockService: mockService));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Not Premium'), findsOneWidget);
      expect(mockService.isPremium, isFalse);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.notPurchased));

      // Purchase monthly subscription
      await tester.tap(find.text('Monthly Premium - ₹299'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(mockService.isLoading, isTrue);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.pending));

      // Wait for purchase to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify premium is activated
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Type: monthly'), findsOneWidget);
      expect(mockService.isPremium, isTrue);
      expect(mockService.activeSubscription, equals(SubscriptionType.monthly));
      expect(mockService.purchaseStatus, equals(PurchaseStatus.purchased));
      expect(mockService.expiryDate, isNotNull);
    });

    testWidgets('Purchase yearly subscription and verify activation',
        (WidgetTester tester) async {
      // Launch test app with mock service
      await tester.pumpWidget(SubscriptionTestApp(mockService: mockService));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Not Premium'), findsOneWidget);

      // Purchase yearly subscription
      await tester.tap(find.text('Yearly Premium - ₹1,999'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.pending));

      // Wait for purchase to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify premium is activated
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Type: yearly'), findsOneWidget);
      expect(mockService.isPremium, isTrue);
      expect(mockService.activeSubscription, equals(SubscriptionType.yearly));
      expect(mockService.purchaseStatus, equals(PurchaseStatus.purchased));
    });

    testWidgets('Purchase lifetime subscription and verify activation',
        (WidgetTester tester) async {
      // Launch test app with mock service
      await tester.pumpWidget(SubscriptionTestApp(mockService: mockService));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Not Premium'), findsOneWidget);

      // Purchase lifetime subscription
      await tester.tap(find.text('Lifetime Premium - ₹4,999'));
      await tester.pump();

      // Wait for purchase to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify premium is activated
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Type: lifetime'), findsOneWidget);
      expect(mockService.isPremium, isTrue);
      expect(mockService.activeSubscription, equals(SubscriptionType.lifetime));
      expect(mockService.expiryDate, isNull);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.purchased));
    });

    testWidgets('Restore previous purchases', (WidgetTester tester) async {
      // Setup previous purchase
      mockService.setupPreviousPurchase(SubscriptionType.yearly);

      // Launch test app with mock service
      await tester.pumpWidget(SubscriptionTestApp(mockService: mockService));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Not Premium'), findsOneWidget);

      // Tap restore purchases button
      await tester.tap(find.text('Restore Purchases'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(mockService.isLoading, isTrue);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.pending));

      // Wait for restore to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify premium is activated
      expect(find.text('Premium Active'), findsOneWidget);
      expect(find.text('Type: yearly'), findsOneWidget);
      expect(mockService.isPremium, isTrue);
      expect(mockService.activeSubscription, equals(SubscriptionType.yearly));
      expect(mockService.purchaseStatus, equals(PurchaseStatus.restored));
    });

    testWidgets('Handle network failure during purchase',
        (WidgetTester tester) async {
      // Setup network failure
      mockService.setupNetworkFailure();

      // Launch test app with mock service
      await tester.pumpWidget(SubscriptionTestApp(mockService: mockService));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Not Premium'), findsOneWidget);

      // Attempt to purchase monthly subscription
      await tester.tap(find.text('Monthly Premium - ₹299'));
      await tester.pump();

      // Wait for error to show
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify error is shown
      expect(find.text('Network error occurred'), findsOneWidget);
      expect(mockService.isPremium, isFalse);
      expect(mockService.purchaseStatus, equals(PurchaseStatus.error));
    });
  });
}
