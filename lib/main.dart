import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'
    show Colors, Brightness, Icons, Scaffold, MaterialApp, ElevatedButton;
import 'home_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'providers/settings_provider.dart';
import 'theme/theme_provider.dart';
import 'services/analytics_service.dart';
import 'services/cloudkit_service.dart';
import 'services/interfaces/notification_service_interface.dart';
import 'services/revenue_cat_service.dart';
import 'services/sync_service.dart';
import 'screens/splash_screen.dart';
import 'screens/iap_test/iap_test_screen.dart';
import 'screens/revenue_cat_test_screen.dart';
import 'services/service_locator.dart';
import 'services/notification/notification_service_migrator.dart';
import 'services/interfaces/database_service_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/logging_service.dart';
import 'services/interfaces/connectivity_service_interface.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';

// Global navigator key used throughout the app
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  // Preserve the native splash screen until the app is fully loaded
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize timezone data at app startup
  try {
    tz.initializeTimeZones();
    debugPrint('🌍 Main: Timezone data initialized successfully');
  } catch (e) {
    debugPrint('🌍 Main: Error initializing timezone data: $e');
    // Continue initialization despite timezone error
    // Will fall back to device time if timezone data is unavailable
  }

  // Set up comprehensive error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint('🔴 Stack trace: ${details.stack}');

    // Log to our own analytics and logging service
    LoggingService.logError(
      'Flutter Error',
      details.exception.toString(),
      details.stack,
    );

    // Log to analytics service for tracking
    AnalyticsService().logEvent('app_error', {
      'type': 'flutter_error',
      'exception': details.exception.toString(),
      'stack': details.stack.toString().substring(
          0,
          min(details.stack.toString().length,
              500)), // Limit stack trace length
      'library': details.library ?? 'unknown',
    });

    // Present error to the user in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle errors that aren't caught by Flutter error mechanisms
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Platform Error: $error');
    debugPrint('🔴 Stack trace: $stack');

    // Log to our logging service
    LoggingService.logError(
      'Platform Error',
      error.toString(),
      stack,
    );

    // Log to analytics service
    AnalyticsService().logEvent('app_error', {
      'type': 'platform_error',
      'error': error.toString(),
      'stack': stack.toString().substring(0, min(stack.toString().length, 500)),
    });

    // Return true to prevent the error from propagating
    return true;
  };

  // Start with a light status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await initializeServices();

  // Run the app with error boundary
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => settingsProvider),
      ChangeNotifierProvider(create: (_) => themeProvider),
      ChangeNotifierProvider(create: (_) => revenueCatService),
      ChangeNotifierProvider<CloudKitService>(create: (_) => cloudKitService),
      ChangeNotifierProvider<SyncService>(create: (_) => syncService),
      Provider<DatabaseServiceInterface>(create: (_) => databaseService),
      Provider.value(value: notificationService),
      Provider<ConnectivityServiceInterface>(
          create: (_) => connectivityService),
    ],
    child: const ErrorBoundary(child: MyApp()),
  ));
}

// Initialize all app services
Future<void> initializeServices() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  settingsProvider = SettingsProvider(prefs);
  await settingsProvider.init();

  // Initialize theme provider
  themeProvider = ThemeProvider(prefs);

  // Initialize connectivity service
  connectivityService = ServiceLocator().connectivityService;
  await connectivityService.initialize();
  debugPrint('🌐 Main: Connectivity service initialized');

  // Use the service locator to get the notification service
  notificationService = ServiceLocator().notificationService;
  await notificationService.initialize();

  // Migrate from old notification service if needed
  await NotificationServiceMigrator.migrate(notificationService);

  // Initialize DatabaseService
  databaseService = ServiceLocator().databaseService;
  await databaseService.initialize();
  debugPrint('💾 Main: Database service initialized');

  // Initialize CloudKit service
  cloudKitService = CloudKitService();
  await cloudKitService.initialize();

  // Initialize Sync service with CloudKit
  syncService = SyncService(cloudKitService: cloudKitService);
  await syncService.initialize();

  // Initialize RevenueCat service
  revenueCatService = RevenueCatService();
}

// Global service instances
late SettingsProvider settingsProvider;
late ThemeProvider themeProvider;
late RevenueCatService revenueCatService;
late CloudKitService cloudKitService;
late SyncService syncService;
late DatabaseServiceInterface databaseService;
late NotificationServiceInterface notificationService;
late ConnectivityServiceInterface connectivityService;

// Helper function to get minimum of two integers
int min(int a, int b) => a < b ? a : b;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize RevenueCat after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final revenueCatService =
          Provider.of<RevenueCatService>(context, listen: false);
      revenueCatService.initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Sync when app is resumed
      final syncService = Provider.of<SyncService>(context, listen: false);
      syncService.syncData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, theme, _) => CupertinoApp(
        navigatorKey: globalNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Pomodoro TimeMaster',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
        ],
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          brightness: theme.isDarkTheme ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: theme.backgroundColor,
          barBackgroundColor: theme.backgroundColor.withAlpha(204),
          textTheme: CupertinoTextThemeData(
            primaryColor: theme.textColor,
            textStyle: TextStyle(color: theme.textColor),
          ),
        ),
        builder: (context, child) {
          // Add a focus scope to properly handle focus throughout the app
          return FocusScope(
            autofocus: true,
            child: child!,
          );
        },
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/premium': (context) => const PremiumScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/history': (context) => const HistoryScreen(),
          '/iap_test': (context) => const IAPTestScreen(),
          '/revenue_cat_test': (context) => const RevenueCatTestScreen(),
        },
      ),
    );
  }
}

// Error boundary widget to capture errors in the widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Show friendly error UI
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unexpected Error',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'re sorry, but something went wrong. The error has been reported and we\'re working on fixing it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Reset the error state and try again
                      setState(() {
                        _hasError = false;
                        _error = null;
                        _stackTrace = null;
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Information:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Text(
                                _stackTrace.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If no error, return the app and set up the error handler
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          // Log the error
          LoggingService.logError(
            'Widget Error',
            errorDetails.exception.toString(),
            errorDetails.stack,
          );

          // Set the error state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _hasError = true;
              _error = errorDetails.exception;
              _stackTrace = errorDetails.stack;
            });
          });

          // Return an empty container
          return Container();
        };

        return widget.child;
      },
    );
  }
}

/// Enable sandbox testing mode for manual testing
Future<void> enableSandboxTesting() async {
  await SandboxTestingHelper.initializeManualTest();
}
