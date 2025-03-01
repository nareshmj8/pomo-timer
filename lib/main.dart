import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/premium_screen.dart';
import 'providers/settings_provider.dart';
import 'services/iap_service.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => IAPService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        initialRoute: '/',
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/premium': (context) => const PremiumScreen(),
        },
      ),
    );
  }
}
