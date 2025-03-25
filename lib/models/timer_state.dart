import 'package:pomodoro_timemaster/models/timer_status.dart';

class TimerState {
  final TimerStatus status;
  final int timeRemaining;
  final int totalDuration;
  final bool isBreak;
  final double progress;

  const TimerState({
    required this.status,
    required this.timeRemaining,
    required this.totalDuration,
    required this.isBreak,
    required this.progress,
  });

  factory TimerState.initial() {
    return const TimerState(
      status: TimerStatus.idle,
      timeRemaining: 0,
      totalDuration: 0,
      isBreak: false,
      progress: 1.0,
    );
  }

  TimerState copyWith({
    TimerStatus? status,
    int? timeRemaining,
    int? totalDuration,
    bool? isBreak,
    double? progress,
  }) {
    return TimerState(
      status: status ?? this.status,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalDuration: totalDuration ?? this.totalDuration,
      isBreak: isBreak ?? this.isBreak,
      progress: progress ?? this.progress,
    );
  }
}
