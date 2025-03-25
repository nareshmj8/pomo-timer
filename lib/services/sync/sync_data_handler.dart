import 'package:shared_preferences/shared_preferences.dart';

/// Handles the actual data synchronization between local storage and iCloud
class SyncDataHandler {
  static const String _lastModifiedKey = 'last_modified';

  // Get all local data to sync
  Future<Map<String, dynamic>> getLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // Collect all relevant data
    Map<String, dynamic> data = {};

    // Add session data and settings
    data['sessionDuration'] = prefs.getDouble('session_duration') ?? 25.0;
    data['shortBreakDuration'] = prefs.getDouble('short_break_duration') ?? 5.0;
    data['longBreakDuration'] = prefs.getDouble('long_break_duration') ?? 15.0;
    data['sessionsBeforeLongBreak'] =
        prefs.getInt('sessions_before_long_break') ?? 4;
    data['autoStartBreaks'] = prefs.getBool('auto_start_breaks') ?? true;
    data['autoStartPomodoros'] = prefs.getBool('auto_start_pomodoros') ?? false;
    data['vibrationEnabled'] = prefs.getBool('vibration_enabled') ?? true;
    data['notificationsEnabled'] =
        prefs.getBool('notifications_enabled') ?? true;
    data['keepScreenOn'] = prefs.getBool('keep_screen_on') ?? false;

    // Add theme and sound preferences
    data['selectedTheme'] = prefs.getString('selected_theme') ?? 'Light';
    data['soundEnabled'] = prefs.getBool('sound_enabled') ?? true;
    data['selectedSound'] = prefs.getString('selected_sound') ?? 'Bell';
    data['soundVolume'] = prefs.getDouble('sound_volume') ?? 0.5;

    // Add session history if available
    final sessionHistory = prefs.getStringList('session_history');
    if (sessionHistory != null) {
      data['sessionHistory'] = sessionHistory;
    }

    // Add progress data
    data['dailyCompletedSessions'] =
        prefs.getInt('daily_completed_sessions') ?? 0;
    data['weeklyCompletedSessions'] =
        prefs.getInt('weekly_completed_sessions') ?? 0;
    data['monthlyCompletedSessions'] =
        prefs.getInt('monthly_completed_sessions') ?? 0;
    data['totalCompletedSessions'] =
        prefs.getInt('total_completed_sessions') ?? 0;
    data['dailyFocusMinutes'] = prefs.getInt('daily_focus_minutes') ?? 0;
    data['weeklyFocusMinutes'] = prefs.getInt('weekly_focus_minutes') ?? 0;
    data['monthlyFocusMinutes'] = prefs.getInt('monthly_focus_minutes') ?? 0;
    data['totalFocusMinutes'] = prefs.getInt('total_focus_minutes') ?? 0;
    data['currentStreak'] = prefs.getInt('current_streak') ?? 0;
    data['bestStreak'] = prefs.getInt('best_streak') ?? 0;
    data['lastCompletedDate'] = prefs.getString('last_completed_date');

    // Add premium status data
    data['subscriptionType'] = prefs.getInt('subscription_type') ?? 0;
    data['expiryDate'] = prefs.getString('expiry_date');

    // Add timestamp for conflict resolution
    final lastModified =
        prefs.getInt(_lastModifiedKey) ?? DateTime.now().millisecondsSinceEpoch;
    data['lastModified'] = lastModified;

    // Save the current timestamp
    await prefs.setInt(_lastModifiedKey, DateTime.now().millisecondsSinceEpoch);

