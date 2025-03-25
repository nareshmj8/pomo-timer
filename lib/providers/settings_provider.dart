import 'dart:async';
// import 'dart:convert'; // Removed unused import
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';
import '../models/chart_data.dart';
// import '../services/notification_service.dart'; // Removed unused import
import 'settings/timer_settings_provider.dart';
import 'settings/theme_settings_provider.dart';
import 'settings/history_provider.dart';
import 'settings/statistics_provider.dart';

/// Main settings provider that coordinates all settings components
class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  // Commented out unused field but preserved for future use
  // final NotificationService _notificationService = NotificationService();
  late final TimerSettingsProvider _timerSettings;
  late final ThemeSettingsProvider _themeSettings;
  late final HistoryProvider _historyProvider;
  late StatisticsProvider _statisticsProvider;

  SettingsProvider(this._prefs) {
    _initProviders();
  }

  /// Initialize all component providers
  Future<void> init() async {
    // This method is kept for backward compatibility
    // All initialization is now done in _initProviders
  }

  /// Initialize all component providers
  void _initProviders() {
    _timerSettings = TimerSettingsProvider(_prefs);
    _themeSettings = ThemeSettingsProvider(_prefs);
    _historyProvider = HistoryProvider(_prefs);
    _statisticsProvider = StatisticsProvider(_historyProvider.history);

    // Load notification settings
    _loadNotificationSettings();

    // Listen to changes in component providers
    _timerSettings.addListener(_notifyListeners);
    _themeSettings.addListener(_notifyListeners);
    _historyProvider.addListener(_onHistoryChanged);
  }

  // Handle history changes
  void _onHistoryChanged() {
    _updateStatistics();
    _notifyListeners();
  }

  // Update statistics with current history data
  void _updateStatistics() {
    // Update the existing statistics provider reference
    _statisticsProvider = StatisticsProvider(_historyProvider.history);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  // Forward timer settings properties and methods
  bool get isTimerRunning => _timerSettings.isTimerRunning;
  bool get isTimerPaused => _timerSettings.isTimerPaused;
  bool get isBreak => _timerSettings.isBreak;
  bool get sessionCompleted => _timerSettings.sessionCompleted;
  Duration? get remainingTime => _timerSettings.remainingTime;
  double get progress => _timerSettings.progress;
  int get completedSessions => _timerSettings.completedSessions;
  String get selectedCategory => _timerSettings.selectedCategory;
  double get sessionDuration => _timerSettings.sessionDuration;
  double get shortBreakDuration => _timerSettings.shortBreakDuration;
  double get longBreakDuration => _timerSettings.longBreakDuration;
  int get sessionsBeforeLongBreak => _timerSettings.sessionsBeforeLongBreak;
  bool get soundEnabled => _timerSettings.soundEnabled;
  int get notificationSoundType => _timerSettings.notificationSoundType;

  void startTimer() => _timerSettings.startTimer();
  void startBreak() => _timerSettings.startBreak();
  void pauseTimer() => _timerSettings.pauseTimer();
  void resumeTimer() => _timerSettings.resumeTimer();
  void resetTimer() => _timerSettings.resetTimer();
  bool shouldTakeLongBreak() => _timerSettings.shouldTakeLongBreak();
  void setSessionDuration(double value) =>
      _timerSettings.setSessionDuration(value);
  void setShortBreakDuration(double value) =>
      _timerSettings.setShortBreakDuration(value);
  void setLongBreakDuration(double value) =>
      _timerSettings.setLongBreakDuration(value);
  void setSessionsBeforeLongBreak(int value) =>
      _timerSettings.setSessionsBeforeLongBreak(value);
  void toggleSound(bool enabled) => _timerSettings.toggleSound(enabled);
  void setSoundEnabled(bool value) => _timerSettings.setSoundEnabled(value);
  void setNotificationSoundType(int value) =>
      _timerSettings.setNotificationSoundType(value);
  void testNotificationSound() => _timerSettings.testNotificationSound();
  void setSelectedCategory(String category) =>
      _timerSettings.setSelectedCategory(category);
  void switchToFocusMode() => _timerSettings.switchToFocusMode();
  void switchToBreakMode() => _timerSettings.switchToBreakMode();
  void setSessionCompleted(bool value) {
    _timerSettings.setSessionCompleted(value);
    // Reload history data when a session is completed
    if (!value) {
      _historyProvider.reloadHistory().then((_) {
        // Don't recreate the StatisticsProvider here, it will be updated by the history listener
        notifyListeners();
      });
    }
  }

  // Forward theme settings properties and methods
  String get selectedTheme => _themeSettings.selectedTheme;
  bool get isDarkTheme => _themeSettings.isDarkTheme;
  Color get backgroundColor => _themeSettings.backgroundColor;
  Color get textColor => _themeSettings.textColor;
  Color get secondaryTextColor => _themeSettings.secondaryTextColor;
  Color get secondaryBackgroundColor => _themeSettings.secondaryBackgroundColor;
  Color get separatorColor => _themeSettings.separatorColor;
  Color get listTileBackgroundColor => _themeSettings.listTileBackgroundColor;
  Color get listTileTextColor => _themeSettings.listTileTextColor;
  List<String> get availableThemes => _themeSettings.availableThemes;

  void setTheme(String theme) => _themeSettings.setTheme(theme);

  // Forward history properties and methods
  List<HistoryEntry> get history => _historyProvider.history;

  void addHistoryEntry(HistoryEntry entry) =>
      _historyProvider.addHistoryEntry(entry);
  void clearHistory() => _historyProvider.clearHistory();
  void deleteHistoryEntry(HistoryEntry entry) =>
      _historyProvider.deleteHistoryEntry(entry);
  List<HistoryEntry> getHistoryByCategory(String category) =>
      _historyProvider.getHistoryByCategory(category);
  List<HistoryEntry> getHistoryByDateRange(DateTime start, DateTime end) =>
      _historyProvider.getHistoryByDateRange(start, end);
  int getTotalDurationByCategory(String category) =>
      _historyProvider.getTotalDurationByCategory(category);
  int getTotalSessionsByCategory(String category) =>
      _historyProvider.getTotalSessionsByCategory(category);

  // Method to refresh history data and update statistics
  Future<void> refreshData() async {
    debugPrint('🔄 SETTINGS_PROVIDER: Starting refreshData...');

    try {
      // Temporarily remove the history provider listener
      _historyProvider.removeListener(_onHistoryChanged);
      debugPrint('🔄 SETTINGS_PROVIDER: Removed history listener');

      // Reload history
      await _historyProvider.reloadHistory();
      debugPrint('🔄 SETTINGS_PROVIDER: History reloaded');

      // Manually update statistics
      _updateStatistics();
      debugPrint('🔄 SETTINGS_PROVIDER: Statistics updated');

      // Re-add the listener
      _historyProvider.addListener(_onHistoryChanged);
      debugPrint('🔄 SETTINGS_PROVIDER: Re-added history listener');

      // Make sure all listeners are notified
      notifyListeners();
      debugPrint('🔄 SETTINGS_PROVIDER: All listeners notified');

      debugPrint('🔄 SETTINGS_PROVIDER: refreshData completed successfully');
    } catch (e) {
      debugPrint('❌ SETTINGS_PROVIDER: Error in refreshData: $e');
      debugPrint('❌ SETTINGS_PROVIDER: Stack trace: ${StackTrace.current}');
      // Always re-add the listener even if there's an error
      _historyProvider.addListener(_onHistoryChanged);
      // Re-throw to allow handling by caller
      rethrow;
    }
  }

  // Forward statistics methods
  List<ChartData> getDailyData(String category) =>
      _statisticsProvider.getDailyData(category);
  List<ChartData> getWeeklyData(String category) =>
      _statisticsProvider.getWeeklyData(category);
  List<ChartData> getMonthlyData(String category) =>
      _statisticsProvider.getMonthlyData(category);
  Map<String, double> getCategoryStats(String category,
          {bool showHours = true}) =>
      _statisticsProvider.getCategoryStats(category, showHours: showHours);

  @override
  void dispose() {
    _timerSettings.dispose();
    _themeSettings.removeListener(_notifyListeners);
    _historyProvider.removeListener(_onHistoryChanged);
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

  // Constants for time calculations
  static const double minutesPerHour = 60.0;

  // These methods are commented out as they're currently unused
  // But preserved for future use
  /*
  // Convert minutes to hours
  double _minutesToHours(int minutes) {
    return minutes / minutesPerHour;
  }

  // Calculate number of sessions based on duration
  double _calculateSessions(int minutes) {
    return minutes * 0.04; // Each minute is 0.04 sessions
  }
  */

  // Method to clear all saved data
  Future<void> clearAllData() async {
    debugPrint('🔄 SETTINGS_PROVIDER: Starting clearAllData...');

    try {
      // First, cancel any running timers and reset timer state
      _timerSettings.resetTimer();
      debugPrint('🔄 SETTINGS_PROVIDER: Timer reset');

      // Reset all settings to defaults in each provider
      await _timerSettings.resetSettingsToDefault();
      debugPrint('🔄 SETTINGS_PROVIDER: Timer settings reset to defaults');

      // Reset theme to default
      _themeSettings.setTheme('System');
      debugPrint('🔄 SETTINGS_PROVIDER: Theme reset to System');

      // Clear history data
      _historyProvider.clearHistory();
      debugPrint('🔄 SETTINGS_PROVIDER: History cleared');

      // Reset notification settings
      _notificationsEnabled = true;
      _vibrationEnabled = true;
      await _saveNotificationSettings();
      debugPrint('🔄 SETTINGS_PROVIDER: Notification settings reset');

      // Reset user info
      _userName = '';
      _userEmail = '';
      debugPrint('🔄 SETTINGS_PROVIDER: User info reset');

      // Update statistics
      _updateStatistics();
      debugPrint('🔄 SETTINGS_PROVIDER: Statistics updated');

      // Notify all listeners about the changes
      notifyListeners();
      debugPrint('🔄 SETTINGS_PROVIDER: Listeners notified');

      debugPrint('🔄 SETTINGS_PROVIDER: clearAllData completed successfully');
    } catch (e) {
      debugPrint('❌ SETTINGS_PROVIDER: Error in clearAllData: $e');
      debugPrint('❌ SETTINGS_PROVIDER: Stack trace: ${StackTrace.current}');
      // Re-throw to allow handling by caller
      rethrow;
    }
  }

  // Method to reset settings to default values
  Future<void> resetSettingsToDefault() async {
    // Reset timer settings to defaults
    await _timerSettings.resetSettingsToDefault();

    // Reset theme to default
    _themeSettings.setTheme('System');

    // Reset user info
    _userName = '';
    _userEmail = '';

    // Reset notification settings
    _notificationsEnabled = true;
    _vibrationEnabled = true;
    await _saveNotificationSettings();

    // Reload history after reset
    await _historyProvider.reloadHistory();

    // Update statistics
    _updateStatistics();

    // Notify listeners about the changes
    notifyListeners();
  }

  // Export data for backup
  Map<String, dynamic> exportData() {
    return {
      'sessionDuration': sessionDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'soundEnabled': soundEnabled,
      'selectedTheme': selectedTheme,
      'completedSessions': completedSessions,
      'history': history.map((entry) => entry.toJson()).toList(),
    };
  }

  // Import data from backup
  Future<bool> importData(Map<String, dynamic> data) async {
    // Fix unnecessary null comparison
    if (data.isEmpty) {
      return false;
    }

    // Validate required fields
    if (data['sessionDuration'] == null ||
        data['shortBreakDuration'] == null ||
        data['longBreakDuration'] == null ||
        data['sessionsBeforeLongBreak'] == null ||
        data['soundEnabled'] == null ||
        data['selectedTheme'] == null ||
        data['completedSessions'] == null) {
      return false;
    }

    // Import settings - this would need to be implemented in each provider
    // For now, we'll just notify listeners
    notifyListeners();
    return true;
  }

  // These methods need to be implemented in the component providers
  // For now, we'll keep them here for backward compatibility
  void updateRemainingTime(Duration remaining) {
    _timerSettings.updateRemainingTime(remaining);
    notifyListeners();
  }

  void clearSessionCompleted() {
    _timerSettings.clearSessionCompleted();
    notifyListeners();
  }

  void incrementCompletedSessions() {
    _timerSettings.incrementCompletedSessions();
    notifyListeners();
  }

  void resetCompletedSessions() {
    _timerSettings.resetCompletedSessions();
    notifyListeners();
  }

  // Keys for notification settings
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _vibrationEnabledKey = 'vibrationEnabled';

  // Notification settings
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;

  // Getters for notification settings
  bool get notificationsEnabled => _notificationsEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // Load notification settings from preferences
  void _loadNotificationSettings() {
    _notificationsEnabled = _prefs.getBool(_notificationsEnabledKey) ?? true;
    _vibrationEnabled = _prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  // Save notification settings to preferences
  Future<void> _saveNotificationSettings() async {
    await _prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
    await _prefs.setBool(_vibrationEnabledKey, _vibrationEnabled);
  }

  // Enable/disable notifications
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _saveNotificationSettings();
    notifyListeners();
  }

  // Enable/disable vibration
  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _saveNotificationSettings();
    notifyListeners();
  }
}
