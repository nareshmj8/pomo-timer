import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isBreak = false;
  Duration? _remainingTime;
  double _progress = 1.0;
  late int _totalSeconds;
  bool _sessionCompleted = false;

  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  bool get isBreak => _isBreak;
  bool get sessionCompleted => _sessionCompleted;
  double get progress => _progress;
  Duration get remainingTime => _remainingTime ?? const Duration(minutes: 25);

  void startTimer(int durationMinutes, Function onComplete) {
    if (_isTimerRunning) return;
    _sessionCompleted = false;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: durationMinutes);
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown(onComplete);
    notifyListeners();
  }

  void startBreak(int durationMinutes, Function onComplete) {
    if (_isTimerRunning) return;
    _sessionCompleted = false;
    _isBreak = true;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _remainingTime = Duration(minutes: durationMinutes);
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown(onComplete);
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isTimerRunning) return;
    _isTimerPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer(Function onComplete) {
    if (!_isTimerRunning || !_isTimerPaused) return;
    _isTimerPaused = false;
    _startCountdown(onComplete);
    notifyListeners();
  }

  void resetTimer(int defaultDurationMinutes) {
    _timer?.cancel();
    _isTimerRunning = false;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: defaultDurationMinutes);
    _progress = 1.0;
    notifyListeners();
  }

  void setSessionCompleted(bool value) {
    _sessionCompleted = value;
    notifyListeners();
  }

  void _startCountdown(Function onComplete) {
    _timer?.cancel();
    _sessionCompleted = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerPaused || !_isTimerRunning) {
        timer.cancel();
        return;
      }

      if (_remainingTime!.inSeconds > 0) {
        _remainingTime = _remainingTime! - const Duration(seconds: 1);
        _progress = _remainingTime!.inSeconds / _totalSeconds;
        notifyListeners();
      } else {
        timer.cancel();
        _isTimerRunning = false;
        _isTimerPaused = false;
        _sessionCompleted = true;
        onComplete();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
