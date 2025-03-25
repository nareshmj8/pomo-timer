import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/widgets/settings/settings_list_tile_container.dart';

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
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool showTopSeparator = true,
    bool showBottomSeparator = true,
    bool isDarkTheme = false,
  }) {
    settingsProvider.isDarkTheme = isDarkTheme;

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: Center(
            child: SettingsListTileContainer(
              child: child,
              padding: padding,
              showTopSeparator: showTopSeparator,
              showBottomSeparator: showBottomSeparator,
            ),
          ),
        ),
      ),
    );
  }

  group('SettingsListTileContainer - Display Tests', () {
    testWidgets('should render child widget', (WidgetTester tester) async {
      const testText = 'Test Child';

      await tester.pumpWidget(buildTestWidget(
        child: const Text(testText),
      ));

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should show top separator when showTopSeparator is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        showTopSeparator: true,
      ));

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      // Check if the first child of Column is a Container (separator)
      final column = tester.widget<Column>(columnFinder);
      expect(column.children.first, isA<Container>());
    });

    testWidgets('should not show top separator when showTopSeparator is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        showTopSeparator: false,
      ));

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      // Check if the first child of Column is a Padding (not a separator)
      final column = tester.widget<Column>(columnFinder);
      expect(column.children.first, isA<Padding>());
    });

    testWidgets('should show bottom separator when showBottomSeparator is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        showBottomSeparator: true,
      ));

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      // Check if the last child of Column is a Container (separator)
      final column = tester.widget<Column>(columnFinder);
      expect(column.children.last, isA<Container>());
    });

    testWidgets(
        'should not show bottom separator when showBottomSeparator is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        showBottomSeparator: false,
      ));

      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      // Check if the last child of Column is NOT a Container (no separator)
      final column = tester.widget<Column>(columnFinder);
      final lastWidget = column.children.last;
      expect(lastWidget, isA<Padding>());
    });

    testWidgets('should apply custom padding when provided',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(20.0);

      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        padding: customPadding,
      ));

      // Find all Padding widgets
      final paddingFinders = find.byType(Padding);

      // Check each Padding to find the one with our custom padding
      bool foundCustomPadding = false;
      for (int i = 0; i < paddingFinders.evaluate().length; i++) {
        final padding = tester.widget<Padding>(paddingFinders.at(i));
        if (padding.padding == customPadding) {
          foundCustomPadding = true;
          break;
        }
      }

      expect(foundCustomPadding, isTrue,
          reason: 'Could not find Padding with custom padding value');
    });
  });

  group('SettingsListTileContainer - Theme Tests', () {
    testWidgets('should adapt to light theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        isDarkTheme: false,
      ));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(CupertinoColors.white));
    });

    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const SizedBox(height: 50),
        isDarkTheme: true,
      ));

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF1C1C1E)));
    });
  });
}
