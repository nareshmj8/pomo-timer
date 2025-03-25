import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/notifications_section.dart';

// Mock SettingsProvider to control state during tests
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  final bool _isDarkTheme;
  bool _soundEnabled = true;
  int _notificationSoundType = 0;
  bool _testSoundCalled = false;

  MockSettingsProvider({
    bool isDarkTheme = false,
    bool soundEnabled = true,
    int notificationSoundType = 0,
  })  : _isDarkTheme = isDarkTheme,
        _soundEnabled = soundEnabled,
        _notificationSoundType = notificationSoundType;

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  int get notificationSoundType => _notificationSoundType;

  @override
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  @override
  void setNotificationSoundType(int value) {
    _notificationSoundType = value;
    notifyListeners();
  }

  @override
  void testNotificationSound() {
    _testSoundCalled = true;
    notifyListeners();
  }

  bool get testSoundCalled => _testSoundCalled;

  @override
  Color get textColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get listTileTextColor =>
      isDarkTheme ? CupertinoColors.white : CupertinoColors.black;

  @override
  Color get secondaryTextColor =>
      isDarkTheme ? CupertinoColors.systemGrey : CupertinoColors.systemGrey;

  @override
  Color get listTileBackgroundColor =>
      isDarkTheme ? const Color(0xFF1C1C1E) : CupertinoColors.white;

  SingleChildScrollView wrapInScrollView(Widget child) {
    return SingleChildScrollView(child: child);
  }

  // Stub implementation for other required members
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockSettingsProvider mockSettings;

  setUp(() {
    mockSettings = MockSettingsProvider();
  });

  Widget buildTestWidget({
    bool isDarkTheme = false,
    bool soundEnabled = true,
    int notificationSoundType = 0,
  }) {
    mockSettings = MockSettingsProvider(
      isDarkTheme: isDarkTheme,
      soundEnabled: soundEnabled,
      notificationSoundType: notificationSoundType,
    );

    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<SettingsProvider>.value(
          value: mockSettings,
          child: const SingleChildScrollView(
            child: NotificationsSection(),
          ),
        ),
      ),
    );
  }

  group('NotificationsSection - Basic Display Tests', () {
    testWidgets('should display section header with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(NotificationsSection), findsOneWidget);
    });

    testWidgets('should display sound toggle and have correct initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(soundEnabled: true));

      expect(find.text('Sound'), findsOneWidget);

      final switchFinder = find.byType(CupertinoSwitch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<CupertinoSwitch>(switchFinder);
      expect(switchWidget.value, true);
    });
  });

  group('NotificationsSection - Sound Toggle Tests', () {
    testWidgets('should toggle sound setting when switch is toggled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(soundEnabled: true));

      // Verify initial state
      expect(mockSettings.soundEnabled, true);

      // Find and tap the switch
      final switchFinder = find.byType(CupertinoSwitch);
      await tester.tap(switchFinder);
      await tester.pump();

      // Verify the state changed
      expect(mockSettings.soundEnabled, false);
    });

    testWidgets('should hide sound options when sound is disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(soundEnabled: false));

      // Sound Type and Test Sound should not be visible
      expect(find.text('Sound Type'), findsNothing);
      expect(find.text('Test Sound'), findsNothing);
    });

    testWidgets('should show sound options when sound is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(soundEnabled: true));

      // Sound Type and Test Sound should be visible
      expect(find.text('Sound Type'), findsOneWidget);
      expect(find.text('Test Sound'), findsOneWidget);
    });
  });

  group('NotificationsSection - Sound Type Tests', () {
    testWidgets('should display the correct sound name based on type',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
        notificationSoundType: 0,
      ));

      // Should show "Tri-tone" for type 0
      expect(find.text('Tri-tone'), findsOneWidget);

      // Rebuild with different sound type
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
        notificationSoundType: 1,
      ));
      await tester.pump();

      // Should show "Chime" for type 1
      expect(find.text('Chime'), findsOneWidget);
    });

    testWidgets('should call testNotificationSound when test sound is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
      ));

      // Initially test sound not called
      expect(mockSettings.testSoundCalled, false);

      // Find and tap the test sound button
      final testSoundFinder = find.text('Test Sound');
      await tester.tap(testSoundFinder);
      await tester.pump();

      // Verify test sound was called
      expect(mockSettings.testSoundCalled, true);
    });
  });

  group('NotificationsSection - Modal Popup Tests', () {
    testWidgets('should show sound picker when sound type is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
      ));

      // Tap on the sound type row
      await tester.tap(find.text('Sound Type'));
      await tester.pumpAndSettle();

      // Verify modal popup is shown
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Verify sound options are in the picker
      expect(find.text('Tri-tone'), findsAtLeastNWidgets(1));
      expect(find.text('Chime'), findsAtLeastNWidgets(1));
      expect(find.text('Bell'), findsAtLeastNWidgets(1));
    });

    testWidgets('should close picker when Cancel is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
      ));

      // Tap on the sound type row
      await tester.tap(find.text('Sound Type'));
      await tester.pumpAndSettle();

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify modal popup is dismissed
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Done'), findsNothing);
    });

    testWidgets('should close picker when Done is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        soundEnabled: true,
      ));

      // Tap on the sound type row
      await tester.tap(find.text('Sound Type'));
      await tester.pumpAndSettle();

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Verify modal popup is dismissed
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Done'), findsNothing);
    });
  });

  group('NotificationsSection - Responsive Tests', () {
    testWidgets('should adapt to tablet mode', (WidgetTester tester) async {
      // Create a tablet-sized screen
      tester.view.physicalSize = const Size(1024 * 3, 768 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(buildTestWidget());
      addTearDown(tester.view.resetPhysicalSize);

      // Verify the widget renders
      expect(find.byType(NotificationsSection), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
    });

    testWidgets('should adapt to small screen mode',
        (WidgetTester tester) async {
      // Create a small-sized screen
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(buildTestWidget());
      addTearDown(tester.view.resetPhysicalSize);

      // Verify the widget renders
      expect(find.byType(NotificationsSection), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
    });
  });
}
