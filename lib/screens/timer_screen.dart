import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';
import 'package:pomodoro_timemaster/widgets/timer/timer_display.dart';
import '../utils/theme_constants.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final List<String> _categories = ['Work', 'Study', 'Life'];
  bool _dialogShown = false;

  void _showCompletionDialog(SettingsProvider settings) {
    if (_dialogShown) return;
    _dialogShown = true;

    final isLongBreakDue = settings.shouldTakeLongBreak();
    final isTablet = ResponsiveUtils.isTablet(context);

    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'Session Complete!',
          style: TextStyle(
            color: settings.textColor,
            fontSize: isTablet
                ? ThemeConstants.mediumFontSize + 1
                : ThemeConstants.mediumFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          isLongBreakDue
              ? 'Great job! Would you like to take a long break?'
              : 'Would you like to take a short break?',
          style: TextStyle(
            color: settings.textColor
                .withAlpha((ThemeConstants.highOpacity * 255).toInt()),
            fontSize: isTablet
                ? ThemeConstants.smallFontSize + 1
                : ThemeConstants.smallFontSize,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Skip',
              style: TextStyle(
                color: settings.textColor,
                fontWeight: FontWeight.w400,
                fontSize: isTablet
                    ? ThemeConstants.mediumFontSize
                    : ThemeConstants.mediumFontSize - 1,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _dialogShown = false;
              });
              settings.resetTimer();
              settings.setSessionCompleted(false);
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              'Start Break',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.activeBlue.darkColor
                    : CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
                fontSize: isTablet
                    ? ThemeConstants.mediumFontSize
                    : ThemeConstants.mediumFontSize - 1,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _dialogShown = false;
              });
              settings.startBreak();
              settings.setSessionCompleted(false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        if (settings.sessionCompleted && !settings.isBreak && !_dialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog(settings);
          });
        }

        if (settings.isTimerRunning) {
          _dialogShown = false;
        }

        final isTablet = ResponsiveUtils.isTablet(context);
        final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
        final screenSize = MediaQuery.of(context).size;

        // Determine if we're in landscape mode
        final isLandscape = screenSize.width > screenSize.height;

        // Use ResponsiveUtils for consistent padding
        final horizontalPadding =
            ResponsiveUtils.getResponsiveHorizontalPadding(context).horizontal;
        final verticalPadding = isLandscape
            ? (isTablet
                ? ThemeConstants.mediumSpacing
                : ThemeConstants.smallSpacing)
            : (isTablet
                ? ThemeConstants.largeSpacing
                : ThemeConstants.mediumSpacing);

        // Determine the mode color
        final modeColor = settings.isBreak
            ? (settings.isDarkTheme
                ? CupertinoColors.activeGreen.darkColor
                : CupertinoColors.activeGreen)
            : (settings.isDarkTheme
                ? CupertinoColors.activeBlue.darkColor
                : CupertinoColors.activeBlue);

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: settings.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: settings.separatorColor
                    .withAlpha((ThemeConstants.lowOpacity * 255).toInt()),
                width: ThemeConstants.thinBorder,
              ),
            ),
            middle: Text(
              'Pomodoro TimeMaster',
              style: TextStyle(
                fontSize: isTablet
                    ? ThemeConstants.mediumFontSize + 1
                    : (isSmallScreen
                        ? ThemeConstants.mediumFontSize - 1
                        : ThemeConstants.mediumFontSize),
                fontWeight: FontWeight.w600,
                color: settings.textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          child: SafeArea(
            // Use LayoutBuilder for more flexible layout
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Adapt layout for landscape mode
                if (isLandscape && !isTablet && constraints.maxHeight < 400) {
                  // Horizontal layout for small landscape screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Timer display (takes more space for better visibility)
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding / 2),
                          child: TimerDisplay(settings: settings),
                        ),
                      ),
                      // Controls (takes less space but remains usable)
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding / 1.5,
                            vertical: ThemeConstants.smallSpacing / 1.5,
                          ),
                          child: settings.isTimerRunning
                              ? _buildRunningControls(context, settings,
                                  isTablet, isSmallScreen, isLandscape)
                              : _buildInitialControls(context, settings,
                                  isTablet, isSmallScreen, isLandscape),
                        ),
                      ),
                    ],
                  );
                }

                // Special layout for tablets in landscape mode
                else if (isLandscape && isTablet) {
                  // Horizontal layout optimized for tablet landscape
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Timer display
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding),
                          child: TimerDisplay(settings: settings),
                        ),
                      ),
                      // Controls - more space on tablets
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding / 1.2,
                            vertical: verticalPadding / 1.2,
                          ),
                          child: settings.isTimerRunning
                              ? _buildRunningControls(context, settings,
                                  isTablet, isSmallScreen, isLandscape)
                              : _buildInitialControls(context, settings,
                                  isTablet, isSmallScreen, isLandscape),
                        ),
                      ),
                    ],
                  );
                }

                // Vertical layout for portrait and larger screens
                return Column(
                  children: [
                    // Timer display (takes most of the space)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Category selector
                            if (!settings.isBreak)
                              AnimatedContainer(
                                duration: ThemeConstants.mediumAnimation,
                                padding: EdgeInsets.only(
                                  bottom: isTablet
                                      ? ThemeConstants.mediumSpacing
                                      : isSmallScreen
                                          ? ThemeConstants.smallSpacing
                                          : ThemeConstants.mediumSpacing,
                                ),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () =>
                                      showCupertinoModalPopup<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoActionSheet(
                                        title: const Text('Select Category'),
                                        message: const Text(
                                            'Choose a category for your focus session'),
                                        actions: _categories
                                            .map(
                                              (category) =>
                                                  CupertinoActionSheetAction(
                                                onPressed: () {
                                                  settings.setSelectedCategory(
                                                      category);
                                                  Navigator.pop(context);
                                                },
                                                isDefaultAction: category ==
                                                    settings.selectedCategory,
                                                child: Text(category),
                                              ),
                                            )
                                            .toList(),
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      );
                                    },
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet
                                          ? ThemeConstants.mediumSpacing
                                          : isSmallScreen
                                              ? ThemeConstants.smallSpacing
                                              : ThemeConstants.mediumSpacing /
                                                  1.5,
                                      vertical: isTablet
                                          ? ThemeConstants.smallSpacing
                                          : isSmallScreen
                                              ? ThemeConstants.tinySpacing
                                              : ThemeConstants.tinySpacing *
                                                  1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: settings.backgroundColor,
                                      borderRadius: BorderRadius.circular(
                                          isTablet
                                              ? ThemeConstants.mediumRadius
                                              : ThemeConstants.smallRadius),
                                      border: Border.all(
                                        color: modeColor.withAlpha(
                                            (ThemeConstants.lowOpacity * 255)
                                                .toInt()),
                                        width: isTablet
                                            ? ThemeConstants.standardBorder +
                                                0.5
                                            : ThemeConstants.standardBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.tag,
                                          size: isTablet
                                              ? ThemeConstants.mediumIconSize *
                                                  0.75
                                              : isSmallScreen
                                                  ? ThemeConstants.smallIconSize
                                                  : ThemeConstants
                                                          .smallIconSize +
                                                      2,
                                          color: modeColor,
                                        ),
                                        SizedBox(
                                            width: isTablet
                                                ? ThemeConstants.smallSpacing
                                                : isSmallScreen
                                                    ? ThemeConstants.tinySpacing
                                                    : ThemeConstants
                                                            .tinySpacing +
                                                        1),
                                        Text(
                                          settings.selectedCategory,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? ThemeConstants.mediumFontSize
                                                : isSmallScreen
                                                    ? ThemeConstants
                                                        .smallFontSize
                                                    : ThemeConstants
                                                            .smallFontSize +
                                                        1,
                                            color: modeColor,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        SizedBox(
                                            width: isTablet
                                                ? ThemeConstants.smallSpacing
                                                : isSmallScreen
                                                    ? ThemeConstants.tinySpacing
                                                    : ThemeConstants
                                                            .tinySpacing +
                                                        1),
                                        Icon(
                                          CupertinoIcons.chevron_down,
                                          size: isTablet
                                              ? ThemeConstants.smallIconSize
                                              : isSmallScreen
                                                  ? ThemeConstants
                                                          .smallIconSize -
                                                      4
                                                  : ThemeConstants
                                                          .smallIconSize -
                                                      2,
                                          color: modeColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            // Wrap timer display in a flexible container to adapt to available space
                            Flexible(
                              child: TimerDisplay(settings: settings),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Timer controls with consistent spacing
                    SafeArea(
                      minimum: EdgeInsets.only(bottom: verticalPadding / 2),
                      child: AnimatedContainer(
                        duration: ThemeConstants.mediumAnimation,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: isTablet
                              ? ThemeConstants.mediumSpacing
                              : ThemeConstants.smallSpacing,
                        ),
                        child: settings.isTimerRunning
                            ? _buildRunningControls(context, settings, isTablet,
                                isSmallScreen, isLandscape)
                            : _buildInitialControls(context, settings, isTablet,
                                isSmallScreen, isLandscape),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialControls(BuildContext context, SettingsProvider settings,
      bool isTablet, bool isSmallScreen, bool isLandscape) {
    // Use fixed responsive values for consistent button sizing
    const double buttonHeight = 46.0;
    const double buttonHeightTablet = 52.0;
    const double buttonRadius = 10.0;
    const double fontSize = 15.0;
    const double fontSizeTablet = 16.0;
    const double iconSize = 18.0;
    const double iconSizeTablet = 20.0;
    const double spacing = 16.0;
    const double spacingTablet = 20.0;

    final double actualButtonHeight =
        isTablet ? buttonHeightTablet : buttonHeight;
    final double actualFontSize = isTablet ? fontSizeTablet : fontSize;
    final double actualIconSize = isTablet ? iconSizeTablet : iconSize;
    final double actualSpacing = isTablet ? spacingTablet : spacing;

    final startButtonColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;

    final breakButtonColor = settings.isDarkTheme
        ? CupertinoColors.activeGreen.darkColor
        : CupertinoColors.activeGreen;

    return AnimatedSize(
      duration: ThemeConstants.mediumAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              'Choose your session',
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 13.0,
                color: settings.textColor
                    .withAlpha((ThemeConstants.mediumOpacity * 255).toInt()),
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: actualSpacing),
          LayoutBuilder(builder: (context, constraints) {
            // Calculate button width based on available width
            final availableWidth = constraints.maxWidth;
            final idealButtonWidth = isTablet ? 160.0 : 140.0;
            final buttonGap = actualSpacing;
            // Calculate actual button width to fit in the available space
            final actualButtonWidth = ((availableWidth - buttonGap) / 2)
                .clamp(80.0, idealButtonWidth);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start button with standardized styling
                Flexible(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      settings.switchToFocusMode();
                      settings.startTimer();
                    },
                    child: Container(
                      width: actualButtonWidth,
                      height: actualButtonHeight,
                      decoration: BoxDecoration(
                        color: startButtonColor,
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.play_fill,
                            color: CupertinoColors.white,
                            size: actualIconSize,
                          ),
                          SizedBox(width: actualSpacing / 2),
                          Text(
                            'Start',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: actualFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: actualSpacing),

                // Break button with standardized styling
                Flexible(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      settings.switchToBreakMode();
                      settings.startBreak();
                    },
                    child: Container(
                      width: actualButtonWidth,
                      height: actualButtonHeight,
                      decoration: BoxDecoration(
                        color: breakButtonColor,
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.pause_fill,
                            color: CupertinoColors.white,
                            size: actualIconSize,
                          ),
                          SizedBox(width: actualSpacing / 2),
                          Text(
                            'Break',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: actualFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRunningControls(BuildContext context, SettingsProvider settings,
      bool isTablet, bool isSmallScreen, bool isLandscape) {
    // Use fixed responsive values for consistent button sizing
    const double buttonHeight = 46.0;
    const double buttonHeightTablet = 52.0;
    const double buttonRadius = 10.0;
    const double fontSize = 15.0;
    const double fontSizeTablet = 16.0;
    const double iconSize = 18.0;
    const double iconSizeTablet = 20.0;
    const double spacing = 16.0;
    const double spacingTablet = 20.0;

    final double actualButtonHeight =
        isTablet ? buttonHeightTablet : buttonHeight;
    final double actualFontSize = isTablet ? fontSizeTablet : fontSize;
    final double actualIconSize = isTablet ? iconSizeTablet : iconSize;
    final double actualSpacing = isTablet ? spacingTablet : spacing;

    final actionColor = settings.isBreak
        ? (settings.isDarkTheme
            ? CupertinoColors.activeGreen.darkColor
            : CupertinoColors.activeGreen)
        : (settings.isDarkTheme
            ? CupertinoColors.activeBlue.darkColor
            : CupertinoColors.activeBlue);

    final cancelColor = settings.isDarkTheme
        ? const Color(0xFF2C2C2E) // Dark gray for dark mode
        : const Color(0xFFE5E5EA); // Light gray for light mode

    return AnimatedSize(
      duration: ThemeConstants.mediumAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              settings.isBreak
                  ? 'Break in progress'
                  : 'Focus session in progress',
              style: TextStyle(
                fontSize: isTablet ? 14.0 : 13.0,
                color: settings.textColor
                    .withAlpha((ThemeConstants.mediumOpacity * 255).toInt()),
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: actualSpacing),
          LayoutBuilder(builder: (context, constraints) {
            // Calculate button width based on available width
            final availableWidth = constraints.maxWidth;
            final idealButtonWidth = isTablet ? 160.0 : 140.0;
            final buttonGap = actualSpacing;
            // Calculate actual button width to fit in the available space
            final actualButtonWidth = ((availableWidth - buttonGap) / 2)
                .clamp(80.0, idealButtonWidth);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume button with standardized styling
                Flexible(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (settings.isTimerPaused) {
                        settings.resumeTimer();
                      } else {
                        settings.pauseTimer();
                      }
                    },
                    child: Container(
                      width: actualButtonWidth,
                      height: actualButtonHeight,
                      decoration: BoxDecoration(
                        color: actionColor,
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: ThemeConstants.shortAnimation,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Icon(
                              settings.isTimerPaused
                                  ? CupertinoIcons.play_fill
                                  : CupertinoIcons.pause_fill,
                              key: ValueKey<bool>(settings.isTimerPaused),
                              color: CupertinoColors.white,
                              size: actualIconSize,
                            ),
                          ),
                          SizedBox(width: actualSpacing / 2),
                          Text(
                            settings.isTimerPaused ? 'Resume' : 'Pause',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: actualFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: actualSpacing),

                // Cancel button with standardized styling
                Flexible(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      settings.resetTimer();
                    },
                    child: Container(
                      width: actualButtonWidth,
                      height: actualButtonHeight,
                      decoration: BoxDecoration(
                        color: cancelColor,
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.xmark,
                            color: settings.textColor,
                            size: actualIconSize,
                          ),
                          SizedBox(width: actualSpacing / 2),
                          Text(
                            'Cancel',
                            style: TextStyle(
                              color: settings.textColor,
                              fontSize: actualFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
