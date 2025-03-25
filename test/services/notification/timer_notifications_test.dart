import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/notification/timer_notifications.dart';
import 'package:pomodoro_timemaster/services/notification/notification_models.dart';

// Generate mocks
@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'timer_notifications_test.mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late TimerNotifications timerNotifications;

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    timerNotifications = TimerNotifications(mockNotificationsPlugin);
  });

  group('TimerNotifications', () {
    test(
        'showTimerCompletionNotification should call plugin.show with correct parameters',
        () async {
      // Arrange
      when(mockNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => true);

      const title = 'Timer Complete';
      const body = 'Time to take a break!';

      // Act
      await timerNotifications.showTimerCompletionNotification(
        title: title,
        body: body,
      );

      // Assert
      verify(mockNotificationsPlugin.show(
        NotificationIds.timerCompletionNotificationId,
        title,
        body,
        any,
        payload: NotificationPayloads.timerCompletion,
      )).called(1);
    });

    test(
        'showBreakCompletionNotification should call plugin.show with correct parameters',
        () async {
      // Arrange
      when(mockNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => true);

      const title = 'Break Complete';
      const body = 'Time to focus!';

      // Act
      await timerNotifications.showBreakCompletionNotification(
        title: title,
        body: body,
      );

      // Assert
      verify(mockNotificationsPlugin.show(
        NotificationIds.breakCompletionNotificationId,
        title,
        body,
        any,
        payload: NotificationPayloads.breakCompletion,
      )).called(1);
    });

    test(
        'showLongBreakCompletionNotification should call plugin.show with correct parameters',
        () async {
      // Arrange
      when(mockNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => true);

      const title = 'Long Break Complete';
      const body = 'Ready for the next session?';

      // Act
      await timerNotifications.showLongBreakCompletionNotification(
        title: title,
        body: body,
      );

      // Assert
      verify(mockNotificationsPlugin.show(
        NotificationIds.longBreakCompletionNotificationId,
        title,
        body,
        any,
        payload: NotificationPayloads.longBreakCompletion,
      )).called(1);
    });

    test('TimerNotifications correctly configures notification details',
        () async {
      // Arrange - we'll use a custom matcher to verify notification details
      // This is more of an implementation test but helps validate notification configuration
      when(mockNotificationsPlugin.show(
        any,
        any,
        any,
        argThat(predicate<NotificationDetails>((details) =>
            details.android != null &&
            details.iOS != null &&
            details.android!.channelId == NotificationChannels.timerChannelId)),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => true);

      // Act
      await timerNotifications.showTimerCompletionNotification(
        title: 'Test',
        body: 'Test Body',
      );

      // Assert
      verify(mockNotificationsPlugin.show(
        any,
        any,
        any,
        argThat(predicate<NotificationDetails>((details) =>
            details.android != null &&
            details.iOS != null &&
            details.android!.channelId == NotificationChannels.timerChannelId &&
            details.android!.importance == Importance.high &&
            details.android!.priority == Priority.high)),
        payload: anyNamed('payload'),
      )).called(1);
    });
  });
}
