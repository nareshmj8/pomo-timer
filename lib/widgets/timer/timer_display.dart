import 'package:flutter/cupertino.dart';
import '../../providers/settings_provider.dart';

class TimerDisplay extends StatelessWidget {
  final SettingsProvider settings;

  const TimerDisplay({
    super.key,
    required this.settings,
  });

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds'.padLeft(8, ' ');
    } else {
      return '$minutes:$seconds'.padLeft(5, ' ');
    }
  }

  Color _getProgressColor(bool isBreak) {
    if (isBreak) {
      return CupertinoColors.activeGreen;
    } else {
      return CupertinoColors.activeBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(settings.isBreak);
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 375;

    return LayoutBuilder(
      builder: (context, constraints) {
        final timerFontSize = isSmallScreen ? 64.0 : 72.0;
        final labelFontSize = isSmallScreen ? 18.0 : 20.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: settings.textColor.withOpacity(0.8),
                letterSpacing: -0.5,
              ),
              child: Text(
                settings.isBreak
                    ? (settings.shouldTakeLongBreak()
                        ? 'Long Break'
                        : 'Short Break')
                    : settings.selectedCategory,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: constraints.maxWidth,
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: timerFontSize,
                  fontWeight: FontWeight.w400,
                  color: settings.textColor,
                  letterSpacing: 0,
                  fontFamily: 'Menlo',
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
                child: Text(
                  _formatTime(settings.remainingTime),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!settings.isBreak)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: settings.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: settings.separatorColor.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    settings.sessionsBeforeLongBreak,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          index < settings.completedSessions
                              ? CupertinoIcons.circle_fill
                              : CupertinoIcons.circle,
                          key: ValueKey(index < settings.completedSessions),
                          size: 12,
                          color: index < settings.completedSessions
                              ? progressColor
                              : settings.secondaryTextColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
