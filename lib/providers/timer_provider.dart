import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isBreak = false;
  Duration? _remainingTime;
  Timer? _timer;
  double _progress = 1.0;
  late int _totalSeconds;
  bool _sessionCompleted = false;

  // Getters
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  bool get isBreak => _isBreak;
  Duration get remainingTime => _remainingTime ?? const Duration(minutes: 25);
  double get progress => _progress;
  bool get sessionCompleted => _sessionCompleted;

  void startTimer(int durationMinutes) {
    if (_isTimerRunning) return;
    _sessionCompleted = false;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: durationMinutes);
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown();
    notifyListeners();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime!.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime!.inSeconds - 1);
        _progress = _remainingTime!.inSeconds / _totalSeconds;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isTimerRunning = false;
        _sessionCompleted = true;
        notifyListeners();
      }
    });
  }

  // ... Add other timer-related methods (pauseTimer, resumeTimer, etc.)

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
