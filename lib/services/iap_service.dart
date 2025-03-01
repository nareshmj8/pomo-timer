import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAPService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isPremium = false;

  // Product IDs
  static const String premiumWeekly = 'premium_weekly';
  static const String premiumMonthly = 'premium_monthly';
  static const String premiumYearly = 'premium_yearly';
  static const String removeAds = 'remove_ads';

  final Set<String> _productIds = {
    premiumWeekly,
    premiumMonthly,
    premiumYearly,
    removeAds,
  };

  bool get isAvailable => _isAvailable;
  bool get isPremium => _isPremium;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;

  IAPService() {
    _init();
  }

  Future<void> _init() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      return;
    }

    // Load previous purchases
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;

    // Get product details
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;

    // Listen to purchases
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase Error: $error'),
    );
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetails) async {
    for (var purchase in purchaseDetails) {
      if (purchase.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchase.status == PurchaseStatus.error) {
        // Show error UI
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Grant entitlement
        await _verifyPurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // Here you would typically verify the purchase with your backend
    // For now, we'll just store it locally
    final prefs = await SharedPreferences.getInstance();

    if (_productIds.contains(purchase.productID)) {
      _isPremium = true;
      await prefs.setBool('isPremium', true);

      // Store purchase expiry date for subscription products
      if (purchase.productID != removeAds) {
        final expiryDate = DateTime.now().add(
          purchase.productID == premiumWeekly
              ? const Duration(days: 7)
              : purchase.productID == premiumMonthly
                  ? const Duration(days: 30)
                  : const Duration(days: 365),
        );
        await prefs.setString('premiumExpiry', expiryDate.toIso8601String());
      }
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    if (product.id == removeAds) {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      return _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // Premium features check methods
  bool canAccessDetailedStats() => _isPremium;
  bool canAccessCustomThemes() => _isPremium;
  bool canExportData() => _isPremium;
  bool hasAdsRemoved() => _isPremium;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
