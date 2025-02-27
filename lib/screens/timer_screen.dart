import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
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
            color: Provider.of<ThemeProvider>(context).textColor,
          ),
        ),
        content: Text(
          isLongBreakDue
              ? 'Great job! Would you like to take a long break?'
              : 'Would you like to take a short break?',
          style: TextStyle(
            color: Provider.of<ThemeProvider>(context).textColor,
          ),
        ),
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
          backgroundColor: Provider.of<ThemeProvider>(context).backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Home',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Provider.of<ThemeProvider>(context).textColor,
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
