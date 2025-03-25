import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';

/// A mock implementation of RevenueCatService for testing.
class MockRevenueCatService extends RevenueCatService {
  bool _isInitialized = false;
  int initializeCallCount = 0;
  int forceReloadOfferingsCallCount = 0;

  // Purchase tracking
  final List<String> purchasedProductIds = [];
  final List<Package> purchasedPackages = [];
  bool restorePurchasesCalled = false;
  int restorePurchasesCallCount = 0;
  bool restorePurchasesResult = false;

  // UI tracking
  bool showSubscriptionPlansCalled = false;
  bool showPremiumBenefitsCalled = false;
  bool openManageSubscriptionsPageCalled = false;

  // State variables
  Offerings? _offerings;
  CustomerInfo? _customerInfo;
  PurchaseStatus _purchaseStatus = PurchaseStatus.notPurchased;
  SubscriptionType _activeSubscription = SubscriptionType.none;
  String _errorMessage = '';
  bool _isLoading = false;
  DateTime? _expiryDate;
  bool _devPremiumOverride = false;

  // Value overrides for testing scenarios
  bool shouldFailInitialization = false;
  bool shouldFailPurchase = false;
  String? purchaseErrorMessage;
  bool shouldFailRestore = false;

  @override
  Offerings? get offerings => _offerings;

  @override
  CustomerInfo? get customerInfo => _customerInfo;

  @override
  PurchaseStatus get purchaseStatus => _purchaseStatus;

  @override
  SubscriptionType get activeSubscription => _activeSubscription;

  @override
  String get errorMessage => _errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  DateTime? get expiryDate => _expiryDate;

  @override
  bool get isPremium =>
      _devPremiumOverride || _activeSubscription != SubscriptionType.none;

