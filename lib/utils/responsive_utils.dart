import 'package:flutter/cupertino.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  /// Screen size breakpoints
  static const double smallScreenWidth = 375;
  static const double mediumScreenWidth = 768;
  static const double largeScreenWidth = 1024;
  static const double extraLargeScreenWidth = 1280;

  /// Check if the current device is a small phone (like iPhone SE)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < smallScreenWidth;
  }

  /// Check if the current device is a tablet (iPad)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mediumScreenWidth;
  }

  /// Check if the current device is a large tablet
  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeScreenWidth;
  }

  /// Check if the current device is an extra large tablet or desktop
  static bool isExtraLargeDevice(BuildContext context) {
    return MediaQuery.of(context).size.width >= extraLargeScreenWidth;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isExtraLargeDevice(context)) {
      return const EdgeInsets.all(32.0);
    } else if (isLargeTablet(context)) {
      return const EdgeInsets.all(28.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get responsive horizontal padding based on screen size
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isExtraLargeDevice(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else if (isLargeTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 28.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 12.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  /// Get responsive font size based on screen size with improved scaling for large screens
  static double getResponsiveFontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isExtraLargeDevice(context)) {
      // More aggressive scaling for extremely large screens
      return large * 1.2;
    } else if (isLargeTablet(context)) {
      return large;
    } else if (isTablet(context)) {
      return medium;
    } else {
      return small;
    }
  }

  /// Get responsive item count for grids based on screen size
  static int getResponsiveGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > MediaQuery.of(context).size.height;

    if (isExtraLargeDevice(context)) {
      return isLandscape
          ? 5
          : 4; // 5 columns for extra large landscape, 4 for portrait
    } else if (isLargeTablet(context)) {
      return isLandscape
          ? 4
          : 3; // 4 columns for large tablet landscape, 3 for portrait
    } else if (isTablet(context)) {
      return isLandscape
          ? 3
          : 2; // 3 columns for tablet landscape, 2 for portrait
    } else if (width >= 600) {
      return isLandscape
          ? 3
          : 2; // 3 columns for large phone landscape, 2 for portrait
    } else {
      return isLandscape
          ? 2
          : 1; // 2 columns for phone landscape, 1 for portrait
    }
  }

  /// Get responsive width for containers based on screen size and percentage
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Get responsive height for containers based on screen size and percentage
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Get responsive size for icons based on screen size
  static double getResponsiveIconSize(BuildContext context) {
    if (isExtraLargeDevice(context)) {
      return 32.0;
    } else if (isLargeTablet(context)) {
      return 30.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else if (isSmallScreen(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  /// Get responsive button height based on screen size
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isExtraLargeDevice(context)) {
      return 60.0;
    } else if (isLargeTablet(context)) {
      return 58.0;
    } else if (isTablet(context)) {
      return 56.0;
    } else if (isSmallScreen(context)) {
      return 44.0;
    } else {
      return 48.0;
    }
  }
}
