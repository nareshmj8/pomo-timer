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
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              borderRadius: BorderRadius.circular(8.0),
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
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: buttonWidth,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              borderRadius: BorderRadius.circular(8.0),
              color: CupertinoColors.systemGrey5,
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
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.systemRed,
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
