import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/data_section.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

// Mock SettingsProvider
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  bool _isDarkTheme = false;

  MockSettingsProvider({
    bool isDarkTheme = false,
  }) : _isDarkTheme = isDarkTheme;

  @override
  bool get isDarkTheme => _isDarkTheme;

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

  @override
  Color get separatorColor =>
      isDarkTheme ? const Color(0xFF38383A) : const Color(0xFFD1D1D6);

  // Implement wrapInScrollView for scroll tests
  @override
  SingleChildScrollView wrapInScrollView(Widget child) {
    return SingleChildScrollView(child: child);
  }

  // Stub implementation for other required members
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock SyncService
class MockSyncService extends ChangeNotifier implements SyncService {
  bool _syncEnabled = true;
  String _lastSyncedTime = 'Yesterday, 5:30 PM';
  bool _isSyncing = false;
  bool _syncCalled = false;

  MockSyncService({
    bool syncEnabled = true,
    String lastSyncedTime = 'Yesterday, 5:30 PM',
    bool isSyncing = false,
  })  : _syncEnabled = syncEnabled,
        _lastSyncedTime = lastSyncedTime,
        _isSyncing = isSyncing;

  @override
  Future<bool> isSyncEnabled() async => _syncEnabled;

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    _syncEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<String> getLastSyncedTime() async => _lastSyncedTime;

  @override
  bool get isSyncing => _isSyncing;

  void setIsSyncing(bool value) {
    _isSyncing = value;
    notifyListeners();
  }

  @override
  Future<bool> syncData() async {
    _syncCalled = true;
    return true;
  }

  bool get syncCalled => _syncCalled;

  // Stub implementation for other required members
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock RevenueCatService
class MockRevenueCatService extends ChangeNotifier
    implements RevenueCatService {
  bool _isPremium = true;

  MockRevenueCatService({
    bool isPremium = true,
  }) : _isPremium = isPremium;

  @override
  bool get isPremium => _isPremium;

  void setIsPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // Stub implementation for other required members
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockSettingsProvider mockSettings;
  late MockSyncService mockSyncService;
  late MockRevenueCatService mockRevenueCatService;

  setUp(() {
    mockSettings = MockSettingsProvider();
    mockSyncService = MockSyncService();
    mockRevenueCatService = MockRevenueCatService();
  });

  Widget buildTestWidget({
    bool isDarkTheme = false,
    bool syncEnabled = true,
    String lastSyncedTime = 'Yesterday, 5:30 PM',
    bool isSyncing = false,
    bool isPremium = true,
  }) {
    mockSettings = MockSettingsProvider(isDarkTheme: isDarkTheme);
    mockSyncService = MockSyncService(
      syncEnabled: syncEnabled,
      lastSyncedTime: lastSyncedTime,
      isSyncing: isSyncing,
    );
    mockRevenueCatService = MockRevenueCatService(isPremium: isPremium);

    // Use TestApp to avoid auto-applied shortcuts and actions from MaterialApp
    return TestApp(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: mockSettings),
          ChangeNotifierProvider<SyncService>.value(value: mockSyncService),
          ChangeNotifierProvider<RevenueCatService>.value(
              value: mockRevenueCatService),
        ],
        child: const DataSection(),
      ),
    );
  }

  group('DataSection - Basic Display Tests', () {
    testWidgets('should display section header with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.byType(DataSection), findsOneWidget);
    });

    testWidgets(
        'should display iCloud Sync toggle and have correct initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(syncEnabled: true));
      await tester.pumpAndSettle();

      expect(find.text('iCloud Sync'), findsOneWidget);

      final switchFinder = find.byType(CupertinoSwitch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<CupertinoSwitch>(switchFinder);
      expect(switchWidget.value, true);
    });

    testWidgets('should show sync status when sync is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        syncEnabled: true,
        lastSyncedTime: 'Yesterday, 5:30 PM',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sync is active'), findsOneWidget);
      expect(find.text('Last Synced: Yesterday, 5:30 PM'), findsOneWidget);
    });

    testWidgets('should show sync disabled status when sync is disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(syncEnabled: false));
      await tester.pumpAndSettle();

      expect(find.text('Sync is disabled'), findsOneWidget);
      expect(
          find.text('Enable iCloud Sync to use this feature'), findsOneWidget);
    });
  });

  group('DataSection - Button and Interaction Tests', () {
    testWidgets('should have enabled Sync Now button when sync is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(syncEnabled: true));
      await tester.pumpAndSettle();

      expect(find.text('Sync Now'), findsOneWidget);

      // Find the button
      final buttonFinder = find.widgetWithText(CupertinoButton, 'Sync Now');
      expect(buttonFinder, findsOneWidget);

      // Verify the button is enabled
      final buttonWidget = tester.widget<CupertinoButton>(buttonFinder);
      expect(buttonWidget.onPressed != null, true);
    });

    testWidgets('should have disabled Sync Now button when sync is disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(syncEnabled: false));
      await tester.pumpAndSettle();

      // Find the button
      final buttonFinder = find.widgetWithText(CupertinoButton, 'Sync Now');
      expect(buttonFinder, findsOneWidget);

      // Verify the button is disabled
      final buttonWidget = tester.widget<CupertinoButton>(buttonFinder);
      expect(buttonWidget.onPressed, null);
    });
  });

  group('DataSection - Premium Feature Tests', () {
    testWidgets('should show feature without blur when user is premium',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(isPremium: true));
      await tester.pumpAndSettle();

      // Premium users shouldn't see the "Premium Feature" text overlay
      expect(find.text('Premium Feature'), findsNothing);
    });

    testWidgets('tapping Sync Now button should call syncData()',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        isPremium: true,
        syncEnabled: true,
      ));
      await tester.pumpAndSettle();

      // Initially sync not called
      expect(mockSyncService.syncCalled, false);

      // Find and tap the Sync Now button
      final buttonFinder = find.widgetWithText(CupertinoButton, 'Sync Now');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verify syncData was called
      expect(mockSyncService.syncCalled, true);
    });
  });
}

// Custom TestApp to avoid issues with MaterialApp and dialogs
class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
      builder: (context, widget) {
        return MediaQuery(
          // Wrap in MediaQuery with test sizes
          data: const MediaQueryData(
            size: Size(375, 812), // iPhone X dimensions
            padding: EdgeInsets.zero,
            devicePixelRatio: 1.0,
          ),
          child: widget!,
        );
      },
    );
  }
}
