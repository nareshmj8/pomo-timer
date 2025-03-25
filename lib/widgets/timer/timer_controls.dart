import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../providers/settings_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/theme_constants.dart';

class TimerControls extends StatelessWidget {
  final SettingsProvider settings;

  const TimerControls({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDarkTheme = settings.isDarkTheme;

    // Responsive button width
    final double buttonWidth = isSmallScreen
        ? 160.0
        : isTablet
            ? 200.0
            : 180.0;

    // Text colors based on theme and state
    const primaryTextColor = CupertinoColors.white;

    // Responsive font and padding sizes
    final buttonFontSize = isSmallScreen
        ? ThemeConstants.bodyFontSize - 1
        : isTablet
            ? ThemeConstants.bodyFontSize + 2
            : ThemeConstants.bodyFontSize;

    final buttonPadding = isSmallScreen
        ? 10.0
        : isTablet
            ? 16.0
            : 12.0;

    final buttonRadius =
        isTablet ? ThemeConstants.mediumRadius : ThemeConstants.smallRadius;

    // Determine the button colors based on timer state
    final startButtonColor = settings.isBreak
        ? (isDarkTheme
            ? CupertinoColors.activeGreen.darkColor
            : CupertinoColors.activeGreen)
        : (isDarkTheme
            ? CupertinoColors.activeBlue.darkColor
            : CupertinoColors.activeBlue);

    final resetButtonColor = isDarkTheme
        ? const Color(0xFF2C2C2E) // Dark gray for dark mode
        : const Color(0xFFE5E5EA); // Light gray for light mode

    // Build the appropriate button based on timer state
    Widget buildTimerButton() {
      if (settings.isTimerRunning) {
        // Show pause/resume button
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (settings.isTimerPaused) {
              settings.resumeTimer();
            } else {
              settings.pauseTimer();
            }
          },
          child: Container(
            width: buttonWidth,
            padding: EdgeInsets.symmetric(vertical: buttonPadding),
            decoration: BoxDecoration(
              color:
                  settings.isTimerPaused ? startButtonColor : resetButtonColor,
              borderRadius: BorderRadius.circular(buttonRadius),
              border: Border.all(
                color: settings.isTimerPaused
                    ? startButtonColor
                    : startButtonColor.withAlpha((0.5 * 255).toInt()),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                settings.isTimerPaused ? 'Resume' : 'Pause',
                style: TextStyle(
                  color: settings.isTimerPaused
                      ? primaryTextColor
                      : startButtonColor,
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        );
      } else {
        // Show start button
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.mediumImpact();
            settings.startTimer();
          },
          child: Container(
            width: buttonWidth,
            padding: EdgeInsets.symmetric(vertical: buttonPadding),
            decoration: BoxDecoration(
              color: startButtonColor,
              borderRadius: BorderRadius.circular(buttonRadius),
              boxShadow: [
                BoxShadow(
                  color: startButtonColor.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Start',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Build the reset button
    Widget buildResetButton() {
      return Opacity(
        opacity: settings.isTimerRunning ? 1.0 : 0.5,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: settings.isTimerRunning
              ? () {
                  HapticFeedback.mediumImpact();
                  settings.resetTimer();
                }
              : null,
          child: Container(
            width: buttonWidth * 0.5,
            padding: EdgeInsets.symmetric(vertical: buttonPadding),
            decoration: BoxDecoration(
              color: resetButtonColor,
              borderRadius: BorderRadius.circular(buttonRadius),
              border: Border.all(
                color: settings.isTimerRunning
                    ? startButtonColor.withAlpha((0.5 * 255).toInt())
                    : startButtonColor.withAlpha((0.2 * 255).toInt()),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                'Reset',
                style: TextStyle(
                  color: settings.isTimerRunning
                      ? startButtonColor
                      : startButtonColor.withAlpha((0.5 * 255).toInt()),
                  fontSize: buttonFontSize - 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Build the skip button (only shown during breaks)
    Widget buildSkipButton() {
      return Opacity(
        opacity: settings.isBreak ? 1.0 : 0.5,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: settings.isBreak
              ? () {
                  HapticFeedback.mediumImpact();
                  settings.resetTimer();
                }
              : null,
          child: Container(
            width: buttonWidth * 0.5,
            padding: EdgeInsets.symmetric(vertical: buttonPadding),
            decoration: BoxDecoration(
              color: resetButtonColor,
              borderRadius: BorderRadius.circular(buttonRadius),
              border: Border.all(
                color: settings.isBreak
                    ? startButtonColor.withAlpha((0.5 * 255).toInt())
                    : startButtonColor.withAlpha((0.2 * 255).toInt()),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                'Skip',
                style: TextStyle(
                  color: settings.isBreak
                      ? startButtonColor
                      : startButtonColor.withAlpha((0.5 * 255).toInt()),
                  fontSize: buttonFontSize - 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main timer button
        buildTimerButton(),

        const SizedBox(height: 12),

        // Secondary buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildResetButton(),
            const SizedBox(width: 12),
            buildSkipButton(),
          ],
        ),
      ],
    );
  }
}
