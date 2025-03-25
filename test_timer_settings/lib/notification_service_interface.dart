/// Interface for notification services
///
/// This interface allows for dependency injection and easier testing
/// by decoupling the implementation from the code that uses it.
abstract class NotificationServiceInterface {
  /// Initialize the notification service
  Future<bool> initialize();

  /// Play a sound when a timer session is completed
  Future<void> playTimerCompletionSound();

  /// Play a sound when a short break is completed
  Future<void> playBreakCompletionSound();

  /// Play a sound when a long break is completed
  Future<void> playLongBreakCompletionSound();

  /// Test the notification sound with the specified type
  Future<void> playTestSound(int soundType);

  /// Schedule a notification for a timer completion
  Future<void> scheduleTimerNotification(Duration duration);

  /// Schedule a notification for a break completion
  Future<void> scheduleBreakNotification(Duration duration);

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications();
}
