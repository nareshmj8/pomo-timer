import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

void main() {
  group('ThemeConstants Basic Properties', () {
    test('should have correct corner radius values', () {
      expect(ThemeConstants.smallRadius, 8.0);
      expect(ThemeConstants.mediumRadius, 12.0);
      expect(ThemeConstants.largeRadius, 16.0);
      expect(ThemeConstants.extraLargeRadius, 24.0);
    });

    test('should have correct spacing values', () {
      expect(ThemeConstants.tinySpacing, 4.0);
      expect(ThemeConstants.smallSpacing, 8.0);
      expect(ThemeConstants.mediumSpacing, 16.0);
      expect(ThemeConstants.largeSpacing, 24.0);
      expect(ThemeConstants.extraLargeSpacing, 32.0);
    });

    test('should have correct font size values', () {
      expect(ThemeConstants.smallFontSize, 13.0);
      expect(ThemeConstants.mediumFontSize, 16.0);
      expect(ThemeConstants.largeFontSize, 20.0);
      expect(ThemeConstants.extraLargeFontSize, 28.0);
      expect(ThemeConstants.timerFontSize, 72.0);
      expect(ThemeConstants.timerFontSizeSmall, 64.0);
      expect(ThemeConstants.headingFontSize, 20.0);
      expect(ThemeConstants.subheadingFontSize, 18.0);
      expect(ThemeConstants.bodyFontSize, 16.0);
      expect(ThemeConstants.captionFontSize, 14.0);
    });

    test('should have correct icon size values', () {
      expect(ThemeConstants.smallIconSize, 16.0);
      expect(ThemeConstants.mediumIconSize, 24.0);
      expect(ThemeConstants.largeIconSize, 32.0);
    });

    test('should have correct button height values', () {
      expect(ThemeConstants.standardButtonHeight, 48.0);
      expect(ThemeConstants.smallButtonHeight, 36.0);
    });

    test('should have correct border width values', () {
      expect(ThemeConstants.thinBorder, 0.5);
      expect(ThemeConstants.standardBorder, 1.0);
      expect(ThemeConstants.thickBorder, 2.0);
      expect(ThemeConstants.borderWidth, 1.0);
      expect(ThemeConstants.separatorWidth, 0.5);
    });

    test('should have correct opacity values', () {
      expect(ThemeConstants.highOpacity, 0.9);
      expect(ThemeConstants.mediumOpacity, 0.7);
      expect(ThemeConstants.lowOpacity, 0.3);
      expect(ThemeConstants.veryLowOpacity, 0.1);
      expect(ThemeConstants.disabledOpacity, 0.5);
      expect(ThemeConstants.activeOpacity, 0.8);
    });

    test('should have correct animation duration values', () {
      expect(ThemeConstants.shortAnimation, const Duration(milliseconds: 150));
      expect(ThemeConstants.mediumAnimation, const Duration(milliseconds: 300));
      expect(ThemeConstants.longAnimation, const Duration(milliseconds: 500));
      expect(
          ThemeConstants.animationDuration, const Duration(milliseconds: 300));
    });
  });

  group('ThemeConstants Shadow Methods', () {
    test('getShadow should return a list with one BoxShadow', () {
      const testColor = Colors.black;
      final shadows = ThemeConstants.getShadow(testColor);

      expect(shadows, isA<List<BoxShadow>>());
      expect(shadows.length, 1);
      expect(shadows[0].color, testColor.withAlpha((0.1 * 255).toInt()));
      expect(shadows[0].blurRadius, 8);
      expect(shadows[0].offset, const Offset(0, 2));
    });

    test('shadow should have correct properties', () {
      expect(ThemeConstants.shadow, isA<List<BoxShadow>>());
      expect(ThemeConstants.shadow.length, 1);
      expect(
          ThemeConstants.shadow[0].color, const Color.fromRGBO(0, 0, 0, 0.1));
      expect(ThemeConstants.shadow[0].blurRadius, 8);
      expect(ThemeConstants.shadow[0].offset, const Offset(0, 2));
    });
  });

  group('ThemeConstants Text Style Methods', () {
    const testColor = Colors.blue;

    test('getHeadingStyle should return correct text style', () {
      final style = ThemeConstants.getHeadingStyle(testColor);

      expect(style.fontSize, ThemeConstants.timerFontSize);
      expect(style.fontWeight, FontWeight.bold);
      expect(style.color, testColor);
    });

    test('getSubheadingStyle should return correct text style', () {
      final style = ThemeConstants.getSubheadingStyle(testColor);

      expect(style.fontSize, ThemeConstants.timerFontSizeSmall);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, testColor);
    });

    test('getBodyStyle should return correct text style', () {
      final style = ThemeConstants.getBodyStyle(testColor);

      expect(style.fontSize, ThemeConstants.mediumFontSize);
      expect(style.color, testColor);
      expect(style.letterSpacing, -0.2);
    });

    test('getCaptionStyle should return correct text style', () {
      final style = ThemeConstants.getCaptionStyle(testColor);

      expect(style.fontSize, ThemeConstants.smallFontSize);
      expect(style.color, testColor);
      expect(style.letterSpacing, -0.1);
    });

    test('heading method should return correct text style', () {
      final style = ThemeConstants.heading(color: testColor);

      expect(style.fontSize, ThemeConstants.headingFontSize);
      expect(style.fontWeight, FontWeight.bold);
      expect(style.color, testColor);
    });

    test('subheading method should return correct text style', () {
      final style = ThemeConstants.subheading(color: testColor);

      expect(style.fontSize, ThemeConstants.subheadingFontSize);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, testColor);
    });

    test('body method should return correct text style', () {
      final style = ThemeConstants.body(color: testColor);

      expect(style.fontSize, ThemeConstants.bodyFontSize);
      expect(style.color, testColor);
    });

    test('caption method should return correct text style', () {
      final style = ThemeConstants.caption(color: testColor);

      expect(style.fontSize, ThemeConstants.captionFontSize);
      expect(style.color, testColor);
    });
  });
}
