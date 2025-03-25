import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/premium/controllers/premium_controller.dart';
import 'package:pomodoro_timemaster/screens/premium/models/pricing_plan.dart';
import 'package:pomodoro_timemaster/screens/premium/views/premium_screen_view.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/widgets/premium_plan_card.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Test widget that embeds the premium screen view for testing
class TestPremiumApp extends StatelessWidget {
  final PremiumController controller;
  final RevenueCatService revenueCatService;
  final SettingsProvider settingsProvider;
  final bool isPremium;

  const TestPremiumApp({
    Key? key,
    required this.controller,
    required this.revenueCatService,
    required this.settingsProvider,
    required this.isPremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<SettingsProvider>.value(
        value: settingsProvider,
        child: Material(
          child: PremiumScreenView(
            controller: controller,
            revenueCatService: revenueCatService,
            isPremium: isPremium,
            onClose: () {},
            onDebugPaywall: () {},
          ),
        ),
      ),
    );
  }
}

// Mock AnimationController for testing
class MockAnimationController extends AnimationController {
  int resetCallCount = 0;
  int forwardCallCount = 0;

  MockAnimationController()
      : super(
          duration: const Duration(milliseconds: 300),
          vsync: const TestVSync(),
        );

  @override
  void reset() {
    resetCallCount++;
    super.reset();
  }

  @override
  TickerFuture forward({double? from}) {
    forwardCallCount++;
    return super.forward(from: from);
  }
}

// TestVSync for the AnimationController
class TestVSync extends TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

// Mock PremiumController for testing
class MockPremiumController extends PremiumController {
  int selectPlanCallCount = 0;
  int handleSubscribeCallCount = 0;
  int restorePurchasesCallCount = 0;

  PricingPlan? lastSelectedPlan;

  MockPremiumController({
    required AnimationController animationController,
    required VoidCallback onStateChanged,
  }) : super(
          animationController: animationController,
          onStateChanged: onStateChanged,
        );

  @override
  void selectPlan(PricingPlan plan) {
    selectPlanCallCount++;
    lastSelectedPlan = plan;
    super.selectPlan(plan);
  }

  @override
  Future<void> handleSubscribe(RevenueCatService revenueCatService) async {
    handleSubscribeCallCount++;
    // No need to call super implementation which might depend on real RevenueCat
  }

  @override
  Future<void> restorePurchases(
      BuildContext context, RevenueCatService revenueCatService) async {
    restorePurchasesCallCount++;
    // No need to call super implementation which might depend on real RevenueCat
  }
}

