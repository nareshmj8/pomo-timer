import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_header.dart';

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
    bool isDarkTheme = false,
  }) {
    settingsProvider.isDarkTheme = isDarkTheme;

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: Center(
            child: SettingsSectionHeader(
              title: title,
            ),
          ),
        ),
      ),
    );
  }

  group('SettingsSectionHeader - Display Tests', () {
    testWidgets('should display the title correctly',
        (WidgetTester tester) async {
      const testTitle = 'Test Section Title';

      await tester.pumpWidget(buildTestWidget(
        title: testTitle,
      ));

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      const testTitle = 'Test Section Title';

      await tester.pumpWidget(buildTestWidget(
        title: testTitle,
      ));

      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsOneWidget);

      final padding = tester.widget<Padding>(paddingFinder);
      expect(
          padding.padding,
          const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 24.0,
            bottom: 8.0,
          ));
    });
  });

  group('SettingsSectionHeader - Theme Tests', () {
    testWidgets('should have correct text style in light theme',
        (WidgetTester tester) async {
      const testTitle = 'Test Section Title';

      await tester.pumpWidget(buildTestWidget(
        title: testTitle,
        isDarkTheme: false,
      ));

      final textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      final textStyle = text.style as TextStyle;

      expect(textStyle.fontSize, 13);
      expect(textStyle.fontWeight, FontWeight.w600);
      expect(textStyle.color, const Color(0xFF6C6C70));
      expect(textStyle.letterSpacing, -0.08);
    });

    testWidgets('should have correct text style in dark theme',
        (WidgetTester tester) async {
      const testTitle = 'Test Section Title';

      await tester.pumpWidget(buildTestWidget(
        title: testTitle,
        isDarkTheme: true,
      ));

      final textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      final textStyle = text.style as TextStyle;

      expect(textStyle.fontSize, 13);
      expect(textStyle.fontWeight, FontWeight.w600);
      expect(textStyle.color, const Color(0xFF8E8E93));
      expect(textStyle.letterSpacing, -0.08);
    });
  });

  group('SettingsSectionHeader - Edge Cases', () {
    testWidgets('should handle empty title gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        title: '',
      ));

      expect(find.byType(Text), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle very long title gracefully',
        (WidgetTester tester) async {
      final longTitle =
          'This is an extremely long section title that would normally wrap to multiple lines '
          'in most UI contexts and might cause layout issues if not handled properly';

      await tester.pumpWidget(buildTestWidget(
        title: longTitle,
      ));

      expect(find.text(longTitle), findsOneWidget);
      // The Text widget should handle wrapping on its own
    });
  });
}
