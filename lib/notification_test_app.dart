import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart'; // Removed unnecessary import
import 'package:pomodoro_timemaster/services/notification_service.dart';

/// A simple app to test notification functionality
class NotificationTestApp extends StatefulWidget {
  const NotificationTestApp({super.key});

  @override
  State<NotificationTestApp> createState() => _NotificationTestAppState();
}

class _NotificationTestAppState extends State<NotificationTestApp> {
  final NotificationService _notificationService = NotificationService();
  String _status = 'Ready to test notifications';
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _status = 'Initializing notification service...';
      });
    }

    try {
      await _notificationService.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _status = 'Notification service initialized successfully';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error initializing notification service: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scheduleTestNotification() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _status = 'Scheduling test notification...';
      });
    }

    try {
      // Schedule a notification for 30 days from now (monthly subscription)
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await _notificationService.scheduleExpiryNotification(
        expiryDate,
        'monthly',
      );

      if (mounted) {
        setState(() {
          _status = 'Test notification scheduled for 3 days before $expiryDate';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error scheduling test notification: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scheduleImmediateNotification() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _status = 'Scheduling immediate test notification...';
      });
    }

    try {
      // Schedule a notification for 3 days + 10 seconds from now
      // This will trigger an immediate notification (10 seconds from now)
      final expiryDate =
          DateTime.now().add(const Duration(days: 3, seconds: 10));
      await _notificationService.scheduleExpiryNotification(
        expiryDate,
        'monthly',
      );

      if (mounted) {
        setState(() {
          _status =
              'Immediate test notification scheduled (should appear in 10 seconds)';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error scheduling immediate notification: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelNotifications() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _status = 'Canceling notifications...';
      });
    }

    try {
      await _notificationService.cancelExpiryNotification();

      if (mounted) {
        setState(() {
          _status = 'Notifications canceled successfully';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error canceling notifications: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkNotificationStatus() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _status = 'Checking notification status...';
      });
    }

    try {
      final isScheduled = await _notificationService.isNotificationScheduled();

      if (mounted) {
        setState(() {
          _status = isScheduled
              ? 'Notification is scheduled'
              : 'No notification is scheduled';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error checking notification status: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add a focus scope to properly handle focus throughout the app
        return FocusScope(
          autofocus: true,
          child: child!,
        );
      },
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Notification Test'),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status display
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(_status),
                      if (_isLoading) ...[
                        const SizedBox(height: 8.0),
                        const CupertinoActivityIndicator(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Test buttons
                CupertinoButton.filled(
                  onPressed: (_isInitialized && !_isLoading)
                      ? _scheduleTestNotification
                      : null,
                  child: const Text('Schedule Test Notification (30 days)'),
                ),
                const SizedBox(height: 12.0),
                CupertinoButton.filled(
                  onPressed: (_isInitialized && !_isLoading)
                      ? _scheduleImmediateNotification
                      : null,
                  child: const Text('Schedule Immediate Test (10 sec)'),
                ),
                const SizedBox(height: 12.0),
                CupertinoButton(
                  onPressed: (_isInitialized && !_isLoading)
                      ? _cancelNotifications
                      : null,
                  child: const Text('Cancel All Notifications'),
                ),
                const SizedBox(height: 12.0),
                CupertinoButton(
                  onPressed: (_isInitialized && !_isLoading)
                      ? _checkNotificationStatus
                      : null,
                  child: const Text('Check Notification Status'),
                ),

                const SizedBox(height: 24.0),
                const Text(
                  'Note: For immediate testing, the notification will appear 10 seconds after scheduling.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