// Mock SettingsProvider for testing
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  bool _isDarkTheme = false;

  @override
  Color get backgroundColor =>
      _isDarkTheme ? CupertinoColors.black : CupertinoColors.white;
  @override
  Color get textColor =>
      _isDarkTheme ? CupertinoColors.white : CupertinoColors.black;
  @override
  Color get listTileBackgroundColor =>
      _isDarkTheme ? Colors.grey[800]! : Colors.grey[200]!;
  @override
  Color get listTileTextColor => textColor;
  @override
  bool get isDarkTheme => _isDarkTheme;

  void setDarkTheme(bool isDark) {
    _isDarkTheme = isDark;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Mock RevenueCatService for testing
class MockRevenueCatService extends ChangeNotifier
    implements RevenueCatService {
  bool _isPremium = false;
  bool _isLoading = false;
  SubscriptionType _activeSubscription = SubscriptionType.none;
  DateTime? _expiryDate;
  Offerings? _offerings;

  // Map to store prices for products
  final Map<String, String> _productPrices = {
    'pomodoro_monthly': '2.99/month',
    'pomodoro_yearly': '19.99/year',
    'pomodoro_lifetime': '39.99',
  };

  // Control the mock behavior through these setters
  set isPremiumMock(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  set isLoadingMock(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set activeSubscriptionMock(SubscriptionType value) {
    _activeSubscription = value;
    notifyListeners();
  }

  @override
  void enableDevPremiumAccess() {
    _isPremium = true;
    notifyListeners();
  }

  @override
  String getPriceForProduct(String productId) {
    return _productPrices[productId] ?? '';
  }

  // Implement required getters
  @override
  bool get isPremium => _isPremium;

  @override
  bool get isLoading => _isLoading;

  @override
  SubscriptionType get activeSubscription => _activeSubscription;

  @override
  DateTime? get expiryDate => _expiryDate;

  @override
  Offerings? get offerings => _offerings;

  @override
  Future<void> forceReloadOfferings() async {
    // Mock implementation
    return Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Helper to create mock offering and packages
Offerings createMockOfferings() {
  final StoreProduct monthlyProduct =
      MockStoreProduct(RevenueCatProductIds.monthlyId, '2.99');
  final StoreProduct yearlyProduct =
      MockStoreProduct(RevenueCatProductIds.yearlyId, '19.99');
  final StoreProduct lifetimeProduct =
      MockStoreProduct(RevenueCatProductIds.lifetimeId, '39.99');

  final Package monthlyPackage = MockPackage('monthly', monthlyProduct);
  final Package yearlyPackage = MockPackage('yearly', yearlyProduct);
  final Package lifetimePackage = MockPackage('lifetime', lifetimeProduct);

  final Offering currentOffering = MockOffering(
      'standard', [monthlyPackage, yearlyPackage, lifetimePackage]);

  return MockOfferings({
    'standard': currentOffering,
  }, currentOffering);
}

// Mock StoreProduct for testing
class MockStoreProduct implements StoreProduct {
  final String _identifier;
  final String _priceString;

  MockStoreProduct(this._identifier, this._priceString);

  @override
  String get identifier => _identifier;

  @override
  String get priceString => _priceString;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Mock Package for testing
class MockPackage implements Package {
  final String _identifier;
  final StoreProduct _storeProduct;

  MockPackage(this._identifier, this._storeProduct);

  @override
  String get identifier => _identifier;

  @override
  StoreProduct get storeProduct => _storeProduct;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Mock Offering for testing
class MockOffering implements Offering {
  final String _identifier;
  final List<Package> _availablePackages;

  MockOffering(this._identifier, this._availablePackages);

  @override
  String get identifier => _identifier;

  @override
  List<Package> get availablePackages => _availablePackages;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Mock Offerings for testing
class MockOfferings implements Offerings {
  final Map<String, Offering> _all;
  final Offering? _current;

  MockOfferings(this._all, this._current);

  @override
  Map<String, Offering> get all => _all;

  @override
  Offering? get current => _current;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

// Main testing class
void main() {
  group('PremiumScreenView', () {
    late MockAnimationController animationController;
    late MockPremiumController premiumController;
    late MockRevenueCatService revenueCatService;
    late MockSettingsProvider settingsProvider;

    setUp(() {
      animationController = MockAnimationController();
      premiumController = MockPremiumController(
        animationController: animationController,
        onStateChanged: () {},
      );
      revenueCatService = MockRevenueCatService();
      settingsProvider = MockSettingsProvider();
    });

    testWidgets('PremiumScreenView with premium active shows premium content',
        (WidgetTester tester) async {
      // Set premium status
      revenueCatService.enableDevPremiumAccess();
      revenueCatService._activeSubscription = SubscriptionType.yearly;
      revenueCatService._expiryDate =
          DateTime.now().add(const Duration(days: 365));

      // Build widget
      await tester.pumpWidget(TestPremiumApp(
        controller: premiumController,
        revenueCatService: revenueCatService,
        settingsProvider: settingsProvider,
        isPremium: true,
      ));
      await tester.pumpAndSettle();

      // Verify premium content is shown
      expect(find.text('Premium Active'), findsOneWidget);

      // Verify checkmark icon is shown
      expect(find.byIcon(CupertinoIcons.checkmark_seal_fill), findsOneWidget);

      // Verify subscription type is displayed
      expect(find.textContaining('Subscription Type:'), findsOneWidget);

      // Verify expiry date is displayed - we use textContaining since the actual date will vary
      expect(find.textContaining('Expires:'), findsOneWidget);

      // Verify restore button
      expect(find.text('Restore Purchases'), findsOneWidget);

      // Verify debug button
      expect(find.text('Debug Paywall'), findsOneWidget);
    });
  });
}
