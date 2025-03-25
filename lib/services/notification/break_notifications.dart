import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro_timemaster/services/notification/notification_models.dart';

/// Manages break-related notifications
class BreakNotifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  BreakNotifications(this._flutterLocalNotificationsPlugin);

  /// Shows a notification when a break is completed
  Future<void> showBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 BreakNotifications: Showing break completion notification');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      channelDescription: NotificationChannels.timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('break_completion'),
      playSound: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'break_completion.aiff',
      categoryIdentifier: 'breakCompletion',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      NotificationIds.breakCompletionNotificationId,
      title,
      body,
      notificationDetails,
      payload: NotificationPayloads.breakCompletion,
    );
  }

  /// Shows a notification when a long break is completed
  Future<void> showLongBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        '🔔 BreakNotifications: Showing long break completion notification');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      channelDescription: NotificationChannels.timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('long_break_completion'),
      playSound: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'long_break_completion.aiff',
      categoryIdentifier: 'longBreakCompletion',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      NotificationIds.longBreakCompletionNotificationId,
      title,
      body,
      notificationDetails,
      payload: NotificationPayloads.longBreakCompletion,
    );
  }
}
