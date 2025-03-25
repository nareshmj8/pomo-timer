import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set surface size to accommodate all content
  final binding = TestWidgetsFlutterBinding.instance;
  binding.window.physicalSizeTestValue = const Size(800, 1600);
  binding.window.devicePixelRatioTestValue = 1.0;

  late MockNotificationService notificationService;
  late SharedPreferences prefs;

  setUp(() async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Initialize mocks
    notificationService = MockNotificationService();
    await notificationService.initialize();

    // Initialize service locator with mocks
    final serviceLocator = ServiceLocator();
    serviceLocator.registerNotificationService(notificationService);
  });

  tearDown(() {
    // Reset service locator
    final serviceLocator = ServiceLocator();
    serviceLocator.reset();
  });

  group('Notification Service Initialization Tests', () {
    testWidgets('Service should initialize correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Verify initialization (should have been called in setUp)
      expect(notificationService.initializeCallCount, equals(1));
      expect(find.text('Initialized: 1 times'), findsOneWidget);
    });

    testWidgets('Service should handle re-initialization',
        (WidgetTester tester) async {
      // Initialize again
      await notificationService.initialize();

      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Verify initialization count increased
      expect(notificationService.initializeCallCount, equals(2));
      expect(find.text('Initialized: 2 times'), findsOneWidget);
    });
  });

  group('Sound Playback Tests', () {
    testWidgets('Should play timer completion sound',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Verify no sounds played initially
      expect(notificationService.timerCompletionSoundCount, equals(0));

      // Play timer completion sound - use the key finder instead of text
      await tester.tap(find.byKey(const Key('playTimerSound')));
      await tester.pumpAndSettle();

      // Verify sound was played
      expect(notificationService.timerCompletionSoundCount, equals(1));
      expect(find.text('Timer Sounds: 1'), findsOneWidget);
    });

    testWidgets('Should play break completion sound',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Play break completion sound - use the key finder instead of text
      await tester.tap(find.byKey(const Key('playBreakSound')));
      await tester.pumpAndSettle();

      // Verify sound was played
      expect(notificationService.breakCompletionSoundCount, equals(1));
      expect(find.text('Break Sounds: 1'), findsOneWidget);
    });

    testWidgets('Should play long break completion sound',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Play long break completion sound - use the key finder instead of text
      await tester.tap(find.byKey(const Key('playLongBreakSound')));
      await tester.pumpAndSettle();

      // Verify sound was played
      expect(notificationService.longBreakCompletionSoundCount, equals(1));
      expect(find.text('Long Break Sounds: 1'), findsOneWidget);
    });
  });

  group('Notification Scheduling Tests', () {
    testWidgets('Should schedule timer notification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Schedule timer notification - use the key finder
      await tester.tap(find.byKey(const Key('scheduleTimerNotification')));
      await tester.pumpAndSettle();

      // Verify notification was scheduled
      expect(notificationService.scheduledTimerNotifications.length, equals(1));
      expect(notificationService.scheduledTimerNotifications.first,
          equals(const Duration(minutes: 25)));
    });

    testWidgets('Should schedule break notification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Schedule break notification - use the key finder
      await tester.tap(find.byKey(const Key('scheduleBreakNotification')));
      await tester.pumpAndSettle();

      // Verify notification was scheduled
      expect(notificationService.scheduledBreakNotifications.length, equals(1));
      expect(notificationService.scheduledBreakNotifications.first,
          equals(const Duration(minutes: 5)));
    });

    testWidgets('Should schedule expiry notification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Schedule expiry notification - use the key finder
      await tester.tap(find.byKey(const Key('scheduleExpiryNotification')));
      await tester.pumpAndSettle();

      // Verify notification was scheduled
      expect(
          notificationService.scheduledExpiryNotifications.length, equals(1));
      expect(
          notificationService.scheduleExpiryNotificationCallCount, equals(1));
      expect(
          notificationService
              .scheduledExpiryNotifications.first['subscriptionType'],
          equals('Monthly'));
    });
  });

  group('Notification Cancellation Tests', () {
    testWidgets('Should cancel all notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Schedule various notifications
      await tester.tap(find.byKey(const Key('scheduleTimerNotification')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('scheduleBreakNotification')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('scheduleExpiryNotification')));
      await tester.pumpAndSettle();

      // Verify notifications were scheduled
      expect(notificationService.scheduledTimerNotifications.length, equals(1));
      expect(notificationService.scheduledBreakNotifications.length, equals(1));
      expect(
          notificationService.scheduledExpiryNotifications.length, equals(1));

      // Scroll to make cancel button visible
      await tester.dragUntilVisible(
        find.byKey(const Key('cancelAllNotifications')),
        find.byType(SingleChildScrollView),
        const Offset(0, 100),
      );
      await tester.pumpAndSettle();

      // Cancel all notifications
      await tester.tap(find.byKey(const Key('cancelAllNotifications')));
      await tester.pumpAndSettle();

      // Verify all notifications were cancelled
      expect(notificationService.scheduledTimerNotifications.length, equals(0));
      expect(notificationService.scheduledBreakNotifications.length, equals(0));
      expect(
          notificationService.scheduledExpiryNotifications.length, equals(0));
      expect(notificationService.cancelAllNotificationsCount, equals(1));
    });

    testWidgets('Should reset notification service state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          notificationService: notificationService,
          prefs: prefs,
          child: const NotificationTestWidget(),
        ),
      );

      // Schedule a notification
      await tester.tap(find.byKey(const Key('scheduleTimerNotification')));
      await tester.pumpAndSettle();

      // Verify notification was scheduled
      expect(notificationService.scheduledTimerNotifications.length, equals(1));

      // Scroll to make reset button visible
      await tester.dragUntilVisible(
        find.byKey(const Key('resetService')),
        find.byType(SingleChildScrollView),
        const Offset(0, 100),
      );
      await tester.pumpAndSettle();

      // Reset service
      await tester.tap(find.byKey(const Key('resetService')));
      await tester.pumpAndSettle();

      // Verify service was reset
      expect(notificationService.scheduledTimerNotifications.length, equals(0));
      expect(notificationService.initializeCallCount, equals(0));
      expect(notificationService.timerCompletionSoundCount, equals(0));
      expect(notificationService.breakCompletionSoundCount, equals(0));
      expect(notificationService.longBreakCompletionSoundCount, equals(0));
    });
  });
}

