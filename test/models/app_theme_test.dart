import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme properties', () {
      final lightTheme = AppTheme.light;

      expect(lightTheme.name, equals('Light'));
      expect(
          lightTheme.backgroundColor, equals(CupertinoColors.systemBackground));
      expect(lightTheme.textColor, equals(CupertinoColors.black));
      expect(lightTheme.isDark, isFalse);
    });

    test('dark theme properties', () {
      final darkTheme = AppTheme.dark;

      expect(darkTheme.name, equals('Dark'));
      expect(darkTheme.backgroundColor, equals(CupertinoColors.black));
      expect(darkTheme.textColor, equals(CupertinoColors.white));
      expect(darkTheme.isDark, isTrue);
    });

    test('custom theme construction', () {
      final customTheme = AppTheme(
        name: 'Custom',
        backgroundColor: const Color(0xFF00FF00),
        textColor: const Color(0xFF000000),
        secondaryTextColor: const Color(0xFF555555),
        listTileBackgroundColor: const Color(0xFFEEEEEE),
        listTileTextColor: const Color(0xFF333333),
        separatorColor: const Color(0xFFCCCCCC),
        isDark: false,
      );

      expect(customTheme.name, equals('Custom'));
      expect(customTheme.backgroundColor, equals(const Color(0xFF00FF00)));
      expect(customTheme.textColor, equals(const Color(0xFF000000)));
      expect(customTheme.secondaryTextColor, equals(const Color(0xFF555555)));
      expect(
          customTheme.listTileBackgroundColor, equals(const Color(0xFFEEEEEE)));
      expect(customTheme.listTileTextColor, equals(const Color(0xFF333333)));
      expect(customTheme.separatorColor, equals(const Color(0xFFCCCCCC)));
      expect(customTheme.isDark, isFalse);
    });

    test('fromName returns correct theme', () {
      expect(AppTheme.fromName('Light'), equals(AppTheme.light));
      expect(AppTheme.fromName('Dark'), equals(AppTheme.dark));
      expect(AppTheme.fromName('NonExistent'), equals(AppTheme.defaultTheme));
    });

    test('availableThemes contains expected themes', () {
      final themes = AppTheme.availableThemes;
      expect(themes, contains(AppTheme.light));
      expect(themes, contains(AppTheme.dark));
      expect(themes, contains(AppTheme.calm));
      expect(themes, contains(AppTheme.forest));
      expect(themes, contains(AppTheme.warmSunset));
      expect(themes.length, equals(5));
    });
  });
}
