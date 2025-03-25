import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/chart_data.dart';
import 'package:pomodoro_timemaster/models/history_entry.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/screens/statistics/statistics_screen.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/category_selector.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/toggle_buttons.dart'
    as app_toggle;
import 'package:pomodoro_timemaster/screens/statistics/components/stat_cards.dart';
import 'package:pomodoro_timemaster/screens/statistics/components/statistics_charts.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/providers/statistics_provider.dart';
import 'package:pomodoro_timemaster/providers/history_provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Mock implementation of SettingsProvider
class MockSettingsProvider with ChangeNotifier implements SettingsProvider {
  bool _isDarkTheme = false;
  List<HistoryEntry> _history = [];

  // Colors used in the settings screen
  final Color _backgroundColor = Colors.white;
  final Color _textColor = Colors.black;
  final Color _secondaryTextColor = Colors.grey;
  final Color _secondaryBackgroundColor = Colors.grey.shade200;
  final Color _separatorColor = Colors.grey.shade300;
  final Color _listTileBackgroundColor = Colors.white;
  final Color _listTileTextColor = Colors.black;

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  void setDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  @override
  List<HistoryEntry> get history => _history;

  @override
  void addHistoryEntry(HistoryEntry entry) {
    _history.add(entry);
    notifyListeners();
  }

  @override
  void clearHistory() {
    _history = [];
    notifyListeners();
  }

  // Mock chart data methods
  @override
  List<ChartData> getDailyData(String category) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return ChartData(
        date: date,
        hours: 1.5 *
            (7 - index), // Example data: higher values for more recent days
        sessions: 2.0 * (7 - index),
        isCurrentPeriod: index == 0,
      );
    });
  }

  @override
  List<ChartData> getWeeklyData(String category) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 7 * index));
      return ChartData(
        date: date,
        hours: 5.0 + index,
        sessions: 4.0 + index,
        isCurrentPeriod: index == 0,
      );
    });
  }

  @override
  List<ChartData> getMonthlyData(String category) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      return ChartData(
        date: date,
        hours: 20.0 + (index * 5),
        sessions: 16.0 + (index * 4),
        isCurrentPeriod: index == 0,
      );
    });
  }

  // Mock stats data
  @override
  Map<String, double> getCategoryStats(String category,
      {bool showHours = true}) {
    return {
      'today': 0.25,
      'week': 5.0,
      'month': 7.55,
      'total': 7.55,
    };
  }

  // Color-related getters required by the Statistics screen
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

  // Add any other methods/properties needed for the tests
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Mock implementation of ThemeProvider
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

