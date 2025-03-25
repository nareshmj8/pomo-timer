import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Basic Theme Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
    });

    testWidgets('Should toggle theme correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(builder: (context, theme, _) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Theme: ${theme.isDarkTheme ? 'Dark' : 'Light'}'),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Toggle theme directly
                          theme.setTheme(theme.isDarkTheme ? 'Light' : 'Dark');
                        },
                        child: const Text('Toggle Theme'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );

      // Verify initially in light mode
      expect(find.text('Theme: Light'), findsOneWidget);

      // Verify initial theme
      expect(themeProvider.isDarkTheme, isFalse);

      // Change theme directly
      themeProvider.setTheme('Dark');
      await tester.pump(); // Rebuild once
      await tester.pump(); // Rebuild again to process all frame changes

      // Verify text updated
      expect(find.text('Theme: Dark'), findsOneWidget);

      // Change back to light
      themeProvider.setTheme('Light');
      await tester.pump();
      await tester.pump();

      // Verify text updated
      expect(find.text('Theme: Light'), findsOneWidget);
    });
  });
}
