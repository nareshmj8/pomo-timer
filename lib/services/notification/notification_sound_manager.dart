import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages notification sounds for the application
///
/// This class handles playing different sounds based on the timer state
/// and provides methods for testing notification sounds.
class NotificationSoundManager {
  static final NotificationSoundManager _instance =
      NotificationSoundManager._internal();
  factory NotificationSoundManager() => _instance;

  NotificationSoundManager._internal();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Sound configuration
  final String _timerSoundFile = 'complete.caf'; // iOS system sound
  final String _breakSoundFile = 'break_complete.caf'; // iOS system sound
  final String _longBreakSoundFile =
      'long_break_complete.caf'; // iOS system sound

  // ID for sound notifications
  static const int _soundNotificationId = 9000;

  /// Play a sound when a timer session is completed
  Future<void> playTimerCompletionSound() async {
    try {
      await _playNotificationSound(
        _timerSoundFile,
        'Timer Complete',
        'Your timer session is complete',
      );
      debugPrint('🔔 NotificationSoundManager: Timer completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationSoundManager: Error playing timer completion sound: $e');
    }
  }

  /// Play a sound when a short break is completed
  Future<void> playBreakCompletionSound() async {
    try {
      await _playNotificationSound(
        _breakSoundFile,
        'Break Complete',
        'Your break is complete',
      );
      debugPrint('🔔 NotificationSoundManager: Break completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationSoundManager: Error playing break completion sound: $e');
    }
  }

  /// Play a sound when a long break is completed
  Future<void> playLongBreakCompletionSound() async {
    try {
      await _playNotificationSound(
        _longBreakSoundFile,
        'Long Break Complete',
        'Your long break is complete',
      );
      debugPrint(
          '🔔 NotificationSoundManager: Long break completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationSoundManager: Error playing long break completion sound: $e');
    }
  }

  /// Test the notification sound with the specified type
  ///
  /// Sound types:
  /// 1 - Timer completion sound
  /// 2 - Break completion sound
  /// 3 - Long break completion sound
  Future<void> playTestSound(int soundType) async {
    try {
      String soundFile;
      String title;
      String body;

      switch (soundType) {
        case 1:
          soundFile = _timerSoundFile;
          title = 'Timer Sound Test';
          body = 'This is how your timer completion will sound';
          break;
        case 2:
          soundFile = _breakSoundFile;
          title = 'Break Sound Test';
          body = 'This is how your break completion will sound';
          break;
        case 3:
          soundFile = _longBreakSoundFile;
          title = 'Long Break Sound Test';
          body = 'This is how your long break completion will sound';
          break;
        default:
          soundFile = _timerSoundFile;
          title = 'Sound Test';
          body = 'Testing notification sound';
          break;
      }

      await _playNotificationSound(soundFile, title, body);
      debugPrint(
          '🔔 NotificationSoundManager: Test sound played (type: $soundType)');
    } catch (e) {
      debugPrint('🔔 NotificationSoundManager: Error playing test sound: $e');
    }
  }

  // Private method to play a notification sound
  Future<void> _playNotificationSound(
      String soundFile, String title, String body) async {
    try {
      if (Platform.isIOS) {
        // iOS notification with sound
        final DarwinNotificationDetails iosNotificationDetails =
            DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: true,
          sound: soundFile,
        );

        final NotificationDetails notificationDetails = NotificationDetails(
          iOS: iosNotificationDetails,
        );

        await _notificationsPlugin.show(
          _soundNotificationId,
          title,
          body,
          notificationDetails,
        );
      } else if (Platform.isAndroid) {
        // Android notification with sound
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'sound_channel',
          'Sound Channel',
          channelDescription: 'Channel for playing sounds',
          importance: Importance.low,
          priority: Priority.low,
          playSound: true,
          enableVibration: false,
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        await _notificationsPlugin.show(
          _soundNotificationId,
          title,
          body,
          notificationDetails,
        );
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationSoundManager: Error playing notification sound: $e');
      rethrow;
    }
  }
}
