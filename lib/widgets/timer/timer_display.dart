import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class TimerDisplay extends StatelessWidget {
  final SettingsProvider settings;

  const TimerDisplay({
    super.key,
    required this.settings,
  });

  String _formatTime(Duration? duration) {
    if (duration == null) {
      return '00:00';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    // Format with proper spacing based on hours
    if (hours > 0) {
      return ' $hours:$minutes:$seconds'; // Space at start for alignment
    } else {
      return ' $minutes:$seconds'; // Space at start for alignment
    }
  }

  Color _getProgressColor(bool isBreak, BuildContext context) {
    final theme = settings.isDarkTheme;
    if (isBreak) {
      return theme
          ? CupertinoColors.activeGreen.darkColor
          : CupertinoColors.activeGreen;
    } else {
      return theme
          ? CupertinoColors.activeBlue.darkColor
          : CupertinoColors.activeBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(settings.isBreak, context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Check for extra small screens like iPhone SE
    final screenSize = MediaQuery.of(context).size;
    final isExtraSmallScreen = screenSize.width < 375;
    final isVerySmallScreen =
        screenSize.width < 320; // For iPhone 4S/5/SE (1st gen)

    // Check for landscape mode
    final isLandscape = screenSize.width > screenSize.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic size calculations
        final maxWidth = constraints.maxWidth;

        // Responsive font sizes - with more aggressive scaling for very small screens
        final timerFontSize = isVerySmallScreen
            ? ThemeConstants.timerFontSizeSmall -
                20 // Even more reduction for iPhone 4S/5/SE (1st gen)
            : isExtraSmallScreen
                ? ThemeConstants.timerFontSizeSmall - 10
                : isSmallScreen
                    ? ThemeConstants.timerFontSizeSmall - 4
                    : isTablet
                        ? ThemeConstants.timerFontSize + 12
                        : isLandscape && constraints.maxHeight < 400
                            ? ThemeConstants.timerFontSizeSmall - 12
                            : ThemeConstants.timerFontSize;

        return Container(
          width: maxWidth,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer text with improved overflow handling using FittedBox
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minHeight:
                      isVerySmallScreen ? 50 : (isExtraSmallScreen ? 60 : 80),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    _formatTime(settings.remainingTime),
                    style: TextStyle(
                      fontSize: timerFontSize,
                      fontWeight: FontWeight.w300,
                      color: settings.textColor,
                      letterSpacing: -0.5,
                      fontFamily: '.SF UI Display',
                      fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ],
                      height: 1.0, // Ensure consistent line height
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .visible, // Allow FittedBox to handle overflow
                  ),
                ),
              ),

              // Fixed size spacer to prevent layout shifts
              SizedBox(
                height: isTablet
                    ? ThemeConstants.smallSpacing
                    : isVerySmallScreen
                        ? ThemeConstants.tinySpacing / 2
                        : isExtraSmallScreen
                            ? ThemeConstants.tinySpacing
                            : ThemeConstants.smallSpacing / 2,
              ),

              // Status text with fixed size container to prevent layout shifts
              AnimatedContainer(
                duration: ThemeConstants.mediumAnimation,
                height: isTablet
                    ? 40
                    : isVerySmallScreen
                        ? 24
                        : isExtraSmallScreen
                            ? 28
                            : 32,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated status indicator with fixed position
                    Container(
                      width:
                          isVerySmallScreen ? 5 : (isExtraSmallScreen ? 6 : 8),
                      height:
                          isVerySmallScreen ? 5 : (isExtraSmallScreen ? 6 : 8),
                      margin: EdgeInsets.only(
                          right: isVerySmallScreen
                              ? 3
                              : (isExtraSmallScreen ? 4 : 6)),
                      decoration: BoxDecoration(
                        color: settings.isTimerRunning
                            ? (settings.isTimerPaused
                                ? CupertinoColors.systemYellow
                                : progressColor)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Status text with container to prevent layout shifts
                    Container(
                      constraints: BoxConstraints(
                        minWidth: isTablet
                            ? 100
                            : isVerySmallScreen
                                ? 50
                                : isExtraSmallScreen
                                    ? 60
                                    : 80,
                      ),
                      child: Text(
                        settings.isTimerRunning
                            ? (settings.isTimerPaused ? 'Paused' : 'Running')
                            : settings.isBreak
                                ? (settings.shouldTakeLongBreak()
                                    ? 'Long Break'
                                    : 'Short Break')
                                : 'Ready',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet
                              ? ThemeConstants.smallFontSize + 2
                              : isVerySmallScreen
                                  ? ThemeConstants.smallFontSize - 2
                                  : isExtraSmallScreen
                                      ? ThemeConstants.smallFontSize - 1
                                      : ThemeConstants.smallFontSize,
                          fontWeight: FontWeight.w400,
                          color: settings.textColor.withAlpha(
                              (ThemeConstants.mediumOpacity * 255).toInt()),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sessions counter section with improved animation and scaling
              AnimatedSize(
                duration: ThemeConstants.mediumAnimation,
                curve: Curves.easeInOut,
                child: !settings.isBreak
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet
                              ? 16
                              : isVerySmallScreen
                                  ? 4
                                  : isExtraSmallScreen
                                      ? 6
                                      : 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sessions until long break text
                            Text(
                              'Sessions until long break',
                              style: TextStyle(
                                fontSize: isTablet
                                    ? ThemeConstants.smallFontSize + 1
                                    : isVerySmallScreen
                                        ? ThemeConstants.smallFontSize - 2
                                        : isExtraSmallScreen
                                            ? ThemeConstants.smallFontSize - 1
                                            : ThemeConstants.smallFontSize,
                                color: settings.textColor.withAlpha(
                                    (ThemeConstants.mediumOpacity * 255)
                                        .toInt()),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(
                              height: isTablet
                                  ? 8.0
                                  : isVerySmallScreen
                                      ? 3.0
                                      : isExtraSmallScreen
                                          ? 4.0
                                          : 6.0,
                            ),
                            // Session dots with improved spacing
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet
                                    ? ThemeConstants.smallSpacing
                                    : isVerySmallScreen
                                        ? ThemeConstants.tinySpacing / 2
                                        : ThemeConstants.tinySpacing,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  settings.sessionsBeforeLongBreak,
                                  (index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet
                                          ? 6.0
                                          : isVerySmallScreen
                                              ? 2.0
                                              : isExtraSmallScreen
                                                  ? 3.0
                                                  : 4.0,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: ThemeConstants.mediumAnimation,
                                      child: Icon(
                                        index < settings.completedSessions
                                            ? CupertinoIcons.circle_fill
                                            : CupertinoIcons.circle,
                                        key: ValueKey(
                                            index < settings.completedSessions),
                                        size: isTablet
                                            ? 16
                                            : isVerySmallScreen
                                                ? 8
                                                : isExtraSmallScreen
                                                    ? 10
                                                    : 12,
                                        color:
                                            index < settings.completedSessions
                                                ? progressColor
                                                : settings.textColor.withAlpha(
                                                    (ThemeConstants.lowOpacity *
                                                            255)
                                                        .toInt()),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: isLandscape
                            ? 0
                            : (isTablet
                                ? 16
                                : isVerySmallScreen
                                    ? 4
                                    : 8),
                      ), // Empty space for break mode with adaptive sizing
              ),
            ],
          ),
        );
      },
    );
  }
}
