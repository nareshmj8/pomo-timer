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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          settings.isBreak
              ? (settings.shouldTakeLongBreak() ? 'Long Break' : 'Short Break')
              : settings.selectedCategory,
          style: const TextStyle(
            fontSize: 20,
            color: CupertinoColors.systemGrey,
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
                strokeWidth: 8,
                backgroundColor: CupertinoColors.systemGrey6,
                color: settings.isBreak
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.activeBlue,
              ),
            ),
            Text(
              _formatTime(settings.remainingTime),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: CupertinoColors.label,
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
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
