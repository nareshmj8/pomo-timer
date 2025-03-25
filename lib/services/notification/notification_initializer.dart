import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:pomodoro_timemaster/services/notification/notification_models.dart';

/// Class responsible for initializing the notification service
class NotificationInitializer {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isInitialized = false;

  NotificationInitializer(this.flutterLocalNotificationsPlugin) {
    _initTimeZone();
  }

  /// Initialize timezone data
  void _initTimeZone() {
    try {
      tz.initializeTimeZones();
      debugPrint(
          '🔔 NotificationInitializer: Timezone data initialized in constructor');
    } catch (e) {
      debugPrint(
          '🔔 NotificationInitializer: Error initializing timezone data: $e');
    }
  }

  /// Initialize the notification service
  Future<bool> initialize() async {
    // Prevent multiple initializations
    if (isInitialized) {
      debugPrint('🔔 NotificationInitializer: Already initialized, skipping');
      return true;
    }

    // Initialize notification settings for Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    // Initialize notification settings for iOS
    final DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // Initialize notification settings for all platforms
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialize the plugin
    final bool? result = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request permissions for iOS
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    isInitialized = result ?? false;
    debugPrint('🔔 NotificationInitializer: Initialized with result: $result');
    return isInitialized;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Create subscription channel
    const AndroidNotificationChannel subscriptionChannel =
        AndroidNotificationChannel(
      NotificationChannels.subscriptionChannelId,
      NotificationChannels.subscriptionChannelName,
      description: NotificationChannels.subscriptionChannelDescription,
      importance: Importance.high,
    );

    // Create timer channel
    const AndroidNotificationChannel timerChannel = AndroidNotificationChannel(
      NotificationChannels.timerChannelId,
      NotificationChannels.timerChannelName,
      description: NotificationChannels.timerChannelDescription,
      importance: Importance.high,
    );

    // Create the channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(subscriptionChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(timerChannel);

    debugPrint('🔔 NotificationInitializer: Created notification channels');
  }

  /// Request permissions for iOS
  Future<void> _requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    debugPrint('🔔 NotificationInitializer: Requested iOS permissions');
  }

  /// Handle legacy iOS notification
  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint(
        '🔔 NotificationInitializer: Received local notification: $id, $title, $body, $payload');
  }

  /// Handle notification response
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint(
        '🔔 NotificationInitializer: Notification tapped with payload: ${response.payload}');
  }
}
