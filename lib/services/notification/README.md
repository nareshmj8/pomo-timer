# Notification Service

This directory contains the implementation of the notification service for the Pomodoro TimeMaster app. The service is responsible for managing all notifications, including timer completion, break completion, and subscription-related notifications.

## Architecture

The notification service is structured using a component-based architecture to improve maintainability and separation of concerns:

- **`notification_service.dart`**: Main facade that coordinates all notification components
- **`notification_models.dart`**: Contains constants and models for notifications
- **`notification_initializer.dart`**: Handles initialization of the notification service
- **`timer_notifications.dart`**: Manages timer completion notifications
- **`break_notifications.dart`**: Manages break and long break completion notifications
- **`subscription_notifications.dart`**: Manages subscription-related notifications
- **`notification_sounds.dart`**: Handles playing notification sounds
- **`notification_service_new.dart`**: Barrel file that exports all components
- **`notification_service_migrator.dart`**: Helper for migrating from the old service

## Usage

To use the notification service in your code, import the main service:

```dart
import 'package:pomodoro_timemaster/services/notification/notification_service.dart';
```

Then, obtain an instance of the service and initialize it:

```dart
final notificationService = NotificationService();
await notificationService.initialize();
```

### Timer Notifications

```dart
// Show timer completion notification
await notificationService.showTimerCompletionNotification(
  title: 'Timer Completed!',
  body: 'Take a short break.',
);

// Play timer completion sound
await notificationService.playTimerCompletionSound();
```

### Break Notifications

```dart
// Show break completion notification
await notificationService.showBreakCompletionNotification(
  title: 'Break Completed!',
  body: 'Time to focus again.',
);

// Show long break completion notification
await notificationService.showLongBreakCompletionNotification(
  title: 'Long Break Over!',
  body: 'Ready to get back to work?',
);
```

### Subscription Notifications

```dart
// Schedule subscription expiry notification
await notificationService.scheduleSubscriptionExpiryNotification(
  expiryDate,
  subscriptionType: SubscriptionType.monthly,
);

// Cancel subscription expiry notification
await notificationService.cancelSubscriptionExpiryNotification();

// Check if subscription notification is scheduled
final isScheduled = await notificationService.isSubscriptionNotificationScheduled();

// Show subscription success notification
await notificationService.showSubscriptionSuccessNotification(
  title: '🎉 You\'re now Premium!',
  body: 'Enjoy unlimited sessions.',
);
```

## Migration

The `NotificationServiceMigrator` helps migrate from the old notification service to the new one. It's automatically called in the app's `main.dart` file:

```dart
// Migrate from old notification service if needed
await NotificationServiceMigrator.migrate();
```

## Adding New Notification Types

To add a new notification type:

1. Add the notification ID in `NotificationIds` class in `notification_models.dart`
2. Add any necessary payload keys in `NotificationPayloads` class
3. Create a new method in the appropriate component class
4. Expose the method in the main `NotificationService` class 