import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pomo_timer/home_screen.dart';
import 'package:pomo_timer/onboarding_screen.dart';
import 'screens/statistics_screen.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:pomo_timer/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
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
        primaryColor:
            Provider.of<ThemeProvider>(context).currentTheme.primaryColor,
        brightness: Provider.of<ThemeProvider>(context).currentTheme.isDark
            ? Brightness.dark
            : Brightness.light,
        scaffoldBackgroundColor:
            Provider.of<ThemeProvider>(context).backgroundColor,
        barBackgroundColor: Provider.of<ThemeProvider>(context)
            .backgroundColor
            .withValues(alpha: 204),
        textTheme: CupertinoTextThemeData(
          primaryColor:
              Provider.of<ThemeProvider>(context).currentTheme.primaryColor,
          textStyle: TextStyle(
            color: Provider.of<ThemeProvider>(context).textColor,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/statistics': (context) => StatisticsScreen(),
      },
    );
  }
}
