import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      themeProvider = ThemeProvider(prefs);
    });

    test('Should initialize with default theme', () {
      expect(themeProvider.isDarkTheme, isFalse);
    });

    test('Should change to dark theme', () {
      // When initialized
      expect(themeProvider.isDarkTheme, isFalse);

      // When changing to dark theme
      themeProvider.setTheme('Dark');

      // Then provider should report dark theme
      expect(themeProvider.isDarkTheme, isTrue);

      // When changing back to light theme
      themeProvider.setTheme('Light');

      // Then provider should report light theme
      expect(themeProvider.isDarkTheme, isFalse);
    });

    test('Should persist theme choice in SharedPreferences', () {
      // When changing to dark theme
      themeProvider.setTheme('Dark');

      // Then SharedPreferences should have the value saved
      expect(prefs.getString('selected_theme'), equals('Dark'));

      // When changing back to light theme
      themeProvider.setTheme('Light');

      // Then SharedPreferences should have the updated value
      expect(prefs.getString('selected_theme'), equals('Light'));
    });

    test('Should load saved theme from SharedPreferences', () {
      // Given a saved theme preference
      prefs.setString('selected_theme', 'Dark');

      // When creating a new instance
      final newProvider = ThemeProvider(prefs);

      // Then it should load the saved theme
      expect(newProvider.isDarkTheme, isTrue);

      // And changing to 'system' theme - revert to default Light theme
      prefs.setString('selected_theme', 'System');
      final systemProvider = ThemeProvider(prefs);

      // Then it should not be dark (without testing system value)
      expect(systemProvider.isDarkTheme, isFalse);
    });
  });
}
