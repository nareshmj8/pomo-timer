import 'package:flutter/cupertino.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color listTileBackgroundColor;
  final Color listTileTextColor;
  final Color separatorColor;
  final Gradient? backgroundGradient;
  final bool isDark;

  const AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.listTileBackgroundColor,
    required this.listTileTextColor,
    required this.separatorColor,
    required this.isDark,
    this.backgroundGradient,
  });

  static const light = AppTheme(
    name: 'Light',
    backgroundColor: CupertinoColors.systemBackground,
    textColor: CupertinoColors.black,
    secondaryTextColor: CupertinoColors.systemGrey,
    listTileBackgroundColor: CupertinoColors.white,
    listTileTextColor: CupertinoColors.black,
    separatorColor: Color(0xFFC6C6C8),
    isDark: false,
  );

  static const dark = AppTheme(
    name: 'Dark',
    backgroundColor: CupertinoColors.black,
    textColor: CupertinoColors.white,
    secondaryTextColor: CupertinoColors.systemGrey,
    listTileBackgroundColor: Color(0xFF1C1C1E),
    listTileTextColor: CupertinoColors.white,
    separatorColor: Color(0xFF38383A),
    isDark: true,
  );

  static const calm = AppTheme(
    name: 'Calm',
    backgroundColor: Color(0xFF7CA5B8),
    textColor: CupertinoColors.white,
    secondaryTextColor: CupertinoColors.systemGrey6,
    listTileBackgroundColor: Color(0xFF6B94A7),
    listTileTextColor: CupertinoColors.white,
    separatorColor: Color(0xFF5B8497),
    isDark: true,
  );

  static const forest = AppTheme(
    name: 'Forest',
    backgroundColor: Color(0xFF2D5A27),
    textColor: CupertinoColors.white,
    secondaryTextColor: CupertinoColors.systemGrey6,
    listTileBackgroundColor: Color(0xFF1C4916),
    listTileTextColor: CupertinoColors.white,
    separatorColor: Color(0xFF0B3805),
    isDark: true,
  );

  static const warmSunset = AppTheme(
    name: 'Warm Sunset',
    backgroundColor: Color(0xFFFF9966),
    textColor: CupertinoColors.white,
    secondaryTextColor: CupertinoColors.systemGrey6,
    listTileBackgroundColor: Color(0xFFFF8855),
    listTileTextColor: CupertinoColors.white,
    separatorColor: Color(0xFFFF7744),
    isDark: true,
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF9966), // warm orange
        Color(0xFFFF5E62), // coral pink
      ],
    ),
  );

  static const defaultTheme = light;

  static List<AppTheme> get availableThemes => [
        light,
        dark,
        calm,
        forest,
        warmSunset,
      ];

  static AppTheme fromName(String name) {
    return availableThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => defaultTheme,
    );
  }
}
