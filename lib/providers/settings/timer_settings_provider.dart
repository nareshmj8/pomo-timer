import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/history_entry.dart';
import '../../services/interfaces/notification_service_interface.dart';
import '../../services/service_locator.dart';

/// Manages timer-related settings and functionality
class TimerSettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  late final NotificationServiceInterface _notificationService;

  // Keys for SharedPreferences
  static const String _sessionDurationKey = 'sessionDuration';
  static const String _shortBreakDurationKey = 'shortBreakDuration';
  static const String _longBreakDurationKey = 'longBreakDuration';
  static const String _sessionsBeforeLongBreakKey = 'sessionsBeforeLongBreak';
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _notificationSoundTypeKey = 'notificationSoundType';
  static const String _completedSessionsKey = 'completedSessions';
  static const String _historyKey = 'history';
  static const String _timerEndTimeKey = 'timerEndTime';
  static const String _timerStateKey = 'timerState';

  // Background timer constants
  static const String _backgroundTimerPortName = 'timer_port';

  // Getters for keys (used by main settings provider)
  String get sessionDurationKey => _sessionDurationKey;
  String get shortBreakDurationKey => _shortBreakDurationKey;
  String get longBreakDurationKey => _longBreakDurationKey;
  String get sessionsBeforeLongBreakKey => _sessionsBeforeLongBreakKey;
  String get soundEnabledKey => _soundEnabledKey;
  String get notificationSoundTypeKey => _notificationSoundTypeKey;
  String get completedSessionsKey => _completedSessionsKey;
  String get historyKey => _historyKey;

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
  DateTime? _timerEndTime;

  // Add a field to store total duration
  late int _totalSeconds;

  /// Constructor with dependency injection
  ///
  /// You can optionally provide a NotificationServiceInterface implementation
  /// for testing purposes
  TimerSettingsProvider(
    this._prefs, {
    dynamic notificationService,
  }) {
    final dynamic serviceNotification = ServiceLocator().notificationService;
    _notificationService = (notificationService ?? serviceNotification)
        as NotificationServiceInterface;

    // Initialize remaining time with default value before loading saved data
    _remainingTime = const Duration(minutes: 25);
    _loadSavedData();
    _setupBackgroundTimerListener();

    // Ensure the timer display always shows the correct duration based on mode
    _updateTimerDisplayBasedOnMode();
  }

  /// Update timer display based on current mode
  void _updateTimerDisplayBasedOnMode() {
    if (!_isTimerRunning) {
      if (_isBreak) {
        if (shouldTakeLongBreak()) {
          _remainingTime = Duration(minutes: _longBreakDuration.round());
        } else {
          _remainingTime = Duration(minutes: _shortBreakDuration.round());
        }
      } else {
        // Focus session (default)
        _remainingTime = Duration(minutes: _sessionDuration.round());
      }
      _totalSeconds = _remainingTime!.inSeconds;
      _progress = 1.0;
    }
  }

  /// Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    _sessionDuration = _prefs.getDouble(_sessionDurationKey) ?? 25.0;
    _shortBreakDuration = _prefs.getDouble(_shortBreakDurationKey) ?? 5.0;
    _longBreakDuration = _prefs.getDouble(_longBreakDurationKey) ?? 15.0;
    _sessionsBeforeLongBreak = _prefs.getInt(_sessionsBeforeLongBreakKey) ?? 4;
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _notificationSoundType = _prefs.getInt(_notificationSoundTypeKey) ?? 0;
    _completedSessions = _prefs.getInt(_completedSessionsKey) ?? 0;

    // Initialize remaining time with session duration for first-time users
    _remainingTime ??= Duration(minutes: _sessionDuration.round());

    // Check if there was a running timer when the app was closed
    final endTimeMillis = _prefs.getInt(_timerEndTimeKey);
    final timerState = _prefs.getString(_timerStateKey);

    if (endTimeMillis != null && timerState != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
      final now = DateTime.now();

      if (endTime.isAfter(now)) {
        // Timer was running and hasn't ended yet
        _timerEndTime = endTime;
        _isTimerRunning = true;
        _isBreak = timerState == 'break';
        _remainingTime = endTime.difference(now);
        _totalSeconds = _isBreak
            ? (_isBreak && shouldTakeLongBreak()
                    ? _longBreakDuration * 60
                    : _shortBreakDuration * 60)
                .round()
            : (_sessionDuration * 60).round();
        _progress = _remainingTime!.inSeconds / _totalSeconds;
        _startCountdown();
      } else {
        // Timer ended while app was closed
        _handleTimerCompletion(timerState == 'break');
        // Clear saved timer state
        await _prefs.remove(_timerEndTimeKey);
        await _prefs.remove(_timerStateKey);
      }
    } else {
      // No running timer, ensure display shows correct duration
      _updateTimerDisplayBasedOnMode();
    }

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

    // Save timer state if running
    if (_isTimerRunning && _timerEndTime != null) {
      await _prefs.setInt(
          _timerEndTimeKey, _timerEndTime!.millisecondsSinceEpoch);
      await _prefs.setString(_timerStateKey, _isBreak ? 'break' : 'session');
    } else {
      await _prefs.remove(_timerEndTimeKey);
      await _prefs.remove(_timerStateKey);
    }
  }

  /// Setup background timer listener
  void _setupBackgroundTimerListener() {
    // Register a port for background communication
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, _backgroundTimerPortName);

    receivePort.listen((message) {
      if (message == 'timer_completed') {
        _handleTimerCompletion(_isBreak);
      }
    });
  }

  /// Handle timer completion
  void _handleTimerCompletion(bool wasBreak) {
    _isTimerRunning = false;
    _isTimerPaused = false;

    if (!wasBreak) {
      // Session completed
      _sessionCompleted = true;
      _remainingTime = Duration(minutes: _sessionDuration.round());
      _progress = 1.0;

      // Add history entry
      final historyEntry = HistoryEntry(
        category: _selectedCategory,
        duration: _currentSessionDuration.round(),
        timestamp: DateTime.now(),
      );

      // Save history entry to SharedPreferences
      final historyJson = _prefs.getStringList(_historyKey) ?? [];
      historyJson.add(jsonEncode(historyEntry.toJson()));
      _prefs.setStringList(_historyKey, historyJson);

      incrementCompletedSessions();

      if (_soundEnabled) {
        _notificationService.playTimerCompletionSound();
      }
    } else {
      // Break completed
      _isBreak = false;
      if (shouldTakeLongBreak()) {
        resetCompletedSessions();
        if (_soundEnabled) {
          _notificationService.playLongBreakCompletionSound();
        }
      } else {
        if (_soundEnabled) {
          _notificationService.playBreakCompletionSound();
        }
      }
      _remainingTime = Duration(minutes: _sessionDuration.round());
      _progress = 1.0;
    }

    _saveData();

    // Ensure we notify listeners about the completion
    notifyListeners();
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
  String get selectedCategory => _selectedCategory;
  double get progress => _progress;
  bool get sessionCompleted => _sessionCompleted;

  /// Start timer
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

    // Set end time for background tracking
    _timerEndTime = DateTime.now().add(_remainingTime!);

    _startCountdown();
    _saveData();
    notifyListeners();
  }

  /// Pause timer
  void pauseTimer() {
    if (!_isTimerRunning) return;
    _isTimerPaused = true;
    _timer?.cancel();

    // Update end time when paused
    if (_timerEndTime != null && _remainingTime != null) {
      _timerEndTime = null;
    }

    _saveData();
    notifyListeners();
  }

  /// Resume timer
  void resumeTimer() {
    if (!_isTimerRunning || !_isTimerPaused) return;
    _isTimerPaused = false;

    // Reset end time when resumed
    if (_remainingTime != null) {
      _timerEndTime = DateTime.now().add(_remainingTime!);
    }

    _startCountdown();
    _saveData();
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

    _totalSeconds = _remainingTime!.inSeconds;
    _progress = 1.0;
    _timerEndTime = null;
    _sessionCompleted = false;

    _saveData();
    notifyListeners();
  }

  /// Update remaining time
  void updateRemainingTime(Duration remaining) {
    _remainingTime = remaining;

    // Update end time
    if (_isTimerRunning && !_isTimerPaused) {
      _timerEndTime = DateTime.now().add(remaining);
      _saveData();
    }

    notifyListeners();
  }

  /// Start break
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

    // Set end time for background tracking
    _timerEndTime = DateTime.now().add(_remainingTime!);

    _startCountdown();
    _saveData();
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
      _totalSeconds = _remainingTime!.inSeconds;
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
      _totalSeconds = _remainingTime!.inSeconds;
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
      _totalSeconds = _remainingTime!.inSeconds;
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

  /// Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
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

  /// Clear session completed
  void clearSessionCompleted() {
    _sessionCompleted = false;
    notifyListeners();
  }

  /// Set session completed
  void setSessionCompleted(bool value) {
    _sessionCompleted = value;
    notifyListeners();
  }

  /// Start timer tick
  void _startCountdown() {
    _timer?.cancel();
    _sessionCompleted = false;

    // Only schedule notifications if the timer is actually running
    // Don't play sounds immediately when starting the timer
    if (_timerEndTime != null && _isTimerRunning && !_isTimerPaused) {
      // We'll let the timer completion handle the notifications
      // No need to play sounds here
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerPaused || !_isTimerRunning) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();

      if (_timerEndTime != null && now.isAfter(_timerEndTime!)) {
        // Timer has ended
        timer.cancel();
        _handleTimerCompletion(_isBreak);
      } else if (_remainingTime!.inSeconds > 0) {
        // Timer is still running
        if (_timerEndTime != null) {
          _remainingTime = _timerEndTime!.difference(now);
        } else {
          _remainingTime = _remainingTime! - const Duration(seconds: 1);
        }
        _progress = _remainingTime!.inSeconds / _totalSeconds;
        notifyListeners();
      }
    });
  }

  /// Reset all timer settings to default values
  Future<void> resetSettingsToDefault() async {
    debugPrint('⏱️ TIMER_SETTINGS: Starting resetSettingsToDefault...');

    try {
      // Reset timer to default state
      _cancelTimer();
      debugPrint('⏱️ TIMER_SETTINGS: Timer cancelled');

      // Reset timer settings to defaults
      _sessionDuration = 25.0;
      _shortBreakDuration = 5.0;
      _longBreakDuration = 15.0;
      _sessionsBeforeLongBreak = 4;
      _completedSessions = 0;
      _currentSessionDuration = 25.0;
      _soundEnabled = true;
      _notificationSoundType = 0;
      debugPrint(
          '⏱️ TIMER_SETTINGS: Timer settings variables reset to defaults');

      // Reset timer state
      _isTimerRunning = false;
      _isTimerPaused = false;
      _isBreak = false;
      _selectedCategory = 'Work';
      _progress = 1.0;
      _sessionCompleted = false;
      _timerEndTime = null;
      _remainingTime = Duration(minutes: _sessionDuration.round());
      _totalSeconds = _remainingTime!.inSeconds;
      debugPrint('⏱️ TIMER_SETTINGS: Timer state reset');

      // Clear only timer-related settings in SharedPreferences, not everything
      await _prefs.remove(_sessionDurationKey);
      await _prefs.remove(_shortBreakDurationKey);
      await _prefs.remove(_longBreakDurationKey);
      await _prefs.remove(_sessionsBeforeLongBreakKey);
      await _prefs.remove(_soundEnabledKey);
      await _prefs.remove(_notificationSoundTypeKey);
      await _prefs.remove(_completedSessionsKey);
      await _prefs.remove(_timerEndTimeKey);
      await _prefs.remove(_timerStateKey);
      debugPrint('⏱️ TIMER_SETTINGS: Timer preferences cleared');

      // Now save the default settings
      await _saveData();
      debugPrint('⏱️ TIMER_SETTINGS: Default settings saved');

      // Notify listeners of the changes
      notifyListeners();
      debugPrint('⏱️ TIMER_SETTINGS: Listeners notified');
      debugPrint(
          '⏱️ TIMER_SETTINGS: resetSettingsToDefault completed successfully');
    } catch (e) {
      debugPrint('❌ TIMER_SETTINGS: Error in resetSettingsToDefault: $e');
      debugPrint('❌ TIMER_SETTINGS: Stack trace: ${StackTrace.current}');
      // Re-throw to allow handling by caller
      rethrow;
    }
  }

  // Import data from backup
  void importData(Map<String, dynamic> data) {
    _sessionDuration = (data['sessionDuration'] as num).toDouble();
    _shortBreakDuration = (data['shortBreakDuration'] as num).toDouble();
    _longBreakDuration = (data['longBreakDuration'] as num).toDouble();
    _sessionsBeforeLongBreak = (data['sessionsBeforeLongBreak'] as num).toInt();
    _soundEnabled = data['soundEnabled'] as bool;
    _completedSessions = (data['completedSessions'] as num).toInt();

    // Reset timer state
    _isTimerRunning = false;
    _isTimerPaused = false;
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _progress = 1.0;
    _timerEndTime = null;

    _saveData();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();

    // Unregister port when disposed
    IsolateNameServer.removePortNameMapping(_backgroundTimerPortName);

    super.dispose();
  }

  /// Switch to focus mode (without starting the timer)
  void switchToFocusMode() {
    _isBreak = false;
    _remainingTime = Duration(minutes: _sessionDuration.round());
    _totalSeconds = _remainingTime!.inSeconds;
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
    _totalSeconds = _remainingTime!.inSeconds;
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
      // Convert the sound type to an integer index for the interface
      // The interface expects an int parameter instead of a string
      await _notificationService.playTestSound(_notificationSoundType);
    }
  }

  /// Cancel the timer
  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
