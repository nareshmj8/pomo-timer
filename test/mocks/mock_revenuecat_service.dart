import 'package:flutter/foundation.dart';

class MockRevenueCatService extends ChangeNotifier {
  bool _isInitialized = false;
  bool _isPremium = false;

  // Initialize mock
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  // Check if user has premium
  bool get isPremium => _isPremium;

  // Set premium status for testing
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    notifyListeners();
  }

  // Mock purchase methods
  Future<bool> purchaseMonthlySubscription() async {
    _isPremium = true;
    notifyListeners();
    return true;
  }

  Future<bool> purchaseYearlySubscription() async {
    _isPremium = true;
    notifyListeners();
    return true;
  }

  Future<bool> purchaseLifetimeSubscription() async {
    _isPremium = true;
    notifyListeners();
    return true;
  }

  // Mock restore purchases
  Future<bool> restorePurchases() async {
    return _isPremium;
  }
}
