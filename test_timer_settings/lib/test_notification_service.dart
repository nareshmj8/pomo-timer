import 'notification_service_interface.dart';

/// A test implementation of NotificationServiceInterface for testing purposes
class TestNotificationService implements NotificationServiceInterface {
  bool _initialized = false;

  // Counters to track method calls
  int timerCompletionSoundCount = 0;
  int breakCompletionSoundCount = 0;
  int longBreakCompletionSoundCount = 0;
  int testSoundCount = 0;
  int cancelAllNotificationsCount = 0;

  // Track scheduled notifications
  final List<Duration> scheduledTimerNotifications = [];
  final List<Duration> scheduledBreakNotifications = [];

  // Last sound type played for testing
  int? lastNotificationSoundType;

  @override
  Future<bool> initialize() async {
    _initialized = true;
    return true;
  }

  @override
  Future<void> playTimerCompletionSound() async {
    timerCompletionSoundCount++;
  }

  @override
  Future<void> playBreakCompletionSound() async {
    breakCompletionSoundCount++;
  }

  @override
  Future<void> playLongBreakCompletionSound() async {
    longBreakCompletionSoundCount++;
  }

  @override
  Future<void> playTestSound(int soundType) async {
    testSoundCount++;
    lastNotificationSoundType = soundType;
  }

  @override
  Future<void> scheduleTimerNotification(Duration duration) async {
    scheduledTimerNotifications.add(duration);
  }

  @override
  Future<void> scheduleBreakNotification(Duration duration) async {
    scheduledBreakNotifications.add(duration);
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllNotificationsCount++;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
  }

  // Helper methods for testing
  bool get isInitialized => _initialized;

  // Reset all counters for fresh tests
  void reset() {
    timerCompletionSoundCount = 0;
    breakCompletionSoundCount = 0;
    longBreakCompletionSoundCount = 0;
    testSoundCount = 0;
    cancelAllNotificationsCount = 0;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
    lastNotificationSoundType = null;
  }
}
