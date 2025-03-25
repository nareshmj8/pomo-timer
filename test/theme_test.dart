import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('Light theme has correct properties', () {
      // Test key properties in light theme
      expect(AppTheme.light.name, equals('Light'));
      expect(AppTheme.light.backgroundColor,
          equals(CupertinoColors.systemBackground));
      expect(AppTheme.light.textColor, equals(CupertinoColors.black));
      expect(AppTheme.light.isDark, isFalse);
    });

    test('Dark theme has correct properties', () {
      // Test key properties in dark theme
      expect(AppTheme.dark.name, equals('Dark'));
      expect(AppTheme.dark.backgroundColor, equals(CupertinoColors.black));
      expect(AppTheme.dark.textColor, equals(CupertinoColors.white));
      expect(AppTheme.dark.isDark, isTrue);
    });

    test('Theme selection by name works', () {
      final selectedTheme = AppTheme.fromName('Forest');

      // Test selected theme
      expect(selectedTheme.name, equals('Forest'));
      expect(selectedTheme.backgroundColor, equals(const Color(0xFF2D5A27)));
      expect(selectedTheme.isDark, isTrue);
    });

    test('Default theme is returned for invalid name', () {
      final selectedTheme = AppTheme.fromName('NonExistentTheme');

      // Should return the default theme
      expect(selectedTheme, equals(AppTheme.defaultTheme));
      expect(selectedTheme, equals(AppTheme.light));
    });

    test('Available themes list contains all themes', () {
      final themes = AppTheme.availableThemes;

      // Check if all themes are in the list
      expect(themes.length, equals(5));
      expect(themes.contains(AppTheme.light), isTrue);
      expect(themes.contains(AppTheme.dark), isTrue);
      expect(themes.contains(AppTheme.calm), isTrue);
      expect(themes.contains(AppTheme.forest), isTrue);
      expect(themes.contains(AppTheme.warmSunset), isTrue);
    });
  });
}
