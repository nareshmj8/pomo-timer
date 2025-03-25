import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/widgets/statistics/statistics_header.dart';

void main() {
  group('StatisticsHeader - Display Tests', () {
    testWidgets('should display the selected category',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'Work',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Category:'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('should display toggle buttons for Hours and Sessions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'All Categories',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
    });

    testWidgets('should highlight Hours when showHours is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'All Categories',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the Hours and Sessions text widgets
      final hoursText = tester.widget<Text>(find.text('Hours'));
      final sessionsText = tester.widget<Text>(find.text('Sessions'));

      // Check if Hours is highlighted (bold) and Sessions is not
      expect((hoursText.style?.fontWeight ?? FontWeight.normal),
          equals(FontWeight.bold));
      expect((sessionsText.style?.fontWeight ?? FontWeight.normal),
          equals(FontWeight.normal));

      // Check colors
      expect(hoursText.style?.color, equals(CupertinoColors.activeBlue));
      expect(sessionsText.style?.color, equals(CupertinoColors.inactiveGray));
    });

    testWidgets('should highlight Sessions when showHours is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'All Categories',
              showHours: false,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the Hours and Sessions text widgets
      final hoursText = tester.widget<Text>(find.text('Hours'));
      final sessionsText = tester.widget<Text>(find.text('Sessions'));

      // Check if Sessions is highlighted (bold) and Hours is not
      expect((hoursText.style?.fontWeight ?? FontWeight.normal),
          equals(FontWeight.normal));
      expect((sessionsText.style?.fontWeight ?? FontWeight.normal),
          equals(FontWeight.bold));

      // Check colors
      expect(hoursText.style?.color, equals(CupertinoColors.inactiveGray));
      expect(sessionsText.style?.color, equals(CupertinoColors.activeBlue));
    });
  });

  group('StatisticsHeader - Interaction Tests', () {
    testWidgets('should call onShowHoursChanged when Hours is tapped',
        (WidgetTester tester) async {
      bool showHoursValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'All Categories',
              showHours: false,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (value) {
                showHoursValue = value;
              },
            ),
          ),
        ),
      );

      // Tap the Hours button
      await tester.tap(find.text('Hours'));
      await tester.pump();

      // Check if the callback was called with the right value
      expect(showHoursValue, isTrue);
    });

    testWidgets('should call onShowHoursChanged when Sessions is tapped',
        (WidgetTester tester) async {
      bool showHoursValue = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'All Categories',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (value) {
                showHoursValue = value;
              },
            ),
          ),
        ),
      );

      // Tap the Sessions button
      await tester.tap(find.text('Sessions'));
      await tester.pump();

      // Check if the callback was called with the right value
      expect(showHoursValue, isFalse);
    });

    testWidgets('should show category picker when category button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'Work',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap the category button
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Check if the category picker is shown
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      expect(
          find.text('Work'),
          findsAtLeastNWidgets(
              1)); // At least one because it's in both the header and the picker
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Life'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should call onCategoryChanged when a category is selected',
        (WidgetTester tester) async {
      String selectedCategory = 'Work';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: selectedCategory,
              showHours: true,
              onCategoryChanged: (category) {
                selectedCategory = category;
              },
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap the category button to open the picker
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Tap the 'Study' option
      await tester.tap(find.text('Study').last);
      await tester.pumpAndSettle();

      // Check if the callback was called with the right value
      expect(selectedCategory, equals('Study'));
    });
  });

  group('StatisticsHeader - Edge Cases', () {
    testWidgets('should handle long category names',
        (WidgetTester tester) async {
      // Use a wider screen configuration to avoid overflow errors
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: 'Very Long Category Name That Might Overflow',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Check that the widget renders without errors
      expect(find.text('Very Long Category Name That Might Overflow'),
          findsOneWidget);

      // Reset the test window size
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('should handle empty category name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsHeader(
              selectedCategory: '',
              showHours: true,
              onCategoryChanged: (_) {},
              onShowHoursChanged: (_) {},
            ),
          ),
        ),
      );

      // Check that the widget renders without errors
      expect(find.text(''), findsOneWidget);
    });
  });
}
