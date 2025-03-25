import 'package:flutter/widgets.dart';

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
  Future<bool> scheduleTimerNotification(Duration duration);

  /// Schedule a notification for a break completion
  Future<bool> scheduleBreakNotification(Duration duration);

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications();

  /// Schedule a notification for subscription expiry
  ///
  /// This method is used by RevenueCatService to notify users when their
  /// subscription is about to expire.
  ///
  /// The [expiryDate] is the date when the subscription will expire.
  /// The [subscriptionType] indicates which type of subscription is expiring.
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType);

  /// Cancel any scheduled subscription expiry notifications
  Future<void> cancelExpiryNotification();

  /// Verify if a particular notification was delivered
  ///
  /// Returns true if the notification with the given ID was successfully delivered,
  /// false otherwise.
  Future<bool> verifyDelivery(int notificationId);

  /// Track a notification that has been scheduled
  ///
  /// This should be called whenever a notification is scheduled to record its
  /// intended delivery time.
  Future<void> trackScheduledNotification(
      int notificationId, DateTime scheduledTime, String notificationType);

  /// Check if there are any missed notifications that weren't delivered
  ///
  /// Returns a list of notification IDs that were scheduled but not delivered
  Future<List<int>> checkMissedNotifications();

  /// Get the most recent delivery verification statistics
  ///
  /// Returns a map with statistics about notification delivery success rate
  Future<Map<String, dynamic>> getDeliveryStats();

  /// Display a dialog showing notification delivery statistics
  ///
  /// This provides feedback to users about notification reliability
  void displayNotificationDeliveryStats(BuildContext context);
}
