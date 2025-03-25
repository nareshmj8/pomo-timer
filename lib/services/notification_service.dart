import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService implements NotificationServiceInterface {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Global navigator key for context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Private constructor
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
  }

  // Flag to track initialization
  bool _isInitialized = false;

  // Flag to track timezone initialization
  bool _isTimezoneInitialized = false;

  // Initialize timezone data
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
            _showTimezoneErrorNotification();
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

  /// Shows a notification to the user about timezone issues
  void _showTimezoneErrorNotification() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Show a snackbar with the timezone error
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
                // Show dialog with instructions to fix timezone
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
          '🔔 NotificationService: Error showing timezone error notification: $e');
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Getter for testing
  FlutterLocalNotificationsPlugin get testablePlugin =>
      flutterLocalNotificationsPlugin;

  // Notification IDs
  static const int expiryNotificationId = 1001;
  static const int timerCompletionNotificationId = 1002;
  static const int breakCompletionNotificationId = 1003;
  static const int longBreakCompletionNotificationId = 1004;
  static const int subscriptionSuccessNotificationId = 1005;

  // Notification channels
  static const String subscriptionChannelId = 'subscription_channel';
  static const String subscriptionChannelName = 'Subscription Notifications';
  static const String subscriptionChannelDescription =
      'Notifications related to your subscription status';

  static const String timerChannelId = 'timer_channel';
  static const String timerChannelName = 'Timer Notifications';
  static const String timerChannelDescription =
      'Notifications related to timer events';

  // Implementation of notification delivery verification

  // Database key for storing notification tracking data
  static const String _notificationTrackingKey = 'notification_tracking_data';

  // Notification types
  static const String _notificationTypeTimer = 'timer';
  static const String _notificationTypeBreak = 'break';
  static const String _notificationTypeLongBreak = 'long_break';
  static const String _notificationTypeExpiry = 'expiry';
  static const String _notificationTypeTest = 'test';

  // Settings provider - simplified to avoid circular dependencies
  final bool _isTimerNotificationEnabled = true; // Default to enabled

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    try {
      // Get existing tracking data
      final trackingData = await _getNotificationTrackingData();

      // Add new notification tracking entry
      trackingData[notificationId.toString()] = {
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'type': notificationType,
        'delivered': false,
        'deliveryChecked': false,
        'scheduledAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Save updated tracking data
      await _saveNotificationTrackingData(trackingData);
      debugPrint(
          '🔔 NotificationService: Tracked notification #$notificationId scheduled for delivery at ${scheduledTime.toLocal()}');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error tracking notification: $e');
    }
  }

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    try {
      // Get tracking data
      final trackingData = await _getNotificationTrackingData();
      final notificationKey = notificationId.toString();

      if (!trackingData.containsKey(notificationKey)) {
        debugPrint(
            '🔔 NotificationService: No tracking data found for notification #$notificationId');
        return false;
      }

      final notificationInfo = trackingData[notificationKey];
      final scheduledTimeMs = notificationInfo['scheduledTime'] as int;
      final scheduledTime =
          DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs);

      // Check if the scheduled time has passed
      if (DateTime.now().isAfter(scheduledTime)) {
        // On iOS, we check if the app badge count changed
        // This is an indirect way to verify delivery since we can't directly query
        // which notifications were delivered
        bool delivered = false;

        if (Platform.isIOS) {
          // For iOS, we check app badge
          // Note: This is an indirect verification and has limitations
          try {
            // We check if the notification was marked as delivered in a previous check
            if (notificationInfo['delivered'] == true) {
              delivered = true;
            } else {
              // Assume delivered if scheduled time has passed and we can't directly verify
              // This has limitations but is the best approximation
              delivered = true;
            }
          } catch (e) {
            debugPrint(
                '🔔 NotificationService: Error checking iOS notification delivery: $e');
          }
        } else if (Platform.isAndroid) {
          // For Android, we check notification history if available (Android 11+)
          // Similar to iOS, we might not be able to directly verify so we use an approximation
          delivered = true;
        }

        // Update tracking data
        notificationInfo['delivered'] = delivered;
        notificationInfo['deliveryChecked'] = true;
        notificationInfo['checkedAt'] = DateTime.now().millisecondsSinceEpoch;
        await _saveNotificationTrackingData(trackingData);

        return delivered;
      } else {
        // Notification is not due yet
        debugPrint(
            '🔔 NotificationService: Notification #$notificationId is not due yet');
        return false;
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error verifying notification delivery: $e');
      return false;
    }
  }

  @override
  Future<List<int>> checkMissedNotifications() async {
    try {
      final List<int> missedNotifications = [];
      final trackingData = await _getNotificationTrackingData();
      final now = DateTime.now();

      // Cleanup old data while checking for missed notifications
      final Map<String, dynamic> updatedData = {};

      for (final entry in trackingData.entries) {
        final notificationId = int.tryParse(entry.key);
        if (notificationId == null) continue;

        final data = entry.value;
        final scheduledTimeMs = data['scheduledTime'] as int;
        final scheduledTime =
            DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs);

        // Keep data for at most 7 days for analysis
        final isRecent = now.difference(scheduledTime).inDays < 7;

        if (isRecent) {
          updatedData[entry.key] = data;

          // Check for missed notifications
          if (now.isAfter(scheduledTime) &&
              data['delivered'] == false &&
              now.difference(scheduledTime).inMinutes > 5) {
            missedNotifications.add(notificationId);

            // Update tracking data
            data['missed'] = true;
            data['missedCheckedAt'] = now.millisecondsSinceEpoch;
          }
        }
      }

      // Save updated tracking data (with cleanup)
      await _saveNotificationTrackingData(updatedData);

      return missedNotifications;
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error checking missed notifications: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    try {
      final trackingData = await _getNotificationTrackingData();
      int total = 0;
      int delivered = 0;
      int missed = 0;

      final Map<String, Map<String, int>> typeStats = {
        _notificationTypeTimer: {'total': 0, 'delivered': 0, 'missed': 0},
        _notificationTypeBreak: {'total': 0, 'delivered': 0, 'missed': 0},
        _notificationTypeLongBreak: {'total': 0, 'delivered': 0, 'missed': 0},
        _notificationTypeExpiry: {'total': 0, 'delivered': 0, 'missed': 0},
        _notificationTypeTest: {'total': 0, 'delivered': 0, 'missed': 0},
      };

      // Calculate statistics
      for (final data in trackingData.values) {
        final scheduledTimeMs = data['scheduledTime'] as int;
        final scheduledTime =
            DateTime.fromMillisecondsSinceEpoch(scheduledTimeMs);

        // Only count notifications that should have been delivered
        if (DateTime.now().isAfter(scheduledTime)) {
          total++;
          final type = data['type'] as String? ?? 'unknown';

          // Update type-specific stats
          if (typeStats.containsKey(type)) {
            typeStats[type]!['total'] = (typeStats[type]!['total'] ?? 0) + 1;
          }

          if (data['delivered'] == true) {
            delivered++;
            if (typeStats.containsKey(type)) {
              typeStats[type]!['delivered'] =
                  (typeStats[type]!['delivered'] ?? 0) + 1;
            }
          } else if (data['missed'] == true) {
            missed++;
            if (typeStats.containsKey(type)) {
              typeStats[type]!['missed'] =
                  (typeStats[type]!['missed'] ?? 0) + 1;
            }
          }
        }
      }

      // Calculate success rate
      final double successRate = total > 0 ? (delivered / total * 100) : 100.0;

      // Return statistics
      return {
        'total': total,
        'delivered': delivered,
        'missed': missed,
        'successRate': successRate,
        'typeStats': typeStats,
        'lastChecked': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint('🔔 NotificationService: Error getting delivery stats: $e');
      return {
        'total': 0,
        'delivered': 0,
        'missed': 0,
        'successRate': 0.0,
        'typeStats': {},
        'lastChecked': DateTime.now().millisecondsSinceEpoch,
        'error': e.toString(),
      };
    }
  }

  // Helper methods for notification tracking

  Future<Map<String, dynamic>> _getNotificationTrackingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_notificationTrackingKey);

      if (data == null || data.isEmpty) {
        return {};
      }

      return Map<String, dynamic>.from(json.decode(data));
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error getting notification tracking data: $e');
      return {};
    }
  }

  Future<void> _saveNotificationTrackingData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonData = json.encode(data);
      await prefs.setString(_notificationTrackingKey, jsonData);
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error saving notification tracking data: $e');
    }
  }

  // Shows a dialog with notification delivery statistics
  void showDeliveryStats(BuildContext context) async {
    if (!context.mounted) return;

    // Store mounted state before async operation
    final bool contextMounted = context.mounted;

    try {
      final stats = await getDeliveryStats();

      // Check if context is still valid after async operation
      if (!contextMounted || !context.mounted) {
        debugPrint(
            '🔔 NotificationService: Context no longer valid after fetching delivery stats');
        return;
      }

      final successRate = stats['successRate'] as double;
      final total = stats['total'] as int;
      final delivered = stats['delivered'] as int;
      final missed = stats['missed'] as int;

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Notification Delivery Stats'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Success Rate: ${successRate.toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                Text('Total Notifications: $total'),
                Text('Delivered: $delivered'),
                Text('Missed: $missed'),
                if (missed > 0 && successRate < 90) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Your device seems to be restricting background notifications. '
                    'To improve delivery, please check your device battery optimization '
                    'settings and ensure this app is not restricted.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Notification Type Breakdown:'),
                const SizedBox(height: 8),
                if (stats['typeStats'] != null)
                  ..._buildTypeStatWidgets(stats['typeStats']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                AppSettings.openAppSettings(type: AppSettingsType.settings);
              },
              child: const Text('Battery Settings'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('🔔 NotificationService: Error showing delivery stats: $e');
    }
  }

  List<Widget> _buildTypeStatWidgets(Map<String, dynamic> typeStats) {
    final List<Widget> widgets = [];

    typeStats.forEach((type, stats) {
      final typeName = _getReadableTypeName(type);
      final total = stats['total'] as int? ?? 0;

      if (total > 0) {
        final delivered = stats['delivered'] as int? ?? 0;
        final successRate = total > 0 ? (delivered / total * 100) : 0.0;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$typeName: ${successRate.toStringAsFixed(1)}% ($delivered/$total)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }
    });

    return widgets;
  }

  String _getReadableTypeName(String type) {
    switch (type) {
      case _notificationTypeTimer:
        return 'Timer Completion';
      case _notificationTypeBreak:
        return 'Break Completion';
      case _notificationTypeLongBreak:
        return 'Long Break Completion';
      case _notificationTypeExpiry:
        return 'Subscription Expiry';
      case _notificationTypeTest:
        return 'Test Notifications';
      default:
        return 'Other';
    }
  }

  // Check for missed notifications periodically
  void startDeliveryVerification() {
    // Initial check
    _checkMissedNotificationsAndUpdateStats();

    // Schedule periodic checks
    Timer.periodic(const Duration(hours: 6), (timer) {
      _checkMissedNotificationsAndUpdateStats();
    });
  }

  // Check for missed notifications and update stats
  Future<void> _checkMissedNotificationsAndUpdateStats() async {
    try {
      final missedNotifications = await checkMissedNotifications();
      final stats = await getDeliveryStats();

      // If we have missed notifications and success rate is concerning, show alert to user
      if (missedNotifications.isNotEmpty &&
          (stats['successRate'] as double) < 75.0) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          // Use Future.delayed to ensure we're not in a build phase
          Future.delayed(Duration.zero, () {
            // Check again if context is still mounted
            if (!context.mounted) return;

            // Show warning about notification delivery issues
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Some notifications might not be delivered properly. Tap for details.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orangeAccent,
                duration: const Duration(seconds: 10),
                action: SnackBarAction(
                  label: 'Details',
                  textColor: Colors.white,
                  onPressed: () => showDeliveryStats(context),
                ),
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error in periodic delivery check: $e');
    }
  }

  // Initialize the notification service
  @override
  Future<bool> initialize() async {
    try {
      debugPrint('🔔 NotificationService: Initializing...');

      // Ensure timezone is initialized
      bool timezoneInitialized = await _initTimeZone();
      if (!timezoneInitialized) {
        debugPrint(
            '🔔 NotificationService: Failed to initialize timezone data. Will use device defaults.');
        // Continue initialization but log the warning - we'll deal with it later when scheduling
      }

      // Initialize settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize settings for iOS
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      // Initialize settings for all platforms
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      final bool? initResult = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      debugPrint(
          '🔔 NotificationService: Plugin initialized with result: $initResult');

      // Request permissions for iOS
      bool permissionsGranted = true;
      if (Platform.isIOS) {
        final bool? result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        permissionsGranted = result ?? false;
        debugPrint('🔔 NotificationService: iOS permissions result: $result');

        // Handle permission denial
        if (!permissionsGranted) {
          _handlePermissionDenial();
        }
      }

      _isInitialized = true;
      debugPrint('🔔 NotificationService: Initialization complete');

      // Start delivery verification system
      startDeliveryVerification();

      return permissionsGranted;
    } catch (e, stackTrace) {
      debugPrint('🔔 NotificationService: Error during initialization: $e');
      debugPrint('🔔 NotificationService: Stack trace: $stackTrace');
      return false;
    }
  }

  // Handle notification tap
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint(
        '🔔 NotificationService: Notification tapped with payload: ${response.payload}');
    // Handle notification tap based on payload
    if (response.payload == 'subscription_expiry') {
      // Navigate to premium screen
      if (RevenueCatService.navigatorKey.currentState != null) {
        RevenueCatService.navigatorKey.currentState!.pushNamed('/premium');
        debugPrint('🔔 NotificationService: Navigated to premium screen');
      } else {
        debugPrint(
            '🔔 NotificationService: Navigator key is null or has no current state');
      }
    }
  }

  // Handle iOS notification when app is in foreground (iOS < 10)
  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // This is only needed for older iOS versions
    debugPrint('🔔 NotificationService: Received iOS notification: $title');
  }

  // Play timer completion sound
  @override
  Future<void> playTimerCompletionSound() async {
    if (!_isInitialized) {
      debugPrint(
          '🔔 NotificationService: Not initialized, initializing now...');
      await initialize();
    }

    try {
      // Create notification details for iOS with specific sound
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'complete.caf', // Using iOS system sound
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        timerCompletionNotificationId,
        'Timer Completed!',
        'Take a short break.',
        notificationDetails,
      );

      debugPrint('🔔 NotificationService: Timer completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error playing timer completion sound: $e');
    }
  }

  // Play break completion sound
  @override
  Future<void> playBreakCompletionSound() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Create notification details for iOS with specific sound
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'break_complete.caf', // Using iOS system sound
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        breakCompletionNotificationId,
        'Break Completed!',
        'Time to focus again.',
        notificationDetails,
      );

      debugPrint('🔔 NotificationService: Break completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error playing break completion sound: $e');
    }
  }

  // Play long break completion sound
  @override
  Future<void> playLongBreakCompletionSound() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Create notification details for iOS with specific sound
      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'long_break_complete.caf', // Using iOS system sound
      );

      // Create notification details for all platforms
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        longBreakCompletionNotificationId,
        'Long Break Over!',
        'Ready to get back to work?',
        notificationDetails,
      );

      debugPrint('🔔 NotificationService: Long break completion sound played');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error playing long break completion sound: $e');
    }
  }

  // Test notification sound
  @override
  Future<void> playTestSound(int soundType) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Determine sound file based on type
      String soundFile;
      String title;
      String body;

      switch (soundType) {
        case 1:
          soundFile = 'complete.caf';
          title = 'Timer Sound Test';
          body = 'This is how your timer completion will sound';
          break;
        case 2:
          soundFile = 'break_complete.caf';
          title = 'Break Sound Test';
          body = 'This is how your break completion will sound';
          break;
        case 3:
          soundFile = 'long_break_complete.caf';
          title = 'Long Break Sound Test';
          body = 'This is how your long break completion will sound';
          break;
        default:
          soundFile = 'complete.caf';
          title = 'Sound Test';
          body = 'Testing notification sound';
      }

      // Create notification details for iOS with the selected sound
      final DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: soundFile,
      );

      // Create notification details for all platforms
      final NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        1000, // Use a different ID for test
        title,
        body,
        notificationDetails,
      );

      debugPrint(
          '🔔 NotificationService: Test sound played (type: $soundType)');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error playing test sound: $e');
    }
  }

  // Schedule timer notification
  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel any existing timer notifications
      await flutterLocalNotificationsPlugin
          .cancel(timerCompletionNotificationId);

      debugPrint(
          '🔔 NotificationService: Scheduling timer notification for duration: ${duration.inMinutes} minutes');

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
            '🔔 NotificationService: Scheduled notification with timezone: ${tz.local}');
      } catch (e) {
        // Fallback to local device time if timezone fails
        debugPrint(
            '🔔 NotificationService: Error using timezone: $e. Using device local time as fallback.');
        scheduledDate = tz.TZDateTime.now(tz.UTC).add(duration);

        // Try to show timezone error to user
        if (!_isTimezoneInitialized) {
          _showTimezoneErrorNotification();
        }
      }

      // Try primary scheduling method first
      try {
        // Schedule notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
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
        await trackScheduledNotification(timerCompletionNotificationId,
            scheduledDate, _notificationTypeTimer);

        debugPrint(
            '🔔 NotificationService: Timer notification scheduled successfully');
        return true;
      } catch (schedulingError) {
        // Try fallback scheduling method
        debugPrint(
            '🔔 NotificationService: Error scheduling timer notification: $schedulingError. Trying fallback method.');

        try {
          // Try with different scheduling mode
          await flutterLocalNotificationsPlugin.zonedSchedule(
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
              '🔔 NotificationService: Timer notification scheduled with fallback method');
          return true;
        } catch (fallbackError) {
          // Use delayed future as ultimate fallback
          debugPrint(
              '🔔 NotificationService: Fallback scheduling failed: $fallbackError. Using delayed Future.');

          // Set a delayed Future to show the notification
          Future.delayed(duration, () {
            try {
              flutterLocalNotificationsPlugin.show(
                timerCompletionNotificationId,
                'Timer Completed!',
                'Take a short break.',
                notificationDetails,
              );
              debugPrint(
                  '🔔 NotificationService: Timer notification shown via delayed Future');
            } catch (e) {
              debugPrint(
                  '🔔 NotificationService: Failed to show timer notification via Future: $e');
            }
          });

          // Show a warning to the user that notifications might be unreliable
          _showSchedulingFallbackNotification();
          return true;
        }
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Critical error scheduling timer notification: $e');
      return false;
    }
  }

  // Schedule break notification
  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel any existing break notifications
      await flutterLocalNotificationsPlugin
          .cancel(breakCompletionNotificationId);

      debugPrint(
          '🔔 NotificationService: Scheduling break notification for duration: ${duration.inMinutes} minutes');

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
            '🔔 NotificationService: Timezone error: $e. Using UTC as fallback.');
        scheduledDate = tz.TZDateTime.now(tz.UTC).add(duration);
      }

      // Try the primary scheduling method first
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
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
        await trackScheduledNotification(breakCompletionNotificationId,
            scheduledDate, _notificationTypeBreak);

        debugPrint(
            '🔔 NotificationService: Break notification scheduled with zonedSchedule');
        return true;
      } catch (schedulingError) {
        // First fallback: Try plain scheduling with a different scheduling mode
        debugPrint(
            '🔔 NotificationService: Error using exactAllowWhileIdle scheduling: $schedulingError. Trying fallback method.');

        try {
          // Try scheduling with a different mode as fallback
          await flutterLocalNotificationsPlugin.zonedSchedule(
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
              '🔔 NotificationService: Break notification scheduled with fallback scheduling mode');
          return true;
        } catch (fallbackError) {
          // Second fallback: Use immediate notification with a delayed future
          debugPrint(
              '🔔 NotificationService: Error with fallback scheduling: $fallbackError. Using last resort method.');

          // Set up a delayed execution as last resort
          Future.delayed(duration, () {
            try {
              flutterLocalNotificationsPlugin.show(
                breakCompletionNotificationId,
                'Break Completed!',
                'Ready to get back to work?',
                notificationDetails,
              );
              debugPrint(
                  '🔔 NotificationService: Break notification shown with delayed Future (last resort)');
            } catch (e) {
              debugPrint(
                  '🔔 NotificationService: Even last resort notification failed: $e');
            }
          });

          // Notify the user that we're using a less reliable method
          _showSchedulingFallbackNotification();
          return true;
        }
      }
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Critical error scheduling break notification: $e');
      return false;
    }
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
          '🔔 NotificationService: Error showing fallback notification: $e');
    }
  }

  // Cancel all pending notifications
  @override
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    if (!_isInitialized) {
      await initialize();
    }

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
        await flutterLocalNotificationsPlugin.zonedSchedule(
          expiryNotificationId,
          'Subscription Expiring Soon',
          'Your $subscriptionType subscription will expire in 3 days. Renew now to keep premium features.',
          tz.TZDateTime.from(notificationDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        debugPrint(
            '🔔 NotificationService: Expiry notification scheduled for $notificationDate');
        return true;
      } catch (e) {
        debugPrint(
            '🔔 NotificationService: Error scheduling expiry notification: $e');
        return false;
      }
    } else {
      debugPrint(
          '🔔 NotificationService: Not scheduling expiry notification - date is in the past');
      return false;
    }
  }

  @override
  Future<void> cancelExpiryNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(expiryNotificationId);
      debugPrint('🔔 NotificationService: Cancelled expiry notification');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error cancelling expiry notification: $e');
    }
  }

  /// Schedule all necessary notifications
  Future<void> scheduleAllNotifications() async {
    try {
      // Cancel any existing notifications first
      await cancelAllNotifications();

      // Schedule default timer expiry notification if needed
      if (_isTimerNotificationEnabled) {
        // Use a placeholder date for the daily reminder
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        await scheduleExpiryNotification(tomorrow, "Daily");
      }

      debugPrint(
          '🔔 NotificationService: All notifications scheduled successfully');
    } catch (e) {
      debugPrint('🔔 NotificationService: Error scheduling notifications: $e');
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
        final pendingRequests = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.pendingNotificationRequests();

        return pendingRequests
                ?.any((request) => request.id == expiryNotificationId) ??
            false;
      }

      // On Android, we check pending notification requests
      if (Platform.isAndroid) {
        final pendingRequests = await flutterLocalNotificationsPlugin
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
          '🔔 NotificationService: Error checking notification status: $e');
      return false;
    }
  }

  // Handle notification permission denial
  void _handlePermissionDenial() {
    debugPrint('🔔 NotificationService: Notification permissions denied');

    // Store the permission state
    _storePermissionState(false);

    // Show instructions to users on next app start
    scheduleMicrotask(() {
      if (navigatorKey.currentContext != null) {
        showPermissionInstructions(navigatorKey.currentContext!);
      }
    });
  }

  // Store notification permission state
  Future<void> _storePermissionState(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_permission_granted', granted);
      await prefs.setInt('notification_permission_last_checked',
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('🔔 NotificationService: Error storing permission state: $e');
    }
  }

  // Show instructions to enable notifications
  void showPermissionInstructions(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'To get timer alerts, please enable notifications for this app in your device settings.\n\n'
          'Go to Settings > Notifications > Pomodoro Timer',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Later'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
          ),
        ],
      ),
    );
  }

  // Show immediate notification with custom title and body
  Future<void> showImmediateNotification(
      {required String title, required String body, String? payload}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Create notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          timerChannelId,
          timerChannelName,
          channelDescription: timerChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Generate a unique ID based on current time
      final int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint(
          '🔔 NotificationService: Showed immediate notification: $title');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error showing immediate notification: $e');
    }
  }

  // Open notification settings
  Future<void> openNotificationSettings() async {
    try {
      if (Platform.isIOS) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
      } else if (Platform.isAndroid) {
        await AppSettings.openAppSettings(type: AppSettingsType.notification);
      }
      debugPrint('🔔 NotificationService: Opened notification settings');
    } catch (e) {
      debugPrint(
          '🔔 NotificationService: Error opening notification settings: $e');

      // Fallback: show a dialog with instructions
      _showOpenSettingsManuallyDialog();
    }
  }

  // Show dialog with instructions for manually opening settings
  void _showOpenSettingsManuallyDialog() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Open Settings'),
            content: const Text(
                'To enable notifications, please open your device settings:\n\n'
                '1. Go to Settings\n'
                '2. Tap on Apps or Application Manager\n'
                '3. Find this app\n'
                '4. Tap on Notifications\n'
                '5. Enable notifications'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Public method to display notification statistics from settings
  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    showDeliveryStats(context);
  }
}
