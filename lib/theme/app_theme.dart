import 'package:flutter/cupertino.dart';

class AppTheme {
  final Color backgroundColor;
  final Color textColor;
  final Gradient? backgroundGradient;

  const AppTheme({
    required this.backgroundColor,
    required this.textColor,
    this.backgroundGradient,
  });

  static const light = AppTheme(
    backgroundColor: CupertinoColors.systemBackground,
    textColor: CupertinoColors.black,
  );

  static const dark = AppTheme(
    backgroundColor: CupertinoColors.black,
    textColor: CupertinoColors.white,
  );

  static const calm = AppTheme(
    backgroundColor: Color(0xFF7CA5B8),
    textColor: CupertinoColors.white,
  );

  static const forest = AppTheme(
    backgroundColor: Color(0xFF2D5A27),
    textColor: CupertinoColors.white,
  );

  static final warmSunset = AppTheme(
    backgroundColor: const Color(0xFFFF9966), // This is used as a fallback
    textColor: CupertinoColors.white,
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF9966), // warm orange
        Color(0xFFFF5E62), // coral pink
      ],
    ),
  );

  static const defaultTheme = light;
}
