import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/interfaces/connectivity_service_interface.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';

/// A service for handling connectivity throughout the app
class ConnectivityService implements ConnectivityServiceInterface {
  static const String _connectionStatusKey = 'connection_status';
  static const int _connectivityCheckIntervalMs = 30000; // 30 seconds

  final Connectivity _connectivity = Connectivity();
  final List<Function(ConnectivityStatus)> _listeners = [];

  ConnectivityStatus _connectionStatus = ConnectivityStatus.unknown;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _periodicCheckTimer;
  int _lastConnectivityCheckMs = 0;
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  // Navigator key for dialogs
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Default constructor
  ConnectivityService();

  @override
  ConnectivityStatus get status => _connectionStatus;

  @override
  Stream<ConnectivityStatus> get connectivityStream =>
      _connectivityController.stream;
  final _connectivityController =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Load last known status from preferences (for offline first support)
      final savedStatus = _prefs?.getInt(_connectionStatusKey);
      if (savedStatus != null) {
        _connectionStatus = ConnectivityStatus.values[savedStatus];
      }

      // Initial connectivity check
      await _updateConnectionStatus();

      // Set up regular connectivity checks
      _startPeriodicChecks();

      // Listen for connectivity changes from the platform
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((results) {
        // Get first result as the primary connectivity type
        final result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        _handleConnectivityChange(result);
      });

      _isInitialized = true;
      LoggingService.logEvent(
          'Connectivity Service', 'Initialized successfully');
    } catch (e) {
      LoggingService.logError(
          'Connectivity Service', 'Error during initialization', e);
      // Set to unknown state in case of initialization error
      _connectionStatus = ConnectivityStatus.unknown;
    }
  }

  // Start periodic connectivity checks
  void _startPeriodicChecks() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _performConnectivityCheck(),
    );
  }

  // Handle connectivity changes from platform
  void _handleConnectivityChange(ConnectivityResult result) {
    // Convert platform connectivity result to our enum
    ConnectivityStatus newStatus;

    switch (result) {
      case ConnectivityResult.wifi:
        newStatus = ConnectivityStatus.wifi;
        break;
      case ConnectivityResult.mobile:
        newStatus = ConnectivityStatus.mobile;
        break;
      case ConnectivityResult.none:
        newStatus = ConnectivityStatus.none;
        break;
      default:
        newStatus = ConnectivityStatus.unknown;
    }

    // Update status
    _updateStatus(newStatus);
  }

  // Update the connection status with proper event emission
  void _updateStatus(ConnectivityStatus newStatus) {
    // Only emit events when status actually changes
    if (newStatus != _connectionStatus) {
      final previous = _connectionStatus;
      _connectionStatus = newStatus;

      // Save to preferences for offline-first UX
      _prefs?.setInt(_connectionStatusKey, newStatus.index);

      // Emit to stream
      _connectivityController.add(newStatus);

      // Notify listeners
      for (final listener in _listeners) {
        listener(newStatus);
      }

      // Log connectivity changes
      LoggingService.logEvent('Connectivity Service',
          'Status changed from $previous to $newStatus');

      // Show user feedback for offline transitions
      if (previous != ConnectivityStatus.none &&
          newStatus == ConnectivityStatus.none) {
        _showOfflineSnackbar();
      } else if (previous == ConnectivityStatus.none &&
          newStatus != ConnectivityStatus.none) {
        _showOnlineSnackbar();
      }
    }
  }

  // Show snackbar when device goes offline
  void _showOfflineSnackbar() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('You are offline. Some features may be limited.'),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show snackbar when device comes back online
  void _showOnlineSnackbar() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 8),
            Text('You are back online.'),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Perform a full connectivity check
  Future<void> _performConnectivityCheck() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Avoid excessive checks
      if (now - _lastConnectivityCheckMs < _connectivityCheckIntervalMs) {
        return;
      }

      _lastConnectivityCheckMs = now;

      // Update the connection status based on platform connectivity
      await _updateConnectionStatus();
    } catch (e) {
      LoggingService.logError(
          'Connectivity Service', 'Error checking connectivity', e);
    }
  }

  // Update connection status based on platform connectivity
  Future<void> _updateConnectionStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;

      switch (result) {
        case ConnectivityResult.wifi:
          _updateStatus(ConnectivityStatus.wifi);
          break;
        case ConnectivityResult.mobile:
          _updateStatus(ConnectivityStatus.mobile);
          break;
        case ConnectivityResult.none:
          _updateStatus(ConnectivityStatus.none);
          break;
        default:
          _updateStatus(ConnectivityStatus.unknown);
      }
    } on PlatformException catch (e) {
      LoggingService.logError(
          'Connectivity Service', 'Platform error checking connectivity', e);
      _updateStatus(ConnectivityStatus.unknown);
    }
  }

  @override
  Future<bool> isOnline() async {
    // Perform a connectivity check if we haven't checked recently
    await _performConnectivityCheck();

    // We're online if status is wifi or mobile
    return _connectionStatus == ConnectivityStatus.wifi ||
        _connectionStatus == ConnectivityStatus.mobile;
  }

  @override
  Future<bool> isWifi() async {
    await _performConnectivityCheck();
    return _connectionStatus == ConnectivityStatus.wifi;
  }

  @override
  Future<bool> isMobile() async {
    await _performConnectivityCheck();
    return _connectionStatus == ConnectivityStatus.mobile;
  }

  @override
  void addListener(Function(ConnectivityStatus) listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  @override
  void removeListener(Function(ConnectivityStatus) listener) {
    _listeners.remove(listener);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _periodicCheckTimer?.cancel();
    _connectivityController.close();
    _listeners.clear();
  }
}
