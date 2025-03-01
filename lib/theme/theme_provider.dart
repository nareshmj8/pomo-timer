import 'package:flutter/foundation.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.defaultTheme;

  AppTheme get currentTheme => _currentTheme;

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
