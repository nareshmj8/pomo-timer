import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
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
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Color _getContrastingColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? CupertinoColors.black
        : CupertinoColors.white;
  }

  @override
  Widget build(BuildContext context) {
    final contrastingColor = _getContrastingColor(settings.backgroundColor);
    final progressBackgroundColor = contrastingColor.withAlpha(26);
    final progressColor = settings.isBreak
        ? CupertinoColors.activeGreen
        : CupertinoColors.activeBlue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          settings.isBreak
              ? (settings.shouldTakeLongBreak() ? 'Long Break' : 'Short Break')
              : settings.selectedCategory,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: contrastingColor.withAlpha(153),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: CircularProgressIndicator(
                value: settings.progress,
                strokeWidth: 10,
                backgroundColor: progressBackgroundColor,
                color: progressColor,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              _formatTime(settings.remainingTime),
              style: TextStyle(
                fontSize: 68,
                fontWeight: FontWeight.w300,
                color: contrastingColor,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!settings.isBreak)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              settings.sessionsBeforeLongBreak,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  index < settings.completedSessions
                      ? CupertinoIcons.circle_fill
                      : CupertinoIcons.circle,
                  size: 12,
                  color: index < settings.completedSessions
                      ? progressColor
                      : contrastingColor.withAlpha(77),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