    return data;
  }

  // Update local data from cloud
  Future<void> updateLocalData(Map<String, dynamic> cloudData) async {
    final prefs = await SharedPreferences.getInstance();

    // Get local modification timestamp
    final localTimestamp = prefs.getInt(_lastModifiedKey) ?? 0;
    final cloudTimestamp = cloudData['lastModified'] as int? ?? 0;

    // Only update if cloud data is newer
    if (cloudTimestamp > localTimestamp) {
      // Update session settings
      if (cloudData.containsKey('sessionDuration')) {
        await prefs.setDouble('session_duration', cloudData['sessionDuration']);
      }

      if (cloudData.containsKey('shortBreakDuration')) {
        await prefs.setDouble(
            'short_break_duration', cloudData['shortBreakDuration']);
      }

      if (cloudData.containsKey('longBreakDuration')) {
        await prefs.setDouble(
            'long_break_duration', cloudData['longBreakDuration']);
      }

      if (cloudData.containsKey('sessionsBeforeLongBreak')) {
        await prefs.setInt(
            'sessions_before_long_break', cloudData['sessionsBeforeLongBreak']);
      }

      if (cloudData.containsKey('autoStartBreaks')) {
        await prefs.setBool('auto_start_breaks', cloudData['autoStartBreaks']);
      }

      if (cloudData.containsKey('autoStartPomodoros')) {
        await prefs.setBool(
            'auto_start_pomodoros', cloudData['autoStartPomodoros']);
      }

      if (cloudData.containsKey('vibrationEnabled')) {
        await prefs.setBool('vibration_enabled', cloudData['vibrationEnabled']);
      }

      if (cloudData.containsKey('notificationsEnabled')) {
        await prefs.setBool(
            'notifications_enabled', cloudData['notificationsEnabled']);
      }

      if (cloudData.containsKey('keepScreenOn')) {
        await prefs.setBool('keep_screen_on', cloudData['keepScreenOn']);
      }

      // Update theme and sound preferences
      if (cloudData.containsKey('selectedTheme')) {
        await prefs.setString('selected_theme', cloudData['selectedTheme']);
      }

      if (cloudData.containsKey('soundEnabled')) {
        await prefs.setBool('sound_enabled', cloudData['soundEnabled']);
      }

      if (cloudData.containsKey('selectedSound')) {
        await prefs.setString('selected_sound', cloudData['selectedSound']);
      }

      if (cloudData.containsKey('soundVolume')) {
        await prefs.setDouble('sound_volume', cloudData['soundVolume']);
      }

      // Update session history
      if (cloudData.containsKey('sessionHistory')) {
        await prefs.setStringList(
            'session_history', cloudData['sessionHistory'].cast<String>());
      }

      // Update progress data
      if (cloudData.containsKey('dailyCompletedSessions')) {
        await prefs.setInt(
            'daily_completed_sessions', cloudData['dailyCompletedSessions']);
      }

      if (cloudData.containsKey('weeklyCompletedSessions')) {
        await prefs.setInt(
            'weekly_completed_sessions', cloudData['weeklyCompletedSessions']);
      }

      if (cloudData.containsKey('monthlyCompletedSessions')) {
        await prefs.setInt('monthly_completed_sessions',
            cloudData['monthlyCompletedSessions']);
      }

      if (cloudData.containsKey('totalCompletedSessions')) {
        await prefs.setInt(
            'total_completed_sessions', cloudData['totalCompletedSessions']);
      }

      if (cloudData.containsKey('dailyFocusMinutes')) {
        await prefs.setInt(
            'daily_focus_minutes', cloudData['dailyFocusMinutes']);
      }

      if (cloudData.containsKey('weeklyFocusMinutes')) {
        await prefs.setInt(
            'weekly_focus_minutes', cloudData['weeklyFocusMinutes']);
      }

      if (cloudData.containsKey('monthlyFocusMinutes')) {
        await prefs.setInt(
            'monthly_focus_minutes', cloudData['monthlyFocusMinutes']);
      }

      if (cloudData.containsKey('totalFocusMinutes')) {
        await prefs.setInt(
            'total_focus_minutes', cloudData['totalFocusMinutes']);
      }

      if (cloudData.containsKey('currentStreak')) {
        await prefs.setInt('current_streak', cloudData['currentStreak']);
      }

      if (cloudData.containsKey('bestStreak')) {
        await prefs.setInt('best_streak', cloudData['bestStreak']);
      }

      if (cloudData.containsKey('lastCompletedDate')) {
        await prefs.setString(
            'last_completed_date', cloudData['lastCompletedDate']);
      }

      // Update premium status data
      if (cloudData.containsKey('subscriptionType')) {
        await prefs.setInt('subscription_type', cloudData['subscriptionType']);
      }

      if (cloudData.containsKey('expiryDate')) {
        await prefs.setString('expiry_date', cloudData['expiryDate']);
      }

      // Update local modification timestamp
      await prefs.setInt(_lastModifiedKey, cloudTimestamp);
    }
  }
}
