import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/premium_screen.dart';
import 'providers/settings_provider.dart';
import 'services/iap_service.dart';
import 'screens/settings_screen.dart';
import 'services/cloudkit_service.dart';
import 'services/sync_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final settingsProvider = SettingsProvider(prefs);
  await settingsProvider.init();

  // Initialize in-app purchases (to be implemented later)
  /* if (await InAppPurchase.instance.isAvailable()) {
    await InAppPurchase.instance.restorePurchases();
  } */

  // Initialize CloudKit service
  final cloudKitService = CloudKitService();
  await cloudKitService.initialize();

  // Initialize Sync service with CloudKit
  final syncService = SyncService(cloudKitService: cloudKitService);
  await syncService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => IAPService()),
        ChangeNotifierProvider<CloudKitService>(create: (_) => cloudKitService),
        ChangeNotifierProvider<SyncService>(create: (_) => syncService),
      ],
      child: const MyApp(),
    ),
  );
}

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
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Pomo Timer',
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
          brightness: settings.selectedTheme == 'Dark'
              ? Brightness.dark
              : Brightness.light,
          scaffoldBackgroundColor: settings.backgroundColor,
          barBackgroundColor: settings.backgroundColor.withAlpha(204),
          textTheme: CupertinoTextThemeData(
            primaryColor: settings.textColor,
            textStyle: TextStyle(color: settings.textColor),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/premium': (context) => const PremiumScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
