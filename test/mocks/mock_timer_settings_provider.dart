import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/providers/settings/timer_settings_provider.dart';

/// A mock implementation of TimerSettingsProvider for testing
class MockTimerSettingsProvider extends ChangeNotifier
    implements TimerSettingsProvider {
  final SharedPreferences _prefs;

  // Timer settings
  double _sessionDuration = 25.0;
  double _shortBreakDuration = 5.0;
  double _longBreakDuration = 15.0;
  int _sessionsBeforeLongBreak = 4;
  int _completedSessions = 0;
  double _currentSessionDuration = 25.0;
  bool _soundEnabled = true;
  int _notificationSoundType = 0; // Default to Tri-tone

  // Timer state
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isBreak = false;
  Duration? _remainingTime;
  String _selectedCategory = 'Work';
  Timer? _timer;
  double _progress = 1.0;
  bool _sessionCompleted = false;
  int _testSoundCallCount = 0;
  String? _lastTestSound;
  int _totalSeconds = 25 * 60; // Default to 25 minutes in seconds

  MockTimerSettingsProvider(this._prefs) {
    _remainingTime = Duration(minutes: _sessionDuration.round());
  }

  @override
  double get sessionDuration => _sessionDuration;

  @override
  double get shortBreakDuration => _shortBreakDuration;

  @override
  double get longBreakDuration => _longBreakDuration;

  @override
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  int get notificationSoundType => _notificationSoundType;

  @override
  int get completedSessions => _completedSessions;

  @override
  bool get isTimerRunning => _isTimerRunning;

  @override
  bool get isTimerPaused => _isTimerPaused;

  @override
  bool get isBreak => _isBreak;

  @override
  Duration? get remainingTime => _remainingTime;

  @override
  double get progress => _progress;

  @override
  bool get sessionCompleted => _sessionCompleted;

  @override
  String get selectedCategory => _selectedCategory;

  // Mock for test counters - not part of the real implementation
  int get testSoundCallCount => _testSoundCallCount;
  String? get lastTestSound => _lastTestSound;

  @override
  void startTimer() {
    _isTimerRunning = true;
    _isTimerPaused = false;
    notifyListeners();
  }

  @override
  void pauseTimer() {
    _isTimerPaused = true;
    notifyListeners();
  }

  @override
  void resumeTimer() {
    _isTimerPaused = false;
    notifyListeners();
  }

  @override
  void resetTimer() {
    _isTimerRunning = false;
    _isTimerPaused = false;
    _progress = 1.0;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    notifyListeners();
  }

  @override
  void startBreak() {
    _isTimerRunning = true;
    _isBreak = true;

    if (shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: _longBreakDuration.round());
    } else {
      _remainingTime = Duration(minutes: _shortBreakDuration.round());
    }

    notifyListeners();
  }

  @override
  void switchToBreakMode() {
    _isBreak = true;
    if (shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: _longBreakDuration.round());
    } else {
      _remainingTime = Duration(minutes: _shortBreakDuration.round());
    }
    notifyListeners();
  }

  @override
  bool shouldTakeLongBreak() {
    return _completedSessions > 0 &&
        _completedSessions % _sessionsBeforeLongBreak == 0;
  }

  @override
  void switchToFocusMode() {
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    notifyListeners();
  }

  @override
  void setSessionDuration(double duration) {
    _sessionDuration = duration;
    if (!_isTimerRunning && !_isBreak) {
      _remainingTime = Duration(minutes: duration.round());
    }
    notifyListeners();
  }

  @override
  void setShortBreakDuration(double duration) {
    _shortBreakDuration = duration;
    if (!_isTimerRunning && _isBreak && !shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: duration.round());
    }
    notifyListeners();
  }

  @override
  void setLongBreakDuration(double duration) {
    _longBreakDuration = duration;
    if (!_isTimerRunning && _isBreak && shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: duration.round());
    }
    notifyListeners();
  }

  @override
  void setSessionsBeforeLongBreak(int count) {
    _sessionsBeforeLongBreak = count;
    notifyListeners();
  }

  @override
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  @override
  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  @override
  void setNotificationSoundType(int type) {
    _notificationSoundType = type;
    notifyListeners();
  }

  @override
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  @override
  void updateRemainingTime(Duration time) {
    _remainingTime = time;
    if (_totalSeconds > 0) {
      _progress = _remainingTime!.inSeconds / _totalSeconds;
    }
    notifyListeners();
  }

  @override
  void incrementCompletedSessions() {
    _completedSessions++;
    notifyListeners();
  }

  @override
  void resetCompletedSessions() {
    _completedSessions = 0;
    notifyListeners();
  }

  @override
  void setSessionCompleted(bool value) {
    _sessionCompleted = value;
    notifyListeners();
  }

  @override
  void clearSessionCompleted() {
    _sessionCompleted = false;
    notifyListeners();
  }

  @override
  Future<void> resetSettingsToDefault() async {
    _sessionDuration = 25.0;
    _shortBreakDuration = 5.0;
    _longBreakDuration = 15.0;
    _sessionsBeforeLongBreak = 4;
    _soundEnabled = true;
    _notificationSoundType = 0;
    _completedSessions = 0;

    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }

    _isTimerRunning = false;
    _isTimerPaused = false;
    _isBreak = false;
    _sessionCompleted = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;

    notifyListeners();
  }

  @override
  void testNotificationSound() {
    if (_soundEnabled) {
      // Map sound type to iOS system sound names
      final List<String> soundNames = [
        'tri-tone.caf',
        'chime.caf',
        'glass.caf',
        'horn.caf',
        'bell.caf',
        'electronic.caf',
        'ascending.caf',
        'descending.caf',
      ];

      String soundName = 'tri-tone.caf'; // Default
      if (_notificationSoundType >= 0 &&
          _notificationSoundType < soundNames.length) {
        soundName = soundNames[_notificationSoundType];
      }

      _testSoundCallCount++;
      _lastTestSound = soundName;
    }
  }

  @override
  Map<String, dynamic> exportData() {
    return {
      'sessionDuration': _sessionDuration,
      'shortBreakDuration': _shortBreakDuration,
      'longBreakDuration': _longBreakDuration,
      'sessionsBeforeLongBreak': _sessionsBeforeLongBreak,
      'soundEnabled': _soundEnabled,
      'notificationSoundType': _notificationSoundType,
      'completedSessions': _completedSessions,
    };
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    _sessionDuration = data['sessionDuration'] ?? 25.0;
    _shortBreakDuration = data['shortBreakDuration'] ?? 5.0;
    _longBreakDuration = data['longBreakDuration'] ?? 15.0;
    _sessionsBeforeLongBreak = data['sessionsBeforeLongBreak'] ?? 4;
    _soundEnabled = data['soundEnabled'] ?? true;
    _notificationSoundType = data['notificationSoundType'] ?? 0;
    _completedSessions = data['completedSessions'] ?? 0;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
    super.dispose();
  }

  // Methods below are required by the TimerSettingsProvider interface but not used in tests

  @override
  Future<void> addHistoryEntry(
      DateTime date, int duration, String category) async {
    // No implementation needed for tests
  }

  @override
  String get completedSessionsKey => 'completedSessions';

  @override
  String get historyKey => 'history';

  @override
  void loadHistory() {
    // No implementation needed for tests
  }

  @override
  String get longBreakDurationKey => 'longBreakDuration';

  @override
  String get notificationSoundTypeKey => 'notificationSoundType';

  @override
  List<Object?> findRecentCategories() {
    return ['Work', 'Study', 'Personal'];
  }

  @override
  String get sessionDurationKey => 'sessionDuration';

  @override
  String get sessionsBeforeLongBreakKey => 'sessionsBeforeLongBreak';

  @override
  String get shortBreakDurationKey => 'shortBreakDuration';

  @override
  String get soundEnabledKey => 'soundEnabled';

  @override
  void saveCategoryHistory(String category) {
    // No implementation needed for tests
  }
}
