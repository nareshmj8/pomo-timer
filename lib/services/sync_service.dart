import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'cloudkit_service.dart';

// Define our own ConnectivityResult enum since we're not using the connectivity_plus package
enum ConnectivityResult { wifi, mobile, none }

enum SyncStatus { notSynced, syncing, synced, failed, waitingForConnection }

class SyncService extends ChangeNotifier {
  static const String _iCloudSyncEnabledKey = 'icloud_sync_enabled';
  static const String _lastSyncedTimeKey = 'last_synced_time';
  static const String _pendingSyncKey = 'pending_sync';

  final CloudKitService _cloudKitService;
  StreamSubscription? _connectivitySubscription;

  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.notSynced;
  String _lastSyncedTime = 'Not synced yet';
  bool _iCloudSyncEnabled = true;
  bool _isOnline = true; // Assume online by default

  // Getters
  bool get isSyncing => _isSyncing;
  SyncStatus get syncStatus => _syncStatus;
  String get lastSyncedTime => _lastSyncedTime;
  bool get iCloudSyncEnabled => _iCloudSyncEnabled;

  // Constructor
  SyncService({CloudKitService? cloudKitService})
      : _cloudKitService = cloudKitService ?? CloudKitService();

  // Initialize sync service
  Future<void> initialize() async {
    // Load saved preferences
    await _loadSyncPreferences();

    // Check if iCloud is available
    final isAvailable = await _cloudKitService.isICloudAvailable();

    if (isAvailable && _iCloudSyncEnabled) {
      // Subscribe to CloudKit changes
      await _cloudKitService.subscribeToChanges();

      // Check for pending syncs
      await _checkPendingSync();
    }

    notifyListeners();
  }

  // Simulate connectivity change
  void _handleConnectivityChange(ConnectivityResult result) {
    _isOnline = result != ConnectivityResult.none;

    if (_isOnline && _syncStatus == SyncStatus.waitingForConnection) {
      _checkPendingSync();
    }
  }

  // Check for pending syncs
  Future<void> _checkPendingSync() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPendingSync = prefs.getBool(_pendingSyncKey) ?? false;

    if (hasPendingSync) {
      await syncData();
    }
  }

  // Load saved preferences for iCloud sync
  Future<void> _loadSyncPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _iCloudSyncEnabled = prefs.getBool(_iCloudSyncEnabledKey) ?? true;
    _lastSyncedTime = prefs.getString(_lastSyncedTimeKey) ?? 'Not synced yet';

    notifyListeners();
  }

  // Get iCloud sync enabled status
  Future<bool> isSyncEnabled() async {
    return _iCloudSyncEnabled;
  }

  // Set iCloud sync enabled status
  Future<void> setSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_iCloudSyncEnabledKey, enabled);

    _iCloudSyncEnabled = enabled;
    notifyListeners();

    if (enabled) {
      // Try to sync immediately when enabled
      await syncData();
    }
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
    notifyListeners();

    return formattedTime;
  }

  // Check if device is online (simplified version)
  Future<bool> _checkConnectivity() async {
    // In a real implementation, you would use connectivity_plus
    // For now, we'll just return the stored value or assume online
    return _isOnline;
  }

  // Sync data with iCloud
  Future<bool> syncData() async {
    // Check if already syncing
    if (_isSyncing) return false;

    // Check if sync is enabled
    if (!_iCloudSyncEnabled) {
      return false;
    }

    // Update status
    _isSyncing = true;
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    // Check connectivity
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      // Mark as pending sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, true);

      _isSyncing = false;
      _syncStatus = SyncStatus.waitingForConnection;
      notifyListeners();

      return false;
    }

    try {
      // Get local data
      final localData = await _getLocalData();

      // Push local data to CloudKit
      final pushSuccess = await _cloudKitService.saveData(localData);

      if (!pushSuccess) {
        _isSyncing = false;
        _syncStatus = SyncStatus.failed;
        notifyListeners();
        return false;
      }

      // Pull data from CloudKit
      final cloudData = await _cloudKitService.fetchData();

      if (cloudData != null) {
        // Resolve conflicts and update local data
        await _updateLocalData(cloudData);
      }

      // Update last synced time
      await updateLastSyncedTime();

      // Clear pending sync flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingSyncKey, false);

      _isSyncing = false;
      _syncStatus = SyncStatus.synced;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error during sync: $e');

      _isSyncing = false;
      _syncStatus = SyncStatus.failed;
      notifyListeners();

      return false;
    }
  }

  // Get all local data to sync
  Future<Map<String, dynamic>> _getLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // Collect all relevant data
    Map<String, dynamic> data = {};

    // Add session data
    data['sessionDuration'] = prefs.getDouble('session_duration') ?? 25.0;
    data['shortBreakDuration'] = prefs.getDouble('short_break_duration') ?? 5.0;
    data['longBreakDuration'] = prefs.getDouble('long_break_duration') ?? 15.0;
    data['sessionsBeforeLongBreak'] =
        prefs.getInt('sessions_before_long_break') ?? 4;

    // Add theme and sound preferences
    data['selectedTheme'] = prefs.getString('selected_theme') ?? 'Light';
    data['soundEnabled'] = prefs.getBool('sound_enabled') ?? true;

    // Add session history if available
    final sessionHistory = prefs.getStringList('session_history');
    if (sessionHistory != null) {
      data['sessionHistory'] = sessionHistory;
    }

    // Add timestamp for conflict resolution
    data['lastModified'] = DateTime.now().millisecondsSinceEpoch;

    return data;
  }

  // Update local data from cloud
  Future<void> _updateLocalData(Map<String, dynamic> cloudData) async {
    final prefs = await SharedPreferences.getInstance();

    // Get local modification timestamp
    final localTimestamp = prefs.getInt('last_modified') ?? 0;
    final cloudTimestamp = cloudData['lastModified'] as int? ?? 0;

    // Only update if cloud data is newer
    if (cloudTimestamp > localTimestamp) {
      // Update session settings
      if (cloudData.containsKey('sessionDuration')) {
        await prefs.setDouble('session_duration', cloudData['sessionDuration']);
      }

      if (cloudData.containsKey('shortBreakDuration')) {
        await prefs.setDouble(
            'short_break_duration', cloudData['shortBreakDuration']);
      }

      if (cloudData.containsKey('longBreakDuration')) {
        await prefs.setDouble(
            'long_break_duration', cloudData['longBreakDuration']);
      }

      if (cloudData.containsKey('sessionsBeforeLongBreak')) {
        await prefs.setInt(
            'sessions_before_long_break', cloudData['sessionsBeforeLongBreak']);
      }

      // Update theme and sound preferences
      if (cloudData.containsKey('selectedTheme')) {
        await prefs.setString('selected_theme', cloudData['selectedTheme']);
      }

      if (cloudData.containsKey('soundEnabled')) {
        await prefs.setBool('sound_enabled', cloudData['soundEnabled']);
      }

      // Update session history
      if (cloudData.containsKey('sessionHistory')) {
        await prefs.setStringList(
            'session_history', cloudData['sessionHistory'].cast<String>());
      }

      // Update local modification timestamp
      await prefs.setInt('last_modified', cloudTimestamp);
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

  // Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