// Mock implementation of StatisticsProvider
class MockStatisticsProvider with ChangeNotifier implements StatisticsProvider {
  @override
  List<ChartData> getDailyData(List<HistoryEntry> history, String category) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: index));
      return ChartData(
        date: date,
        hours: 1.5 * (7 - index),
        sessions: 2.0 * (7 - index),
        isCurrentPeriod: index == 0,
      );
    });
  }

  @override
  Map<String, double> getCategoryStats(
      List<HistoryEntry> history, String category) {
    return {
      'today': 0.25,
      'week': 5.0,
      'month': 7.55,
      'total': 7.55,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Mock implementation of HistoryProvider
class MockHistoryProvider with ChangeNotifier implements HistoryProvider {
  List<HistoryEntry> _history = [];

  @override
  List<HistoryEntry> get history => _history;

  @override
  void addHistoryEntry(HistoryEntry entry) {
    _history.add(entry);
    notifyListeners();
  }

  void clear() {
    _history = [];
    notifyListeners();
  }

  // Add some sample history data
  void seedWithSampleData() {
    final now = DateTime.now();

    // Add entries for today
    addHistoryEntry(HistoryEntry(
      category: 'Work',
      duration: 25 * 60, // 25 minutes in seconds
      timestamp: now.subtract(const Duration(hours: 2)),
    ));

    // Add entries for yesterday
    addHistoryEntry(HistoryEntry(
      category: 'Study',
      duration: 30 * 60,
      timestamp: now.subtract(const Duration(days: 1, hours: 5)),
    ));

    // Add entries for last week
    addHistoryEntry(HistoryEntry(
      category: 'Personal',
      duration: 15 * 60,
      timestamp: now.subtract(const Duration(days: 5)),
    ));

    // Add older entries
    addHistoryEntry(HistoryEntry(
      category: 'Work',
      duration: 45 * 60,
      timestamp: now.subtract(const Duration(days: 15)),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

// Mock implementation of RevenueCatService
class MockRevenueCatService with ChangeNotifier implements RevenueCatService {
  @override
  CustomerInfo? get customerInfo => null;

  @override
  String get errorMessage => '';

  @override
  DateTime? get expiryDate => null;

  @override
  bool get isLoading => false;

  @override
  bool get isPremium => true; // Set to true to prevent premium blur overlays

  @override
  Offerings? get offerings => null;

  @override
  PurchaseStatus get purchaseStatus => PurchaseStatus.notPurchased;

  @override
  SubscriptionType get activeSubscription => SubscriptionType.none;

  @override
  void disableDevPremiumAccess() {}

  @override
  void enableDevPremiumAccess() {}

  @override
  Future<void> forceReloadOfferings() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> openManageSubscriptionsPage() async {}

  @override
  Future<CustomerInfo?> purchasePackage(Package package) async => null;

  @override
  Future<void> purchaseProduct(String productId) async {}

  @override
  Future<bool> restorePurchases() async => true;

  @override
  Future<void> showPremiumBenefits(BuildContext context) async {}

  @override
  Future<void> showSubscriptionPlans(BuildContext context) async {}

  @override
  Future<void> cancelExpiryNotification() async {}

  @override
  Future<bool> checkAccessAndShowPaywallIfNeeded(BuildContext context) async =>
      true;

  @override
  Future<Map<String, dynamic>> debugPaywallConfiguration() async => {};

  @override
  Future<Offerings?> getOfferings() async => null;

  @override
  String getPriceForProduct(String productId) => "\$0.00";

  @override
  Package? getPackageForProduct(String productId) => null;

  @override
  Future<void> trackPurchaseButtonClicked(String productId) async {}

  @override
  Future<bool> verifyPremiumEntitlements() async => true;

  @override
  Future<Widget> buildPaywall(BuildContext context,
          {bool showClose = true}) async =>
      const SizedBox();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late MockSettingsProvider settingsProvider;
  late MockThemeProvider themeProvider;
  late MockStatisticsProvider statisticsProvider;
  late MockHistoryProvider historyProvider;
  late MockRevenueCatService revenueCatService;

  setUp(() {
    settingsProvider = MockSettingsProvider();
    themeProvider = MockThemeProvider();
    statisticsProvider = MockStatisticsProvider();
    historyProvider = MockHistoryProvider();
    revenueCatService = MockRevenueCatService();

    // Add sample history data
    historyProvider.seedWithSampleData();
  });

  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<StatisticsProvider>.value(
            value: statisticsProvider),
        ChangeNotifierProvider<HistoryProvider>.value(value: historyProvider),
        ChangeNotifierProvider<RevenueCatService>.value(
            value: revenueCatService),
      ],
      child: const MaterialApp(
        home: StatisticsScreen(),
      ),
    );
  }

  group('StatisticsScreen UI Tests', () {
    testWidgets('should display Statistics title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('should display category selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Category:'), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
    });

    testWidgets('should display toggle buttons for hours/sessions view',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);
      expect(find.byType(app_toggle.ToggleButtons), findsOneWidget);
    });

    testWidgets('should display stat cards with values',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('THIS MONTH'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.byType(StatCards), findsOneWidget);
    });

    testWidgets('should display statistics charts',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Trends'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.byType(StatisticsCharts), findsOneWidget);
    });

    testWidgets('should adapt to dark theme', (WidgetTester tester) async {
      themeProvider.setDarkTheme(true);
      settingsProvider.setDarkTheme(true);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkTheme, isTrue);
      expect(settingsProvider.isDarkTheme, isTrue);
    });
  });

  group('StatisticsScreen Interaction Tests', () {
    testWidgets('should debug widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find all Text widgets for debugging purposes
      final textWidgets = tester.widgetList(find.byType(Text)).toList();

      // Print all the text widgets found
      debugPrint('DEBUG: Text widgets found:');
      for (var widget in textWidgets) {
        if (widget is Text) {
          debugPrint('  - "${widget.data}"');
        }
      }
    });
  });
}
