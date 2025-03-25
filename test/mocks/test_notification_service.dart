import 'package:flutter/widgets.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';

/// A test implementation of NotificationServiceInterface for testing purposes
class TestNotificationService implements NotificationServiceInterface {
  bool _initialized = false;

  // Counters to track method calls
  int timerCompletionSoundCount = 0;
  int breakCompletionSoundCount = 0;
  int longBreakCompletionSoundCount = 0;
  int testSoundCount = 0;
  int cancelAllNotificationsCount = 0;
  int cancelExpiryNotificationCount = 0;
  int checkMissedNotificationsCount = 0;
  int verifyDeliveryCount = 0;
  int displayStatsCount = 0;
  int trackScheduledCount = 0;

  // Last sound type played for testing
  int? lastNotificationSoundType;

  // Last tracked notification info
  int? lastNotificationId;
  DateTime? lastScheduledTime;
  String? lastNotificationType;

  // Track scheduled notifications
  final List<Duration> scheduledTimerNotifications = [];
  final List<Duration> scheduledBreakNotifications = [];
  final List<Map<String, dynamic>> scheduledExpiryNotifications = [];
  final Map<int, bool> notificationDeliveryStatus = {};

  @override
  Future<bool> initialize() async {
    _initialized = true;
    return true;
  }

  @override
  Future<void> playTimerCompletionSound() async {
    timerCompletionSoundCount++;
  }

  @override
  Future<void> playBreakCompletionSound() async {
    breakCompletionSoundCount++;
  }

  @override
  Future<void> playLongBreakCompletionSound() async {
    longBreakCompletionSoundCount++;
  }

  @override
  Future<void> playTestSound(int soundType) async {
    testSoundCount++;
    lastNotificationSoundType = soundType;
  }

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    scheduledTimerNotifications.add(duration);
    return true;
  }

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    scheduledBreakNotifications.add(duration);
    return true;
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllNotificationsCount++;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
  }

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    scheduledExpiryNotifications.add({
      'expiryDate': expiryDate,
      'subscriptionType': subscriptionType,
    });
    return true;
  }

  @override
  Future<void> cancelExpiryNotification() async {
    cancelExpiryNotificationCount++;
    scheduledExpiryNotifications.clear();
  }

  @override
  Future<List<int>> checkMissedNotifications() async {
    checkMissedNotificationsCount++;
    return [];
  }

  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    displayStatsCount++;
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    return {
      'scheduled': scheduledTimerNotifications.length +
          scheduledBreakNotifications.length +
          scheduledExpiryNotifications.length,
      'delivered': notificationDeliveryStatus.values.where((v) => v).length,
    };
  }

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    trackScheduledCount++;
    lastNotificationId = notificationId;
    lastScheduledTime = scheduledTime;
    lastNotificationType = notificationType;
    notificationDeliveryStatus[notificationId] = false; // Not delivered yet
  }

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    verifyDeliveryCount++;
    return notificationDeliveryStatus[notificationId] ?? false;
  }

  // Helper methods for testing
  bool get isInitialized => _initialized;

  // Reset all counters for fresh tests
  void reset() {
    timerCompletionSoundCount = 0;
    breakCompletionSoundCount = 0;
    longBreakCompletionSoundCount = 0;
    testSoundCount = 0;
    cancelAllNotificationsCount = 0;
    cancelExpiryNotificationCount = 0;
    checkMissedNotificationsCount = 0;
    verifyDeliveryCount = 0;
    displayStatsCount = 0;
    trackScheduledCount = 0;

    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
    scheduledExpiryNotifications.clear();
    notificationDeliveryStatus.clear();

    lastNotificationSoundType = null;
    lastNotificationId = null;
    lastScheduledTime = null;
    lastNotificationType = null;
  }

  // Helper to simulate notification delivery
  void markNotificationAsDelivered(int notificationId) {
    notificationDeliveryStatus[notificationId] = true;
  }
}
