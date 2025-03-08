import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../providers/settings_provider.dart';

class TimerControls extends StatelessWidget {
  final SettingsProvider settings;

  const TimerControls({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonWidth = 100.0;
    final bool isDarkMode = settings.selectedTheme == 'Dark';

    // Primary button colors based on theme
    final primaryButtonColor = isDarkMode
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;

    // Secondary button colors based on theme
    final secondaryButtonColor =
        isDarkMode ? settings.secondaryBackgroundColor : CupertinoColors.white;
    final secondaryButtonBorder = Border.all(
      color: isDarkMode
          ? CupertinoColors.systemGrey.withOpacity(0.3)
          : CupertinoColors.systemGrey5,
      width: 1.0,
    );

    // Text colors based on theme and state
    final primaryTextColor = CupertinoColors.white;
    final secondaryTextColor = settings.isTimerRunning
        ? CupertinoColors.destructiveRed
        : CupertinoColors.activeBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: buttonWidth,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: settings.isTimerRunning && !settings.isTimerPaused
                  ? 0.8
                  : 1.0,
              child: CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                borderRadius: BorderRadius.circular(10.0),
                pressedOpacity: 0.6,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (!settings.isTimerRunning) {
                    settings.startTimer();
                  } else if (settings.isTimerPaused) {
                    settings.resumeTimer();
                  } else {
                    settings.pauseTimer();
                  }
                },
                child: Text(
                  !settings.isTimerRunning
                      ? 'Start'
                      : (settings.isTimerPaused ? 'Resume' : 'Pause'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: buttonWidth,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryButtonColor,
                border: secondaryButtonBorder,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: CupertinoColors.systemGrey5.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                borderRadius: BorderRadius.circular(10.0),
                color: secondaryButtonColor,
                pressedOpacity: 0.6,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (settings.isTimerRunning) {
                    settings.resetTimer();
                  } else {
                    settings.startBreak();
                  }
                },
                child: Text(
                  settings.isTimerRunning ? 'Reset' : 'Break',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double calculateInterval(double maxY) {
  if (maxY <= 5) return 1;
  if (maxY <= 10) return 2;
  return (maxY / 5).ceil().toDouble();
}

// Add gradient to bars
LinearGradient get barGradient => LinearGradient(
      colors: [
        CupertinoColors.systemBlue,
        CupertinoColors.systemBlue.withOpacity(0.7),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
