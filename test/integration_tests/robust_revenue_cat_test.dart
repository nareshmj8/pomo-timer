import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_notification_service.dart';
import '../mocks/mock_revenue_cat_service.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final MockRevenueCatService revenueCatService;
  final SharedPreferences prefs;

  const TestApp({
    Key? key,
    required this.child,
    required this.revenueCatService,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockRevenueCatService>.value(
          value: revenueCatService,
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

class PremiumTestWidget extends StatelessWidget {
  const PremiumTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final revenueCatService = Provider.of<MockRevenueCatService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Features Test')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Premium Status'),
            subtitle: Text(revenueCatService.isPremium.toString()),
            trailing: Switch(
              value: revenueCatService.isPremium,
              onChanged: (_) {
                // Toggle premium status for testing
                if (revenueCatService.isPremium) {
                  revenueCatService.disableDevPremiumAccess();
                } else {
                  revenueCatService.enableDevPremiumAccess();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Active Subscription'),
            subtitle: Text(revenueCatService.activeSubscription.toString()),
          ),
          ListTile(
            title: const Text('Purchase Status'),
            subtitle: Text(revenueCatService.purchaseStatus.toString()),
          ),
          ListTile(
            title: const Text('Expiry Date'),
            subtitle: Text(
                revenueCatService.expiryDate?.toString() ?? 'No expiry date'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () async {
              // Simulate monthly subscription purchase
              await revenueCatService.purchaseProduct('monthly_subscription');
            },
            child: const Text('Purchase Monthly Subscription'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulate yearly subscription purchase
              await revenueCatService.purchaseProduct('yearly_subscription');
            },
            child: const Text('Purchase Yearly Subscription'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulate lifetime subscription purchase
              await revenueCatService.purchaseProduct('lifetime_subscription');
            },
            child: const Text('Purchase Lifetime'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulate restore purchase
              await revenueCatService.restorePurchases();
            },
            child: const Text('Restore Purchases'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () async {
              // Toggle offerings availability
              revenueCatService.shouldFailPurchase =
                  !revenueCatService.shouldFailPurchase;
              if (revenueCatService.shouldFailPurchase) {
                revenueCatService.purchaseErrorMessage =
                    'Purchase failed: Test error';
              }
            },
            child: const Text('Toggle Purchase Failure'),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRevenueCatService revenueCatService;
  late MockNotificationService notificationService;
  late SharedPreferences prefs;

  setUp(() async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Initialize mocks
    revenueCatService = MockRevenueCatService();
    await revenueCatService.initialize();

    notificationService = MockNotificationService();
    await notificationService.initialize();

    // Initialize service locator with mocks
    final serviceLocator = ServiceLocator();
    serviceLocator.registerNotificationService(notificationService);
    serviceLocator.registerRevenueCatService(revenueCatService);
  });

  tearDown(() {
    // Reset service locator
    final serviceLocator = ServiceLocator();
    serviceLocator.reset();
  });

  group('Premium Status Tests', () {
    testWidgets('User should not be premium by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Verify user is not premium by default
      expect(revenueCatService.isPremium, isFalse);
      expect(
          revenueCatService.activeSubscription, equals(SubscriptionType.none));
      expect(find.text('false'), findsWidgets);
      expect(find.text('SubscriptionType.none'), findsOneWidget);
    });

    testWidgets('User can enable premium access in dev mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Toggle premium status using the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Verify user is now premium
      expect(revenueCatService.isPremium, isTrue);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      expect(find.text('true'), findsWidgets);
      expect(find.text('SubscriptionType.yearly'), findsOneWidget);
    });
  });

  group('Subscription Purchase Tests', () {
    testWidgets('User can purchase monthly subscription',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Verify user is not premium initially
      expect(revenueCatService.isPremium, isFalse);

      // Purchase monthly subscription
      await tester.tap(find.text('Purchase Monthly Subscription'));
      await tester.pumpAndSettle();

      // Verify user is now premium with monthly subscription
      expect(revenueCatService.isPremium, isTrue);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.monthly));
      expect(
          revenueCatService.purchaseStatus, equals(PurchaseStatus.purchased));
      expect(revenueCatService.expiryDate, isNotNull);
    });

    testWidgets('User can purchase yearly subscription',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Purchase yearly subscription
      await tester.tap(find.text('Purchase Yearly Subscription'));
      await tester.pumpAndSettle();

      // Verify user is now premium with yearly subscription
      expect(revenueCatService.isPremium, isTrue);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      expect(
          revenueCatService.purchaseStatus, equals(PurchaseStatus.purchased));
      expect(revenueCatService.expiryDate, isNotNull);
    });

    testWidgets('User can purchase lifetime subscription',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Purchase lifetime subscription
      await tester.tap(find.text('Purchase Lifetime'));
      await tester.pumpAndSettle();

      // Verify user is now premium with lifetime subscription
      expect(revenueCatService.isPremium, isTrue);
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.lifetime));
      expect(
          revenueCatService.purchaseStatus, equals(PurchaseStatus.purchased));
      expect(revenueCatService.expiryDate, isNull); // Lifetime has no expiry
    });
  });

  group('Purchase Error Handling Tests', () {
    testWidgets('Should handle purchase failures', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Enable purchase failure mode
      await tester.tap(find.text('Toggle Purchase Failure'));
      await tester.pumpAndSettle();

      // Attempt to purchase
      await tester.tap(find.text('Purchase Monthly Subscription'));
      await tester.pumpAndSettle();

      // Verify purchase failed
      expect(revenueCatService.isPremium, isFalse);
      expect(revenueCatService.purchaseStatus, equals(PurchaseStatus.error));
      expect(revenueCatService.errorMessage, contains('Purchase failed'));
    });

    testWidgets('Restore purchases should work correctly',
        (WidgetTester tester) async {
      // Configure the mock to successfully restore a subscription
      revenueCatService.restorePurchasesResult = true;

      await tester.pumpWidget(
        TestApp(
          revenueCatService: revenueCatService,
          prefs: prefs,
          child: const PremiumTestWidget(),
        ),
      );

      // Initially not premium
      expect(revenueCatService.isPremium, isFalse);

      // Restore purchases
      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      // Verify purchase was restored
      expect(revenueCatService.isPremium, isTrue);
      expect(revenueCatService.purchaseStatus, equals(PurchaseStatus.restored));
      expect(revenueCatService.activeSubscription,
          equals(SubscriptionType.yearly));
      expect(revenueCatService.restorePurchasesCalled, isTrue);
    });
  });
}
