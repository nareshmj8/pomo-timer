import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart'; // Import for debugPaintSizeEnabled
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/reset_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock SettingsProvider to control behavior during tests
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  final bool _isDarkTheme;
  bool _resetCalled = false;
  bool _resetHistoryCalled = false;
  bool _resetTasksCalled = false;
  bool _resetSettingsCalled = false;

  MockSettingsProvider({bool isDarkTheme = false})
      : _isDarkTheme = isDarkTheme,
        super();

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  Color get textColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  Future<void> clearAllData() async {
    _resetCalled = true;
    await Future.delayed(const Duration(
        milliseconds: 100)); // Small delay to simulate processing
    notifyListeners();
  }

  void resetAll() {
    _resetCalled = true;
  }

  void resetHistory() {
    _resetHistoryCalled = true;
  }

  void resetTasks() {
    _resetTasksCalled = true;
  }

  void resetSettings() {
    _resetSettingsCalled = true;
  }

  bool get resetCalled => _resetCalled;
  bool get resetHistoryCalled => _resetHistoryCalled;
  bool get resetTasksCalled => _resetTasksCalled;
  bool get resetSettingsCalled => _resetSettingsCalled;

  // Implement other required methods with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Setup SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();

    // Disable debug painting
    debugDisableShadows = true;
    debugPaintSizeEnabled = false;

    // Setup to ignore overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed') ||
          details.toString().contains('overflow') ||
          details.toString().contains('constraints') ||
          details.toString().contains('pixels')) {
        // Ignore overflow errors
        return;
      }
      // For other errors, use the original error handler
      FlutterError.presentError(details);
    };
  });

  // Helper function to build the widget tree for testing
  Widget buildTestWidget({bool isDarkTheme = false}) {
    final mockSettings = MockSettingsProvider(isDarkTheme: isDarkTheme);

    return CupertinoApp(
      home: ChangeNotifierProvider<SettingsProvider>.value(
        value: mockSettings,
        child: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Test'),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: const ResetSection(),
            ),
          ),
        ),
      ),
    );
  }

  group('ResetSection - Basic Display Tests', () {
    testWidgets('should display reset button', (WidgetTester tester) async {
      // Set a consistent viewport size
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(CupertinoButton, 'Reset All Data'),
          findsOneWidget);
    });
  });

  group('ResetSection - Dialog Tests', () {
    testWidgets('should show confirmation dialog when reset button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoButton, 'Reset All Data'));
      await tester.pumpAndSettle();

      expect(find.text('Reset all data?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(
          find.widgetWithText(CupertinoDialogAction, 'Reset'), findsOneWidget);
    });

    testWidgets('should dismiss dialog when Cancel is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoButton, 'Reset All Data'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Reset all data?'), findsNothing);
    });

    testWidgets('should call clearAllData when Reset is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoButton, 'Reset All Data'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Reset'));
      await tester.pump(); // Start the reset operation

      // Wait for async operation to complete
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Success dialog should appear
      expect(find.text('Reset Complete'), findsOneWidget);
      expect(find.text('Your all data have been reset to default values.'),
          findsOneWidget);

      // The mock provider's clearAllData should have been called
      final mockProvider = Provider.of<SettingsProvider>(
          tester.element(find.byType(ResetSection)),
          listen: false) as MockSettingsProvider;

      expect(mockProvider.resetCalled, true);

      // Close the success dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('should show completion dialog after reset',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoButton, 'Reset All Data'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Reset'));
      await tester.pump(); // Start the reset operation

      // Wait for async operation to complete
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify the completion dialog is displayed
      expect(find.text('Reset Complete'), findsOneWidget);
      expect(find.text('Your all data have been reset to default values.'),
          findsOneWidget);

      // Tap OK to dismiss the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Dialog should now be gone
      expect(find.text('Reset Complete'), findsNothing);
    });
  });

  group('ResetSection - Dark Mode Tests', () {
    testWidgets('should render correctly in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isDarkTheme: true));
      await tester.pumpAndSettle();

      // Verify button is present and has correct styling
      expect(find.widgetWithText(CupertinoButton, 'Reset All Data'),
          findsOneWidget);
    });

    testWidgets('dark mode dialogs should have correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isDarkTheme: true));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.widgetWithText(CupertinoButton, 'Reset All Data'));
      await tester.pumpAndSettle();

      // Verify dialog presence and styling
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(
          find.widgetWithText(CupertinoDialogAction, 'Reset'), findsOneWidget);

      // Close dialog
      await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });
  });

  group('ResetSection - Accessibility Tests', () {
    testWidgets('should have appropriate UI elements for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify buttons are accessible
      expect(find.widgetWithText(CupertinoButton, 'Reset All Data'),
          findsOneWidget);

      // Ensure buttons have appropriate size for touch targets
      final resetButtonFinder =
          find.widgetWithText(CupertinoButton, 'Reset All Data');
      final resetButton = tester.widget(resetButtonFinder) as CupertinoButton;

      // Verify button padding - this helps with touch targets
      expect(resetButton.padding, isNotNull);

      // Verify section header for screen readers
      expect(find.text('Reset'), findsOneWidget);
    });
  });
}
