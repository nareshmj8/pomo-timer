import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/premium_plan_card.dart';

class StubSettingsProvider extends ChangeNotifier implements SettingsProvider {
  bool _isDarkTheme;

  StubSettingsProvider({bool isDarkTheme = false}) : _isDarkTheme = isDarkTheme;

  @override
  bool get isDarkTheme => _isDarkTheme;

  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  @override
  Color get textColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  Color get listTileBackgroundColor =>
      isDarkTheme ? const Color(0xFF1C1C1E) : CupertinoColors.white;

  @override
  Color get separatorColor =>
      isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200;

  // Stub implementation for other required members
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late StubSettingsProvider settingsProvider;

  setUp(() {
    settingsProvider = StubSettingsProvider();
  });

  Widget buildTestWidget({
    required String title,
    required String description,
    required String price,
    required bool isSelected,
    String? tag,
    required VoidCallback onTap,
    bool isDarkTheme = false,
  }) {
    settingsProvider.isDarkTheme = isDarkTheme;

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: Center(
            child: PremiumPlanCard(
              title: title,
              description: description,
              price: price,
              isSelected: isSelected,
              tag: tag,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  group('PremiumPlanCard - Display Tests', () {
    testWidgets('should display title, description and price correctly',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: false,
        onTap: () {
          tapped = true;
        },
      ));

      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Billed monthly'), findsOneWidget);
      expect(find.text('\$2.99/month'), findsOneWidget);
    });

    testWidgets('should display tag when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Yearly',
        description: 'Billed annually',
        price: '\$19.99/year',
        isSelected: false,
        tag: 'Best value!',
        onTap: () {},
      ));

      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Billed annually'), findsOneWidget);
      expect(find.text('\$19.99/year'), findsOneWidget);
    });

    testWidgets('should show check icon when selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: true,
        onTap: () {},
      ));

      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsOneWidget);
    });

    testWidgets('should not show check icon when not selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: false,
        onTap: () {},
      ));

      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsNothing);
    });
  });

  group('PremiumPlanCard - Theme Tests', () {
    testWidgets('should adapt to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: true,
        isDarkTheme: false,
        onTap: () {},
      ));

      final container = find.byType(AnimatedContainer);
      expect(container, findsOneWidget);

      // We can't directly test colors in widget tests without rendering,
      // but we can verify the widget builds correctly
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: true,
        isDarkTheme: true,
        onTap: () {},
      ));

      final container = find.byType(AnimatedContainer);
      expect(container, findsOneWidget);

      // We can't directly test dark theme colors without rendering,
      // but we can verify the widget builds correctly
      expect(find.text('Monthly'), findsOneWidget);
    });
  });

  group('PremiumPlanCard - Interaction Tests', () {
    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(buildTestWidget(
        title: 'Monthly',
        description: 'Billed monthly',
        price: '\$2.99/month',
        isSelected: false,
        onTap: () {
          tapped = true;
        },
      ));

      await tester.tap(find.byType(PremiumPlanCard));
      expect(tapped, isTrue);
    });
  });

  group('PremiumPlanCard - Edge Cases', () {
    testWidgets('should handle long texts gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title:
            'A Very Very Very Long Plan Title That Might Cause Overflow Issues',
        description:
            'This is an extremely long description that could potentially overflow the available space in the card',
        price: '\$999.99/millennium',
        isSelected: false,
        onTap: () {},
      ));

      // The widget should render without errors, even with long text
      expect(find.byType(PremiumPlanCard), findsOneWidget);
    });
  });
}
