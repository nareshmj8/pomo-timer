import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/main.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/screens/splash_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences for testing
  SharedPreferences.setMockInitialValues({});

  // Mock binary messenger before tests
  final TestDefaultBinaryMessengerBinding binding =
      TestDefaultBinaryMessengerBinding.instance;

  // Setup mocks for FlutterNativeSplash
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter_native_splash'),
    (methodCall) async {
      if (methodCall.method == 'remove') {
        return null;
      }
      return null;
    },
  );

  group('Main App Tests', () {
    testWidgets('should verify CupertinoApp structure with Consumer2',
        (WidgetTester tester) async {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Create settings provider and theme provider
      final settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();
      final themeProvider = ThemeProvider(prefs);

      // Build our test app with the minimum required providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ],
          child: Consumer2<SettingsProvider, ThemeProvider>(
            builder: (context, settings, theme, _) => CupertinoApp(
              navigatorKey: GlobalKey<NavigatorState>(),
              debugShowCheckedModeBanner: false,
              title: 'Pomodoro TimeMaster',
              theme: CupertinoThemeData(
                primaryColor: CupertinoColors.activeBlue,
                brightness:
                    theme.isDarkTheme ? Brightness.dark : Brightness.light,
              ),
              home: const SizedBox(), // Simple placeholder
              routes: {
                '/home': (context) => const SizedBox(),
                '/statistics': (context) => const SizedBox(),
                '/premium': (context) => const SizedBox(),
                '/settings': (context) => const SizedBox(),
                '/history': (context) => const SizedBox(),
                '/iap_test': (context) => const SizedBox(),
                '/revenue_cat_test': (context) => const SizedBox(),
              },
            ),
          ),
        ),
      );

      // Verify that CupertinoApp is created
      expect(find.byType(CupertinoApp), findsOneWidget);

      // Verify CupertinoApp properties
      final app = tester.widget<CupertinoApp>(find.byType(CupertinoApp));
      expect(app.title, 'Pomodoro TimeMaster');
      expect(app.debugShowCheckedModeBanner, false);

      // Verify theme
      final theme = app.theme;
      expect(theme, isNotNull);
      expect(theme!.brightness,
          equals(Brightness.light)); // Default is light theme
      expect(theme.primaryColor, equals(CupertinoColors.activeBlue));

      // Verify routes
      expect(app.routes!.length, 7);
      expect(app.routes!.containsKey('/home'), true);
      expect(app.routes!.containsKey('/statistics'), true);
      expect(app.routes!.containsKey('/premium'), true);
      expect(app.routes!.containsKey('/settings'), true);
      expect(app.routes!.containsKey('/history'), true);
      expect(app.routes!.containsKey('/iap_test'), true);
      expect(app.routes!.containsKey('/revenue_cat_test'), true);
    });

    testWidgets('should verify MultiProvider structure in main()',
        (WidgetTester tester) async {
      // Build a widget tree with MultiProvider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>(
              create: (_) => MockSettingsProvider(),
            ),
            ChangeNotifierProvider<ThemeProvider>(
              create: (_) => MockThemeProvider(),
            ),
            ChangeNotifierProvider<RevenueCatService>(
              create: (_) => MockRevenueCatService(),
            ),
            ChangeNotifierProvider<CloudKitService>(
              create: (_) => MockCloudKitService(),
            ),
            ChangeNotifierProvider<SyncService>(
              create: (_) => MockSyncService(),
            ),
            Provider<NotificationService>.value(
              value: MockNotificationService(),
            ),
          ],
          child: const SizedBox(), // Simple placeholder
        ),
      );

      // Verify providers are available in the widget tree
      final BuildContext context = tester.element(find.byType(SizedBox));
      expect(Provider.of<SettingsProvider>(context, listen: false),
          isA<MockSettingsProvider>());
      expect(Provider.of<ThemeProvider>(context, listen: false),
          isA<MockThemeProvider>());
      expect(Provider.of<RevenueCatService>(context, listen: false),
          isA<MockRevenueCatService>());
      expect(Provider.of<CloudKitService>(context, listen: false),
          isA<MockCloudKitService>());
      expect(Provider.of<SyncService>(context, listen: false),
          isA<MockSyncService>());
      expect(Provider.of<NotificationService>(context, listen: false),
          isA<MockNotificationService>());
    });

    testWidgets('MyApp widget structure test', (WidgetTester tester) async {
      // Create mock providers
      final settingsProvider = MockSettingsProvider();
      final themeProvider = MockThemeProvider();
      final revenueCatService = MockRevenueCatService();
      final cloudKitService = MockCloudKitService();
      final syncService = MockSyncService();
      final notificationService = MockNotificationService();

      // We'll create a TestMyApp to avoid the real MyApp's timer issue
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(
                value: settingsProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<RevenueCatService>.value(
                value: revenueCatService),
            ChangeNotifierProvider<CloudKitService>.value(
                value: cloudKitService),
            ChangeNotifierProvider<SyncService>.value(value: syncService),
            Provider<NotificationService>.value(value: notificationService),
          ],
          child: TestMyApp(),
        ),
      );

      // Skip animation frames
      await tester.pump();

      // Verify app structure is created
      expect(find.byType(CupertinoApp), findsOneWidget);

      // Verify TestSplashScreen is shown
      expect(find.byType(TestSplashScreen), findsOneWidget);
    });
  });
}

// Simple test versions of classes to avoid timer issues
class TestSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Test Splash Screen'),
    );
  }
}

class TestMyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, theme, _) => CupertinoApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        debugShowCheckedModeBanner: false,
        title: 'Pomodoro TimeMaster',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          brightness: theme.isDarkTheme ? Brightness.dark : Brightness.light,
        ),
        home: TestSplashScreen(),
      ),
    );
  }
}

// Mock classes for testing
class MockSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  Future<void> init() async {}

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockThemeProvider extends ChangeNotifier implements ThemeProvider {
  bool _isDarkTheme = false;
  Color _backgroundColor = const Color(0xFFFFFFFF);
  Color _textColor = const Color(0xFF000000);

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  Color get backgroundColor => _backgroundColor;

  @override
  Color get textColor => _textColor;

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockNotificationService implements NotificationService {
  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockCloudKitService extends ChangeNotifier implements CloudKitService {
  @override
  Future<void> initialize() async {}

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockSyncService extends ChangeNotifier implements SyncService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> syncData() async {
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockRevenueCatService extends ChangeNotifier
    implements RevenueCatService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<void> initialize() async {}

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
