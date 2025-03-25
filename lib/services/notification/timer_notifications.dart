import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pomodoro_timemaster/services/notification/notification_models.dart';

/// Manages timer-related notifications
class TimerNotifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  TimerNotifications(this._flutterLocalNotificationsPlugin);

  /// Shows a notification when the timer completes
  Future<void> showTimerCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 TimerNotifications: Showing timer completion notification');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      channelDescription: NotificationChannels.timerChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('timer_completion'),
      playSound: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'timer_completion.aiff',
      categoryIdentifier: 'timerCompletion',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      NotificationIds.timerCompletionNotificationId,
      title,
      body,
      notificationDetails,
      payload: NotificationPayloads.timerCompletion,
    );
  }

  /// Show break completion notification
  Future<void> showBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      channelDescription: NotificationChannels.timerChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Break completed',
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'break_completion.wav',
      categoryIdentifier: 'timer',
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

    debugPrint('🔔 TimerNotifications: Showed break completion notification');
  }

  /// Show long break completion notification
  Future<void> showLongBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      channelDescription: NotificationChannels.timerChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Long break completed',
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'long_break_completion.wav',
      categoryIdentifier: 'timer',
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

    debugPrint(
        '🔔 TimerNotifications: Showed long break completion notification');
  }
}
