import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:pomodoro_timemaster/services/interfaces/analytics_service_interface.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import 'package:pomodoro_timemaster/services/interfaces/database_service_interface.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';
import 'package:pomodoro_timemaster/services/analytics_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/database_service.dart';
import 'package:pomodoro_timemaster/services/interfaces/connectivity_service_interface.dart';
import 'package:pomodoro_timemaster/services/connectivity_service.dart';

/// Service Locator for dependency injection
///
/// This class provides a centralized location for service registration and resolution.
/// It allows for easy mocking of services in tests.
class ServiceLocator {
  /// Singleton instance of the ServiceLocator
  static final ServiceLocator _instance = ServiceLocator._internal();

  /// Factory constructor that returns the singleton instance
  factory ServiceLocator() => _instance;

  /// Private constructor for singleton pattern
  ServiceLocator._internal();

  // Private service instances
  NotificationServiceInterface? _notificationService;
  AnalyticsServiceInterface? _analyticsService;
  RevenueCatServiceInterface? _revenueCatService;
  DatabaseServiceInterface? _databaseService;
  ConnectivityServiceInterface? _connectivityService;

  /// Reset all services (typically used in testing)
  void reset() {
    _notificationService = null;
    _analyticsService = null;
    _revenueCatService = null;
    _databaseService = null;
    _connectivityService = null;
  }

  /// Get the notification service instance
  NotificationServiceInterface get notificationService {
    return _notificationService ??= NotificationService();
  }

  /// Register a NotificationService instance
  ///
  /// Typically used for testing to inject a mock service
  void registerNotificationService(NotificationServiceInterface service) {
    _notificationService = service;
  }

  /// Get the AnalyticsService instance
  ///
  /// If no instance has been registered, creates and returns the default instance
  AnalyticsServiceInterface get analyticsService {
    _analyticsService ??= AnalyticsService();
    return _analyticsService!;
  }

  /// Register an AnalyticsService instance
  ///
  /// Typically used for testing to inject a mock service
  void registerAnalyticsService(AnalyticsServiceInterface service) {
    _analyticsService = service;
  }

  /// Get the RevenueCatService instance
  ///
  /// If no instance has been registered, creates and returns the default instance
  RevenueCatServiceInterface get revenueCatService {
    _revenueCatService ??= RevenueCatService();
    return _revenueCatService!;
  }

  /// Register a RevenueCatService instance
  ///
  /// Typically used for testing to inject a mock service
  void registerRevenueCatService(RevenueCatServiceInterface service) {
    _revenueCatService = service;
  }

  /// Get the DatabaseService instance
  ///
  /// If no instance has been registered, creates and returns the default instance
  DatabaseServiceInterface get databaseService {
    return _databaseService ??= DatabaseService();
  }

  /// Register a DatabaseService instance
  ///
  /// Typically used for testing to inject a mock service
  void registerDatabaseService(DatabaseServiceInterface service) {
    _databaseService = service;
  }

  /// Get the ConnectivityService instance
  ///
  /// If no instance has been registered, creates and returns the default instance
  ConnectivityServiceInterface get connectivityService {
    _connectivityService ??= ConnectivityService();
    return _connectivityService!;
  }

  /// Register a ConnectivityService instance
  ///
  /// Typically used for testing to inject a mock service
  void registerConnectivityService(ConnectivityServiceInterface service) {
    _connectivityService = service;
  }
}
