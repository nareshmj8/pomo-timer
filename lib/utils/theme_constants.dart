import 'package:flutter/cupertino.dart';

/// Constants for app theming to ensure consistency
class ThemeConstants {
  // Corner radii
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Spacing
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Font sizes
  static const double smallFontSize = 13.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;
  static const double extraLargeFontSize = 28.0;
  static const double timerFontSize = 72.0;
  static const double timerFontSizeSmall = 64.0;
  static const double headingFontSize = 20.0;
  static const double subheadingFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;

  // Button heights
  static const double standardButtonHeight = 48.0;
  static const double smallButtonHeight = 36.0;

  // Border widths
  static const double thinBorder = 0.5;
  static const double standardBorder = 1.0;
  static const double thickBorder = 2.0;
  static const double borderWidth = 1.0;
  static const double separatorWidth = 0.5;

  // Opacity values
  static const double highOpacity = 0.9;
  static const double mediumOpacity = 0.7;
  static const double lowOpacity = 0.3;
  static const double veryLowOpacity = 0.1;
  static const double disabledOpacity = 0.5;
  static const double activeOpacity = 0.8;

  // Utility method to convert opacity to alpha value (0-255)
  static int opacityToAlpha(double opacity) {
    return (255 * opacity).round();
  }

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Improved shadow properties with dark mode consideration
  static List<BoxShadow> getShadow(Color color, {bool isDarkMode = false}) {
    if (isDarkMode) {
      // Enhanced shadow for dark mode - more visible but subtle
      return [
        BoxShadow(
          color: color.withAlpha(opacityToAlpha(0.2)),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      // Standard shadow for light mode
      return [
        BoxShadow(
          color: color.withAlpha((0.1 * 255).toInt()),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }

  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Button highlight states with enhanced visibility in dark mode
  static Color getButtonHighlightColor(Color baseColor,
      {bool isDarkMode = false}) {
    if (isDarkMode) {
      // Enhanced highlight effect for dark mode - brighter and more noticeable
      final HSLColor hslColor = HSLColor.fromColor(baseColor);
      return hslColor
          .withLightness((hslColor.lightness + 0.15).clamp(0.0, 1.0))
          .withSaturation((hslColor.saturation - 0.1).clamp(0.0, 1.0))
          .toColor();
    } else {
      // Standard highlight for light mode
      return baseColor.withAlpha(opacityToAlpha(mediumOpacity));
    }
  }

  // Button press effect for enhanced feedback
  static Color getButtonPressedColor(Color baseColor,
      {bool isDarkMode = false}) {
    if (isDarkMode) {
      // More dramatic pressed effect for dark mode
      final HSLColor hslColor = HSLColor.fromColor(baseColor);
      return hslColor
          .withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0))
          .withSaturation((hslColor.saturation + 0.1).clamp(0.0, 1.0))
          .toColor();
    } else {
      // Standard press effect for light mode
      return baseColor.withAlpha(opacityToAlpha(highOpacity));
    }
  }

  // Button decoration with consistent style across the app
  static BoxDecoration getStandardButtonDecoration({
    required Color color,
    required bool isDarkMode,
    bool isPressed = false,
    bool isHighlighted = false,
    double borderRadius = ThemeConstants.mediumRadius,
  }) {
    Color backgroundColor = color;

    if (isPressed) {
      backgroundColor = getButtonPressedColor(color, isDarkMode: isDarkMode);
    } else if (isHighlighted) {
      backgroundColor = getButtonHighlightColor(color, isDarkMode: isDarkMode);
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isPressed ? [] : getShadow(color, isDarkMode: isDarkMode),
    );
  }

  // Get consistent text styles
  static TextStyle getHeadingStyle(Color color) {
    return TextStyle(
      fontSize: timerFontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle getSubheadingStyle(Color color) {
    return TextStyle(
      fontSize: timerFontSizeSmall,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle getBodyStyle(Color color) {
    return TextStyle(
      fontSize: mediumFontSize,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle getCaptionStyle(Color color) {
    return TextStyle(
      fontSize: smallFontSize,
      color: color,
      letterSpacing: -0.1,
    );
  }

  static TextStyle heading({required Color color}) {
    return TextStyle(
      fontSize: headingFontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle subheading({required Color color}) {
    return TextStyle(
      fontSize: subheadingFontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle body({required Color color}) {
    return TextStyle(
      fontSize: bodyFontSize,
      color: color,
    );
  }

  static TextStyle caption({required Color color}) {
    return TextStyle(
      fontSize: captionFontSize,
      color: color,
    );
  }

  // Utility method to determine if the app is in dark mode
  static bool isDarkMode(BuildContext context) {
    return CupertinoTheme.of(context).brightness == Brightness.dark;
  }

  // Helper method to get a slightly modified button color based on theme
  static Color getButtonColor(BuildContext context) {
    final baseColor = isDarkMode(context)
        ? const Color(0xFF303030) // Dark gray for dark mode
        : const Color(0xFFE0E0E0); // Light gray for light mode

    return baseColor.withAlpha(opacityToAlpha(mediumOpacity)); // 70% opacity
  }

  // Helper method to get a slightly modified card color based on theme
  static Color getCardColor(BuildContext context) {
    final baseColor = isDarkMode(context)
        ? const Color(0xFF262626) // Dark gray for dark mode
        : const Color(0xFFF5F5F5); // Light gray for light mode

    return baseColor.withAlpha(opacityToAlpha(highOpacity)); // 90% opacity
  }
}