class TestApp extends StatelessWidget {
  final Widget child;
  final MockNotificationService notificationService;
  final SharedPreferences prefs;

  const TestApp({
    Key? key,
    required this.child,
    required this.notificationService,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockNotificationService>.value(
          value: notificationService,
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
}

class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<MockNotificationService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Tests')),
      body: Container(
        constraints: const BoxConstraints(maxHeight: 1500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Sections
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Initialized: ${notificationService.initializeCallCount} times',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Timer Sounds: ${notificationService.timerCompletionSoundCount}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Break Sounds: ${notificationService.breakCompletionSoundCount}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Long Break Sounds: ${notificationService.longBreakCompletionSoundCount}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sound Controls
                const Text('Sound Controls',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('playTimerSound'),
                        onPressed: () async {
                          await notificationService.playTimerCompletionSound();
                        },
                        child: const Text('Play Timer Sound'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('playBreakSound'),
                        onPressed: () async {
                          await notificationService.playBreakCompletionSound();
                        },
                        child: const Text('Play Break Sound'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('playLongBreakSound'),
                        onPressed: () async {
                          await notificationService
                              .playLongBreakCompletionSound();
                        },
                        child: const Text('Play Long Break Sound'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notification Controls
                const Text('Notification Controls',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('scheduleTimerNotification'),
                        onPressed: () async {
                          await notificationService.scheduleTimerNotification(
                              const Duration(minutes: 25));
                        },
                        child: const Text('Schedule Timer (25m)'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('scheduleBreakNotification'),
                        onPressed: () async {
                          await notificationService.scheduleBreakNotification(
                              const Duration(minutes: 5));
                        },
                        child: const Text('Schedule Break (5m)'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('scheduleExpiryNotification'),
                        onPressed: () async {
                          final now = DateTime.now();
                          final expiryDate = now.add(const Duration(days: 30));
                          await notificationService.scheduleExpiryNotification(
                              expiryDate, 'Monthly');
                        },
                        child: const Text('Schedule Expiry (30d)'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Management Controls
                const Text('Management',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('cancelAllNotifications'),
                        onPressed: () async {
                          await notificationService.cancelAllNotifications();
                        },
                        child: const Text('Cancel All Notifications'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('resetService'),
                        onPressed: () {
                          notificationService.reset();
                        },
                        child: const Text('Reset Service'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
