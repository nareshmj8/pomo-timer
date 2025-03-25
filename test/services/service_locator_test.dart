import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:pomodoro_timemaster/services/interfaces/analytics_service_interface.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import '../mocks/test_notification_service.dart';
import '../mocks/mock_analytics_service.dart';
import '../mocks/mock_revenue_cat_service.dart';

// Stub implementations for testing
class StubNotificationService implements NotificationServiceInterface {
  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> cancelExpiryNotification() async {}

  @override
  Future<void> playBreakCompletionSound() async {}

  @override
  Future<void> playLongBreakCompletionSound() async {}

  @override
  Future<void> playTestSound(int soundType) async {}

  @override
  Future<void> playTimerCompletionSound() async {}

  @override
  Future<bool> scheduleBreakNotification(Duration duration) async => true;

  @override
  Future<bool> scheduleExpiryNotification(
          DateTime expiryDate, String subscriptionType) async =>
      true;

  @override
  Future<bool> scheduleTimerNotification(Duration duration) async => true;

  @override
  Future<List<int>> checkMissedNotifications() async => [];

  @override
  void displayNotificationDeliveryStats(BuildContext context) {}

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async =>
      {'scheduled': 0, 'delivered': 0};

  @override
  Future<void> trackScheduledNotification(int notificationId,
      DateTime scheduledTime, String notificationType) async {}

  @override
  Future<bool> verifyDelivery(int notificationId) async => true;
}

class StubAnalyticsService implements AnalyticsServiceInterface {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> logEvent(String name,
      [Map<String, dynamic>? parameters]) async {}

  @override
  Future<void> logPremiumFeatureTapped(String featureName) async {}

  @override
  Future<void> logPremiumScreenViewed() async {}

  @override
  Future<void> logPurchaseCompleted(
      {required String productId,
      required double price,
      required String currency,
      required String paymentMethod,
      required bool success}) async {}

  @override
  Future<void> logPurchasesRestored(bool success) async {}

  @override
  Future<void> logSubscriptionExpired(String subscriptionType) async {}

  @override
  Future<void> logSubscriptionUpdated(
      {required String productId,
      required String subscriptionType,
      required bool isRenewal}) async {}

  @override
  Future<void> setUserProperties(Map<String, dynamic> properties) async {}
}

class StubRevenueCatService implements RevenueCatServiceInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late ServiceLocator serviceLocator;

  setUp(() {
    serviceLocator = ServiceLocator();
    // Reset the service locator before each test
    serviceLocator.reset();
  });

  group('ServiceLocator', () {
    test('should be a singleton', () {
      final instance1 = ServiceLocator();
      final instance2 = ServiceLocator();

      expect(identical(instance1, instance2), true);
    });

    group('NotificationService', () {
      test('should return registered mock service', () {
        final mockService = TestNotificationService();
        serviceLocator.registerNotificationService(mockService);

        final service = serviceLocator.notificationService;

        expect(service, isNotNull);
        expect(identical(service, mockService), true);
      });
    });

    group('AnalyticsService', () {
      test('should return registered mock service', () {
        final mockService = MockAnalyticsService();
        serviceLocator.registerAnalyticsService(mockService);

        final service = serviceLocator.analyticsService;

        expect(service, isNotNull);
        expect(identical(service, mockService), true);
      });
    });

    group('RevenueCatService', () {
      test('should return registered mock service', () {
        final mockService = MockRevenueCatService();
        serviceLocator.registerRevenueCatService(mockService);

        final service = serviceLocator.revenueCatService;

        expect(service, isNotNull);
        expect(identical(service, mockService), true);
      });
    });

    test('reset should clear all registered services', () {
      // Register mock services
      final mockNotificationService = TestNotificationService();
      final mockAnalyticsService = MockAnalyticsService();
      final mockRevenueCatService = MockRevenueCatService();

      serviceLocator.registerNotificationService(mockNotificationService);
      serviceLocator.registerAnalyticsService(mockAnalyticsService);
      serviceLocator.registerRevenueCatService(mockRevenueCatService);

      // Verify they are registered
      expect(
          identical(
              serviceLocator.notificationService, mockNotificationService),
          true);
      expect(identical(serviceLocator.analyticsService, mockAnalyticsService),
          true);
      expect(identical(serviceLocator.revenueCatService, mockRevenueCatService),
          true);

      // Reset the service locator
      serviceLocator.reset();

      // Verify new instances are created
      expect(
          identical(
              serviceLocator.notificationService, mockNotificationService),
          false);
      expect(identical(serviceLocator.analyticsService, mockAnalyticsService),
          false);
      expect(identical(serviceLocator.revenueCatService, mockRevenueCatService),
          false);
    });
  });
}
