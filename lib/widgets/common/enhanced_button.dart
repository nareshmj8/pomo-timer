import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import '../../utils/theme_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

/// An enhanced button component with better visual feedback,
/// especially optimized for dark mode
class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isFullWidth;
  final bool isOutlined;
  final double? height;
  final double? borderRadius;
  final EdgeInsets? padding;
  final double? fontSize;

  const EnhancedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.height,
    this.borderRadius,
    this.padding,
    this.fontSize,
  }) : super(key: key);

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDarkMode = settings.isDarkTheme;

    // Determine the button's base color
    final buttonColor = widget.color ??
        (isDarkMode
            ? CupertinoColors.activeBlue.darkColor
            : CupertinoColors.activeBlue);

    // Determine text/icon color
    final contentColor = widget.textColor ??
        (widget.isOutlined ? buttonColor : CupertinoColors.white);

    // Determine the button's height based on device
    final buttonHeight = widget.height ??
        (ResponsiveUtils.isTablet(context)
            ? ThemeConstants.standardButtonHeight + 4
            : ThemeConstants.standardButtonHeight);

    // Determine font size based on device
    final textSize =
        widget.fontSize ?? (ResponsiveUtils.isTablet(context) ? 17.0 : 16.0);

    // Get enhanced decoration with state-based appearance
    final decoration = widget.isOutlined
        ? BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
                widget.borderRadius ?? ThemeConstants.mediumRadius),
            border: Border.all(
              color: _isPressed
                  ? ThemeConstants.getButtonPressedColor(buttonColor,
                      isDarkMode: isDarkMode)
                  : _isHovered
                      ? ThemeConstants.getButtonHighlightColor(buttonColor,
                          isDarkMode: isDarkMode)
                      : buttonColor,
              width: 1.5,
            ),
          )
        : ThemeConstants.getStandardButtonDecoration(
            color: buttonColor,
            isDarkMode: isDarkMode,
            isPressed: _isPressed,
            isHighlighted: _isHovered,
            borderRadius: widget.borderRadius ?? ThemeConstants.mediumRadius,
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: ThemeConstants.shortAnimation,
          height: buttonHeight,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: decoration,
          child: Row(
            mainAxisSize:
                widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: contentColor,
                  size: textSize + 2,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: contentColor,
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to access ResponsiveUtils without import conflicts
class ResponsiveUtils {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }
}
