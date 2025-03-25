import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import '../interfaces/notification_service_interface.dart';
import 'notification_sound_manager.dart';
import 'notification_scheduler.dart';
import 'notification_tracking.dart';
import 'notification_ui.dart';
import 'expiry_notification_manager.dart';
import 'notification_channel_manager.dart';

/// Main notification service that implements the notification service interface
///
/// This class coordinates all notification-related components and implements
/// the NotificationServiceInterface.
class NotificationService implements NotificationServiceInterface {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Global navigator key for context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Component managers
  final NotificationSoundManager _soundManager = NotificationSoundManager();
  final NotificationScheduler _scheduler = NotificationScheduler();
  final NotificationTracking _tracking = NotificationTracking();
  final NotificationUi _ui = NotificationUi();
  final ExpiryNotificationManager _expiryManager = ExpiryNotificationManager();
  final NotificationChannelManager _channelManager =
      NotificationChannelManager();

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialization flags
  bool _isInitialized = false;
  bool _isTimezoneInitialized = false;

  NotificationService._internal() {
    // Initialize timezone data asynchronously
    _initTimeZone().then((success) {
      if (success) {
        debugPrint(
            '🔔 NotificationService: Timezone initialization successful');
      } else {
        debugPrint('🔔 NotificationService: Timezone initialization failed');
      }
    });

    // Set up tracking callback for components
    _scheduler.setTrackingCallback(_tracking.trackScheduledNotification);
    _expiryManager.setTrackingCallback(_tracking.trackScheduledNotification);
    _ui.setGetDeliveryStatsCallback(_tracking.getDeliveryStats);
  }

  /// Initialize the notification service
  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize the plugin
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      // The initialize method might return null on newer versions of the plugin,
      // in which case we assume it was successful
      final initResult = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      final success = initResult ?? true;

      // Initialize notification channels
      await _channelManager.initializeChannels(_notificationsPlugin);

      _isInitialized = success;
      debugPrint('🔔 NotificationService: Initialization status: $success');

      return success;
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error initializing notification service: $e');
      return false;
    }
  }

  /// Play a sound when a timer session is completed
  @override
  Future<void> playTimerCompletionSound() async {
    await _soundManager.playTimerCompletionSound();
  }

  /// Play a sound when a short break is completed
  @override
  Future<void> playBreakCompletionSound() async {
    await _soundManager.playBreakCompletionSound();
  }

  /// Play a sound when a long break is completed
  @override
  Future<void> playLongBreakCompletionSound() async {
    await _soundManager.playLongBreakCompletionSound();
  }

  /// Test the notification sound with the specified type
  @override
  Future<void> playTestSound(int soundType) async {
    await _soundManager.playTestSound(soundType);
  }

  /// Schedule a notification for a timer completion
  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _scheduler.scheduleTimerNotification(duration);
  }

  /// Schedule a notification for a break completion
  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _scheduler.scheduleBreakNotification(duration);
  }

  /// Cancel all pending notifications
  @override
  Future<void> cancelAllNotifications() async {
    return await _scheduler.cancelAllNotifications();
  }

  /// Schedule a notification for subscription expiry
  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _expiryManager.scheduleExpiryNotification(
        expiryDate, subscriptionType);
  }

  /// Cancel any scheduled subscription expiry notifications
  @override
  Future<void> cancelExpiryNotification() async {
    return await _expiryManager.cancelExpiryNotification();
  }

  /// Verify if a particular notification was delivered
  @override
  Future<bool> verifyDelivery(int notificationId) async {
    return await _tracking.verifyDelivery(notificationId);
  }

  /// Track a notification that has been scheduled
  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    await _tracking.trackScheduledNotification(
        notificationId, scheduledTime, notificationType);
  }

  /// Check if there are any missed notifications that weren't delivered
  @override
  Future<List<int>> checkMissedNotifications() async {
    return await _tracking.checkMissedNotifications();
  }

  /// Get the most recent delivery verification statistics
  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    return await _tracking.getDeliveryStats();
  }

  /// Display a dialog showing notification delivery statistics
  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    _ui.displayNotificationDeliveryStats(context);
  }

  // Internal notification handlers

  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint(
        '🔔 NotificationService: Received local notification - ID: $id, Title: $title');
    // This is used for iOS versions below 10
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint(
        '🔔 NotificationService: Notification response received - ID: ${response.id}');
    // Handle notification response like navigation based on payload
  }

  // Timezone initialization

  Future<bool> _initTimeZone() async {
    if (_isTimezoneInitialized) return true;

    int retryCount = 0;
    const maxRetries = 3;
    Duration backoffDelay = const Duration(milliseconds: 500);

    while (retryCount < maxRetries) {
      try {
        tz_data.initializeTimeZones();
        final String localTimeZone =
            await FlutterNativeTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimeZone));

        debugPrint(
            '🔔 NotificationService: Timezone data initialized successfully with timezone: $localTimeZone');
        _isTimezoneInitialized = true;
        return true;
      } catch (e) {
        retryCount++;
        debugPrint(
            '🔔 NotificationService: Error initializing timezone data (attempt $retryCount/$maxRetries): $e');

        if (retryCount < maxRetries) {
          await Future.delayed(backoffDelay);
          // Exponential backoff
          backoffDelay *= 2;
        } else {
          // Final attempt: fallback to UTC if available
          try {
            tz_data.initializeTimeZones();
            tz.setLocalLocation(tz.getLocation('UTC'));
            debugPrint(
                '🔔 NotificationService: Falling back to UTC timezone after initialization failures');
            _isTimezoneInitialized = true;

            // Notify user about timezone issues
            final context = navigatorKey.currentContext;
            if (context != null && context.mounted) {
              _ui.showTimezoneErrorNotification(context);
            }
            return true;
          } catch (fallbackError) {
            debugPrint(
                '🔔 NotificationService: Even UTC fallback failed: $fallbackError');
            return false;
          }
        }
      }
    }
    return false;
  }
}