  @override
  Future<void> initialize() async {
    initializeCallCount++;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate network delay

    if (shouldFailInitialization) {
      _errorMessage = 'Failed to initialize RevenueCat';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isInitialized = true;

    // Create mock offerings if not already set
    if (_offerings == null) {
      _createMockOfferings();
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> forceReloadOfferings() async {
    forceReloadOfferingsCallCount++;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate network delay
    _createMockOfferings();

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> purchaseProduct(String productId) async {
    if (!_isInitialized) {
      await initialize();
    }

    _purchaseStatus = PurchaseStatus.pending;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate purchase delay

    if (shouldFailPurchase) {
      _purchaseStatus = PurchaseStatus.error;
      _errorMessage = purchaseErrorMessage ?? 'Purchase failed';
      _isLoading = false;
      notifyListeners();
      return;
    }

    purchasedProductIds.add(productId);

    // Update subscription based on product ID
    if (productId.contains('monthly')) {
      _activeSubscription = SubscriptionType.monthly;
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    } else if (productId.contains('yearly')) {
      _activeSubscription = SubscriptionType.yearly;
      _expiryDate = DateTime.now().add(const Duration(days: 365));
    } else if (productId.contains('lifetime')) {
      _activeSubscription = SubscriptionType.lifetime;
      _expiryDate = null;
    }

    _purchaseStatus = PurchaseStatus.purchased;
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isInitialized) {
      await initialize();
    }

    _purchaseStatus = PurchaseStatus.pending;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate purchase delay

    if (shouldFailPurchase) {
      _purchaseStatus = PurchaseStatus.error;
      _errorMessage = purchaseErrorMessage ?? 'Purchase failed';
      _isLoading = false;
      notifyListeners();
      return null;
    }

    purchasedPackages.add(package);
    purchasedProductIds.add(package.storeProduct.identifier);

    // Update subscription based on product ID
    String productId = package.storeProduct.identifier;
    if (productId.contains('monthly')) {
      _activeSubscription = SubscriptionType.monthly;
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    } else if (productId.contains('yearly')) {
      _activeSubscription = SubscriptionType.yearly;
      _expiryDate = DateTime.now().add(const Duration(days: 365));
    } else if (productId.contains('lifetime')) {
      _activeSubscription = SubscriptionType.lifetime;
      _expiryDate = null;
    }

    _purchaseStatus = PurchaseStatus.purchased;
    _isLoading = false;
    notifyListeners();

    return _customerInfo;
  }

  @override
  Future<bool> restorePurchases() async {
    restorePurchasesCalled = true;
    restorePurchasesCallCount++;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay

    if (shouldFailRestore) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Set a default restoration result if not already set
    if (restorePurchasesResult) {
      // Simulate a successful restore of yearly subscription
      _activeSubscription = SubscriptionType.yearly;
      _expiryDate = DateTime.now().add(const Duration(days: 365));
      _purchaseStatus = PurchaseStatus.restored;
    }

    _isLoading = false;
    notifyListeners();
    return restorePurchasesResult;
  }

  @override
  Future<void> showSubscriptionPlans(BuildContext context) async {
    showSubscriptionPlansCalled = true;
    // This is a UI method, just track that it was called
  }

  @override
  Future<void> showPremiumBenefits(BuildContext context) async {
    showPremiumBenefitsCalled = true;
    // This is a UI method, just track that it was called
  }

  @override
  void enableDevPremiumAccess() {
    _devPremiumOverride = true;
    _activeSubscription = SubscriptionType.yearly;
    _expiryDate = DateTime.now().add(const Duration(days: 365));
    notifyListeners();
  }

  @override
  void disableDevPremiumAccess() {
    _devPremiumOverride = false;

    // If we have a real subscription, keep it, otherwise reset
    if (_activeSubscription == SubscriptionType.none ||
        _purchaseStatus != PurchaseStatus.purchased) {
      _activeSubscription = SubscriptionType.none;
      _expiryDate = null;
    }
    notifyListeners();
  }

  // Helper to create mock offerings
  void _createMockOfferings() {
    // Implementation would create mock offerings here
    // This would depend on the structure of your Offerings object
  }

  @override
  Future<void> openManageSubscriptionsPage() async {
    openManageSubscriptionsPageCalled = true;
    // Just track that it was called
  }

  /// Reset the mock service to its initial state
  void reset() {
    _isInitialized = false;
    initializeCallCount = 0;
    forceReloadOfferingsCallCount = 0;

    // Reset purchase tracking
    purchasedProductIds.clear();
    purchasedPackages.clear();
    restorePurchasesCalled = false;
    restorePurchasesCallCount = 0;
    restorePurchasesResult = false;

    // Reset UI tracking
    showSubscriptionPlansCalled = false;
    showPremiumBenefitsCalled = false;
    openManageSubscriptionsPageCalled = false;

    // Reset state variables
    _offerings = null;
    _customerInfo = null;
    _purchaseStatus = PurchaseStatus.notPurchased;
    _activeSubscription = SubscriptionType.none;
    _errorMessage = '';
    _isLoading = false;
    _expiryDate = null;
    _devPremiumOverride = false;

    // Reset test scenario flags
    shouldFailInitialization = false;
    shouldFailPurchase = false;
    purchaseErrorMessage = null;
    shouldFailRestore = false;
  }

  /// Configure the mock service for specific test scenarios
  void configureForTestScenario(
      {String? scenario,
      SubscriptionType? subscriptionType,
      DateTime? expiryDate,
      PurchaseStatus? status,
      bool? shouldFail}) {
    reset(); // Start fresh

    if (scenario != null) {
      // Original string-based configuration
      switch (scenario) {
        case 'premium_monthly':
          _activeSubscription = SubscriptionType.monthly;
          _expiryDate = DateTime.now().add(const Duration(days: 30));
          _purchaseStatus = PurchaseStatus.purchased;
          break;

        case 'premium_yearly':
          _activeSubscription = SubscriptionType.yearly;
          _expiryDate = DateTime.now().add(const Duration(days: 365));
          _purchaseStatus = PurchaseStatus.purchased;
          break;

        case 'premium_lifetime':
          _activeSubscription = SubscriptionType.lifetime;
          _expiryDate = null;
          _purchaseStatus = PurchaseStatus.purchased;
          break;

        case 'expired':
          _activeSubscription = SubscriptionType.none;
          _expiryDate = DateTime.now().subtract(const Duration(days: 10));
          _purchaseStatus = PurchaseStatus.expired;
          break;

        case 'not_purchased':
          _activeSubscription = SubscriptionType.none;
          _expiryDate = null;
          _purchaseStatus = PurchaseStatus.notPurchased;
          break;

        case 'purchase_error':
          shouldFailPurchase = true;
          purchaseErrorMessage = 'Test purchase error';
          break;

        case 'initialization_error':
          shouldFailInitialization = true;
          break;

        case 'restore_success':
          restorePurchasesResult = true;
          break;

        case 'restore_fail':
          shouldFailRestore = true;
          break;

        default:
          // Default case is a clean reset
          break;
      }
    } else {
      // Direct parameter-based configuration
      if (subscriptionType != null) {
        _activeSubscription = subscriptionType;
      }

      if (expiryDate != null) {
        _expiryDate = expiryDate;
      }

      if (status != null) {
        _purchaseStatus = status;
      } else if (_activeSubscription != SubscriptionType.none) {
        _purchaseStatus = PurchaseStatus.purchased;
      }

      if (shouldFail == true) {
        shouldFailPurchase = true;
        purchaseErrorMessage = 'Test purchase error';
      }
    }

    notifyListeners();
  }
}
