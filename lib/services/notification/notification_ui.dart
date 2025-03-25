import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';

/// Manages notification-related UI elements
///
/// This class handles displaying notification delivery statistics and other
/// notification-related dialogs.
class NotificationUi {
  static final NotificationUi _instance = NotificationUi._internal();
  factory NotificationUi() => _instance;

  NotificationUi._internal();

  // Function to get delivery stats from tracking
  Future<Map<String, dynamic>> Function()? _getDeliveryStatsCallback;

  /// Set the callback for retrieving delivery statistics
  void setGetDeliveryStatsCallback(
      Future<Map<String, dynamic>> Function() callback) {
    _getDeliveryStatsCallback = callback;
  }

  /// Display notification delivery statistics
  void displayNotificationDeliveryStats(BuildContext context) {
    showDeliveryStats(context);
  }

  /// Show a dialog with notification delivery statistics
  void showDeliveryStats(BuildContext context) async {
    if (_getDeliveryStatsCallback == null) {
      debugPrint('🔔 NotificationUi: No delivery stats callback set');
      return;
    }

    // Store mounted state
    final bool contextMounted = context.mounted;

    try {
      final stats = await _getDeliveryStatsCallback!();

      // Check if context is still valid after async operation
      if (!contextMounted || !context.mounted) {
        debugPrint(
            '🔔 NotificationUi: Context no longer valid after fetching stats');
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
      debugPrint('🔔 NotificationUi: Error showing delivery stats: $e');
    }
  }

  /// Show instructions to enable notifications
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

  /// Show dialog with instructions for manually opening settings
  void showOpenSettingsManuallyDialog(BuildContext context) {
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

  /// Show notification about timezone error
  void showTimezoneErrorNotification(BuildContext context) {
    try {
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
    } catch (e) {
      debugPrint(
          '🔔 NotificationUi: Error showing timezone error notification: $e');
    }
  }

  /// Show notification about scheduling fallback being used
  void showSchedulingFallbackNotification(BuildContext context) {
    try {
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
    } catch (e) {
      debugPrint('🔔 NotificationUi: Error showing fallback notification: $e');
    }
  }

  // Build widgets showing notification type statistics
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

  // Get readable names for notification types
  String _getReadableTypeName(String type) {
    switch (type) {
      case 'timer':
        return 'Timer Completion';
      case 'break':
        return 'Break Completion';
      case 'long_break':
        return 'Long Break Completion';
      case 'expiry':
        return 'Subscription Expiry';
      case 'test':
        return 'Test Notifications';
      default:
        return 'Other';
    }
  }
}
