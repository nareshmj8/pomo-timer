import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/theme/theme_provider.dart';
import 'package:pomodoro_timemaster/theme/app_theme.dart';

@GenerateMocks([SharedPreferences])
import 'theme_provider_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late ThemeProvider themeProvider;

  setUp(() {
    mockPrefs = MockSharedPreferences();

    // Default values for SharedPreferences
    when(mockPrefs.getString('selected_theme')).thenReturn(null);
    when(mockPrefs.remove('selected_theme')).thenAnswer((_) async => true);
    when(mockPrefs.setString('selected_theme', any))
        .thenAnswer((_) async => true);
  });

  group('ThemeProvider initialization', () {
    test('Should initialize with default theme when no saved theme', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn(null);

      // Act
      themeProvider = ThemeProvider(mockPrefs);

      // Assert
      expect(themeProvider.currentTheme, equals(AppTheme.defaultTheme));
      expect(
          themeProvider.selectedThemeName, equals(AppTheme.defaultTheme.name));
      expect(themeProvider.isDarkTheme, equals(AppTheme.defaultTheme.isDark));
    });

    test('Should initialize with saved theme when available', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn('Dark');

      // Act
      themeProvider = ThemeProvider(mockPrefs);

      // Assert
      expect(themeProvider.selectedThemeName, equals('Dark'));
      expect(themeProvider.isDarkTheme, isTrue);
    });
  });

  group('Theme selection', () {
    test('Should change theme correctly', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn(null);
      when(mockPrefs.setString('selected_theme', any))
          .thenAnswer((_) async => true);
      themeProvider = ThemeProvider(mockPrefs);

      // Initial state
      expect(
          themeProvider.selectedThemeName, equals(AppTheme.defaultTheme.name));

      // Act - change to dark theme
      themeProvider.setTheme('Dark');

      // Assert
      expect(themeProvider.selectedThemeName, equals('Dark'));
      expect(themeProvider.isDarkTheme, isTrue);
      verify(mockPrefs.setString('selected_theme', 'Dark')).called(1);
    });

    test('Should reset theme correctly', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn('Dark');
      themeProvider = ThemeProvider(mockPrefs);

      // Initial state
      expect(themeProvider.selectedThemeName, equals('Dark'));

      // Act - reset theme
      themeProvider.resetTheme();

      // Assert
      expect(
          themeProvider.selectedThemeName, equals(AppTheme.defaultTheme.name));
      expect(themeProvider.isDarkTheme, equals(AppTheme.defaultTheme.isDark));
      verify(mockPrefs.remove('selected_theme')).called(1);
    });
  });

  group('Theme properties', () {
    test('Should provide correct theme properties', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn('Dark');
      when(mockPrefs.setString('selected_theme', 'Light'))
          .thenAnswer((_) async => true);
      themeProvider = ThemeProvider(mockPrefs);

      // Assert - verify dark theme properties
      expect(
          themeProvider.backgroundColor, equals(AppTheme.dark.backgroundColor));
      expect(themeProvider.textColor, equals(AppTheme.dark.textColor));
      expect(themeProvider.secondaryTextColor,
          equals(AppTheme.dark.secondaryTextColor));
      expect(themeProvider.listTileBackgroundColor,
          equals(AppTheme.dark.listTileBackgroundColor));
      expect(themeProvider.listTileTextColor,
          equals(AppTheme.dark.listTileTextColor));
      expect(
          themeProvider.separatorColor, equals(AppTheme.dark.separatorColor));
      expect(themeProvider.backgroundGradient,
          equals(AppTheme.dark.backgroundGradient));

      // Act - change to light theme
      themeProvider.setTheme('Light');

      // Assert - verify light theme properties
      expect(themeProvider.backgroundColor,
          equals(AppTheme.light.backgroundColor));
      expect(themeProvider.textColor, equals(AppTheme.light.textColor));
      expect(themeProvider.secondaryTextColor,
          equals(AppTheme.light.secondaryTextColor));
      expect(themeProvider.listTileBackgroundColor,
          equals(AppTheme.light.listTileBackgroundColor));
      expect(themeProvider.listTileTextColor,
          equals(AppTheme.light.listTileTextColor));
      expect(
          themeProvider.separatorColor, equals(AppTheme.light.separatorColor));
      expect(themeProvider.backgroundGradient,
          equals(AppTheme.light.backgroundGradient));
    });

    test('Should provide list of available themes', () {
      // Setup
      when(mockPrefs.getString('selected_theme')).thenReturn(null);
      themeProvider = ThemeProvider(mockPrefs);

      // Assert
      expect(themeProvider.availableThemes, equals(AppTheme.availableThemes));
      expect(themeProvider.availableThemes.length, greaterThan(1));
    });
  });
}
