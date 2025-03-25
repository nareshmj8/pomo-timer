import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';

// Mock BuildContext
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockBuildContext mockContext;

  setUp(() {
    mockContext = MockBuildContext();
  });

  Widget buildTestWidget({required Widget child, required Size size}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Material(child: child),
      ),
    );
  }

  group('ResponsiveUtils Screen Size Detection', () {
    testWidgets('isSmallScreen returns true for small screens',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(374, 800), // Smaller than smallScreenWidth
        child: Builder(builder: (context) {
          result = ResponsiveUtils.isSmallScreen(context);
          return const SizedBox();
        }),
      ));

      expect(result, true);
    });

    testWidgets('isSmallScreen returns false for medium screens',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(400, 800), // Larger than smallScreenWidth
        child: Builder(builder: (context) {
          result = ResponsiveUtils.isSmallScreen(context);
          return const SizedBox();
        }),
      ));

      expect(result, false);
    });

    testWidgets('isTablet returns true for tablet screens',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(768, 1024), // Equal to mediumScreenWidth
        child: Builder(builder: (context) {
          result = ResponsiveUtils.isTablet(context);
          return const SizedBox();
        }),
      ));

      expect(result, true);
    });

    testWidgets('isLargeTablet returns true for large tablet screens',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(1024, 1366), // Equal to largeScreenWidth
        child: Builder(builder: (context) {
          result = ResponsiveUtils.isLargeTablet(context);
          return const SizedBox();
        }),
      ));

      expect(result, true);
    });
  });

  group('ResponsiveUtils Padding', () {
    testWidgets('getResponsivePadding returns correct padding for tablet',
        (WidgetTester tester) async {
      EdgeInsets? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024), // Tablet size
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsivePadding(context);
          return const SizedBox();
        }),
      ));

      expect(result, const EdgeInsets.all(24.0));
    });

    testWidgets('getResponsivePadding returns correct padding for small screen',
        (WidgetTester tester) async {
      EdgeInsets? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(320, 568), // Small screen
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsivePadding(context);
          return const SizedBox();
        }),
      ));

      expect(result, const EdgeInsets.all(12.0));
    });

    testWidgets(
        'getResponsivePadding returns correct padding for medium screen',
        (WidgetTester tester) async {
      EdgeInsets? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(414, 896), // Medium phone
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsivePadding(context);
          return const SizedBox();
        }),
      ));

      expect(result, const EdgeInsets.all(16.0));
    });

    testWidgets(
        'getResponsiveHorizontalPadding returns correct padding for tablet',
        (WidgetTester tester) async {
      EdgeInsets? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024), // Tablet size
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsiveHorizontalPadding(context);
          return const SizedBox();
        }),
      ));

      expect(result, const EdgeInsets.symmetric(horizontal: 24.0));
    });
  });

  group('ResponsiveUtils Font Sizes', () {
    testWidgets(
        'getResponsiveFontSize returns correct size for each device size',
        (WidgetTester tester) async {
      double? smallResult;
      double? mediumResult;
      double? largeResult;

      // Small phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(320, 568),
        child: Builder(builder: (context) {
          smallResult = ResponsiveUtils.getResponsiveFontSize(
            context,
            small: 12,
            medium: 14,
            large: 16,
          );
          return const SizedBox();
        }),
      ));

      // Tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024),
        child: Builder(builder: (context) {
          mediumResult = ResponsiveUtils.getResponsiveFontSize(
            context,
            small: 12,
            medium: 14,
            large: 16,
          );
          return const SizedBox();
        }),
      ));

      // Large tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(1024, 1366),
        child: Builder(builder: (context) {
          largeResult = ResponsiveUtils.getResponsiveFontSize(
            context,
            small: 12,
            medium: 14,
            large: 16,
          );
          return const SizedBox();
        }),
      ));

      expect(smallResult, 12);
      expect(mediumResult, 14);
      expect(largeResult, 16);
    });
  });

  group('ResponsiveUtils Grid Count', () {
    testWidgets(
        'getResponsiveGridCount returns correct count for different devices',
        (WidgetTester tester) async {
      int? phoneResult;
      int? tabletResult;
      int? largeTabletResult;

      // Phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(414, 896),
        child: Builder(builder: (context) {
          phoneResult = ResponsiveUtils.getResponsiveGridCount(context);
          return const SizedBox();
        }),
      ));

      // Tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024),
        child: Builder(builder: (context) {
          tabletResult = ResponsiveUtils.getResponsiveGridCount(context);
          return const SizedBox();
        }),
      ));

      // Large tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(1024, 1366),
        child: Builder(builder: (context) {
          largeTabletResult = ResponsiveUtils.getResponsiveGridCount(context);
          return const SizedBox();
        }),
      ));

      expect(phoneResult, 2);
      expect(tabletResult, 3);
      expect(largeTabletResult, 4);
    });
  });

  group('ResponsiveUtils Dimensions', () {
    testWidgets('getResponsiveWidth returns correct percentage of screen width',
        (WidgetTester tester) async {
      double? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(400, 800),
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsiveWidth(context, 0.5);
          return const SizedBox();
        }),
      ));

      expect(result, 200.0); // 50% of 400
    });

    testWidgets(
        'getResponsiveHeight returns correct percentage of screen height',
        (WidgetTester tester) async {
      double? result;

      await tester.pumpWidget(buildTestWidget(
        size: const Size(400, 800),
        child: Builder(builder: (context) {
          result = ResponsiveUtils.getResponsiveHeight(context, 0.25);
          return const SizedBox();
        }),
      ));

      expect(result, 200.0); // 25% of 800
    });

    testWidgets(
        'getResponsiveIconSize returns correct size for different devices',
        (WidgetTester tester) async {
      double? smallResult;
      double? mediumResult;
      double? tabletResult;

      // Small phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(320, 568),
        child: Builder(builder: (context) {
          smallResult = ResponsiveUtils.getResponsiveIconSize(context);
          return const SizedBox();
        }),
      ));

      // Medium phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(414, 896),
        child: Builder(builder: (context) {
          mediumResult = ResponsiveUtils.getResponsiveIconSize(context);
          return const SizedBox();
        }),
      ));

      // Tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024),
        child: Builder(builder: (context) {
          tabletResult = ResponsiveUtils.getResponsiveIconSize(context);
          return const SizedBox();
        }),
      ));

      expect(smallResult, 20.0);
      expect(mediumResult, 24.0);
      expect(tabletResult, 28.0);
    });

    testWidgets(
        'getResponsiveButtonHeight returns correct height for different devices',
        (WidgetTester tester) async {
      double? smallResult;
      double? mediumResult;
      double? tabletResult;

      // Small phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(320, 568),
        child: Builder(builder: (context) {
          smallResult = ResponsiveUtils.getResponsiveButtonHeight(context);
          return const SizedBox();
        }),
      ));

      // Medium phone
      await tester.pumpWidget(buildTestWidget(
        size: const Size(414, 896),
        child: Builder(builder: (context) {
          mediumResult = ResponsiveUtils.getResponsiveButtonHeight(context);
          return const SizedBox();
        }),
      ));

      // Tablet
      await tester.pumpWidget(buildTestWidget(
        size: const Size(800, 1024),
        child: Builder(builder: (context) {
          tabletResult = ResponsiveUtils.getResponsiveButtonHeight(context);
          return const SizedBox();
        }),
      ));

      expect(smallResult, 44.0);
      expect(mediumResult, 48.0);
      expect(tabletResult, 56.0);
    });
  });
}
