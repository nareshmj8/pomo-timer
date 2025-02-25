import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pomo_timer/home_screen.dart';
import 'package:pomo_timer/onboarding_screen.dart';
import 'screens/statistics_screen.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: CupertinoApp(
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
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          brightness: Brightness.light,
          scaffoldBackgroundColor: CupertinoColors.systemBackground,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => OnboardingScreen(),
          '/home': (context) => HomeScreen(),
          '/statistics': (context) => StatisticsScreen(),
        },
      ),
    );
  }
}
