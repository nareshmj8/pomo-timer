import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  String _selectedCategory = 'Work';
  final List<String> _categories = ['Work', 'Study', 'Life'];
  bool _dialogShown = false;

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _showCompletionDialog(SettingsProvider settings) {
    if (_dialogShown) return;
    _dialogShown = true;

    final isLongBreakDue = settings.shouldTakeLongBreak();

    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Session Complete!'),
        content: Text(isLongBreakDue
            ? 'Great job! Would you like to take a long break?'
            : 'Would you like to take a short break?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Skip'),
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
            child: const Text('Start Break'),
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

        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text(
              'Home',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: CupertinoColors.systemBackground,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTopSection(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            settings.isBreak
                                ? (settings.shouldTakeLongBreak()
                                    ? 'Long Break'
                                    : 'Short Break')
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                      ),
                    ),
                  ),
                  _buildBottomSection(settings),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Category:',
              style: TextStyle(
                fontSize: 17,
                color: CupertinoColors.label,
              ),
            ),
            GestureDetector(
              onTap: () => showCupertinoModalPopup<void>(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoActionSheet(
                    title: const Text('Select Category'),
                    actions: _categories
                        .map(
                          (category) => CupertinoActionSheetAction(
                            onPressed: () {
                              settings.setSelectedCategory(category);
                              Navigator.pop(context);
                            },
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  );
                },
              ),
              child: Row(
                children: [
                  Text(
                    settings.selectedCategory,
                    style: const TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: CupertinoColors.activeBlue,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSection(SettingsProvider settings) {
    const double buttonWidth = 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
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
