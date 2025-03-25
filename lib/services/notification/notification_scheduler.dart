import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:app_settings/app_settings.dart';

/// Manages notification scheduling for the application
///
/// This class handles scheduling timer and break notifications, as well as
/// cancellation of notifications.
class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;

  NotificationScheduler._internal();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Global navigator key for context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Notification IDs
  static const int timerCompletionNotificationId = 1002;
  static const int breakCompletionNotificationId = 1003;
  static const int longBreakCompletionNotificationId = 1004;

  // Notification tracking
  static const String _notificationTypeTimer = 'timer';
  static const String _notificationTypeBreak = 'break';
  static const String _notificationTypeLongBreak = 'long_break';

  // Notification tracking callback
  Function(int, DateTime, String)? _trackNotificationCallback;

  /// Set the notification tracking callback
  void setTrackingCallback(Function(int, DateTime, String) callback) {
    _trackNotificationCallback = callback;
  }

  /// Schedule a notification for timer completion
  Future<bool> scheduleTimerNotification(Duration duration) async {
    try {
      // Cancel any existing timer notifications
      await _notificationsPlugin.cancel(timerCompletionNotificationId);

      debugPrint(
          '🔔 NotificationScheduler: Scheduling timer notification for duration: ${duration.inMinutes} minutes');

      // Define notification details for different platforms
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        // Customize iOS notification properties
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'complete.caf',
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Calculate when the notification should be shown
      tz.TZDateTime scheduledDate;
      try {
        scheduledDate = tz.TZDateTime.now(tz.local).add(duration);
        debugPrint(
            '🔔 NotificationScheduler: Scheduled notification with timezone: ${tz.local}');
      } catch (e) {
        // Fallback to local device time if timezone fails
        debugPrint(
            '🔔 NotificationScheduler: Error using timezone: $e. Using device local time as fallback.');
        scheduledDate = tz.TZDateTime.now(tz.UTC).add(duration);

        // Try to show timezone error to user
        _showTimezoneErrorNotification();
      }

      // Try primary scheduling method first
      try {
        // Schedule notification
        await _notificationsPlugin.zonedSchedule(
          timerCompletionNotificationId,
          'Timer Completed!',
          'Take a short break.',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Track the scheduled notification for delivery verification
        if (_trackNotificationCallback != null) {
          _trackNotificationCallback!(timerCompletionNotificationId,
              scheduledDate, _notificationTypeTimer);
        }

        debugPrint(
            '🔔 NotificationScheduler: Timer notification scheduled successfully');
        return true;
      } catch (schedulingError) {
        // Try fallback scheduling method
        debugPrint(
            '🔔 NotificationScheduler: Error scheduling timer notification: $schedulingError. Trying fallback method.');

        try {
          // Try with different scheduling mode
          await _notificationsPlugin.zonedSchedule(
            timerCompletionNotificationId,
            'Timer Completed!',
            'Take a short break.',
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint(
              '🔔 NotificationScheduler: Timer notification scheduled with fallback method');
          return true;
        } catch (fallbackError) {
          // Use delayed future as ultimate fallback
          debugPrint(
              '🔔 NotificationScheduler: Fallback scheduling failed: $fallbackError. Using delayed Future.');

          // Set a delayed Future to show the notification
          Future.delayed(duration, () {
            try {
              _notificationsPlugin.show(
                timerCompletionNotificationId,
                'Timer Completed!',
                'Take a short break.',
                notificationDetails,
              );
              debugPrint(
                  '🔔 NotificationScheduler: Timer notification shown via delayed Future');
            } catch (e) {
              debugPrint(
                  '🔔 NotificationScheduler: Failed to show timer notification via Future: $e');
            }
          });

          // Show a warning to the user that notifications might be unreliable
          _showSchedulingFallbackNotification();
          return true;
        }
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationScheduler: Critical error scheduling timer notification: $e');
      return false;
    }
  }

  /// Schedule a notification for break completion
  Future<bool> scheduleBreakNotification(Duration duration) async {
    try {
      // Cancel any existing break notifications
      await _notificationsPlugin.cancel(breakCompletionNotificationId);

      debugPrint(
          '🔔 NotificationScheduler: Scheduling break notification for duration: ${duration.inMinutes} minutes');

      // Create notification details for iOS
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'break_complete.caf',
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Calculate when the notification should be shown
      tz.TZDateTime scheduledDate;
      try {
        scheduledDate = tz.TZDateTime.now(tz.local).add(duration);
      } catch (e) {
        // Fallback to UTC if timezone initialization failed
        debugPrint(
            '🔔 NotificationScheduler: Timezone error: $e. Using UTC as fallback.');
        scheduledDate = tz.TZDateTime.now(tz.UTC).add(duration);
      }

      // Try the primary scheduling method first
      try {
        await _notificationsPlugin.zonedSchedule(
          breakCompletionNotificationId,
          'Break Completed!',
          'Ready to get back to work?',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Track the scheduled notification for delivery verification
        if (_trackNotificationCallback != null) {
          _trackNotificationCallback!(breakCompletionNotificationId,
              scheduledDate, _notificationTypeBreak);
        }

        debugPrint(
            '🔔 NotificationScheduler: Break notification scheduled with zonedSchedule');
        return true;
      } catch (schedulingError) {
        // First fallback: Try plain scheduling with a different scheduling mode
        debugPrint(
            '🔔 NotificationScheduler: Error using exactAllowWhileIdle scheduling: $schedulingError. Trying fallback method.');

        try {
          // Try scheduling with a different mode as fallback
          await _notificationsPlugin.zonedSchedule(
            breakCompletionNotificationId,
            'Break Completed!',
            'Ready to get back to work?',
            scheduledDate,
            notificationDetails,
            // Different scheduling mode as fallback
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );

          debugPrint(
              '🔔 NotificationScheduler: Break notification scheduled with fallback scheduling mode');
          return true;
        } catch (fallbackError) {
          // Second fallback: Use immediate notification with a delayed future
          debugPrint(
              '🔔 NotificationScheduler: Error with fallback scheduling: $fallbackError. Using last resort method.');

          // Set up a delayed execution as last resort
          Future.delayed(duration, () {
            try {
              _notificationsPlugin.show(
                breakCompletionNotificationId,
                'Break Completed!',
                'Ready to get back to work?',
                notificationDetails,
              );
              debugPrint(
                  '🔔 NotificationScheduler: Break notification shown with delayed Future (last resort)');
            } catch (e) {
              debugPrint(
                  '🔔 NotificationScheduler: Even last resort notification failed: $e');
            }
          });

          // Notify the user that we're using a less reliable method
          _showSchedulingFallbackNotification();
          return true;
        }
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationScheduler: Critical error scheduling break notification: $e');
      return false;
    }
  }

  /// Schedule a notification for long break completion
  Future<bool> scheduleLongBreakNotification(Duration duration) async {
    try {
      // Cancel any existing long break notifications
      await _notificationsPlugin.cancel(longBreakCompletionNotificationId);

      debugPrint(
          '🔔 NotificationScheduler: Scheduling long break notification for duration: ${duration.inMinutes} minutes');

      // Create notification details for iOS
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'long_break_complete.caf',
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Calculate when the notification should be shown
      tz.TZDateTime scheduledDate;
      try {
        scheduledDate = tz.TZDateTime.now(tz.local).add(duration);
      } catch (e) {
        // Fallback to UTC if timezone initialization failed
        debugPrint(
            '🔔 NotificationScheduler: Timezone error: $e. Using UTC as fallback.');
        scheduledDate = tz.TZDateTime.now(tz.UTC).add(duration);
      }

      // Try the primary scheduling method
      try {
        await _notificationsPlugin.zonedSchedule(
          longBreakCompletionNotificationId,
          'Long Break Completed!',
          'Ready to get back to work?',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Track the scheduled notification for delivery verification
        if (_trackNotificationCallback != null) {
          _trackNotificationCallback!(longBreakCompletionNotificationId,
              scheduledDate, _notificationTypeLongBreak);
        }

        debugPrint(
            '🔔 NotificationScheduler: Long break notification scheduled successfully');
        return true;
      } catch (e) {
        debugPrint(
            '🔔 NotificationScheduler: Error scheduling long break notification: $e');

        // Use delayed future as fallback
        Future.delayed(duration, () {
          try {
            _notificationsPlugin.show(
              longBreakCompletionNotificationId,
              'Long Break Completed!',
              'Ready to get back to work?',
              notificationDetails,
            );
            debugPrint(
                '🔔 NotificationScheduler: Long break notification shown via delayed Future');
          } catch (e) {
            debugPrint(
                '🔔 NotificationScheduler: Failed to show long break notification via Future: $e');
          }
        });

        return true;
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationScheduler: Critical error scheduling long break notification: $e');
      return false;
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🔔 NotificationScheduler: Cancelled all notifications');
  }

  // Show notification about scheduling fallback being used
  void _showSchedulingFallbackNotification() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notification scheduling issue detected. Some notifications may be delayed.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Notification Scheduling Issue'),
                    content: const Text(
                      'Your device is having trouble scheduling precise notifications. '
                      'This may affect the timing of break and timer alerts.\n\n'
                      'Possible solutions:\n'
                      '• Restart the app\n'
                      '• Check system notification settings\n'
                      '• Ensure the app has proper permissions\n'
                      '• Update your operating system',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationScheduler: Error showing fallback notification: $e');
    }
  }

  // Show notification about timezone error
  void _showTimezoneErrorNotification() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Warning: There was an issue with your timezone settings. Notifications may not be precisely timed.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Fix',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Timezone Issue Detected'),
                    content: const Text(
                        'Your device timezone settings may be incorrect, which can affect notification timing.\n\n'
                        'To fix this issue:\n'
                        '1. Go to your device Settings\n'
                        '2. Check that Date & Time settings are correct\n'
                        '3. Enable "Set automatically" if available\n'
                        '4. Restart the app'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('I\'ll fix it later'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          // Try to open device settings
                          AppSettings.openAppSettings(
                              type: AppSettingsType.settings);
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationScheduler: Error showing timezone error notification: $e');
    }
  }
}
