import 'dart:async';

/// An interface for connectivity services
abstract class ConnectivityServiceInterface {
  /// Stream that emits connectivity status changes
  Stream<ConnectivityStatus> get connectivityStream;

  /// Current connectivity status
  ConnectivityStatus get status;

  /// Check if the device is currently online
  Future<bool> isOnline();

  /// Check if the device is connected to WiFi
  Future<bool> isWifi();

  /// Check if the device is connected to mobile data
  Future<bool> isMobile();

  /// Initialize the connectivity service
  Future<void> initialize();

  /// Dispose the connectivity service
  void dispose();

  /// Add a listener for connectivity changes
  void addListener(Function(ConnectivityStatus) listener);

  /// Remove a connectivity listener
  void removeListener(Function(ConnectivityStatus) listener);
}

/// Enum representing different connectivity statuses
enum ConnectivityStatus {
  /// Device is connected to WiFi
  wifi,

  /// Device is connected to mobile data
  mobile,

  /// Device is not connected to any network
  none,

  /// Connectivity status is unknown
  unknown
}
