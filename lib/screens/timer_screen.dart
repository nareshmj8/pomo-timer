import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer/timer_display.dart';
import '../widgets/timer/timer_controls.dart';
import '../widgets/timer/category_selector.dart';

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

    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          'Session Complete!',
          style: TextStyle(
            color: settings.textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          isLongBreakDue
              ? 'Great job! Would you like to take a long break?'
              : 'Would you like to take a short break?',
          style: TextStyle(
            color: settings.textColor.withOpacity(0.8),
            fontSize: 13,
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
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
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

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: settings.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: settings.separatorColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            middle: Text(
              'Home',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CategorySelector(
                    settings: settings,
                    categories: _categories,
                  ),
                  Expanded(
                    child: Center(
                      child: TimerDisplay(settings: settings),
                    ),
                  ),
                  TimerControls(settings: settings),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
