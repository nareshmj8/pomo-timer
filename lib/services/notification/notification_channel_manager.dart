import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Manages notification channels for the application
///
/// This class handles the creation and configuration of notification channels
/// on different platforms.
class NotificationChannelManager {
  static final NotificationChannelManager _instance =
      NotificationChannelManager._internal();
  factory NotificationChannelManager() => _instance;

  NotificationChannelManager._internal();

  // Notification channels
  static const String subscriptionChannelId = 'subscription_channel';
  static const String subscriptionChannelName = 'Subscription Notifications';
  static const String subscriptionChannelDescription =
      'Notifications related to your subscription status';

  static const String timerChannelId = 'timer_channel';
  static const String timerChannelName = 'Timer Notifications';
  static const String timerChannelDescription =
      'Notifications related to timer events';

  /// Initialize notification channels
  ///
  /// This method creates and configures the notification channels on different platforms.
  Future<void> initializeChannels(
      FlutterLocalNotificationsPlugin notificationsPlugin) async {
    try {
      if (Platform.isAndroid) {
        await _initializeAndroidChannels(notificationsPlugin);
      } else if (Platform.isIOS) {
        await _initializeIOSChannels(notificationsPlugin);
      }
      debugPrint(
          '🔔 NotificationChannelManager: Channels initialized successfully');
    } catch (e) {
      debugPrint(
          '🔔 NotificationChannelManager: Error initializing channels: $e');
    }
  }

  /// Initialize Android notification channels
  Future<void> _initializeAndroidChannels(
      FlutterLocalNotificationsPlugin notificationsPlugin) async {
    // Timer channel
    const AndroidNotificationChannel timerChannel = AndroidNotificationChannel(
      timerChannelId,
      timerChannelName,
      description: timerChannelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Subscription channel
    const AndroidNotificationChannel subscriptionChannel =
        AndroidNotificationChannel(
      subscriptionChannelId,
      subscriptionChannelName,
      description: subscriptionChannelDescription,
      importance: Importance.high,
    );

    // Create the channels
    final flutterLocalNotificationsPlugin = notificationsPlugin;
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(timerChannel);
      await androidImplementation
          .createNotificationChannel(subscriptionChannel);
      debugPrint('🔔 NotificationChannelManager: Android channels created');
    }
  }

  /// Initialize iOS notification settings
  Future<void> _initializeIOSChannels(
      FlutterLocalNotificationsPlugin notificationsPlugin) async {
    // For iOS, we don't create channels but we request permissions
    final flutterLocalNotificationsPlugin = notificationsPlugin;
    final iOSImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSImplementation != null) {
      await iOSImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
      debugPrint('🔔 NotificationChannelManager: iOS permissions requested');
    }
  }

  /// Get the appropriate channel ID based on notification type
  String getChannelIdForType(String notificationType) {
    if (notificationType == 'expiry') {
      return subscriptionChannelId;
    } else {
      return timerChannelId;
    }
  }
}
