import 'package:flutter/foundation.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'mock_cloudkit_service.dart';
import 'mock_revenue_cat_service.dart';

/// Mock implementation of SyncService for testing
class MockSyncService extends ChangeNotifier implements SyncService {
  final MockCloudKitService cloudKitService;
  bool _isInitialized = false;
  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.notSynced;
  String _lastSyncedTime = 'Not synced yet';
  bool _iCloudSyncEnabled = false;
  String _errorMessage = '';
  bool _isPremium = false;
  MockRevenueCatService? _revenueCatService;

  MockSyncService(this.cloudKitService,
      {MockRevenueCatService? revenueCatService}) {
    _revenueCatService = revenueCatService;
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isSyncing => _isSyncing;

  @override
  SyncStatus get syncStatus => _syncStatus;

  @override
  String get lastSyncedTime => _lastSyncedTime;

  @override
  bool get iCloudSyncEnabled => _iCloudSyncEnabled;

  @override
  bool get isPremium => _revenueCatService?.isPremium ?? _isPremium;

  @override
  String get errorMessage => _errorMessage;

  /// Mock setting premium status
  void setPremium(bool value) {
    _isPremium = value;

    // If premium is false, automatically disable iCloud sync
    if (!value && _iCloudSyncEnabled) {
      _iCloudSyncEnabled = false;
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'Premium subscription required for iCloud sync';
    }

    notifyListeners();
  }

  /// Initialize sync service
  @override
  Future<void> initialize() async {
    _isInitialized = true;

    // Check if we should disable iCloud sync due to premium status
    if (_iCloudSyncEnabled && !isPremium) {
      _iCloudSyncEnabled = false;
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'Premium subscription required for iCloud sync';
    }

    // Check if iCloud is available
    if (_iCloudSyncEnabled && !cloudKitService.isAvailable) {
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'iCloud is not available';
    }

    notifyListeners();
  }

  /// Get iCloud sync enabled status
  @override
  Future<bool> getSyncEnabled() async {
    return _iCloudSyncEnabled;
  }

  /// Set iCloud sync enabled status
  @override
  Future<void> setSyncEnabled(bool enabled) async {
    // Only allow enabling if premium
    if (enabled && !isPremium) {
      _errorMessage = 'Premium subscription required for iCloud sync';
      _syncStatus = SyncStatus.failed;
      notifyListeners();
      return;
    }

    _iCloudSyncEnabled = enabled;
    if (enabled) {
      _syncStatus = SyncStatus.notSynced;
      _errorMessage = '';
    }
    notifyListeners();
  }

  /// Get iCloud sync enabled status
  @override
  Future<bool> isSyncEnabled() async {
    return _iCloudSyncEnabled;
  }

  /// Get last synced time
  @override
  Future<String> getLastSyncedTime() async {
    return _lastSyncedTime;
  }

  /// Update last synced time to now
  @override
  Future<String> updateLastSyncedTime() async {
    _lastSyncedTime = 'Today, 12:00 PM';
    notifyListeners();
    return _lastSyncedTime;
  }

  /// Sync data with iCloud
  @override
  Future<bool> syncData() async {
    _isSyncing = true;
    _syncStatus = SyncStatus.syncing;
    _errorMessage = '';
    notifyListeners();

    // Simulate sync delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if iCloud is available first
    if (!cloudKitService.isAvailable) {
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'iCloud is not available';
      _isSyncing = false;
      notifyListeners();
      return false;
    }

    // Check if premium status is valid
    if (!isPremium) {
      _syncStatus = SyncStatus.failed;
      _errorMessage = 'Premium subscription required for iCloud sync';
      _iCloudSyncEnabled = false;
      _isSyncing = false;
      notifyListeners();
      return false;
    }

    // Check if sync is enabled
    if (!_iCloudSyncEnabled) {
      _syncStatus = SyncStatus.notSynced;
      _errorMessage = 'iCloud sync is not enabled';
      _isSyncing = false;
      notifyListeners();
      return false;
    }

    // Success case
    _syncStatus = SyncStatus.synced;
    _isSyncing = false;
    await updateLastSyncedTime();
    notifyListeners();
    return true;
  }

  /// Set online status for testing network conditions
  @override
  void setOnlineStatus(bool isOnline) {
    if (!isOnline) {
      _syncStatus = SyncStatus.waitingForConnection;
    }
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    debugPrint(
        'MockSyncService: Method not implemented: ${invocation.memberName}');
    return super.noSuchMethod(invocation);
  }
}
