import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pomodoro_timemaster/models/timer_state.dart';
import 'package:pomodoro_timemaster/models/timer_status.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  late TimerState _timerState;

  TimerService() {
    _timerState = TimerState.initial();
  }

  TimerState get timerState => _timerState;
  bool get isRunning => _timerState.status == TimerStatus.running;

  void startTimer(int durationMinutes, Function onComplete) {
    if (isRunning) return;

    _timerState = TimerState(
      status: TimerStatus.running,
      timeRemaining: durationMinutes * 60,
      totalDuration: durationMinutes * 60,
      isBreak: false,
      progress: 1.0,
    );

    _startCountdown(onComplete);
    notifyListeners();
  }

  void startBreak(int durationMinutes, Function onComplete) {
    if (isRunning) return;

    _timerState = TimerState(
      status: TimerStatus.running,
      timeRemaining: durationMinutes * 60,
      totalDuration: durationMinutes * 60,
      isBreak: true,
      progress: 1.0,
    );

    _startCountdown(onComplete);
    notifyListeners();
  }

  void pauseTimer() {
    if (!isRunning) return;

    _timerState = _timerState.copyWith(
      status: TimerStatus.paused,
    );

    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer(Function onComplete) {
    if (_timerState.status != TimerStatus.paused) return;

    _timerState = _timerState.copyWith(
      status: TimerStatus.running,
    );

    _startCountdown(onComplete);
    notifyListeners();
  }

  void resetTimer(int defaultDurationMinutes) {
    _timer?.cancel();

    _timerState = const TimerState(
      status: TimerStatus.idle,
      timeRemaining: 0,
      totalDuration: 0,
      isBreak: false,
      progress: 1.0,
    );

    notifyListeners();
  }

  void _startCountdown(Function onComplete) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerState.status != TimerStatus.running) {
        timer.cancel();
        return;
      }

      if (_timerState.timeRemaining > 0) {
        int newTimeRemaining = _timerState.timeRemaining - 1;
        double newProgress = newTimeRemaining / _timerState.totalDuration;

        _timerState = _timerState.copyWith(
          timeRemaining: newTimeRemaining,
          progress: newProgress,
        );

        notifyListeners();
      } else {
        timer.cancel();

        _timerState = _timerState.copyWith(
          status: TimerStatus.completed,
          timeRemaining: 0,
          progress: 0.0,
        );

        onComplete();
        notifyListeners();
      }
    });
  }

  void loadState() {
    // Here we would normally load the state from SharedPreferences
    // For testing purposes, we'll just set a fixed state
    _timerState = const TimerState(
      status: TimerStatus.running,
      timeRemaining: 1200,
      totalDuration: 1500,
      isBreak: false,
      progress: 0.8,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
