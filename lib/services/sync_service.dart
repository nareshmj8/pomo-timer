import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'cloudkit_service.dart';
import 'revenue_cat_service.dart';
import 'sync/sync_data_handler.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';
import 'package:pomodoro_timemaster/services/payment_sheet_handler.dart';

// Enhanced enum for sync status with more detailed states
enum SyncStatus {
  notSynced,
  preparing,
  uploading,
  downloading,
  merging,
  finalizing,
  synced,
  failed,
  waitingForConnection,
}

// Sync progress class to hold detailed sync information
class SyncProgress {
  final SyncStatus status;
  final double progressPercentage;
  final String statusMessage;
  final String detailMessage;
  final String lastSynced;
  final bool isPremium;
  final bool isEnabled;
  final bool hasError;
  final String errorMessage;

  SyncProgress({
    required this.status,
    this.progressPercentage = 0.0,
    this.statusMessage = '',
    this.detailMessage = '',
    required this.lastSynced,
    required this.isPremium,
    required this.isEnabled,
    this.hasError = false,
    this.errorMessage = '',
  });

  // Helper method to get color based on status
  Color getStatusColor() {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.waitingForConnection:
        return Colors.orange;
      case SyncStatus.preparing:
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.merging:
      case SyncStatus.finalizing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get human-readable status text
  String getStatusText() {
    switch (status) {
      case SyncStatus.notSynced:
        return 'Not Synced';
      case SyncStatus.preparing:
        return 'Preparing...';
      case SyncStatus.uploading:
        return 'Uploading...';
      case SyncStatus.downloading:
        return 'Downloading...';
      case SyncStatus.merging:
        return 'Merging Data...';
      case SyncStatus.finalizing:
        return 'Finalizing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.waitingForConnection:
        return 'Waiting for Connection';
    }
  }
}

class SyncService extends ChangeNotifier {
  static const String _iCloudSyncEnabledKey = 'icloud_sync_enabled';
  static const String _lastSyncedTimeKey = 'last_synced_time';
  static const String _pendingSyncKey = 'pending_sync';
  static const String _premiumRequiredMessage =
      'Premium subscription required for iCloud sync';

  final CloudKitService _cloudKitService;
  final RevenueCatService _revenueCatService;
  final SyncDataHandler _dataHandler = SyncDataHandler();
  Timer? _connectivityCheckTimer;

  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.notSynced;
  String _lastSyncedTime = 'Not synced yet';
  bool _iCloudSyncEnabled = false; // Default to disabled
  bool _isOnline = true; // Assume online by default
  String _errorMessage = '';

  // New fields for detailed sync progress
  double _progressPercentage = 0.0;
  String _statusMessage = '';
  String _detailMessage = '';

  // Stream controller for sync progress updates
  final StreamController<SyncProgress> _progressStreamController =
      StreamController<SyncProgress>.broadcast();

  // Ensure safe transaction handling
  bool _paymentSheetActive = false;
  final GlobalKey<NavigatorState> _paymentContextKey =
      GlobalKey<NavigatorState>();

  // Getters
  bool get isSyncing => _isSyncing;
  SyncStatus get syncStatus => _syncStatus;
  String get lastSyncedTime => _lastSyncedTime;
  bool get iCloudSyncEnabled => _iCloudSyncEnabled;
  bool get isPremium => _revenueCatService.isPremium;
  String get errorMessage => _errorMessage;
  double get progressPercentage => _progressPercentage;
  String get statusMessage => _statusMessage;
  String get detailMessage => _detailMessage;
  Stream<SyncProgress> get progressStream => _progressStreamController.stream;

  // Constructor
  SyncService({
    CloudKitService? cloudKitService,
    RevenueCatService? revenueCatService,
  })  : _cloudKitService = cloudKitService ?? CloudKitService(),
        _revenueCatService = revenueCatService ?? RevenueCatService();

