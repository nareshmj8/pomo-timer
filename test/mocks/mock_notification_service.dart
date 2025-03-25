import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';

/// Mock implementation of NotificationService for testing
class MockNotificationService extends ChangeNotifier
    implements NotificationServiceInterface {
  bool _isInitialized = false;

  // Mock flags for testing
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool notificationScheduled = false;

  // Capture method calls for verification
  int initializeCallCount = 0;

  /// Tracks which sounds were played
  int timerCompletionSoundCount = 0;
  int breakCompletionSoundCount = 0;
  int longBreakCompletionSoundCount = 0;
  int testSoundCount = 0;
  int scheduleExpiryNotificationCallCount = 0;
  int cancelExpiryNotificationCallCount = 0;
  int? lastPlayedTestSound;

  /// Tracks scheduled notifications
  final List<Duration> scheduledTimerNotifications = [];
  final List<Duration> scheduledBreakNotifications = [];
  final List<Map<String, dynamic>> scheduledExpiryNotifications = [];
  int cancelAllNotificationsCount = 0;

  // Call counts for scheduling
  int timerNotificationScheduleCount = 0;
  int breakNotificationScheduleCount = 0;
  int verifyDeliveryCallCount = 0;
  int checkMissedNotificationsCallCount = 0;
  int getDeliveryStatsCallCount = 0;
  int displayStatsCallCount = 0;
  int trackScheduledCallCount = 0;

  // Tracking data for new methods
  final Map<int, bool> notificationDeliveryStatus = {};
  final Map<int, Map<String, dynamic>> scheduledNotificationsInfo = {};

  /// Initialization result to return
  bool initializationResult = true;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    initializeCallCount++;
    notifyListeners();
    return initializationResult;
  }

  @override
  Future<bool> isNotificationScheduled() async {
    return notificationScheduled;
  }

  @override
  Future<bool> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    if (!_isInitialized) {
      await initialize();
    }
    scheduleExpiryNotificationCallCount++;
    scheduledExpiryNotifications.add({
      'expiryDate': expiryDate,
      'subscriptionType': subscriptionType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    notificationScheduled = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> cancelExpiryNotification() async {
    if (!_isInitialized) {
      await initialize();
    }
    cancelExpiryNotificationCallCount++;
    scheduledExpiryNotifications.clear();
    notificationScheduled = false;
    notifyListeners();
  }

  Future<void> showSubscriptionSuccessNotification(String type) async {
    notifyListeners();
  }

  Future<void> showTimerCompletionNotification(
      String title, String body) async {
    notifyListeners();
  }

  Future<void> showBreakCompletionNotification(
      String title, String body) async {
    notifyListeners();
  }

  Future<void> showLongBreakCompletionNotification(
      String title, String body) async {
    notifyListeners();
  }

  // Check if notifications are enabled
  @override
  Future<bool> areNotificationsEnabled() async {
    return notificationsEnabled;
  }

  // Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled = enabled;
    notifyListeners();
  }

  // Check if sound is enabled
  @override
  Future<bool> isSoundEnabled() async {
    return soundEnabled;
  }

  // Set sound enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    soundEnabled = enabled;
    notifyListeners();
  }

  // Check if vibration is enabled
  @override
  Future<bool> isVibrationEnabled() async {
    return vibrationEnabled;
  }

  // Set vibration enabled/disabled
  Future<void> setVibrationEnabled(bool enabled) async {
    vibrationEnabled = enabled;
    notifyListeners();
  }

  // Play timer completion sound
  @override
  Future<void> playTimerCompletionSound() async {
    if (!_isInitialized) {
      await initialize();
    }
    timerCompletionSoundCount++;
    notifyListeners();
  }

  // Play break completion sound
  @override
  Future<void> playBreakCompletionSound() async {
    if (!_isInitialized) {
      await initialize();
    }
    breakCompletionSoundCount++;
    notifyListeners();
  }

  // Play long break completion sound
  @override
  Future<void> playLongBreakCompletionSound() async {
    if (!_isInitialized) {
      await initialize();
    }
    longBreakCompletionSoundCount++;
    notifyListeners();
  }

  // Play test sound
  @override
  Future<void> playTestSound(int soundType) async {
    if (!_isInitialized) {
      await initialize();
    }
    testSoundCount++;
    lastPlayedTestSound = soundType;
    notifyListeners();
  }

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Don't schedule if notifications are disabled
    if (!notificationsEnabled) {
      return false;
    }

    timerNotificationScheduleCount++;
    scheduledTimerNotifications.add(duration);
    notificationScheduled = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Don't schedule if notifications are disabled
    if (!notificationsEnabled) {
      return false;
    }

    breakNotificationScheduleCount++;
    scheduledBreakNotifications.add(duration);
    notificationScheduled = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }
    cancelAllNotificationsCount++;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
    scheduledExpiryNotifications.clear();
    notificationScheduled = false;
    notifyListeners();
  }

  @override
  Future<bool> verifyDelivery(int notificationId) async {
    verifyDeliveryCallCount++;
    return notificationDeliveryStatus[notificationId] ?? false;
  }

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {
    trackScheduledCallCount++;
    scheduledNotificationsInfo[notificationId] = {
      'scheduledTime': scheduledTime,
      'notificationType': notificationType,
      'delivered': false
    };
    notificationDeliveryStatus[notificationId] = false;
  }

  @override
  Future<List<int>> checkMissedNotifications() async {
    checkMissedNotificationsCallCount++;
    // Return IDs of scheduled but not delivered notifications
    return notificationDeliveryStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    getDeliveryStatsCallCount++;
    int total = notificationDeliveryStatus.length;
    int delivered = notificationDeliveryStatus.values.where((v) => v).length;

    return {
      'scheduled': total,
      'delivered': delivered,
      'success_rate': total > 0
          ? '${(delivered / total * 100).toStringAsFixed(1)}%'
          : 'N/A',
    };
  }

  @override
  void displayNotificationDeliveryStats(BuildContext context) {
    displayStatsCallCount++;
    // Mock implementation that just counts the call
  }

  // Helper method to simulate notification delivery for testing
  void markNotificationAsDelivered(int notificationId) {
    notificationDeliveryStatus[notificationId] = true;
    if (scheduledNotificationsInfo.containsKey(notificationId)) {
      scheduledNotificationsInfo[notificationId]?['delivered'] = true;
    }
    notifyListeners();
  }

  /// Resets all tracked events for testing purposes
  void reset() {
    _isInitialized = false;
    initializeCallCount = 0;
    timerCompletionSoundCount = 0;
    breakCompletionSoundCount = 0;
    longBreakCompletionSoundCount = 0;
    testSoundCount = 0;
    scheduleExpiryNotificationCallCount = 0;
    cancelExpiryNotificationCallCount = 0;
    lastPlayedTestSound = null;
    scheduledTimerNotifications.clear();
    scheduledBreakNotifications.clear();
    scheduledExpiryNotifications.clear();
    cancelAllNotificationsCount = 0;
    timerNotificationScheduleCount = 0;
    breakNotificationScheduleCount = 0;
    verifyDeliveryCallCount = 0;
    checkMissedNotificationsCallCount = 0;
    getDeliveryStatsCallCount = 0;
    displayStatsCallCount = 0;
    trackScheduledCallCount = 0;
    notificationDeliveryStatus.clear();
    scheduledNotificationsInfo.clear();
    notificationsEnabled = true;
    soundEnabled = true;
    vibrationEnabled = true;
    notificationScheduled = false;
    initializationResult = true;
    notifyListeners();
  }

  /// Sets the initialization result for testing failure scenarios
  void setInitializationResult(bool result) {
    initializationResult = result;
  }

  // Helper method to show an immediate notification for tests
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Mock implementation
  }

  // Helper to open notification settings for tests
  Future<void> openNotificationSettings() async {
    // Mock implementation
  }
}
