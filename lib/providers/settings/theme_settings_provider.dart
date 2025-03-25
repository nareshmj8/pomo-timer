import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart'; // Removed unnecessary import
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme-related settings
class ThemeSettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const String _selectedThemeKey = 'selectedTheme';

  // Theme settings
  String _selectedTheme = 'Light';

  // Available themes
  final List<String> _availableThemes = [
    'System',
    'Light',
    'Dark',
    'Citrus Orange',
    'Rose Quartz',
    'Seafoam Green',
    'Lavender Mist'
  ];

  ThemeSettingsProvider(this._prefs) {
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    _selectedTheme = _prefs.getString(_selectedThemeKey) ?? 'Light';
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    await _prefs.setString(_selectedThemeKey, _selectedTheme);
  }

  // Getters
  String get selectedTheme => _selectedTheme;
  List<String> get availableThemes => _availableThemes;

  bool get isDarkTheme {
    if (_selectedTheme == 'System') {
      // Use the system theme (MediaQuery would be checked in the UI)
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _selectedTheme == 'Dark';
  }

  Color get backgroundColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme
          ? const Color(0xFF000000)
          : CupertinoColors.systemGroupedBackground;
    } else if (_selectedTheme == 'Dark') {
      return const Color(0xFF000000);
    } else if (_selectedTheme == 'Light') {
      return CupertinoColors.systemGroupedBackground;
    } else {
      switch (_selectedTheme) {
        case 'Citrus Orange':
          return const Color(0xFFFFD9A6);
        case 'Rose Quartz':
          return const Color(0xFFF8C8D7);
        case 'Seafoam Green':
          return const Color(0xFFD9F2E6);
        case 'Lavender Mist':
          return const Color(0xFFE6D9F2);
        default:
          return CupertinoColors.systemGroupedBackground;
      }
    }
  }

  Color get textColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme ? CupertinoColors.white : CupertinoColors.label;
    } else if (_selectedTheme == 'Dark') {
      return CupertinoColors.white;
    } else {
      return CupertinoColors.label;
    }
  }

  Color get secondaryTextColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme
          ? const Color(0xFF98989F)
          : CupertinoColors.secondaryLabel;
    } else if (_selectedTheme == 'Dark') {
      return const Color(0xFF98989F);
    }
    return CupertinoColors.secondaryLabel;
  }

  Color get secondaryBackgroundColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme
          ? const Color(0xFF1C1C1E)
          : CupertinoColors.tertiarySystemGroupedBackground;
    } else if (_selectedTheme == 'Dark') {
      return const Color(0xFF1C1C1E);
    } else if (_selectedTheme == 'Light') {
      return CupertinoColors.tertiarySystemGroupedBackground;
    } else {
      switch (_selectedTheme) {
        case 'Citrus Orange':
          return const Color(0xFFFFE5CC);
        case 'Rose Quartz':
          return const Color(0xFFFADFE7);
        case 'Seafoam Green':
          return const Color(0xFFE6F5EE);
        case 'Lavender Mist':
          return const Color(0xFFF0E6F2);
        default:
          return CupertinoColors.tertiarySystemGroupedBackground;
      }
    }
  }

  Color get separatorColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme ? const Color(0xFF38383A) : CupertinoColors.separator;
    } else if (_selectedTheme == 'Dark') {
      return const Color(0xFF38383A);
    }
    return CupertinoColors.separator;
  }

  Color get listTileBackgroundColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme ? const Color(0xFF1C1C1E) : CupertinoColors.white;
    } else if (_selectedTheme == 'Dark') {
      return const Color(0xFF1C1C1E);
    }
    return CupertinoColors.white;
  }

  Color get listTileTextColor {
    if (_selectedTheme == 'System') {
      return isDarkTheme ? CupertinoColors.white : CupertinoColors.label;
    } else if (_selectedTheme == 'Dark') {
      return CupertinoColors.white;
    }
    return CupertinoColors.label;
  }

  // Set theme
  void setTheme(String theme) {
    if (_availableThemes.contains(theme)) {
      _selectedTheme = theme;
      _saveData();
      notifyListeners();
    }
  }
}
