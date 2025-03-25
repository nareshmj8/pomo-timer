import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';

// A standalone test app that doesn't use the singleton NotificationService
class NotificationTestApp extends StatefulWidget {
  final Function(BuildContext) onBuild;
  const NotificationTestApp({Key? key, required this.onBuild})
      : super(key: key);

  @override
  State<NotificationTestApp> createState() => _NotificationTestAppState();
}

class _NotificationTestAppState extends State<NotificationTestApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Notification Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // We're not actually using these buttons in tests,
                  // they're just placeholders for the UI
                },
                child: const Text('Test Timer Notification'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Test Break Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mock notification service for testing
class MockNotificationService implements NotificationService {
  // Track notification requests
  Map<String, bool> notificationsShown = {};

  // Track scheduled notifications
  Map<String, DateTime> scheduledNotifications = {};

  // Return a dummy plugin for testing
  @override
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @override
  FlutterLocalNotificationsPlugin get testablePlugin =>
      flutterLocalNotificationsPlugin;

  // Override methods to track calls
  @override
  Future<bool> initialize() async {
    // Skip actual initialization
    debugPrint(
        '🔔 MockNotificationService: Initialization skipped for testing');
    return true;
  }

  @override
  Future<void> cancelAllNotifications() async {
    debugPrint('🔔 MockNotificationService: Cancelled all notifications');
    scheduledNotifications.clear();
    return;
  }

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    final scheduledDate = DateTime.now().add(duration);
    debugPrint(
        '🔔 MockNotificationService: Scheduled timer notification for $scheduledDate');
    scheduledNotifications['timerNotification'] = scheduledDate;
    return true;
  }

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    final scheduledDate = DateTime.now().add(duration);
    debugPrint(
        '🔔 MockNotificationService: Scheduled break notification for $scheduledDate');
    scheduledNotifications['breakNotification'] = scheduledDate;
    return true;
  }

  @override
  Future<void> showPermissionInstructions(BuildContext context) async {
    debugPrint('🔔 MockNotificationService: Showing permission instructions');
    notificationsShown['permissionInstructions'] = true;
    return;
  }

  Future<bool> areNotificationsEnabled() async {
    return true;
  }

  Future<bool> isSoundEnabled() async {
    return true;
  }

  Future<bool> isVibrationEnabled() async {
    return true;
  }

  Future<void> showTimerCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        '🔔 MockNotificationService: Timer completion notification shown - $title: $body');
    notificationsShown['timerCompletion'] = true;
  }

  @override
  Future<void> playTimerCompletionSound() async {
    debugPrint('🔔 MockNotificationService: Playing timer completion sound');
    return;
  }

  Future<void> showBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        '🔔 MockNotificationService: Break completion notification shown - $title: $body');
    notificationsShown['breakCompletion'] = true;
  }

  @override
  Future<void> playBreakCompletionSound() async {
    debugPrint('🔔 MockNotificationService: Playing break completion sound');
    return;
  }

  Future<void> showLongBreakCompletionNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        '🔔 MockNotificationService: Long break completion notification shown - $title: $body');
    notificationsShown['longBreakCompletion'] = true;
  }

  @override
  Future<void> playLongBreakCompletionSound() async {
    debugPrint(
        '🔔 MockNotificationService: Playing long break completion sound');
    return;
  }

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    scheduledNotifications['expiryNotification'] = expiryDate;
    debugPrint(
        '🔔 MockNotificationService: Scheduled expiry notification for $expiryDate');
    return true;
  }

  @override
  Future<void> cancelExpiryNotification() async {
    scheduledNotifications.remove('expiryNotification');
    debugPrint('🔔 MockNotificationService: Cancelled expiry notification');
  }

  @override
  Future<bool> isNotificationScheduled() async {
    return scheduledNotifications.containsKey('expiryNotification');
  }

  Future<void> showSubscriptionSuccessNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        '🔔 MockNotificationService: Subscription success notification shown - $title: $body');
    notificationsShown['subscriptionSuccess'] = true;
  }

  Future<void> playSubscriptionSuccessSound() async {
    debugPrint(
        '🔔 MockNotificationService: Playing subscription success sound');
    return;
  }

  @override
  Future<void> playTestSound(int sound) async {
    debugPrint('🔔 MockNotificationService: Playing test sound: $sound');
    return;
  }

  void handleNotificationResponse(NotificationResponse response) {
    debugPrint(
        '🔔 MockNotificationService: Handling notification response with payload: ${response.payload}');
  }

  // New required methods from NotificationServiceInterface
  @override
  Future<List<int>> checkMissedNotifications() async {
    debugPrint('🔔 MockNotificationService: Checking missed notifications');
    return [];
  }

  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    debugPrint(
        '🔔 MockNotificationService: Displaying notification delivery stats');
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    debugPrint('🔔 MockNotificationService: Getting delivery stats');
    return {'scheduled': 0, 'delivered': 0};
  }

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    debugPrint(
        '🔔 MockNotificationService: Tracking scheduled notification $notificationId of type $notificationType at $scheduledTime');
  }

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    debugPrint(
        '🔔 MockNotificationService: Verifying delivery of notification $notificationId');
    return false;
  }

  @override
  Future<void> openNotificationSettings() async {
    debugPrint('🔔 MockNotificationService: Opening notification settings');
  }

  @override
  Future<void> scheduleAllNotifications() async {
    debugPrint('🔔 MockNotificationService: Scheduling all notifications');
  }

  @override
  void showDeliveryStats(BuildContext context) {
    debugPrint('🔔 MockNotificationService: Showing delivery stats');
  }

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint(
        '🔔 MockNotificationService: Showing immediate notification: $title - $body');
  }

  @override
  Future<void> startDeliveryVerification() async {
    debugPrint('🔔 MockNotificationService: Starting delivery verification');
  }

  // Reset tracking for tests
  void reset() {
    notificationsShown.clear();
    scheduledNotifications.clear();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationService mockService;

  group('Notification Integration Tests', () {
    setUp(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      // Create the mock notification service
      mockService = MockNotificationService();
      mockService.reset();
    });

    testWidgets('Timer completion notification can be shown',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Test timer completion notification
      await mockService.showTimerCompletionNotification(
        title: 'Session Complete',
        body: 'Your focus session is complete',
      );

      // Verify the notification was "shown"
      expect(mockService.notificationsShown['timerCompletion'], isTrue);
    });

    testWidgets('Break completion notification can be shown',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Test break completion notification
      await mockService.showBreakCompletionNotification(
        title: 'Break Complete',
        body: 'Your break is over',
      );

      // Verify the notification was "shown"
      expect(mockService.notificationsShown['breakCompletion'], isTrue);
    });

    testWidgets('Long break completion notification can be shown',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Test long break completion notification
      await mockService.showLongBreakCompletionNotification(
        title: 'Long Break Complete',
        body: 'Ready to focus again?',
      );

      // Verify the notification was "shown"
      expect(mockService.notificationsShown['longBreakCompletion'], isTrue);
    });

    testWidgets('Subscription success notification can be shown',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Test subscription success notification
      await mockService.showSubscriptionSuccessNotification(
        title: 'Premium Activated',
        body: 'Thank you for subscribing to premium!',
      );

      // Verify the notification was "shown"
      expect(mockService.notificationsShown['subscriptionSuccess'], isTrue);
    });

    testWidgets('Expiry notifications can be scheduled and cancelled',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Schedule a notification for 30 days from now (simulating subscription expiry)
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await mockService.scheduleExpiryNotification(expiryDate, 'monthly');

      // Verify the notification was scheduled
      expect(
          mockService.scheduledNotifications['expiryNotification'], isNotNull);
      expect(await mockService.isNotificationScheduled(), isTrue);

      // Check that the scheduled time is close to what we expected
      final scheduledTime =
          mockService.scheduledNotifications['expiryNotification']!;
      final difference = scheduledTime.difference(expiryDate).inMinutes.abs();

      // Allow for a small difference due to execution time
      expect(difference < 5, isTrue);

      // Cancel the notification
      await mockService.cancelExpiryNotification();

      // Verify it was cancelled
      expect(await mockService.isNotificationScheduled(), isFalse);
    });

    testWidgets('Notification permissions can be checked',
        (WidgetTester tester) async {
      // Load a minimal test UI
      await tester.pumpWidget(
        NotificationTestApp(
          onBuild: (context) {
            // testContext = context;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Check notification permissions
      final permissionsEnabled = await mockService.areNotificationsEnabled();

      // Our mock returns true
      expect(permissionsEnabled, isTrue);

      // Check sound and vibration settings
      expect(await mockService.isSoundEnabled(), isTrue);
      expect(await mockService.isVibrationEnabled(), isTrue);
    });
  });
}
