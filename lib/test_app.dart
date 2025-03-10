import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/settings_screen.dart';
import 'providers/settings_provider.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final settingsProvider = SettingsProvider(prefs);
  await settingsProvider.init();

  // Initialize SyncService
  final syncService = SyncService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        Provider<SyncService>(create: (_) => syncService),
      ],
      child: const TestApp(),
    ),
  );
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => CupertinoApp(
        title: 'Pomodoro Timer',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
          brightness: settings.selectedTheme == 'Dark'
              ? Brightness.dark
              : Brightness.light,
          scaffoldBackgroundColor: settings.backgroundColor,
          barBackgroundColor: settings.backgroundColor.withAlpha(204),
        ),
        home: const SettingsScreen(),
      ),
    );
  }
}
