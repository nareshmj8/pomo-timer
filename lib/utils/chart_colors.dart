import 'package:flutter/cupertino.dart';
import 'theme_constants.dart';

/// Utility for managing color schemes in charts with accessibility considerations
class ChartColors {
  /// Default color schemes that work well in both light and dark modes
  /// Each color has sufficient contrast and is distinguishable in both modes
  static List<Color> getAccessibleColorScheme({required bool isDarkMode}) {
    return isDarkMode
        ? [
            // Optimized dark mode colors with improved contrast
            const Color(0xFF5DADE2), // Bright blue
            const Color(0xFF58D68D), // Bright green
            const Color(0xFFF4D03F), // Bright yellow
            const Color(0xFFEC7063), // Bright red
            const Color(0xFFAF7AC5), // Bright purple
            const Color(0xFF45B39D), // Teal
            const Color(0xFFF5B041), // Orange
            const Color(0xFF5499C7), // Medium blue
          ]
        : [
            // Light mode colors with good contrast
            const Color(0xFF2E86C1), // Dark blue
            const Color(0xFF27AE60), // Dark green
            const Color(0xFFF1C40F), // Yellow
            const Color(0xFFE74C3C), // Red
            const Color(0xFF8E44AD), // Purple
            const Color(0xFF16A085), // Teal
            const Color(0xFFD35400), // Dark orange
            const Color(0xFF3498DB), // Medium blue
          ];
  }

  /// Get colors for specific chart types
  static List<Color> getCategoryColors({required bool isDarkMode}) {
    return isDarkMode
        ? [
            // Category colors for dark mode with additional brightness
            const Color(0xFF5DADE2), // Blue
            const Color(0xFF58D68D), // Green
            const Color(0xFFF4D03F), // Yellow
            const Color(0xFFEC7063), // Red
            const Color(0xFFAF7AC5), // Purple
            const Color(0xFF45B39D), // Teal
          ]
        : [
            // Category colors for light mode
            const Color(0xFF2E86C1), // Blue
            const Color(0xFF27AE60), // Green
            const Color(0xFFF1C40F), // Yellow
            const Color(0xFFE74C3C), // Red
            const Color(0xFF8E44AD), // Purple
            const Color(0xFF16A085), // Teal
          ];
  }

  /// Get accessible line chart colors
  static Map<String, Color> getLineChartColors({required bool isDarkMode}) {
    return {
      'focus': isDarkMode ? const Color(0xFF5DADE2) : const Color(0xFF2E86C1),
      'break': isDarkMode ? const Color(0xFF58D68D) : const Color(0xFF27AE60),
      'average': isDarkMode ? const Color(0xFFF5B041) : const Color(0xFFD35400),
      'grid': isDarkMode
          ? const Color(0xFF4A4A4A) // Darker grid lines for dark mode
          : const Color(0xFFD0D0D0), // Lighter grid lines for light mode
      'text': isDarkMode
          ? const Color(0xFFE0E0E0) // Brighter text for dark mode
          : const Color(0xFF333333), // Darker text for light mode
    };
  }

  /// Get specific accessible pie chart colors
  static List<Color> getPieChartColors({required bool isDarkMode}) {
    return getAccessibleColorScheme(isDarkMode: isDarkMode);
  }

  /// Get accessible bar chart colors
  static List<Color> getBarChartColors({required bool isDarkMode}) {
    return getAccessibleColorScheme(isDarkMode: isDarkMode);
  }

  /// Generate a gradient for line charts with accessibility in mind
  static LinearGradient getAccessibleGradient(
      {required Color color,
      required bool isDarkMode,
      bool isVertical = false}) {
    final startColor = isDarkMode
        ? color.withAlpha(
            ThemeConstants.opacityToAlpha(0.6)) // 60% opacity for dark mode
        : color.withAlpha(
            ThemeConstants.opacityToAlpha(0.5)); // 50% opacity for light mode

    final endColor = isDarkMode
        ? color.withAlpha(
            ThemeConstants.opacityToAlpha(0.2)) // 20% opacity for dark mode
        : color.withAlpha(
            ThemeConstants.opacityToAlpha(0.1)); // 10% opacity for light mode

    return LinearGradient(
      begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [startColor, endColor],
    );
  }

  /// Gets gradient colors suitable for charts in both dark and light mode
  static List<Color> getGradientColors({required bool isDarkMode}) {
    return isDarkMode
        ? [
            const Color(0xFF5DADE2), // Blue
            const Color(0xFF58D68D), // Green
            const Color(0xFFF5B041), // Orange
            const Color(0xFFEC7063), // Red
          ]
        : [
            const Color(0xFF2E86C1), // Blue
            const Color(0xFF27AE60), // Green
            const Color(0xFFD35400), // Orange
            const Color(0xFFE74C3C), // Red
          ];
  }

  /// Gets the color for positive/negative trends with accessibility in mind
  static Color getTrendColor(
      {required bool isPositive, required bool isDarkMode}) {
    if (isPositive) {
      // Positive trend colors (green)
      return isDarkMode
          ? const Color(0xFF58D68D) // Brighter green for dark mode
          : const Color(0xFF27AE60); // Standard green for light mode
    } else {
      // Negative trend colors (red)
      return isDarkMode
          ? const Color(0xFFEC7063) // Brighter red for dark mode
          : const Color(0xFFE74C3C); // Standard red for light mode
    }
  }

  /// Get high contrast color pairs that work in both light and dark mode
  static Map<String, Color> getHighContrastPair({required bool isDarkMode}) {
    return {
      'primary': isDarkMode
          ? const Color(0xFF5DADE2) // Bright blue for dark mode
          : const Color(0xFF2E86C1), // Dark blue for light mode
      'secondary': isDarkMode
          ? const Color(0xFFF5B041) // Bright orange for dark mode
          : const Color(0xFFD35400), // Dark orange for light mode
      'contrast': isDarkMode
          ? CupertinoColors.white // White text/elements for dark mode
          : CupertinoColors.black, // Black text/elements for light mode
    };
  }

  // Create a gradient based on a color
  static LinearGradient createGradient(Color color, bool isDarkMode,
      {bool isVertical = false}) {
    final startColor = isDarkMode
        ? color.withAlpha(
            ThemeConstants.opacityToAlpha(0.6)) // 60% opacity for dark mode
        : color.withAlpha(
            ThemeConstants.opacityToAlpha(0.5)); // 50% opacity for light mode

    final endColor = isDarkMode
        ? color.withAlpha(
            ThemeConstants.opacityToAlpha(0.2)) // 20% opacity for dark mode
        : color.withAlpha(
            ThemeConstants.opacityToAlpha(0.1)); // 10% opacity for light mode

    return LinearGradient(
      begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [startColor, endColor],
    );
  }
}
