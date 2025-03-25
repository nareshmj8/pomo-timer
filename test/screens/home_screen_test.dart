import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/home_screen.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import '../mocks/mock_revenue_cat_service.dart';

// Create a simple mock of SyncService
class MockSyncService extends ChangeNotifier implements SyncService {
  bool _isSyncEnabled = false;
  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.notSynced;
  DateTime? _lastSyncedTime;
  String _errorMessage = '';
  bool _initialized = false;

  @override
  Future<bool> isSyncEnabled() async {
    return _isSyncEnabled;
  }

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    _isSyncEnabled = enabled;
    notifyListeners();
  }

  @override
  Future<bool> syncData() async {
    _isSyncing = true;
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    _isSyncing = false;
    _syncStatus = SyncStatus.synced;
    _lastSyncedTime = DateTime.now();
    notifyListeners();
    return true;
  }

  @override
  Future<void> initialize() async {
    _initialized = true;
    return;
  }

  @override
  bool get isSyncing => _isSyncing;

  @override
  SyncStatus get syncStatus => _syncStatus;

  @override
  String get errorMessage => _errorMessage;

  @override
  Future<String> getLastSyncedTime() async {
    return _lastSyncedTime != null
        ? _lastSyncedTime.toString()
        : 'Not synced yet';
  }

  @override
  bool get iCloudSyncEnabled => _isSyncEnabled;

  @override
  bool get isPremium => true;

  @override
  String get lastSyncedTime => _lastSyncedTime?.toString() ?? 'Not synced yet';

  @override
  Future<bool> getSyncEnabled() async {
    return _isSyncEnabled;
  }

  @override
  Future<String> updateLastSyncedTime() async {
    final formattedTime = DateTime.now().toString();
    _lastSyncedTime = DateTime.now();
    notifyListeners();
    return formattedTime;
  }

  // For testing - set online status
  void setOnlineStatus(bool isOnline) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen should navigate between tabs',
      (WidgetTester tester) async {
    // Set up SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialize providers
    final settingsProvider = SettingsProvider(sharedPreferences);

    final mockRevenueCatService = MockRevenueCatService();
    final mockSyncService = MockSyncService();

    // Disable provider error check for testing
    Provider.debugCheckInvalidValueType = null;

    // Build app with minimal widget size to avoid overflow issues
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 600)),
        child: MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider,
              ),
              ChangeNotifierProvider<RevenueCatServiceInterface>.value(
                value: mockRevenueCatService,
              ),
              ChangeNotifierProvider<RevenueCatService>.value(
                value: mockRevenueCatService,
              ),
              ChangeNotifierProvider<SyncService>.value(
                value: mockSyncService,
              ),
            ],
            child: const HomeScreen(),
          ),
        ),
      ),
    );

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Initially Timer tab should be shown
    expect(find.text('Timer'), findsWidgets);

    // Navigate to Statistics tab
    await tester.tap(find.byIcon(CupertinoIcons.graph_square));
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsWidgets);

    // Navigate to History tab
    await tester.tap(find.byIcon(CupertinoIcons.clock));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsWidgets);

    // Navigate to Settings tab
    await tester.tap(find.byIcon(CupertinoIcons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    // Navigate back to Timer tab
    await tester.tap(find.byIcon(CupertinoIcons.timer));
    await tester.pumpAndSettle();
    expect(find.text('Timer'), findsWidgets);
  });
}