  // Helper to create and emit sync progress updates
  void _updateSyncProgress({
    SyncStatus? status,
    double? progressPercentage,
    String? statusMessage,
    String? detailMessage,
    bool? hasError,
    String? errorMessage,
  }) {
    // Update local fields if provided
    if (status != null) _syncStatus = status;
    if (progressPercentage != null) _progressPercentage = progressPercentage;
    if (statusMessage != null) _statusMessage = statusMessage;
    if (detailMessage != null) _detailMessage = detailMessage;
    if (errorMessage != null) _errorMessage = errorMessage;

    // Create progress object
    final progress = SyncProgress(
      status: _syncStatus,
      progressPercentage: _progressPercentage,
      statusMessage: _statusMessage,
      detailMessage: _detailMessage,
      lastSynced: _lastSyncedTime,
      isPremium: isPremium,
      isEnabled: _iCloudSyncEnabled,
      hasError: hasError ?? (_syncStatus == SyncStatus.failed),
      errorMessage: _errorMessage,
    );

    // Emit progress update
    _progressStreamController.add(progress);

    // Notify listeners for widget rebuilds
    notifyListeners();
  }

  // Initialize sync service
  Future<void> initialize() async {
    // Load saved preferences
    await _loadSyncPreferences();

    // Check if iCloud is available and user is premium
    final isAvailable = await _cloudKitService.isICloudAvailable();
    final isPremiumUser = _revenueCatService.isPremium;

    // Only enable sync if user is premium, iCloud is available, and sync is enabled in settings
    if (isAvailable && _iCloudSyncEnabled && isPremiumUser) {
      // Subscribe to CloudKit changes
      await _cloudKitService.subscribeToChanges();

      // Check for pending syncs
      await _checkPendingSync();
    } else if (_iCloudSyncEnabled && !isPremiumUser) {
      // If user has sync enabled but is not premium, disable it
      await setSyncEnabled(false);
      _errorMessage = _premiumRequiredMessage;
      _updateSyncProgress(
          hasError: true, errorMessage: _premiumRequiredMessage);
    }

    // Listen for CloudKit availability changes
    _cloudKitService.availabilityStream.listen((available) async {
      if (available && _iCloudSyncEnabled && _revenueCatService.isPremium) {
        // Try to sync when iCloud becomes available
        await _checkPendingSync();
      }
    });

    // Listen for data changed events from CloudKit
    _cloudKitService.dataChangedStream.listen((_) {
      if (_iCloudSyncEnabled && _revenueCatService.isPremium && !_isSyncing) {
        // Auto-sync when data changes are detected
        _updateSyncProgress(
            status: SyncStatus.preparing,
            statusMessage: 'Changes detected, syncing...',
            progressPercentage: 0.0);
        syncData();
      }
    });

    // Listen for error events from CloudKit
    _cloudKitService.errorStream.listen((errorInfo) {
      if (_iCloudSyncEnabled) {
        final errorCode = errorInfo['code'] as String? ?? 'UNKNOWN_ERROR';
        final errorMsg =
            errorInfo['message'] as String? ?? 'Unknown error occurred';

        _updateSyncProgress(
            status: SyncStatus.failed,
            statusMessage: 'Sync error',
            detailMessage: errorMsg,
            hasError: true,
            errorMessage: 'Error: $errorCode - $errorMsg');
      }
    });

    // Listen for premium status changes
    _revenueCatService.addListener(_onPremiumStatusChanged);

    // Monitor connectivity for transaction robustness
    Connectivity().onConnectivityChanged.listen((results) {
      // Take the first result as the primary connectivity type
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _handleConnectivityChange(result);
    });

    // Start connectivity check timer
    _startConnectivityTimer();
  }

