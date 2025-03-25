import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/notification/notification_models.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

/// Class responsible for subscription-related notifications
class SubscriptionNotifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  SubscriptionNotifications(this._flutterLocalNotificationsPlugin);

  /// Schedule a notification for subscription expiry
  Future<void> scheduleExpiryNotification(DateTime expiryDate,
      {SubscriptionType? subscriptionType}) async {
    // Only schedule for monthly and yearly subscriptions
    if (subscriptionType != null &&
        subscriptionType != SubscriptionType.monthly &&
        subscriptionType != SubscriptionType.yearly) {
      debugPrint(
          '🔔 SubscriptionNotifications: Not scheduling for lifetime subscription');
      return;
    }

    // Calculate notification time (3 days before expiry)
    final notificationTime = expiryDate.subtract(const Duration(days: 3));

    // Don't schedule if the notification time is in the past
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint(
          '🔔 SubscriptionNotifications: Notification time is in the past, not scheduling');
      return;
    }

    // Create Android notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.subscriptionChannelId,
      NotificationChannels.subscriptionChannelName,
      channelDescription: NotificationChannels.subscriptionChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    // Create iOS notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'subscription_alert.caf',
    );

    // Create notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Get subscription type text if available
    String subscriptionTypeText = '';
    if (subscriptionType != null) {
      subscriptionTypeText =
          subscriptionType == SubscriptionType.monthly ? 'monthly' : 'yearly';
    }

    // Get TZDateTime for scheduling
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(notificationTime);

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      NotificationIds.expiryNotificationId,
      subscriptionType != null
          ? 'Your $subscriptionTypeText subscription is expiring soon'
          : 'Your subscription is expiring soon',
      'Your premium features will expire in 3 days. Tap to renew your subscription.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: NotificationPayloads.subscriptionExpiry,
    );

    // Save scheduled notification info to preferences
    await _saveScheduledNotification(expiryDate);

    debugPrint(
        '🔔 SubscriptionNotifications: Scheduled expiry notification for ${scheduledDate.toIso8601String()}');
  }

  /// Cancel the subscription expiry notification
  Future<void> cancelExpiryNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(
      NotificationIds.expiryNotificationId,
    );

    // Clear scheduled notification info from preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_expiry_date');

    debugPrint('🔔 SubscriptionNotifications: Cancelled expiry notification');
  }

  /// Show subscription success notification
  Future<void> showSubscriptionSuccessNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.subscriptionChannelId,
      NotificationChannels.subscriptionChannelName,
      channelDescription: NotificationChannels.subscriptionChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'subscription_alert.caf',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      NotificationIds.subscriptionSuccessNotificationId,
      title,
      body,
      notificationDetails,
      payload: NotificationPayloads.subscriptionSuccess,
    );

    debugPrint(
        '🔔 SubscriptionNotifications: Showed subscription success notification');
  }

  /// Check if notification is already scheduled
  Future<bool> isNotificationScheduled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryDateString = prefs.getString('notification_expiry_date');

      if (expiryDateString == null) {
        debugPrint(
            '🔔 SubscriptionNotifications: No notification scheduled (no expiry date found)');
        return false;
      }

      final expiryDate = DateTime.parse(expiryDateString);

      // If expiry date has passed, notification is no longer valid
      if (expiryDate.isBefore(DateTime.now())) {
        debugPrint(
            '🔔 SubscriptionNotifications: Expiry date has passed, removing old notification data');
        await prefs.remove('notification_expiry_date');
        return false;
      }

      debugPrint(
          '🔔 SubscriptionNotifications: Notification is scheduled for expiry date: $expiryDate');
      return true;
    } catch (e) {
      debugPrint(
          '🔔 SubscriptionNotifications: Error checking notification schedule: $e');
      return false;
    }
  }

  /// Save scheduled notification info to preferences
  Future<void> _saveScheduledNotification(DateTime expiryDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'notification_expiry_date', expiryDate.toIso8601String());
      debugPrint(
          '🔔 SubscriptionNotifications: Saved notification data for expiry date: $expiryDate');
    } catch (e) {
      debugPrint(
          '🔔 SubscriptionNotifications: Error saving notification data: $e');
      rethrow; // Rethrow to allow caller to handle the error
    }
  }

  /// Convert DateTime to tz.TZDateTime for scheduling
  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    try {
      final scheduledDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        10, // Schedule for 10 AM
        0,
      );

      // For testing purposes, if the date is today, schedule for 10 seconds from now
      final now = DateTime.now();
      if (scheduledDate.year == now.year &&
          scheduledDate.month == now.month &&
          scheduledDate.day == now.day) {
        final testDate = now.add(const Duration(seconds: 10));
        debugPrint(
            '🔔 SubscriptionNotifications: Using test date for today: $testDate');
        return tz.TZDateTime.from(testDate, tz.local);
      }

      final result = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint(
          '🔔 SubscriptionNotifications: Converted DateTime $scheduledDate to TZDateTime $result');
      return result;
    } catch (e) {
      debugPrint(
          '🔔 SubscriptionNotifications: Error converting to TZDateTime: $e');
      // Fallback to current time + 1 minute if conversion fails
      return tz.TZDateTime.from(
        DateTime.now().add(const Duration(minutes: 1)),
        tz.local,
      );
    }
  }
}
