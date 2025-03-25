import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  AppTheme _currentTheme = AppTheme.defaultTheme;

  ThemeProvider(SharedPreferences prefs) {
    _prefs = prefs;
    _loadSavedTheme();
  }

  AppTheme get currentTheme => _currentTheme;
  String get selectedThemeName => _currentTheme.name;
  bool get isDarkTheme => _currentTheme.isDark;

  List<AppTheme> get availableThemes => AppTheme.availableThemes;

  Color get backgroundColor => _currentTheme.backgroundColor;
  Color get textColor => _currentTheme.textColor;
  Color get secondaryTextColor => _currentTheme.secondaryTextColor;
  Color get listTileBackgroundColor => _currentTheme.listTileBackgroundColor;
  Color get listTileTextColor => _currentTheme.listTileTextColor;
  Color get separatorColor => _currentTheme.separatorColor;
  Gradient? get backgroundGradient => _currentTheme.backgroundGradient;

  void _loadSavedTheme() {
    final savedThemeName = _prefs.getString('selected_theme') ?? 'light';
    _currentTheme = AppTheme.fromName(savedThemeName);
  }

  void setTheme(String themeName) {
    _currentTheme = AppTheme.fromName(themeName);
    _prefs.setString('selected_theme', themeName);
    notifyListeners();
  }

  void resetTheme() {
    _currentTheme = AppTheme.defaultTheme;
    _prefs.remove('selected_theme');
    notifyListeners();
  }
}
