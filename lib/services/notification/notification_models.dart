/// Constants and models for the notification service

/// Notification IDs
class NotificationIds {
  static const int expiryNotificationId = 1001;
  static const int timerCompletionNotificationId = 1002;
  static const int breakCompletionNotificationId = 1003;
  static const int longBreakCompletionNotificationId = 1004;
  static const int subscriptionSuccessNotificationId = 1005;
}

/// Notification channels
class NotificationChannels {
  // Subscription channel
  static const String subscriptionChannelId = 'subscription_channel';
  static const String subscriptionChannelName = 'Subscription Notifications';
  static const String subscriptionChannelDescription =
      'Notifications related to your subscription status';

  // Timer channel
  static const String timerChannelId = 'timer_channel';
  static const String timerChannelName = 'Timer Notifications';
  static const String timerChannelDescription =
      'Notifications related to timer events';
}

/// Notification payload keys
class NotificationPayloads {
  static const String timerCompletion = 'timer_completion';
  static const String breakCompletion = 'break_completion';
  static const String longBreakCompletion = 'long_break_completion';
  static const String subscriptionExpiry = 'subscription_expiry';
  static const String subscriptionSuccess = 'subscription_success';
}
