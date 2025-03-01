import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';
import '../models/chart_data.dart';
import '../services/sound_service.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsProvider(this._prefs) {
    _loadSavedData();
  }

  // Keys for SharedPreferences
  static const String _sessionDurationKey = 'sessionDuration';
  static const String _shortBreakDurationKey = 'shortBreakDuration';
  static const String _longBreakDurationKey = 'longBreakDuration';
  static const String _sessionsBeforeLongBreakKey = 'sessionsBeforeLongBreak';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _selectedThemeKey = 'selectedTheme';
  static const String _historyKey = 'history';
  static const String _completedSessionsKey = 'completedSessions';

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    _sessionDuration = _prefs.getDouble(_sessionDurationKey) ?? 25.0;
    _shortBreakDuration = _prefs.getDouble(_shortBreakDurationKey) ?? 5.0;
    _longBreakDuration = _prefs.getDouble(_longBreakDurationKey) ?? 15.0;
    _sessionsBeforeLongBreak = _prefs.getInt(_sessionsBeforeLongBreakKey) ?? 4;
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _selectedTheme = _prefs.getString(_selectedThemeKey) ?? 'Light';
    _completedSessions = _prefs.getInt(_completedSessionsKey) ?? 0;

    // Load history
    final historyJson = _prefs.getStringList(_historyKey);
    if (historyJson != null) {
      _history = historyJson
          .map((json) => HistoryEntry.fromJson(jsonDecode(json)))
          .toList();
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    await _prefs.setDouble(_sessionDurationKey, _sessionDuration);
    await _prefs.setDouble(_shortBreakDurationKey, _shortBreakDuration);
    await _prefs.setDouble(_longBreakDurationKey, _longBreakDuration);
    await _prefs.setInt(_sessionsBeforeLongBreakKey, _sessionsBeforeLongBreak);
    await _prefs.setBool(_soundEnabledKey, _soundEnabled);
    await _prefs.setString(_selectedThemeKey, _selectedTheme);
    await _prefs.setInt(_completedSessionsKey, _completedSessions);

    // Save history
    final historyJson =
        _history.map((entry) => jsonEncode(entry.toJson())).toList();
    await _prefs.setStringList(_historyKey, historyJson);
  }

  double _sessionDuration = 25.0;
  double _shortBreakDuration = 5.0;
  double _longBreakDuration = 15.0;
  int _sessionsBeforeLongBreak = 4;
  int _completedSessions = 0;
  double _currentSessionDuration = 25.0;

  Future<void> init() async {
    await _loadSavedData();
  }

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
  static const int minutesPerHour = 60;

  double _minutesToHours(int minutes) {
    return minutes / minutesPerHour;
  }

  double _calculateSessions(int minutes) {
    return minutes * 0.04; // Each minute is 0.04 sessions
  }

  // Get statistics for a category
  Map<String, double> getCategoryStats(String category,
      {bool showHours = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    double todayHours = 0;
    double weekHours = 0;
    double monthHours = 0;
    double totalHours = 0;
    double todaySessions = 0;
    double weekSessions = 0;
    double monthSessions = 0;
    double totalSessions = 0;

    for (var entry in _history) {
      if (category != 'All Categories' && entry.category != category) continue;

      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final hours = _minutesToHours(entry.duration);
      final sessions = _calculateSessions(entry.duration);

      if (entryDate == today) {
        todayHours += hours;
        todaySessions += sessions;
      }
      if (entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        weekHours += hours;
        weekSessions += sessions;
      }
      if (entryDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        monthHours += hours;
        monthSessions += sessions;
      }
      totalHours += hours;
      totalSessions += sessions;
    }

    return showHours
        ? {
            'today': todayHours,
            'week': weekHours,
            'month': monthHours,
            'total': totalHours,
          }
        : {
            'today': todaySessions,
            'week': weekSessions,
            'month': monthSessions,
            'total': totalSessions,
          };
  }

  // Get daily data for the last 7 days
  List<ChartData> getDailyData(String category) {
    final now = DateTime.now();
    final List<ChartData> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(dayStart) &&
            entry.timestamp.isBefore(dayEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: dayStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
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

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(weekStart) &&
            entry.timestamp.isBefore(weekEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: weekStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
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

      int totalMinutes = 0;
      double totalSessions = 0;

      for (var entry in _history) {
        if (category != 'All Categories' && entry.category != category) {
          continue;
        }
        if (entry.timestamp.isAfter(monthStart) &&
            entry.timestamp.isBefore(monthEnd)) {
          totalMinutes += entry.duration;
          totalSessions += _calculateSessions(entry.duration);
        }
      }

      data.add(ChartData(
        date: monthStart,
        hours: _minutesToHours(totalMinutes),
        sessions: totalSessions,
        isCurrentPeriod: i == 0,
      ));
    }

    return data;
  }

  void startTimer() {
    if (_isTimerRunning) return;
    _sessionCompleted = false;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _isBreak = false;
    _currentSessionDuration = _sessionDuration;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown();
    _saveData();
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
    bool isLongBreak = shouldTakeLongBreak();
    _remainingTime = Duration(
        minutes: isLongBreak
            ? _longBreakDuration.round()
            : _shortBreakDuration.round());
    if (isLongBreak) {
      resetCompletedSessions();
    }
    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _startCountdown();
    notifyListeners();
  }

  void incrementCompletedSessions() {
    _completedSessions++;
    _saveData();
    notifyListeners();
  }

  void resetCompletedSessions() {
    _completedSessions = 0;
    _saveData();
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
    _saveData();
    notifyListeners();
  }

  void setShortBreakDuration(double duration) {
    _shortBreakDuration = duration;
    _saveData();
    notifyListeners();
  }

  void setLongBreakDuration(double duration) {
    _longBreakDuration = duration;
    _saveData();
    notifyListeners();
  }

  void setSessionsBeforeLongBreak(int sessions) {
    _sessionsBeforeLongBreak = sessions;
    _saveData();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void _startCountdown() {
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

        if (!_isBreak) {
          _history.add(HistoryEntry(
            category: _selectedCategory,
            duration: _currentSessionDuration.round(),
            timestamp: DateTime.now(),
          ));
          incrementCompletedSessions();
          _sessionCompleted = true;
          _remainingTime = Duration(minutes: _sessionDuration.round());
          _progress = 1.0;

          if (_soundEnabled) {
            _soundService.playCompletionSound();
          }
          _saveData();
        } else {
          _isBreak = false;
          if (shouldTakeLongBreak()) {
            resetCompletedSessions();
          }
          _remainingTime = Duration(minutes: _sessionDuration.round());
          _progress = 1.0;

          if (_soundEnabled) {
            _soundService.playCompletionSound();
          }
          _saveData();
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
    _soundService.dispose();
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

  Color get backgroundColor {
    switch (_selectedTheme) {
      case 'Dark':
        return CupertinoColors.black;
      case 'Citrus Orange':
        return const Color(0xFFFFD9A6);
      case 'Rose Quartz':
        return const Color(0xFFF8C8D7);
      case 'Seafoam Green':
        return const Color(0xFFD9F2E6);
      case 'Lavender Mist':
        return const Color(0xFFE6D9F2);
      case 'Light':
      default:
        return CupertinoColors.systemGroupedBackground;
    }
  }

  Color get textColor {
    switch (_selectedTheme) {
      case 'Dark':
        return CupertinoColors.white;
      case 'Light':
      case 'Citrus Orange':
      case 'Rose Quartz':
      case 'Seafoam Green':
      case 'Lavender Mist':
      default:
        return CupertinoColors.label;
    }
  }

  Color get secondaryBackgroundColor {
    switch (_selectedTheme) {
      case 'Dark':
        return CupertinoColors.darkBackgroundGray;
      case 'Citrus Orange':
        return const Color(0xFFFFE5CC);
      case 'Rose Quartz':
        return const Color(0xFFFADFE7);
      case 'Seafoam Green':
        return const Color(0xFFE6F5EE);
      case 'Lavender Mist':
        return const Color(0xFFF0E6F2);
      case 'Light':
      default:
        return CupertinoColors.secondarySystemGroupedBackground;
    }
  }

  void setTheme(String theme) {
    _selectedTheme = theme;
    _saveData();
    notifyListeners();
  }

  final SoundService _soundService = SoundService();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveData();
    notifyListeners();
  }

  // Add to existing methods
  void clearHistory() {
    _history.clear();
    _saveData();
    notifyListeners();
  }

  // Method to clear all saved data
  Future<void> clearAllData() async {
    await _prefs.clear();
    _loadSavedData();
  }

  // Export all app data to JSON
  Map<String, dynamic> exportData() {
    return {
      'sessionDuration': _sessionDuration,
      'shortBreakDuration': _shortBreakDuration,
      'longBreakDuration': _longBreakDuration,
      'sessionsBeforeLongBreak': _sessionsBeforeLongBreak,
      'soundEnabled': _soundEnabled,
      'selectedTheme': _selectedTheme,
      'completedSessions': _completedSessions,
      'history': _history.map((entry) => entry.toJson()).toList(),
    };
  }

  // Import app data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    // Validate required fields
    if (!_validateImportData(data)) {
      throw Exception('Invalid backup file format');
    }

    // Import settings
    _sessionDuration = (data['sessionDuration'] as num).toDouble();
    _shortBreakDuration = (data['shortBreakDuration'] as num).toDouble();
    _longBreakDuration = (data['longBreakDuration'] as num).toDouble();
    _sessionsBeforeLongBreak = (data['sessionsBeforeLongBreak'] as num).toInt();
    _soundEnabled = data['soundEnabled'] as bool;
    _selectedTheme = data['selectedTheme'] as String;
    _completedSessions = (data['completedSessions'] as num).toInt();

    // Import history
    if (data['history'] != null) {
      try {
        _history = (data['history'] as List)
            .map((json) => HistoryEntry.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Invalid history data format');
      }
    } else {
      _history = [];
    }

    // Save imported data
    await _saveData();

    // Reset timer state
    _isTimerRunning = false;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;

    notifyListeners();
  }

  // Validate import data
  bool _validateImportData(Map<String, dynamic> data) {
    final requiredFields = [
      'sessionDuration',
      'shortBreakDuration',
      'longBreakDuration',
      'sessionsBeforeLongBreak',
      'soundEnabled',
      'selectedTheme',
      'completedSessions'
    ];

    // Check if all required fields exist
    for (final field in requiredFields) {
      if (!data.containsKey(field)) return false;
    }

    // Validate numeric ranges
    try {
      final sessionDuration = (data['sessionDuration'] as num).toDouble();
      final shortBreakDuration = (data['shortBreakDuration'] as num).toDouble();
      final longBreakDuration = (data['longBreakDuration'] as num).toDouble();
      final sessionsBeforeLongBreak =
          (data['sessionsBeforeLongBreak'] as num).toInt();

      if (sessionDuration < 1 || sessionDuration > 120) return false;
      if (shortBreakDuration < 1 || shortBreakDuration > 30) return false;
      if (longBreakDuration < 5 || longBreakDuration > 45) return false;
      if (sessionsBeforeLongBreak < 1 || sessionsBeforeLongBreak > 8)
        return false;
    } catch (e) {
      return false;
    }

    return true;
  }
}
