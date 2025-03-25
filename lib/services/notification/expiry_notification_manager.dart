import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Manages subscription expiry notifications
///
/// This class handles scheduling and cancellation of subscription expiry notifications.
class ExpiryNotificationManager {
  static final ExpiryNotificationManager _instance =
      ExpiryNotificationManager._internal();
  factory ExpiryNotificationManager() => _instance;

  ExpiryNotificationManager._internal();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int expiryNotificationId = 1001;

  // Notification tracking callback
  Function(int, DateTime, String)? _trackNotificationCallback;

  /// Set the notification tracking callback
  void setTrackingCallback(Function(int, DateTime, String) callback) {
    _trackNotificationCallback = callback;
  }

  /// Schedule a notification for subscription expiry
  ///
  /// The notification will be shown 3 days before the subscription expires.
  /// Returns true if scheduling was successful, false otherwise.
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    // Calculate notification time (3 days before expiry)
    final notificationDate = expiryDate.subtract(const Duration(days: 3));

    // Only schedule if the notification date is in the future
    if (notificationDate.isAfter(DateTime.now())) {
      try {
        // Create notification details
        const NotificationDetails notificationDetails = NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        // Schedule the notification
        await _notificationsPlugin.zonedSchedule(
          expiryNotificationId,
          'Subscription Expiring Soon',
          'Your $subscriptionType subscription will expire in 3 days. Renew now to keep premium features.',
          tz.TZDateTime.from(notificationDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Track the scheduled notification
        if (_trackNotificationCallback != null) {
          _trackNotificationCallback!(
              expiryNotificationId, notificationDate, 'expiry');
        }

        debugPrint(
            '🔔 ExpiryNotificationManager: Expiry notification scheduled for $notificationDate');
        return true;
      } catch (e) {
        debugPrint(
            '🔔 ExpiryNotificationManager: Error scheduling expiry notification: $e');
        return false;
      }
    } else {
      debugPrint(
          '🔔 ExpiryNotificationManager: Not scheduling expiry notification - date is in the past');
      return false;
    }
  }

  /// Cancel any scheduled subscription expiry notifications
  Future<void> cancelExpiryNotification() async {
    try {
      await _notificationsPlugin.cancel(expiryNotificationId);
      debugPrint('🔔 ExpiryNotificationManager: Cancelled expiry notification');
    } catch (e) {
      debugPrint(
          '🔔 ExpiryNotificationManager: Error cancelling expiry notification: $e');
    }
  }

  /// Check if an expiry notification is currently scheduled
  Future<bool> isNotificationScheduled() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }

    try {
      // On iOS, we can get pending notification requests
      if (Platform.isIOS) {
        final pendingRequests = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.pendingNotificationRequests();

        return pendingRequests
                ?.any((request) => request.id == expiryNotificationId) ??
            false;
      }

      // On Android, we check pending notification requests
      if (Platform.isAndroid) {
        final pendingRequests = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.pendingNotificationRequests();

        return pendingRequests
                ?.any((request) => request.id == expiryNotificationId) ??
            false;
      }

      return false;
    } catch (e) {
      debugPrint(
          '🔔 ExpiryNotificationManager: Error checking notification status: $e');
      return false;
    }
  }
}
