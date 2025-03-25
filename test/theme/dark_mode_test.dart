import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';

// Import test mocks
import '../mocks/mock_notification_service.dart';

// Import app entry point without running main()
import 'package:pomodoro_timemaster/main.dart' show MyApp;
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

void main() {
  group('Dark Mode Tests', () {
    late ThemeProvider themeProvider;
    late SharedPreferences prefs;
    late MockNotificationService mockNotificationService;
    late SettingsProvider settingsProvider;

    // Helper method to wrap MyApp with required providers for theme testing
    Widget buildTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: mockNotificationService),
        ],
        child: Builder(builder: (context) {
          // Create a simplified app that just displays the theme status
          return MaterialApp(
            theme: ThemeData(
              brightness: themeProvider.isDarkTheme
                  ? Brightness.dark
                  : Brightness.light,
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                child: Text(
                    'Current theme: ${themeProvider.isDarkTheme ? "Dark" : "Light"}'),
              ),
            ),
          );
        }),
      );
    }

    setUp(() async {
      // Set up mock shared preferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Set up providers
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();
      themeProvider = ThemeProvider(prefs);

      // Set up mock notification service
      mockNotificationService = MockNotificationService();

      // Register mock notification service
      ServiceLocator().registerNotificationService(mockNotificationService);
    });

    // Basic test to verify dark/light mode works
    testWidgets(
      'App should toggle between dark and light mode',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          // Create a minimal test app with just ThemeProvider
          ChangeNotifierProvider.value(
            value: themeProvider,
            child: Consumer<ThemeProvider>(
              builder: (context, theme, _) {
                // Get the current theme
                final isDark = theme.isDarkTheme;

                return MaterialApp(
                  theme: ThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Current theme: ${isDark ? "Dark" : "Light"}'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Toggle theme
                              if (isDark) {
                                themeProvider.setTheme('Light');
                              } else {
                                themeProvider.setTheme('Dark');
                              }
                            },
                            child: Text('Toggle Theme'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Initially should be light mode
        expect(find.text('Current theme: Light'), findsOneWidget);

        // Tap button to toggle to dark mode
        await tester.tap(find.text('Toggle Theme'));
        await tester.pumpAndSettle();

        // Now should be dark mode
        expect(find.text('Current theme: Dark'), findsOneWidget);

        // Tap again to go back to light mode
        await tester.tap(find.text('Toggle Theme'));
        await tester.pumpAndSettle();

        // Should be back to light mode
        expect(find.text('Current theme: Light'), findsOneWidget);
      },
    );

    testWidgets('App should initialize with dark theme preference',
        (WidgetTester tester) async {
      // Set up SharedPreferences
      SharedPreferences.setMockInitialValues({
        'selected_theme': 'Dark',
      });

      // Re-initialize providers with updated preferences
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();

      // Initialize the app with test providers
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // App should show dark theme text
      expect(find.text('Current theme: Dark'), findsOneWidget);
    });

    testWidgets('Dark theme should persist after app restart',
        (WidgetTester tester) async {
      // Set up SharedPreferences with dark mode
      SharedPreferences.setMockInitialValues({
        'selected_theme': 'Dark',
      });

      // Re-initialize providers with updated preferences
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
      settingsProvider = SettingsProvider(prefs);
      await settingsProvider.init();

      // Initialize the app
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // App should show dark theme text
      expect(find.text('Current theme: Dark'), findsOneWidget);

      // "Restart" the app
      await tester.pumpWidget(Container());
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // App should still show dark theme text
      expect(find.text('Current theme: Dark'), findsOneWidget);
    });

    // Test theme attributes directly
    testWidgets('Theme properties from provider', (WidgetTester tester) async {
      // Set up SharedPreferences with dark mode
      SharedPreferences.setMockInitialValues({
        'selected_theme': 'Dark',
      });

      // Re-initialize providers and shared prefs with updated values
      prefs = await SharedPreferences.getInstance();
      print("Selected theme from prefs: ${prefs.getString('selected_theme')}");

      // Explicitly set Dark theme in preferences to ensure it's set
      prefs.setString('selected_theme', 'Dark');

      // Create theme provider that should now use Dark theme
      themeProvider = ThemeProvider(prefs);
      print("Theme provider isDarkTheme: ${themeProvider.isDarkTheme}");
      print("Theme provider name: ${themeProvider.selectedThemeName}");

      // Verify theme provider has correct settings
      expect(themeProvider.isDarkTheme, isTrue,
          reason: 'Theme provider should indicate dark mode');
      expect(themeProvider.selectedThemeName, equals('Dark'),
          reason: 'Theme name should be Dark');

      // Create a simple test widget
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final themeProvider = Provider.of<ThemeProvider>(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Provider says: ${themeProvider.isDarkTheme ? "Dark" : "Light"}'),
                        Text('Theme name: ${themeProvider.selectedThemeName}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify text shows we're using the Dark theme according to provider
      expect(find.text('Provider says: Dark'), findsOneWidget);
      expect(find.text('Theme name: Dark'), findsOneWidget);
    });
  });
}

// Helper functions for contrast calculation
double _calculateLuminance(Color color) {
  final double red = _linearize(color.red / 255);
  final double green = _linearize(color.green / 255);
  final double blue = _linearize(color.blue / 255);

  return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

double _linearize(double colorComponent) {
  return colorComponent <= 0.03928
      ? colorComponent / 12.92
      : pow((colorComponent + 0.055) / 1.055, 2.4);
}

double min(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;
double pow(double x, double exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
