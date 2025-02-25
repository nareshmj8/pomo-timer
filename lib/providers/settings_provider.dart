import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class HistoryEntry {
  final String category;
  final int duration;
  final DateTime timestamp;

  HistoryEntry({
    required this.category,
    required this.duration,
    required this.timestamp,
  });
}

class SettingsProvider with ChangeNotifier {
  double _sessionDuration = 25.0;
  double _shortBreakDuration = 5.0;
  double _longBreakDuration = 15.0;
  int _sessionsBeforeLongBreak = 4;
  int _completedSessions = 0;

  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isBreak = false;
  Duration? _remainingTime;
  String _selectedCategory = 'Work';
  Timer? _timer;

  double _progress = 1.0;

  // Add a field to store total duration
  late int _totalSeconds;

  // Add list to store history
  List<HistoryEntry> _history = [];
  List<HistoryEntry> get history => _history;

  // Add flag for session completion
  bool _sessionCompleted = false;
  bool get sessionCompleted => _sessionCompleted;

  double get sessionDuration => _sessionDuration;
  double get shortBreakDuration => _shortBreakDuration;
  double get longBreakDuration => _longBreakDuration;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;
  int get completedSessions => _completedSessions;
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  bool get isBreak => _isBreak;
  Duration get remainingTime =>
      _remainingTime ?? Duration(minutes: _sessionDuration.round());
  String get selectedCategory => _selectedCategory;
  double get progress => _progress;

  // Constants for time calculations
  static const int DEFAULT_SESSION_MINUTES = 25;
  static const int MINUTES_PER_HOUR = 60;

  // Convert minutes to hours
  double _minutesToHours(int minutes) {
    return minutes / MINUTES_PER_HOUR;
  }

  // Get statistics for a category
  Map<String, double> getCategoryStats(String category) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todayHours = 0;
    double weekHours = 0;
    double monthHours = 0;
    double totalHours = 0;

    for (var entry in _history) {
      if (category != 'All Categories' && entry.category != category) continue;

      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final sessionHours = _minutesToHours(entry.duration);

      if (entryDate == today) {
        todayHours += sessionHours;
      }
      if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weekHours += sessionHours;
      }
      if (entryDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        monthHours += sessionHours;
      }
      totalHours += sessionHours;
    }

    return {
      'today': todayHours,
      'week': weekHours,
      'month': monthHours,
      'total': totalHours,
    };
  }

  int _calculateSessions(int minutes) {
    return (minutes / DEFAULT_SESSION_MINUTES).floor();
  }

  // Get daily data for the last 7 days
  List<ChartData> getDailyData(String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      double hours = 0;
      int sessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category)
          continue;
        if (entry.timestamp.isAfter(dayStart) &&
            entry.timestamp.isBefore(dayEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: dayStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  // Get weekly data for the last 7 weeks
  List<ChartData> getWeeklyData(String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      double hours = 0;
      int sessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category)
          continue;
        if (entry.timestamp.isAfter(weekStart) &&
            entry.timestamp.isBefore(weekEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: weekStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  List<ChartData> getMonthlyData(String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      double hours = 0;
      int sessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category)
          continue;
        if (entry.timestamp.isAfter(monthStart) &&
            entry.timestamp.isBefore(monthEnd)) {
          hours += _minutesToHours(entry.duration);
          sessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: monthStart,
        hours: hours,
        sessions: sessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  void startTimer() {
    if (_isTimerRunning) return;
    _sessionCompleted = false; // Reset flag
    _isTimerRunning = true;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown();
    notifyListeners();
  }

  void pauseTimer() {
    if (!_isTimerRunning) return;
    _isTimerPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    if (!_isTimerRunning || !_isTimerPaused) return;
    _isTimerPaused = false;
    _startCountdown();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;
    notifyListeners();
  }

  void updateRemainingTime(Duration remaining) {
    _remainingTime = remaining;
    notifyListeners();
  }

  void startBreak() {
    if (_isTimerRunning) return;
    _sessionCompleted = false;
    _isBreak = true;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _remainingTime = Duration(
        minutes: shouldTakeLongBreak()
            ? _longBreakDuration.round() // Use long break duration
            : _shortBreakDuration.round());
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown();
    notifyListeners();
  }

  void incrementCompletedSessions() {
    _completedSessions++;
    notifyListeners();
  }

  void resetCompletedSessions() {
    _completedSessions = 0;
    notifyListeners();
  }

  bool shouldTakeLongBreak() {
    return _completedSessions >= _sessionsBeforeLongBreak;
  }

  void setSessionDuration(double duration) {
    _sessionDuration = duration;
    if (!_isTimerRunning) {
      _remainingTime = Duration(minutes: duration.round());
    }
    notifyListeners();
  }

  void setShortBreakDuration(double duration) {
    _shortBreakDuration = duration;
    notifyListeners();
  }

  void setLongBreakDuration(double duration) {
    _longBreakDuration = duration;
    notifyListeners();
  }

  void setSessionsBeforeLongBreak(int sessions) {
    _sessionsBeforeLongBreak = sessions;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();
    _sessionCompleted = false; // Reset flag at start

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

        if (!_isBreak) {
          _history.add(HistoryEntry(
            category: _selectedCategory,
            duration: _sessionDuration.round(),
            timestamp: DateTime.now(),
          ));
          incrementCompletedSessions();
          _sessionCompleted = true; // Set flag when session completes
          _remainingTime = Duration(minutes: _sessionDuration.round());
          _progress = 1.0;
        } else {
          _isBreak = false;
          _remainingTime = Duration(minutes: _sessionDuration.round());
          _progress = 1.0;
        }
        notifyListeners();
      }
    });
  }

  void clearSessionCompleted() {
    _sessionCompleted = false;
    notifyListeners();
  }

  void setSessionCompleted(bool value) {
    _sessionCompleted = value;
    notifyListeners();
  }

  void submitFeedback(String feedback) {
    // TODO: Implement feedback submission logic
    // For now, just print the feedback
    print('Feedback submitted: $feedback');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _userName = '';
  String _userEmail = '';

  // Add to existing getters
  String get userName => _userName;
  String get userEmail => _userEmail;

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void updateUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  String _selectedTheme = 'Light';
  String get selectedTheme => _selectedTheme;

  void setTheme(String theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}

// Add this class for chart data
class ChartData {
  final DateTime date;
  final double hours;
  final int sessions;
  final bool isCurrentPeriod;

  ChartData({
    required this.date,
    required this.hours,
    required this.sessions,
    required this.isCurrentPeriod,
  });
}
