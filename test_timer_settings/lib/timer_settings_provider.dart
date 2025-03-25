import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service_interface.dart';

/// Manages timer-related settings and functionality
class TimerSettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final NotificationServiceInterface _notificationService;

  // Keys for SharedPreferences
  static const String _sessionDurationKey = 'session_duration';
  static const String _shortBreakDurationKey = 'short_break_duration';
  static const String _longBreakDurationKey = 'long_break_duration';
  static const String _sessionsBeforeLongBreakKey =
      'sessions_before_long_break';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _notificationSoundTypeKey = 'notification_sound_type';
  static const String _completedSessionsKey = 'completed_sessions';

  // Timer settings
  double _sessionDuration = 25.0;
  double _shortBreakDuration = 5.0;
  double _longBreakDuration = 15.0;
  int _sessionsBeforeLongBreak = 4;
  int _completedSessions = 0;
  bool _soundEnabled = true;
  int _notificationSoundType = 0; // Default to Tri-tone

  // Timer state
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  bool _isBreak = false;
  Duration? _remainingTime;
  Timer? _timer;
  double _progress = 1.0;

  /// Constructor with dependency injection
  ///
  /// You can optionally provide a NotificationServiceInterface implementation
  /// for testing purposes
  TimerSettingsProvider(
    this._prefs, {
    required NotificationServiceInterface notificationService,
  }) : _notificationService = notificationService {
    _loadSavedData();
  }

  /// Load saved data from SharedPreferences
  void _loadSavedData() {
    _sessionDuration = _prefs.getDouble(_sessionDurationKey) ?? 25.0;
    _shortBreakDuration = _prefs.getDouble(_shortBreakDurationKey) ?? 5.0;
    _longBreakDuration = _prefs.getDouble(_longBreakDurationKey) ?? 15.0;
    _sessionsBeforeLongBreak = _prefs.getInt(_sessionsBeforeLongBreakKey) ?? 4;
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _notificationSoundType = _prefs.getInt(_notificationSoundTypeKey) ?? 0;
    _completedSessions = _prefs.getInt(_completedSessionsKey) ?? 0;

    // Initialize remaining time with session duration for first-time users
    _remainingTime ??= Duration(minutes: _sessionDuration.round());

    // Initialize notification service
    _notificationService.initialize();

    notifyListeners();
  }

  /// Save data to SharedPreferences
  Future<void> _saveData() async {
    await _prefs.setDouble(_sessionDurationKey, _sessionDuration);
    await _prefs.setDouble(_shortBreakDurationKey, _shortBreakDuration);
    await _prefs.setDouble(_longBreakDurationKey, _longBreakDuration);
    await _prefs.setInt(_sessionsBeforeLongBreakKey, _sessionsBeforeLongBreak);
    await _prefs.setBool(_soundEnabledKey, _soundEnabled);
    await _prefs.setInt(_notificationSoundTypeKey, _notificationSoundType);
    await _prefs.setInt(_completedSessionsKey, _completedSessions);
  }

  /// Getters
  double get sessionDuration => _sessionDuration;
  double get shortBreakDuration => _shortBreakDuration;
  double get longBreakDuration => _longBreakDuration;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;
  bool get soundEnabled => _soundEnabled;
  int get notificationSoundType => _notificationSoundType;
  int get completedSessions => _completedSessions;
  bool get isTimerRunning => _isTimerRunning;
  bool get isTimerPaused => _isTimerPaused;
  bool get isBreak => _isBreak;
  Duration? get remainingTime => _remainingTime;
  double get progress => _progress;

  /// Start timer
  void startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;

    notifyListeners();
  }

  /// Pause timer
  void pauseTimer() {
    if (!_isTimerRunning) return;
    _isTimerPaused = true;
    _timer?.cancel();

    notifyListeners();
  }

  /// Resume timer
  void resumeTimer() {
    if (!_isTimerRunning || !_isTimerPaused) return;
    _isTimerPaused = false;

    notifyListeners();
  }

  /// Reset timer
  void resetTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    _isTimerPaused = false;

    // Keep the current mode (focus or break) but reset the timer
    if (_isBreak) {
      if (shouldTakeLongBreak()) {
        _remainingTime = Duration(minutes: _longBreakDuration.round());
      } else {
        _remainingTime = Duration(minutes: _shortBreakDuration.round());
      }
    } else {
      _remainingTime = Duration(minutes: _sessionDuration.round());
    }

    _progress = 1.0;

    notifyListeners();
  }

  /// Start break
  void startBreak() {
    if (_isTimerRunning) return;
    _isBreak = true;
    _isTimerRunning = true;
    _isTimerPaused = false;
    bool isLongBreak = shouldTakeLongBreak();
    _remainingTime = Duration(
      minutes:
          isLongBreak
              ? _longBreakDuration.round()
              : _shortBreakDuration.round(),
    );
    _progress = 1.0;

    notifyListeners();
  }

  /// Increment completed sessions
  void incrementCompletedSessions() {
    _completedSessions++;
    _saveData();
    notifyListeners();
  }

  /// Reset completed sessions
  void resetCompletedSessions() {
    _completedSessions = 0;
    _saveData();
    notifyListeners();
  }

  /// Check if should take long break
  bool shouldTakeLongBreak() {
    return _completedSessions >= _sessionsBeforeLongBreak;
  }

  /// Update session duration
  void setSessionDuration(double duration) {
    _sessionDuration = duration;
    // Update the timer display if we're in focus mode and not running
    if (!_isTimerRunning && !_isBreak) {
      _remainingTime = Duration(minutes: duration.round());
      _progress = 1.0;
    }
    _saveData();
    notifyListeners();
  }

  /// Update short break duration
  void setShortBreakDuration(double duration) {
    _shortBreakDuration = duration;
    // Update the timer display if we're in short break mode and not running
    if (!_isTimerRunning && _isBreak && !shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: duration.round());
      _progress = 1.0;
    }
    _saveData();
    notifyListeners();
  }

  /// Update long break duration
  void setLongBreakDuration(double duration) {
    _longBreakDuration = duration;
    // Update the timer display if we're in long break mode and not running
    if (!_isTimerRunning && _isBreak && shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: duration.round());
      _progress = 1.0;
    }
    _saveData();
    notifyListeners();
  }

  /// Update sessions before long break
  void setSessionsBeforeLongBreak(int sessions) {
    _sessionsBeforeLongBreak = sessions;
    _saveData();
    notifyListeners();
  }

  /// Toggle sound
  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    _saveData();
    notifyListeners();
  }

  /// Set sound enabled
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveData();
    notifyListeners();
  }

  /// Switch to focus mode (without starting the timer)
  void switchToFocusMode() {
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;
    notifyListeners();
  }

  /// Switch to break mode (without starting the timer)
  void switchToBreakMode() {
    _isBreak = true;
    if (shouldTakeLongBreak()) {
      _remainingTime = Duration(minutes: _longBreakDuration.round());
    } else {
      _remainingTime = Duration(minutes: _shortBreakDuration.round());
    }
    _progress = 1.0;
    notifyListeners();
  }

  /// Set notification sound type
  void setNotificationSoundType(int value) {
    if (value >= 0 && value <= 7) {
      // 8 sound types (0-7)
      _notificationSoundType = value;
      _saveData();
      notifyListeners();
    }
  }

  /// Test notification sound
  void testNotificationSound() async {
    if (_soundEnabled) {
      await _notificationService.playTestSound(_notificationSoundType);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