  // Handle premium status changes
  void _onPremiumStatusChanged() {
    if (!_revenueCatService.isPremium && _iCloudSyncEnabled) {
      // If user lost premium status but has sync enabled, disable it
      setSyncEnabled(false);

      // Set a more detailed error message
      final errorMsg =
          'iCloud sync has been disabled because your premium subscription has expired. '
          'Your data is still available locally. '
          'To continue syncing across devices, please renew your subscription.';

      // Update sync status with error
      _updateSyncProgress(
          status: SyncStatus.failed,
          statusMessage: 'Premium expired',
          detailMessage: 'Sync disabled due to expired subscription',
          hasError: true,
          errorMessage: errorMsg);

      // Log this event
      LoggingService.logEvent(
          'Sync Service', 'Sync disabled due to expired premium subscription');

      // Show notification if appropriate
      _showPremiumExpiredNotification();
    }
  }

  // Show notification when premium expires and sync is disabled
  void _showPremiumExpiredNotification() {
    try {
      // Use the notification service directly
      final notificationService = NotificationService();
      notificationService.showImmediateNotification(
        title: 'iCloud Sync Disabled',
        body:
            'iCloud sync has been disabled because your premium subscription has expired.',
        payload: 'premium_expired',
      );
    } catch (e) {
      debugPrint('Error showing premium expired notification: $e');
    }
  }

