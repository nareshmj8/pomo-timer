import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/theme_settings_provider.dart';

void main() {
  // Initialize the binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeSettingsProvider themeSettingsProvider;
  late SharedPreferences prefs;

  setUp(() async {
    // Initialize SharedPreferences with mock data
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    themeSettingsProvider = ThemeSettingsProvider(prefs);
  });

  group('ThemeSettingsProvider Initialization', () {
    test('should initialize with default light theme', () {
      // Default theme should be 'Light'
      expect(themeSettingsProvider.selectedTheme, 'Light');
      expect(themeSettingsProvider.isDarkTheme, false);
    });

    test('should initialize with saved theme', () async {
      // Setup preferences with a saved theme
      await prefs.setString('selectedTheme', 'Dark');

      // Create a new provider that should load the saved theme
      final newProvider = ThemeSettingsProvider(prefs);

      // Wait for async _loadSavedData to complete
      await Future.delayed(Duration.zero);

      expect(newProvider.selectedTheme, 'Dark');
      expect(newProvider.isDarkTheme, true);
    });

    test('should have expected list of available themes', () {
      final themes = themeSettingsProvider.availableThemes;
      expect(themes, isNotEmpty);
      expect(themes, contains('System'));
      expect(themes, contains('Light'));
      expect(themes, contains('Dark'));
      expect(themes, contains('Citrus Orange'));
      expect(themes, contains('Rose Quartz'));
      expect(themes, contains('Seafoam Green'));
      expect(themes, contains('Lavender Mist'));
      expect(themes.length, 7); // Ensure all themes are present
    });
  });

  group('ThemeSettingsProvider Theme Switching', () {
    test('should change theme correctly', () async {
      // Initially Light theme
      expect(themeSettingsProvider.selectedTheme, 'Light');
      expect(themeSettingsProvider.isDarkTheme, false);

      // Change to Dark theme
      themeSettingsProvider.setTheme('Dark');
      expect(themeSettingsProvider.selectedTheme, 'Dark');
      expect(themeSettingsProvider.isDarkTheme, true);

      // Change to custom theme (not dark)
      themeSettingsProvider.setTheme('Citrus Orange');
      expect(themeSettingsProvider.selectedTheme, 'Citrus Orange');
      expect(themeSettingsProvider.isDarkTheme, false);

      // Wait for async operations to complete
      await Future.delayed(Duration.zero);
    });

    test('should ignore invalid theme names', () {
      // Start with Light theme
      expect(themeSettingsProvider.selectedTheme, 'Light');

      // Try to set an invalid theme
      themeSettingsProvider.setTheme('InvalidThemeName');

      // Theme should not change
      expect(themeSettingsProvider.selectedTheme, 'Light');
    });

    test('should notify listeners when theme changes', () {
      // Setup a counter to track notifications
      int notificationCount = 0;
      themeSettingsProvider.addListener(() {
        notificationCount++;
      });

      // Initial count should be zero
      expect(notificationCount, 0);

      // Change theme, should trigger notification
      themeSettingsProvider.setTheme('Dark');
      expect(notificationCount, 1);

      // Change theme again, should trigger another notification
      themeSettingsProvider.setTheme('Citrus Orange');
      expect(notificationCount, 2);

      // Set the same theme, should still notify (implementation detail)
      themeSettingsProvider.setTheme('Citrus Orange');
      expect(notificationCount, 3);

      // Invalid theme should not notify
      themeSettingsProvider.setTheme('InvalidTheme');
      expect(notificationCount, 3); // No change
    });
  });

  group('ThemeSettingsProvider Color Values', () {
    test('should provide correct colors for Light theme', () {
      themeSettingsProvider.setTheme('Light');

      // Verify color values for Light theme
      expect(themeSettingsProvider.backgroundColor,
          CupertinoColors.systemGroupedBackground);
      expect(themeSettingsProvider.textColor, CupertinoColors.label);
      expect(themeSettingsProvider.secondaryTextColor,
          CupertinoColors.secondaryLabel);
      expect(themeSettingsProvider.secondaryBackgroundColor,
          CupertinoColors.tertiarySystemGroupedBackground);
      expect(themeSettingsProvider.separatorColor, CupertinoColors.separator);
      expect(
          themeSettingsProvider.listTileBackgroundColor, CupertinoColors.white);
      expect(themeSettingsProvider.listTileTextColor, CupertinoColors.label);
    });

    test('should provide correct colors for Dark theme', () {
      themeSettingsProvider.setTheme('Dark');

      // Verify color values for Dark theme
      expect(themeSettingsProvider.backgroundColor, const Color(0xFF000000));
      expect(themeSettingsProvider.textColor, CupertinoColors.white);
      expect(themeSettingsProvider.secondaryTextColor, const Color(0xFF98989F));
      expect(themeSettingsProvider.secondaryBackgroundColor,
          const Color(0xFF1C1C1E));
      expect(themeSettingsProvider.separatorColor, const Color(0xFF38383A));
      expect(themeSettingsProvider.listTileBackgroundColor,
          const Color(0xFF1C1C1E));
      expect(themeSettingsProvider.listTileTextColor, CupertinoColors.white);
    });

    test('should provide correct colors for custom themes', () {
      // Test Citrus Orange theme
      themeSettingsProvider.setTheme('Citrus Orange');
      expect(themeSettingsProvider.backgroundColor, const Color(0xFFFFD9A6));
      expect(themeSettingsProvider.secondaryBackgroundColor,
          const Color(0xFFFFE5CC));

      // Test Rose Quartz theme
      themeSettingsProvider.setTheme('Rose Quartz');
      expect(themeSettingsProvider.backgroundColor, const Color(0xFFF8C8D7));
      expect(themeSettingsProvider.secondaryBackgroundColor,
          const Color(0xFFFADFE7));

      // Test Seafoam Green theme
      themeSettingsProvider.setTheme('Seafoam Green');
      expect(themeSettingsProvider.backgroundColor, const Color(0xFFD9F2E6));
      expect(themeSettingsProvider.secondaryBackgroundColor,
          const Color(0xFFE6F5EE));

      // Test Lavender Mist theme
      themeSettingsProvider.setTheme('Lavender Mist');
      expect(themeSettingsProvider.backgroundColor, const Color(0xFFE6D9F2));
      expect(themeSettingsProvider.secondaryBackgroundColor,
          const Color(0xFFF0E6F2));
    });

    testWidgets('should handle System theme behavior',
        (WidgetTester tester) async {
      // Set to System theme
      themeSettingsProvider.setTheme('System');
      expect(themeSettingsProvider.selectedTheme, 'System');

      // In tests, we can only verify the implementation doesn't crash
      // We can't fully test the system theme detection as it depends on platform brightness
      expect(() => themeSettingsProvider.isDarkTheme, returnsNormally);
      expect(() => themeSettingsProvider.backgroundColor, returnsNormally);
      expect(() => themeSettingsProvider.textColor, returnsNormally);
    });
  });

  group('ThemeSettingsProvider Persistence', () {
    test('should persist theme changes to SharedPreferences', () async {
      // Change theme to Dark
      themeSettingsProvider.setTheme('Dark');

      // Wait for async operations to complete
      await Future.delayed(Duration.zero);

      // Verify the theme was saved to SharedPreferences
      expect(prefs.getString('selectedTheme'), 'Dark');

      // Change to a custom theme
      themeSettingsProvider.setTheme('Citrus Orange');

      // Wait for async operations to complete
      await Future.delayed(Duration.zero);

      // Verify the theme was updated in SharedPreferences
      expect(prefs.getString('selectedTheme'), 'Citrus Orange');
    });

    test('should load theme from SharedPreferences on initialization',
        () async {
      // Pre-set a value in SharedPreferences
      await prefs.setString('selectedTheme', 'Lavender Mist');

      // Create a new provider that should read this value
      final newProvider = ThemeSettingsProvider(prefs);

      // Wait for async _loadSavedData to complete
      await Future.delayed(Duration.zero);

      // The theme should be the one we set in SharedPreferences
      expect(newProvider.selectedTheme, 'Lavender Mist');
    });
  });

  group('ThemeSettingsProvider Robustness', () {
    test('should cycle through all themes without errors', () {
      // Cycle through all available themes
      for (final theme in themeSettingsProvider.availableThemes) {
        expect(() => themeSettingsProvider.setTheme(theme), returnsNormally);
        expect(themeSettingsProvider.selectedTheme, theme);
      }
    });
  });
}
