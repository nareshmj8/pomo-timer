import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_section_footer.dart';

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
    required String text,
    bool isDarkTheme = false,
  }) {
    settingsProvider.isDarkTheme = isDarkTheme;

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: Center(
            child: SettingsSectionFooter(
              text: text,
            ),
          ),
        ),
      ),
    );
  }

  group('SettingsSectionFooter - Display Tests', () {
    testWidgets('should display the text correctly',
        (WidgetTester tester) async {
      const testText =
          'This is a footer explanation text for the settings section';

      await tester.pumpWidget(buildTestWidget(
        text: testText,
      ));

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      const testText = 'Footer text';

      await tester.pumpWidget(buildTestWidget(
        text: testText,
      ));

      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsOneWidget);

      final padding = tester.widget<Padding>(paddingFinder);
      expect(
          padding.padding,
          const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 16.0,
          ));
    });
  });

  group('SettingsSectionFooter - Theme Tests', () {
    testWidgets('should have correct text style in light theme',
        (WidgetTester tester) async {
      const testText = 'Footer text';

      await tester.pumpWidget(buildTestWidget(
        text: testText,
        isDarkTheme: false,
      ));

      final textFinder = find.text(testText);
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      final textStyle = text.style as TextStyle;

      expect(textStyle.fontSize, 13);
      expect(textStyle.color, const Color(0xFF6C6C70));
      expect(textStyle.height, 1.3);
    });

    testWidgets('should have correct text style in dark theme',
        (WidgetTester tester) async {
      const testText = 'Footer text';

      await tester.pumpWidget(buildTestWidget(
        text: testText,
        isDarkTheme: true,
      ));

      final textFinder = find.text(testText);
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      final textStyle = text.style as TextStyle;

      expect(textStyle.fontSize, 13);
      expect(textStyle.color, const Color(0xFF8E8E93));
      expect(textStyle.height, 1.3);
    });
  });

  group('SettingsSectionFooter - Edge Cases', () {
    testWidgets('should handle empty text gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        text: '',
      ));

      expect(find.byType(Text), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle multiline text gracefully',
        (WidgetTester tester) async {
      final multilineText = 'This is a multiline footer text.\n'
          'It contains several lines of text to explain a setting.\n'
          'The footer should handle this gracefully and maintain proper spacing.';

      await tester.pumpWidget(buildTestWidget(
        text: multilineText,
      ));

      expect(find.text(multilineText), findsOneWidget);
      // The Text widget should handle multiline text with the specified line height
    });

    testWidgets('should handle very long text gracefully',
        (WidgetTester tester) async {
      final longText =
          'This is an extremely long footer text that would normally wrap to multiple lines '
          'in most UI contexts. Footer text is often used to provide additional context or explanations '
          'for settings, and they can sometimes be quite verbose to ensure users understand the implications '
          'of their choices. This test verifies that the footer handles long text gracefully.';

      await tester.pumpWidget(buildTestWidget(
        text: longText,
      ));

      expect(find.text(longText), findsOneWidget);
      // The Text widget should handle wrapping on its own
    });
  });
}