  // Start a timer to periodically check connectivity
  void _startConnectivityTimer() {
    _connectivityCheckTimer?.cancel();
    _connectivityCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_iCloudSyncEnabled && _revenueCatService.isPremium) {
        await _checkConnectivity();
      }
    });
  }

  // Load saved preferences for iCloud sync
  Future<void> _loadSyncPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Default to false (disabled)
    _iCloudSyncEnabled = prefs.getBool(_iCloudSyncEnabledKey) ?? false;

    _lastSyncedTime = prefs.getString(_lastSyncedTimeKey) ?? 'Not synced yet';

    // Emit initial progress state
    _updateSyncProgress(
      status: _syncStatus,
      progressPercentage: 0.0,
      statusMessage: _iCloudSyncEnabled ? 'Ready to sync' : 'Sync disabled',
      detailMessage: _iCloudSyncEnabled ? 'Last synced: $_lastSyncedTime' : '',
    );
  }

  // Get iCloud sync enabled status
  Future<bool> getSyncEnabled() async {
    return _iCloudSyncEnabled;
  }

  // Set iCloud sync enabled status
  Future<void> setSyncEnabled(bool enabled) async {
    // Clear any previous error messages
    _errorMessage = '';

    // Check if user is premium before enabling
    if (enabled && !_revenueCatService.isPremium) {
      _errorMessage = _premiumRequiredMessage;
      _updateSyncProgress(
          statusMessage: 'Premium required',
          detailMessage: 'Premium subscription required for sync',
          hasError: true,
          errorMessage: _premiumRequiredMessage);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_iCloudSyncEnabledKey, enabled);

    _iCloudSyncEnabled = enabled;

    if (enabled) {
      // If enabling sync, check if we can sync now
      final isAvailable = await _cloudKitService.isICloudAvailable();
      if (isAvailable) {
        _updateSyncProgress(
            status: SyncStatus.preparing,
            statusMessage: 'Preparing for sync',
            progressPercentage: 0.1);

        await _cloudKitService.subscribeToChanges();
        await syncData();
      } else {
        _updateSyncProgress(
            status: SyncStatus.waitingForConnection,
            statusMessage: 'Waiting for iCloud',
            detailMessage: 'iCloud not available',
            progressPercentage: 0.0);
      }
    } else {
      // If disabling sync, update status
      _updateSyncProgress(
          status: SyncStatus.notSynced,
          statusMessage: 'Sync disabled',
          detailMessage: '',
          progressPercentage: 0.0);
    }
  }

  // Handle connectivity change with transaction safety
  void _handleConnectivityChange(ConnectivityResult result) {
    final bool wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    // Handle reconnection for sync
    if (_isOnline &&
        !wasOnline &&
        _syncStatus == SyncStatus.waitingForConnection) {
      _updateSyncProgress(
          status: SyncStatus.preparing,
          statusMessage: 'Connection restored',
          detailMessage: 'Syncing pending changes',
          progressPercentage: 0.1);
      _checkPendingSync();
    } else if (!_isOnline && _iCloudSyncEnabled) {
      _updateSyncProgress(
          status: SyncStatus.waitingForConnection,
          statusMessage: 'Waiting for connection',
          detailMessage: 'Network offline',
          progressPercentage: 0.0);
    }

    // If we were in the middle of a payment and got reconnected,
    // check if we need to process any pending transactions
    if (_isOnline && !wasOnline && _revenueCatService.isPremium) {
      _checkPendingPurchases();
    }
  }

  // Check for pending syncs
  Future<void> _checkPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPendingSync = prefs.getBool(_pendingSyncKey) ?? false;

    if (hasPendingSync) {
      _updateSyncProgress(
          status: SyncStatus.preparing,
          statusMessage: 'Processing pending sync',
          detailMessage: 'Syncing data that was queued while offline',
          progressPercentage: 0.1);
      await syncData();
    }
  }

  // Get iCloud sync enabled status
  Future<bool> isSyncEnabled() async {
    return _iCloudSyncEnabled;
  }

  // Get last synced time
  Future<String> getLastSyncedTime() async {
    return _lastSyncedTime;
  }

  // Update last synced time to now
  Future<String> updateLastSyncedTime() async {
    final now = DateTime.now();
    final formattedTime = DateFormat('MMM d, yyyy h:mm a').format(now);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncedTimeKey, formattedTime);

    _lastSyncedTime = formattedTime;
    _updateSyncProgress(detailMessage: 'Last synced: $formattedTime');

    return formattedTime;
  }

  // Check if device is online using CloudKit availability as a proxy
  Future<bool> _checkConnectivity() async {
    // Use CloudKit availability as a proxy for network connectivity
    // This is more efficient than using a separate connectivity package
    final isCloudAvailable = await _cloudKitService.isICloudAvailable();
    _isOnline = isCloudAvailable;

    if (_isOnline != isCloudAvailable) {
      if (isCloudAvailable) {
        _updateSyncProgress(
            statusMessage: 'iCloud available',
            detailMessage: 'Connected to iCloud');
      } else {
        _updateSyncProgress(
            status: SyncStatus.waitingForConnection,
            statusMessage: 'iCloud unavailable',
            detailMessage: 'Waiting for iCloud connection',
            progressPercentage: 0.0);
      }
    }

    return _isOnline;
  }

  // Sync data with iCloud
  Future<bool> syncData() async {
    // Check if already syncing
    if (_isSyncing) return false;

    // Check if sync is enabled
    if (!_iCloudSyncEnabled) {
      _updateSyncProgress(
          status: SyncStatus.notSynced,
          statusMessage: 'Sync disabled',
          progressPercentage: 0.0);
      return false;
    }

    // Update status to indicate sync is starting
    _isSyncing = true;
    _updateSyncProgress(
        status: SyncStatus.preparing,
        statusMessage: 'Preparing to sync',
        detailMessage: 'Checking connection',
        progressPercentage: 0.05);

    // Check connectivity
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      // Mark as pending sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, true);

      _isSyncing = false;
      _updateSyncProgress(
          status: SyncStatus.waitingForConnection,
          statusMessage: 'Waiting for connection',
          detailMessage: 'Sync will resume when connection is available',
          progressPercentage: 0.0);

      return false;
    }

    try {
      // Get local data using the data handler
      _updateSyncProgress(
          status: SyncStatus.preparing,
          statusMessage: 'Collecting local data',
          progressPercentage: 0.2);
      final localData = await _dataHandler.getLocalData();

      // Push local data to CloudKit
      _updateSyncProgress(
          status: SyncStatus.uploading,
          statusMessage: 'Uploading to iCloud',
          progressPercentage: 0.4);
      final pushSuccess =
          await _cloudKitService.saveData('session', '1', localData);

      if (!pushSuccess) {
        _isSyncing = false;
        _updateSyncProgress(
            status: SyncStatus.failed,
            statusMessage: 'Upload failed',
            detailMessage: 'Could not save data to iCloud',
            hasError: true,
            errorMessage: 'Failed to upload data to iCloud',
            progressPercentage: 0.0);
        return false;
      }

      // Pull data from CloudKit
      _updateSyncProgress(
          status: SyncStatus.downloading,
          statusMessage: 'Downloading from iCloud',
          progressPercentage: 0.6);
      final cloudData = await _cloudKitService.fetchData('session', '1');

      if (cloudData != null) {
        // Resolve conflicts and update local data using the data handler
        _updateSyncProgress(
            status: SyncStatus.merging,
            statusMessage: 'Merging data',
            detailMessage: 'Resolving conflicts between local and cloud data',
            progressPercentage: 0.8);
        await _dataHandler.updateLocalData(cloudData);
      }

      // Update last synced time
      _updateSyncProgress(
          status: SyncStatus.finalizing,
          statusMessage: 'Finalizing sync',
          progressPercentage: 0.9);
      await updateLastSyncedTime();

      // Clear pending sync flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, false);

      _isSyncing = false;
      _updateSyncProgress(
          status: SyncStatus.synced,
          statusMessage: 'Sync complete',
          detailMessage: 'Last synced: $_lastSyncedTime',
          progressPercentage: 1.0);

      // Reset progress after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (_syncStatus == SyncStatus.synced) {
          _progressPercentage = 0.0;
          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error during sync: $e');

      _isSyncing = false;
      _updateSyncProgress(
          status: SyncStatus.failed,
          statusMessage: 'Sync failed',
          detailMessage: 'Error: $e',
          hasError: true,
          errorMessage: 'Sync error: $e',
          progressPercentage: 0.0);

      return false;
    }
  }

  // Set online status (for testing)
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (isOnline) {
      _handleConnectivityChange(ConnectivityResult.wifi);
    } else {
      _handleConnectivityChange(ConnectivityResult.none);
    }
  }

  // Get current sync progress
  SyncProgress getCurrentProgress() {
    return SyncProgress(
      status: _syncStatus,
      progressPercentage: _progressPercentage,
      statusMessage: _statusMessage,
      detailMessage: _detailMessage,
      lastSynced: _lastSyncedTime,
      isPremium: isPremium,
      isEnabled: _iCloudSyncEnabled,
      hasError: _syncStatus == SyncStatus.failed,
      errorMessage: _errorMessage,
    );
  }

  // Get a payment context for safe payment sheet presentation
  BuildContext? getPaymentContext() {
    return _paymentContextKey.currentContext;
  }

  // Check for pending purchases when connectivity is restored
  Future<void> _checkPendingPurchases() async {
    if (_paymentSheetActive) {
      // Don't interfere if we're already showing a payment sheet
      return;
    }

    try {
      // Process any pending transactions
      await _revenueCatService.checkPendingPurchases();
    } catch (e) {
      debugPrint('Error checking pending purchases: $e');
      LoggingService.logError(
          'Sync Service', 'Error checking pending purchases', e);
    }
  }

  // Helper for presenting payment sheets safely
  Future<PaymentSheetStatus> presentPaymentSheet(
      BuildContext context, dynamic package) async {
    _paymentSheetActive = true;

    try {
      final result = await PaymentSheetHandler.presentPaymentSheet(
        context: context,
        package: package,
      );

      return result;
    } catch (e) {
      LoggingService.logError(
          'Sync Service', 'Error presenting payment sheet', e);
      return PaymentSheetStatus.error;
    } finally {
      _paymentSheetActive = false;
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _connectivityCheckTimer?.cancel();
    _revenueCatService.removeListener(_onPremiumStatusChanged);
    _progressStreamController.close();
    super.dispose();
  }
}
