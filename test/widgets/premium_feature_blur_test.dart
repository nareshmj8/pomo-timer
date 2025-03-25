import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/widgets/premium_feature_blur.dart';

class MockRevenueCatService extends ChangeNotifier
    with Mock
    implements RevenueCatService {
  bool _isPremium = false;

  @override
  bool get isPremium => _isPremium;

  void setIsPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }
}

void main() {
  late MockRevenueCatService mockRevenueCatService;

  setUp(() {
    mockRevenueCatService = MockRevenueCatService();
  });

  Widget buildTestWidget({
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    mockRevenueCatService.setIsPremium(isPremium);

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<RevenueCatService>.value(
          value: mockRevenueCatService,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: PremiumFeatureBlur(
                featureName: 'Statistics',
                onTap: onTap,
                child: Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text('Premium Content'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('PremiumFeatureBlur - Display Tests', () {
    testWidgets('should show child content without blur when user is premium',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        isPremium: true,
        onTap: () {},
      ));

      // Child content should be visible
      expect(find.text('Premium Content'), findsOneWidget);

      // Blur effect should not be applied
      expect(find.byType(ImageFiltered), findsNothing);

      // Upgrade text should not be visible
      expect(find.text('Premium Feature'), findsNothing);
    });

    testWidgets('should apply blur effect when user is not premium',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        isPremium: false,
        onTap: () {},
      ));

      // Child content should still be in the widget tree
      expect(find.text('Premium Content'), findsOneWidget);

      // Blur effect should be applied
      expect(find.byType(ImageFiltered), findsOneWidget);

      // Premium feature text should be visible
      expect(find.text('Premium Feature'), findsOneWidget);
    });
  });

  group('PremiumFeatureBlur - Interaction Tests', () {
    testWidgets('should call onTap when premium button is tapped',
        (WidgetTester tester) async {
      bool tapPressed = false;

      await tester.pumpWidget(buildTestWidget(
        isPremium: false,
        onTap: () {
          tapPressed = true;
        },
      ));

      // Find and tap the InkWell that wraps the blur overlay
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsOneWidget);
      await tester.tap(inkWell);

      // Verify callback was triggered
      expect(tapPressed, isTrue);
    });

    testWidgets('should not show InkWell when user is premium',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        isPremium: true,
        onTap: () {},
      ));

      // The upgrade gesture detector should not be in the widget tree
      expect(
          find.descendant(
            of: find.byType(PremiumFeatureBlur),
            matching: find.byType(InkWell),
          ),
          findsNothing);
    });
  });

  group('PremiumFeatureBlur - State Changes', () {
    testWidgets('should update UI when premium status changes',
        (WidgetTester tester) async {
      // Start with non-premium
      await tester.pumpWidget(buildTestWidget(
        isPremium: false,
        onTap: () {},
      ));

      // Verify blur is applied
      expect(find.byType(ImageFiltered), findsOneWidget);
      expect(find.text('Premium Feature'), findsOneWidget);

      // Change to premium
      mockRevenueCatService.setIsPremium(true);

      // Rebuild widget to reflect changes
      await tester.pump();

      // Verify blur is removed
      expect(find.byType(ImageFiltered), findsNothing);
      expect(find.text('Premium Feature'), findsNothing);
    });
  });

  group('PremiumFeatureBlur - Edge Cases', () {
    testWidgets('should handle empty or small child gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RevenueCatService>.value(
              value: mockRevenueCatService,
              child: Center(
                child: PremiumFeatureBlur(
                  featureName: 'Small Feature',
                  onTap: () {},
                  child: const SizedBox(width: 5, height: 5),
                ),
              ),
            ),
          ),
        ),
      );

      // Widget should render without errors
      expect(find.byType(PremiumFeatureBlur), findsOneWidget);
    });
  });
}
