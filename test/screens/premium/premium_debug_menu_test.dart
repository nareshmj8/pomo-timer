import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/screens/premium/controllers/premium_controller.dart';
import 'package:pomodoro_timemaster/screens/premium/widgets/premium_debug_menu.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

// Generate mocks
@GenerateMocks([RevenueCatService, PremiumController])
import 'premium_debug_menu_test.mocks.dart';

void main() {
  late MockRevenueCatService mockRevenueCatService;
  late MockPremiumController mockPremiumController;

  setUp(() {
    mockRevenueCatService = MockRevenueCatService();
    mockPremiumController = MockPremiumController();

    // Set up default stubs to avoid MissingStubError
    when(mockRevenueCatService.activeSubscription)
        .thenReturn(SubscriptionType.none);
    when(mockRevenueCatService.expiryDate).thenReturn(null);
  });

  // Create a wrapper with navigator for testing dialogs
  Widget createAppWithNavigator() {
    return CupertinoApp(
      home: Navigator(
        onGenerateRoute: (settings) {
          return CupertinoPageRoute(
            builder: (context) => const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Test'),
              ),
              child: Center(
                child: Text('Test Screen'),
              ),
            ),
          );
        },
      ),
    );
  }

  group('Premium Debug Menu', () {
    testWidgets('shows all debug options', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createAppWithNavigator());

      // Act
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      await tester
          .pumpAndSettle(); // Use pumpAndSettle to finish all animations

      // Assert - verify all options are shown
      expect(find.text('Premium Debug Menu'), findsOneWidget);
      expect(find.text('Select a debug action:'), findsOneWidget);
      expect(find.text('Run Automated Tests'), findsOneWidget);
      expect(find.text('Open Test Suite'), findsOneWidget);
      expect(find.text('Debug Paywall Configuration'), findsOneWidget);
      expect(find.text('Force Reload Offerings'), findsOneWidget);
      expect(find.text('Verify Premium Status'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping "Cancel" dismisses the dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createAppWithNavigator());

      // Act - show menu
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      await tester.pumpAndSettle();

      // Assert - dialog is shown
      expect(find.text('Premium Debug Menu'), findsOneWidget);

      // Act - tap "Cancel"
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog is dismissed
      expect(find.text('Premium Debug Menu'), findsNothing);
    });

    testWidgets('calls service methods when buttons are tapped',
        (WidgetTester tester) async {
      // Set up mocks to return immediately
      when(mockRevenueCatService.debugPaywallConfiguration())
          .thenAnswer((_) async => <String, dynamic>{'status': 'success'});
      when(mockRevenueCatService.forceReloadOfferings())
          .thenAnswer((_) async => {});
      when(mockRevenueCatService.verifyPremiumEntitlements())
          .thenAnswer((_) async => false);

      // Arrange
      await tester.pumpWidget(createAppWithNavigator());

      // Debug Paywall
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      // Use pump instead of pumpAndSettle to avoid timeouts
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Debug Paywall Configuration'));

      // Force Reload Offerings - create a fresh dialog each time
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Force Reload Offerings'));

      // Verify Premium Status
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Verify Premium Status'));

      // Restore Purchases
      showPremiumDebugMenu(
        tester.element(find.text('Test Screen')),
        mockRevenueCatService,
        mockPremiumController,
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Restore Purchases'));

      // Give time for callbacks to be triggered
      await tester.pump(const Duration(milliseconds: 500));

      // Verify all methods were called
      verify(mockRevenueCatService.debugPaywallConfiguration()).called(1);
      verify(mockRevenueCatService.forceReloadOfferings()).called(1);
      verify(mockRevenueCatService.verifyPremiumEntitlements()).called(1);
      verify(mockPremiumController.restorePurchases(any, mockRevenueCatService))
          .called(1);
    });
  });
}
