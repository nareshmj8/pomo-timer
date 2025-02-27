import 'package:flutter/cupertino.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final bool isDark;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    this.backgroundColor,
    this.gradient,
    this.isDark = false,
  });
}
