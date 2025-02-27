import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomo_timer/models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  late SharedPreferences _prefs;

  static final List<AppTheme> availableThemes = [
    AppTheme(
      name: 'Light',
      primaryColor: CupertinoColors.systemBlue,
      backgroundColor: CupertinoColors.systemBackground,
    ),
    AppTheme(
      name: 'Dark',
      primaryColor: CupertinoColors.systemBlue,
      backgroundColor: CupertinoColors.black,
      isDark: true,
    ),
    AppTheme(
      name: 'Ocean',
      primaryColor: const Color(0xFF40C9FF),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF40C9FF), Color(0xFF2C7BE5)],
      ),
    ),
    AppTheme(
      name: 'Sunset',
      primaryColor: const Color(0xFFFF6B6B),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
      ),
    ),
    AppTheme(
      name: 'Forest',
      primaryColor: const Color(0xFF2ECC71),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
      ),
    ),
  ];

  AppTheme _currentTheme = availableThemes[0]; // Light theme is default
  AppTheme get currentTheme => _currentTheme;

  // Helper methods for consistent color access
  Color get backgroundColor =>
      _currentTheme.backgroundColor ?? CupertinoColors.systemBackground;
  Color get textColor =>
      _currentTheme.isDark ? CupertinoColors.white : CupertinoColors.black;
  Color get secondaryBackgroundColor => _currentTheme.isDark
      ? CupertinoColors.systemGrey6.darkColor
      : CupertinoColors.systemGrey6.color;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      setTheme(savedTheme);
    }
  }

  void setTheme(String themeName) {
    final theme = availableThemes.firstWhere(
      (theme) => theme.name == themeName,
      orElse: () => availableThemes[0],
    );
    if (theme != _currentTheme) {
      _currentTheme = theme;
      _prefs.setString(_themeKey, themeName);
      notifyListeners();
    }
  }
}
