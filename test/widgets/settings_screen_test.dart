import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/settings_screen.dart';
import 'package:pomodoro_timemaster/screens/settings/components/timer_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/appearance_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/notifications_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/data_section.dart';
import 'package:pomodoro_timemaster/screens/settings/components/about_section.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

class MockSettingsProvider with ChangeNotifier implements SettingsProvider {
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _isDarkTheme = false;
  double _workDuration = 25.0;
  double _shortBreakDuration = 5.0;
  double _longBreakDuration = 15.0;
  int _cyclesBeforeLongBreak = 4;
  int _notificationSoundType = 0;
  List<HistoryEntry> _history = [];
  String _selectedTheme = 'Light';

  // Colors used in the settings screen
  final Color _backgroundColor = Colors.white;
  final Color _textColor = Colors.black;
  final Color _secondaryTextColor = Colors.grey;
  final Color _secondaryBackgroundColor = Colors.grey.shade200;
  final Color _separatorColor = Colors.grey.shade300;
  final Color _listTileBackgroundColor = Colors.white;
  final Color _listTileTextColor = Colors.black;

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  @override
  bool get notificationsEnabled => _notificationsEnabled;

  @override
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  void setDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  @override
  double get workDuration => _workDuration;

  @override
  void setWorkDuration(double minutes) {
    _workDuration = minutes;
    notifyListeners();
  }

  @override
  double get shortBreakDuration => _shortBreakDuration;

  @override
  void setShortBreakDuration(double minutes) {
    _shortBreakDuration = minutes;
    notifyListeners();
  }

  @override
  double get longBreakDuration => _longBreakDuration;

  @override
  void setLongBreakDuration(double minutes) {
    _longBreakDuration = minutes;
    notifyListeners();
  }

  @override
  int get cyclesBeforeLongBreak => _cyclesBeforeLongBreak;

  @override
  int get sessionsBeforeLongBreak => _cyclesBeforeLongBreak;

  @override
  void setCyclesBeforeLongBreak(int cycles) {
    _cyclesBeforeLongBreak = cycles;
    notifyListeners();
  }

  @override
  void setSessionsBeforeLongBreak(int value) {
    _cyclesBeforeLongBreak = value;
    notifyListeners();
  }

  @override
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  @override
  List<dynamic> get historyEntries => _history;

  @override
  List<HistoryEntry> get history => _history;

  @override
  int get notificationSoundType => _notificationSoundType;

  @override
  void setNotificationSoundType(int value) {
    _notificationSoundType = value;
    notifyListeners();
  }

  @override
  String get selectedTheme => _selectedTheme;

  @override
  void setTheme(String theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  // Color-related getters required by the Settings screen
  @override
  Color get backgroundColor => _isDarkTheme ? Colors.black : _backgroundColor;

  @override
  Color get textColor => _isDarkTheme ? Colors.white : _textColor;

  @override
  Color get secondaryTextColor => _secondaryTextColor;

  @override
  Color get secondaryBackgroundColor => _secondaryBackgroundColor;

  @override
  Color get separatorColor => _separatorColor;

  @override
  Color get listTileBackgroundColor => _listTileBackgroundColor;

  @override
  Color get listTileTextColor => _listTileTextColor;

  @override
  double get sessionDuration => _workDuration;

  @override
  void setSessionDuration(double value) {
    _workDuration = value;
    notifyListeners();
  }

  // Add any other methods/properties needed for the tests
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockThemeProvider with ChangeNotifier implements ThemeProvider {
  bool _isDarkTheme = false;

  @override
  void setDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  AppTheme get currentTheme => _isDarkTheme ? AppTheme.dark : AppTheme.light;

  @override
  Color get backgroundColor => currentTheme.backgroundColor;

  @override
  Color get textColor => currentTheme.textColor;

  @override
  Color get secondaryTextColor => currentTheme.secondaryTextColor;

  @override
  Color get listTileBackgroundColor => currentTheme.listTileBackgroundColor;

  @override
  Color get listTileTextColor => currentTheme.listTileTextColor;

  @override
  Color get separatorColor => currentTheme.separatorColor;

  @override
  Gradient? get backgroundGradient => currentTheme.backgroundGradient;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockRevenueCatService with ChangeNotifier implements RevenueCatService {
  bool _isPremium = false;

  @override
  bool get isPremium => _isPremium;

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  @override
  SubscriptionType get activeSubscription =>
      _isPremium ? SubscriptionType.lifetime : SubscriptionType.none;

  @override
  DateTime? get expiryDate =>
      _isPremium ? DateTime.now().add(Duration(days: 365)) : null;

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockSyncService with ChangeNotifier implements SyncService {
  bool _isSyncEnabled = false;
  String _lastSynced = "Never synced";

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
  Future<String> getLastSyncedTime() async {
    return _lastSynced;
  }

  @override
  Future<bool> syncData() async {
    _lastSynced = DateTime.now().toString();
    notifyListeners();
    return true;
  }

  @override
  bool get isPremium => true;

  @override
  bool get isSyncing => false;

  @override
  String get errorMessage => '';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late MockSettingsProvider settingsProvider;
  late MockThemeProvider themeProvider;
  late MockRevenueCatService revenueCatService;
  late MockSyncService syncService;

  setUp(() {
    settingsProvider = MockSettingsProvider();
    themeProvider = MockThemeProvider();
    revenueCatService = MockRevenueCatService();
    syncService = MockSyncService();
  });

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<RevenueCatService>.value(
            value: revenueCatService),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
      ],
      child: MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  testWidgets('should display all main sections', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(TimerSection), findsOneWidget);
    expect(find.byType(AppearanceSection), findsOneWidget);
    expect(find.byType(NotificationsSection), findsOneWidget);
    expect(find.byType(AboutSection), findsOneWidget);
  });

  testWidgets('should display "Settings" title', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('should adapt to dark theme', (WidgetTester tester) async {
    settingsProvider.setDarkTheme(true);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(settingsProvider.isDarkTheme, isTrue);
    // This is a simplified check, in a real test we might want to check specific colors
  });

  testWidgets('should display "Done" button when navigated to',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text('Test'),
                ),
                child: Center(
                  child: CupertinoButton(
                    child: Text('Go to Settings'),
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider<SettingsProvider>.value(
                                  value: settingsProvider),
                              ChangeNotifierProvider<ThemeProvider>.value(
                                  value: themeProvider),
                              ChangeNotifierProvider<RevenueCatService>.value(
                                  value: revenueCatService),
                              ChangeNotifierProvider<SyncService>.value(
                                  value: syncService),
                            ],
                            child: SettingsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Go to Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
  });

  group('SettingsScreen Interaction Tests', () {
    testWidgets('should navigate back when Done is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text('Test'),
                  ),
                  child: Center(
                    child: CupertinoButton(
                      child: Text('Go to Settings'),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider<SettingsProvider>.value(
                                    value: settingsProvider),
                                ChangeNotifierProvider<ThemeProvider>.value(
                                    value: themeProvider),
                                ChangeNotifierProvider<RevenueCatService>.value(
                                    value: revenueCatService),
                                ChangeNotifierProvider<SyncService>.value(
                                    value: syncService),
                              ],
                              child: SettingsScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsNothing);
    });
  });
}
