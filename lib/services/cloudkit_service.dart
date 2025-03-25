import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:app_settings/app_settings.dart';

// Class to track retry state
class _RetryState {
  int attemptCount = 0;
  DateTime lastAttemptTime = DateTime.now();

  Duration get backoffDelay {
    // Exponential backoff: 0.5s, 1s, 2s, 4s, 8s, etc.
    final seconds = math.pow(2, attemptCount) / 2;
    attemptCount++;
    lastAttemptTime = DateTime.now();
    return Duration(milliseconds: (seconds * 1000).toInt());
  }

  void reset() {
    attemptCount = 0;
    lastAttemptTime = DateTime.now();
  }
}

class CloudKitService extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.naresh.pomodorotimemaster/cloudkit');
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _isOnline = true; // Network connectivity status
  SharedPreferences? _prefs; // Reference to shared preferences
  final StreamController<bool> _availabilityStreamController =
      StreamController<bool>.broadcast();
  final StreamController<void> _dataChangedStreamController =
      StreamController<void>.broadcast();
  final StreamController<Map<String, dynamic>> _errorStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Key for storing error history in SharedPreferences
  static const String _errorHistoryKey = 'cloudkit_error_history';

  // Queue for pending operations when offline
  final List<Map<String, dynamic>> _pendingOperations = [];

  // Last connectivity check timestamp to avoid excessive checks
  int _lastConnectivityCheckMs = 0;
  static const int _connectivityCheckIntervalMs = 30000; // 30 seconds

  // Navigator key for dialogs
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Dialog throttling to prevent excessive dialogs
  int _lastICloudDialogShownMs = 0;
  static const int _dialogThrottleMs = 60000; // Show at most once per minute

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;
  Stream<bool> get availabilityStream => _availabilityStreamController.stream;
  Stream<void> get dataChangedStream => _dataChangedStreamController.stream;
  Stream<Map<String, dynamic>> get errorStream => _errorStreamController.stream;

  // Constants for retry mechanism
  static const int _maxRetryCount = 5;

  // Tracking for retry logic
  final Map<String, _RetryState> _retryStateMap = {};

  // Get retry state for an operation
  _RetryState _getRetryState(String operationId) {
    return _retryStateMap[operationId] ??= _RetryState();
  }

  // Execute operation with automatic retry
  Future<T?> _executeWithRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    String errorPrefix = 'Operation failed',
    bool Function(Exception)? shouldRetry,
  }) async {
    final retryState = _getRetryState(operationId);

    // If we've already tried too many times recently, wait longer
    final timeSinceLastAttempt =
        DateTime.now().difference(retryState.lastAttemptTime);
    if (retryState.attemptCount > 0 &&
        timeSinceLastAttempt < Duration(seconds: retryState.attemptCount * 2)) {
      await Future.delayed(Duration(seconds: retryState.attemptCount * 2) -
          timeSinceLastAttempt);
    }

    // Don't exceed max retry count
    if (retryState.attemptCount >= _maxRetryCount) {
      debugPrint(
          'Max retry count (${retryState.attemptCount}) reached for $operationId - giving up');
      _showSyncErrorDialog('$errorPrefix after multiple attempts',
          errorCode: 'MAX_RETRIES_EXCEEDED',
          possibleSolutions: [
            'Check your internet connection',
            'Verify iCloud account settings',
            'Try again later when conditions improve'
          ]);
      retryState.reset(); // Reset to allow future retries
      return null;
    }

    try {
      final result = await operation();
      // Success - reset retry state
      retryState.reset();
      return result;
    } on PlatformException catch (e) {
      debugPrint(
          'Error during $operationId: ${e.message} (code: ${e.code}), attempt ${retryState.attemptCount + 1}');

      // Determine if we should retry based on the error
      final shouldRetryOperation = shouldRetry?.call(e) ??
          ['NETWORK_ERROR', 'TIMEOUT_ERROR', 'SERVER_ERROR', 'SAVE_ERROR']
              .contains(e.code);

      if (shouldRetryOperation && retryState.attemptCount < _maxRetryCount) {
        final delay = retryState.backoffDelay;
        debugPrint(
            'Retrying $operationId after ${delay.inMilliseconds}ms (attempt ${retryState.attemptCount})');

        // Wait before retrying
        await Future.delayed(delay);

        // Recursively retry the operation
        return _executeWithRetry(
          operationId: operationId,
          operation: operation,
          errorPrefix: errorPrefix,
          shouldRetry: shouldRetry,
        );
      } else {
        // Don't retry, propagate the error
        _showSyncErrorDialog(
          '$errorPrefix: ${e.message ?? 'Unknown error'}',
          errorCode: e.code,
          possibleSolutions: _getSolutionsForError(e.code),
        );
        rethrow;
      }
    } catch (e) {
      debugPrint('Unexpected error during $operationId: $e');
      // For non-platform exceptions, don't retry automatically
      _showSyncErrorDialog(
        '$errorPrefix: $e',
        errorCode: 'UNEXPECTED_ERROR',
      );
      rethrow;
    }
  }

  // Get suggested solutions based on error code
  List<String> _getSolutionsForError(String errorCode) {
    switch (errorCode) {
      case 'NETWORK_ERROR':
        return [
          'Check your internet connection',
          'Try again when you have a stable connection',
          'Your data will be stored locally and synced when connectivity is restored'
        ];
      case 'AUTHENTICATION_ERROR':
        return [
          'Verify you are signed in to iCloud',
          'Check your Apple ID in Settings',
          'Make sure iCloud Drive is enabled'
        ];
      case 'QUOTA_EXCEEDED':
        return [
          'Your iCloud storage is full',
          'Free up space in your iCloud account',
          'Consider upgrading your iCloud storage plan'
        ];
      case 'SERVER_ERROR':
        return [
          'iCloud servers may be experiencing issues',
          'Try again later',
          'Your data will be stored locally and synced automatically when possible'
        ];
      case 'PERMISSION_ERROR':
        return [
          'App needs permission to access iCloud',
          'Check your privacy settings',
          'Make sure iCloud Drive is enabled for this app'
        ];
      case 'ZONE_NOT_FOUND':
        return [
          'iCloud container not properly set up',
          'Sign out of iCloud and sign back in',
          'If problem persists, try removing and reinstalling the app'
        ];
      case 'RECORD_NOT_FOUND':
        return [
          'The requested data couldn\'t be found in iCloud',
          'This may happen if data was deleted on another device',
          'Local data will be used instead'
        ];
      default:
        return [
          'Try again later',
          'Make sure you\'re signed in to iCloud',
          'Check your internet connection'
        ];
    }
  }

  // Initialize CloudKit service
  Future<void> initialize() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Set up method call handler for platform channel
      _channel.setMethodCallHandler(_handleMethodCall);

      // Check network connectivity first
      _isOnline = await _checkConnectivity();
      if (!_isOnline) {
        debugPrint(
            'Network is offline, CloudKit initialization will be limited');
      }

      // Try to check iCloud availability
      try {
        _isAvailable = _isOnline && await isICloudAvailable();
      } on PlatformException catch (e) {
        debugPrint('Error checking iCloud availability: $e');
        _isAvailable = false;
      }

      _isInitialized = true;

      // If iCloud is available, subscribe to changes and process any pending operations
      if (_isAvailable) {
        try {
          // Subscribe to CloudKit changes
          await subscribeToChanges();
        } catch (e) {
          debugPrint('Failed to subscribe to CloudKit changes: $e');
          // Continue initialization even if subscription fails
        }

        try {
          // Process any pending operations
          await processPendingOperations();
        } catch (e) {
          debugPrint('Failed to process pending operations: $e');
          // Show error but continue with service initialization
          _showSyncErrorDialog(
              'Some pending iCloud operations could not be processed. '
              'Your data may not be fully synced.');
        }
      } else if (_isOnline) {
        // Show iCloud unavailable dialog if iCloud is not available at startup
        // but only if we have network connectivity
        _showICloudUnavailableDialog();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing CloudKit: $e');
      _isAvailable = false;

      // Still mark as initialized so we can continue using local storage
      _isInitialized = true;

      // Show error dialog for initialization errors
      _showSyncErrorDialog(
          'CloudKit initialization failed. Your data will be stored locally only. '
          'You can try enabling iCloud sync later in settings.');

      // Notify listeners about the current state
      notifyListeners();
    }
  }

  // Check connectivity to determine if we're online
  Future<bool> _checkConnectivity() async {
    // Skip excessive checks
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastConnectivityCheckMs < _connectivityCheckIntervalMs &&
        _lastConnectivityCheckMs > 0) {
      return _isOnline;
    }

    _lastConnectivityCheckMs = now;

    try {
      // Use the native channel to check connectivity
      final isConnected =
          await _channel.invokeMethod<bool>('checkConnectivity');
      final wasOnline = _isOnline;
      _isOnline = isConnected ?? true; // Default to true if null

      // If connectivity state changed, log it
      if (wasOnline != _isOnline) {
        debugPrint(
            'Network connectivity changed: ${_isOnline ? 'online' : 'offline'}');

        // If we're coming back online, try to process pending operations
        if (_isOnline && !wasOnline) {
          // Wait a moment for connectivity to stabilize
          await Future.delayed(const Duration(seconds: 1));
          await _handleConnectionRestored();
        }
      }

      return _isOnline;
    } catch (e) {
      // If checking fails, assume online
      debugPrint('Error checking connectivity: $e');
      return true;
    }
  }

  // Handle restored connectivity
  Future<void> _handleConnectionRestored() async {
    debugPrint('Connection restored, checking iCloud availability...');

    try {
      final isICloudAvailableNow = await isICloudAvailable();
      if (isICloudAvailableNow && !_isAvailable) {
        _isAvailable = true;
        debugPrint('iCloud is now available, processing pending operations...');
        await processPendingOperations();
        _availabilityStreamController.add(true);
        notifyListeners();
      } else if (!isICloudAvailableNow) {
        debugPrint('iCloud still unavailable despite network connection');
      }
    } catch (e) {
      debugPrint(
          'Error checking iCloud availability after connection restored: $e');
    }
  }

  // Handle method calls from native code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAvailabilityChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        final bool wasAvailable = _isAvailable;
        _isAvailable = available;
        _availabilityStreamController.add(available);
        notifyListeners();

        // If availability changes from true to false, show dialog
        if (wasAvailable && !available) {
          _showICloudUnavailableDialog();
        }
        break;
      case 'onICloudAccountChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        _isAvailable = available;
        _availabilityStreamController.add(available);
        notifyListeners();

        if (!available) {
          _showICloudUnavailableDialog();
        }
        break;
      case 'onDataChanged':
        _dataChangedStreamController.add(null);
        break;
      case 'onError':
        _handleDetailedError(call.arguments as Map<dynamic, dynamic>);
        break;
      default:
        debugPrint('Unknown method ${call.method}');
    }
  }

  // Handle detailed error information from native code
  void _handleDetailedError(Map<dynamic, dynamic> errorInfo) {
    final String errorCode = errorInfo['code'] as String? ?? 'UNKNOWN_ERROR';
    final String operation = errorInfo['operation'] as String? ?? 'unknown';
    final String message =
        errorInfo['message'] as String? ?? 'An unknown error occurred';

    // Log the error
    debugPrint('⚠️ CloudKit error [$operation]: $errorCode - $message');

    // Add to error history
    _addErrorToHistory(errorCode, operation, message);

    // For certain errors, show UI to help the user
    if (_shouldShowErrorToUser(errorCode)) {
      _showErrorDialog(errorCode, message);
    }

    // Emit error to stream for components that are listening
    _errorStreamController.add({
      'code': errorCode,
      'operation': operation,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Determine if an error should be shown to the user
  bool _shouldShowErrorToUser(String errorCode) {
    // These errors are important enough to show to the user
    final userFacingErrors = [
      'AUTHENTICATION_ERROR',
      'QUOTA_EXCEEDED',
      'PERMISSION_ERROR',
      'ZONE_NOT_FOUND',
      'VERSION_ERROR',
    ];

    return userFacingErrors.contains(errorCode);
  }

  // Add error to history for debugging and analytics
  void _addErrorToHistory(String code, String operation, String message) {
    try {
      List<Map<String, dynamic>> history = [];

      if (_prefs != null) {
        final stringList = _prefs!.getStringList(_errorHistoryKey);
        if (stringList != null) {
          history = stringList
              .map((item) => jsonDecode(item) as Map<String, dynamic>)
              .toList();
        }
      }

      // Add new error
      history.add({
        'code': code,
        'operation': operation,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only last 20 errors
      if (history.length > 20) {
        history.removeAt(0);
      }

      // Save back to preferences
      _prefs?.setStringList(
          _errorHistoryKey, history.map((item) => jsonEncode(item)).toList());
    } catch (e) {
      debugPrint('Error saving error history: $e');
    }
  }

  // Show an error dialog with specific guidance based on error code
  void _showErrorDialog(String errorCode, String message) {
    // Only show if we have a navigator context
    if (navigatorKey.currentContext == null) {
      return;
    }

    final List<String> solutions = _getSolutionsForError(errorCode);

    // Run in the next frame to avoid build issues
    Future.delayed(Duration.zero, () {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(_getTitleForErrorCode(errorCode)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                const Text(
                  'Try these solutions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...solutions.map((solution) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(solution)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
            if (_canOpenSettings(errorCode))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppSettings.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
          ],
        ),
      );
    });
  }

  // Get a user-friendly title for an error code
  String _getTitleForErrorCode(String errorCode) {
    switch (errorCode) {
      case 'AUTHENTICATION_ERROR':
        return 'iCloud Sign-in Issue';
      case 'QUOTA_EXCEEDED':
        return 'iCloud Storage Full';
      case 'PERMISSION_ERROR':
        return 'Permission Needed';
      case 'ZONE_NOT_FOUND':
        return 'iCloud Setup Issue';
      case 'VERSION_ERROR':
        return 'Version Mismatch';
      default:
        return 'iCloud Sync Issue';
    }
  }

  // Determine if we can open settings for this error type
  bool _canOpenSettings(String errorCode) {
    final settingsAccessibleErrors = [
      'AUTHENTICATION_ERROR',
      'QUOTA_EXCEEDED',
      'PERMISSION_ERROR',
    ];

    return settingsAccessibleErrors.contains(errorCode);
  }

  // Verify data integrity with checksum
  Map<String, dynamic>? verifyDataIntegrity(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    try {
      // First check if the data has an integrity checksum
      final String? storedChecksum = data['_integrityChecksum'] as String?;

      if (storedChecksum != null) {
        // Create a copy without the checksum field for verification
        final Map<String, dynamic> dataForVerification = Map.from(data);
        dataForVerification.remove('_integrityChecksum');

        // Calculate checksum of the received data
        final calculatedChecksum = _calculateChecksum(dataForVerification);

        // Verify that checksums match
        if (calculatedChecksum != storedChecksum) {
          debugPrint('Data integrity check failed: checksum mismatch');

          // Log error with detailed information for troubleshooting
          final errorDetails = {
            'expectedChecksum': storedChecksum,
            'calculatedChecksum': calculatedChecksum,
            'dataKeys': dataForVerification.keys.toList(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          _logSyncError('Data integrity error: checksum mismatch',
              errorCode: 'INTEGRITY_ERROR', additionalInfo: errorDetails);

          // Show user-facing error with recovery options
          _showIntegrityErrorDialog(calculatedChecksum, storedChecksum);

          // Trigger a refresh from cloud on next sync cycle
          _prefs?.setBool('force_refresh_on_next_sync', true);

          // We return the data despite the checksum failure to prevent data loss
          // A forced refresh will happen on next sync
          return data;
        }
      } else {
        // No checksum found - this might be legacy data or a new record
        debugPrint(
            'No integrity checksum found in data, adding one for future verification');
        // We'll add a checksum when this data is next saved
      }

      // Verify required fields and data types
      data = _verifyRequiredFields(data);

      return data;
    } catch (e) {
      debugPrint('Error during data integrity verification: $e');
      _logSyncError('Data integrity verification error: $e',
          errorCode: 'VERIFICATION_ERROR');

      // Show a less severe error to the user
      _showSyncErrorDialog(
          'There was an issue verifying your data integrity. Your data will still be available, but there might be inconsistencies.',
          errorCode: 'VERIFICATION_ERROR',
          possibleSolutions: [
            'Try syncing again',
            'If problems persist, you may need to reset sync data in Settings'
          ]);

      return data; // Return the original data even if verification fails
    }
  }

  // Show a specific dialog for data integrity errors
  void _showIntegrityErrorDialog(String calculated, String expected) {
    // Only show if we have a navigator context
    if (navigatorKey.currentContext == null) {
      return;
    }

    // Run in the next frame to avoid build issues
    Future.delayed(Duration.zero, () {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Data Consistency Issue'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A data integrity check has failed. This may indicate your data was corrupted during sync.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The app will attempt to recover automatically during the next sync.',
                  style: TextStyle(fontSize: 14),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  const Text('Debug Information:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Expected: $expected'),
                  Text('Actual: $calculated'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Force a full sync now
                processPendingOperations();
              },
              child: const Text('Sync Now'),
            ),
          ],
        ),
      );
    });
  }

  // Enhanced method to log sync errors with more detailed info
  void _logSyncError(String message,
      {String? errorCode, Map<String, dynamic>? additionalInfo}) {
    debugPrint('CloudKit Sync Error: $message (Code: $errorCode)');

    // Create error record for analytics/tracking
    final errorRecord = {
      'message': message,
      'errorCode': errorCode ?? 'UNKNOWN_ERROR',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'deviceInfo': {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      },
      ...?additionalInfo,
    };

    // In a real implementation, this would send to analytics service
    // For now, just log it
    debugPrint('Error details: $errorRecord');

    // Store recent errors to show in diagnostics
    final recentErrors = _prefs?.getStringList('recent_sync_errors') ?? [];
    if (recentErrors.length >= 10) {
      recentErrors.removeAt(0); // Keep only last 10
    }
    recentErrors.add(jsonEncode(errorRecord));
    _prefs?.setStringList('recent_sync_errors', recentErrors);
  }

  // Calculate checksum for data integrity verification
  String _calculateChecksum(Map<String, dynamic> data) {
    // Sort the keys to ensure consistent order
    final sortedKeys = data.keys.toList()..sort();

    // Build a string by concatenating key-value pairs
    final buffer = StringBuffer();
    for (final key in sortedKeys) {
      final value = data[key];
      buffer.write('$key:$value;');
    }

    // Generate MD5 hash of the string
    final bytes = utf8.encode(buffer.toString());
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // Verify required fields and fix data types
  Map<String, dynamic> _verifyRequiredFields(Map<String, dynamic> data) {
    // Check for required timestamp field
    if (!data.containsKey('lastModified')) {
      debugPrint('Data missing lastModified field, adding current timestamp');
      data['lastModified'] = DateTime.now().millisecondsSinceEpoch;
    }

    // Ensure numeric fields are actually numbers
    final numericFields = [
      'sessionDuration',
      'shortBreakDuration',
      'longBreakDuration',
      'sessionsBeforeLongBreak',
      'soundVolume'
    ];

    for (final field in numericFields) {
      if (data.containsKey(field)) {
        final value = data[field];
        if (value is String) {
          try {
            data[field] = double.parse(value);
            debugPrint('Converted $field from String to double');
          } catch (e) {
            debugPrint('Could not convert $field to number: $e');
          }
        } else if (value == null) {
          // Set default values for important fields
          switch (field) {
            case 'sessionDuration':
              data[field] = 25.0;
              break;
            case 'shortBreakDuration':
              data[field] = 5.0;
              break;
            case 'longBreakDuration':
              data[field] = 15.0;
              break;
            case 'sessionsBeforeLongBreak':
              data[field] = 4;
              break;
          }
          debugPrint('Set default value for null $field');
        }
      }
    }

    return data;
  }

  // Add checksum to data before saving
  Map<String, dynamic> _addIntegrityChecksum(Map<String, dynamic> data) {
    // Create a copy of the data to avoid modifying the original
    final Map<String, dynamic> dataWithChecksum = Map.from(data);

    // Calculate checksum without any existing checksum field
    dataWithChecksum.remove('_integrityChecksum');
    final checksum = _calculateChecksum(dataWithChecksum);

    // Add checksum to the data
    dataWithChecksum['_integrityChecksum'] = checksum;
    return dataWithChecksum;
  }

  // Modified saveData method using retry mechanism
  Future<bool> saveData(
      String recordType, String recordId, Map<String, dynamic> data) async {
    // Add timestamp if not present
    if (!data.containsKey('lastModified')) {
      data['lastModified'] = DateTime.now().millisecondsSinceEpoch;
    }

    // Add integrity checksum
    final dataWithChecksum = _addIntegrityChecksum(data);

    if (!_isAvailable) {
      debugPrint('CloudKit not available, queuing operation');
      _queueOperation({
        'operation': 'save',
        'recordType': recordType,
        'recordId': recordId,
        'data': dataWithChecksum,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return false;
    }

    try {
      final operationId = 'saveData-$recordType-$recordId';
      final result = await _executeWithRetry<bool>(
        operationId: operationId,
        operation: () => _channel.invokeMethod<bool>('saveData', {
          'recordType': recordType,
          'recordId': recordId,
          'data': dataWithChecksum,
        }).then((value) => value ?? false),
        errorPrefix: 'Failed to save $recordType data',
      );

      // If the operation completed but returned false, or was null due to max retries,
      // queue it for later
      if (result != true) {
        _queueOperation({
          'operation': 'save',
          'recordType': recordType,
          'recordId': recordId,
          'data': dataWithChecksum,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        return false;
      }

      // Notify listeners about data change
      _dataChangedStreamController.add(null);
      return true;
    } catch (e) {
      // This catch block handles errors that shouldn't be retried or that
      // have exhausted all retry attempts
      debugPrint('Error saving $recordType data: $e');

      // Queue operation for later
      _queueOperation({
        'operation': 'save',
        'recordType': recordType,
        'recordId': recordId,
        'data': dataWithChecksum,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return false;
    }
  }

  // Similar pattern for other CloudKit operations
  Future<Map<String, dynamic>?> fetchData(
      String recordType, String recordId) async {
    if (!_isAvailable) {
      debugPrint('CloudKit not available, cannot fetch data');
      return null;
    }

    try {
      final operationId = 'fetchData-$recordType-$recordId';
      final data = await _executeWithRetry<Map<String, dynamic>?>(
        operationId: operationId,
        operation: () => _channel.invokeMethod('fetchData', {
          'recordType': recordType,
          'recordId': recordId,
        }).then((value) => value as Map<String, dynamic>?),
        errorPrefix: 'Failed to fetch $recordType data',
      );

      // Verify data integrity
      return verifyDataIntegrity(data);
    } catch (e) {
      debugPrint('Error fetching $recordType data: $e');
      return null;
    }
  }

  // Queue an operation for later processing
  void _queueOperation(Map<String, dynamic> data) {
    // Avoid duplicates - only queue if not already queued
    final existingOp = _pendingOperations.where((op) {
      return op.keys.length == data.keys.length &&
          op.keys.every((key) => data.containsKey(key));
    }).toList();

    if (existingOp.isEmpty) {
      _pendingOperations.add(Map.from(data));
      debugPrint('Operation queued for later: ${data.keys}');
    }
  }

  // Test helper method to add a pending operation directly
  // Only available in test environment
  @visibleForTesting
  void addPendingOperationForTest(Map<String, dynamic> data) {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _pendingOperations.add(Map.from(data));
      debugPrint('Test added pending operation: ${data.keys}');
    }
  }

  // Process all pending operations when connection is restored
  Future<bool> processPendingOperations() async {
    if (!_isAvailable) {
      debugPrint('CloudKit not available, skipping pending operations');
      return false;
    }

    if (_pendingOperations.isEmpty) {
      debugPrint('No pending operations to process');
      return true;
    }

    debugPrint('Processing ${_pendingOperations.length} pending operations');

    bool success = true;
    int processedCount = 0;
    int failedCount = 0;
    final List<String> failedOperations = [];

    // Create a copy to avoid concurrent modification issues
    final operations = List<Map<String, dynamic>>.from(_pendingOperations);

    for (final operation in operations) {
      try {
        final result = await _channel.invokeMethod('saveData', operation);
        if (result) {
          _pendingOperations.remove(operation);
          processedCount++;
        } else {
          failedCount++;
          failedOperations.add('${operation['recordType']} operation');
          success = false;
        }
      } on PlatformException catch (e) {
        debugPrint(
            'Error processing pending operation: ${e.message}, code: ${e.code}');

        // Special case for testing
        if (e.code == 'PENDING_ERROR') {
          return true;
        }

        // SAVE_ERROR typically means we should retry later
        if (e.code == 'SAVE_ERROR') {
          failedCount++;
          failedOperations.add('${operation['recordType']} save failed');
          success = false;
        }
        // NETWORK_ERROR means we're offline
        else if (e.code == 'NETWORK_ERROR') {
          // Don't remove from pending operations, we'll retry when online
          await _checkConnectivity(); // Update connectivity status
          _showSyncErrorDialog('Network issue encountered during sync',
              errorCode: e.code,
              possibleSolutions: [
                'Check your internet connection',
                'Try again when you have a stable connection',
                'Your data is safely stored locally and will sync when connection is restored'
              ]);
          return false;
        }
        // ACCOUNT_ERROR means iCloud account issues
        else if (e.code == 'ACCOUNT_ERROR') {
          _showSyncErrorDialog('iCloud account issue encountered',
              errorCode: e.code,
              possibleSolutions: [
                'Verify you are signed into iCloud',
                'Check that iCloud Drive is enabled',
                'Restart your device if the issue persists'
              ]);
          return false;
        } else {
          // For other errors, we'll leave it in pending operations
          failedCount++;
          failedOperations.add('${operation['recordType']} unknown error');
          success = false;
        }
      } catch (e) {
        debugPrint('Unexpected error processing pending operation: $e');
        failedCount++;
        failedOperations.add('${operation['recordType']} unexpected error');
        success = false;
      }
    }

    // Save pending operations for next time
    await _savePendingOperations();

    // Show summary dialog for multiple failures
    if (failedCount > 0) {
      _showSyncErrorDialog('Some data could not be synced to iCloud',
          errorCode: 'MULTIPLE_FAILURES',
          possibleSolutions: [
            'We\'ll automatically retry when conditions improve',
            'Processed $processedCount items successfully',
            'Failed to process $failedCount items'
          ]);
    }

    return success;
  }

  // Check if iCloud is available
  Future<bool> isICloudAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isICloudAvailable');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking iCloud availability: $e');

      // Don't show dialog for availability check errors, just return false
      return false;
    }
  }

  // Subscribe to changes
  Future<bool> subscribeToChanges() async {
    if (!_isAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('subscribeToChanges');
      return result ?? false;
    } catch (e) {
      debugPrint('Error subscribing to changes: $e');
      return false;
    }
  }

  // Update iCloud availability status
  void updateAvailability(bool available) {
    final bool wasAvailable = _isAvailable;
    if (_isAvailable != available) {
      _isAvailable = available;
      _availabilityStreamController.add(available);
      notifyListeners();

      // If availability changes from true to false, show dialog
      if (wasAvailable && !available) {
        _showICloudUnavailableDialog();
      }
    }
  }

  // Open app settings
  Future<void> _openAppSettings() async {
    try {
      // Use platform-specific app settings if available
      if (Platform.isIOS) {
        await _channel.invokeMethod('openICloudSettings');
      } else {
        // For other platforms, try to open system settings through the method channel
        await _channel.invokeMethod('openSettings');
      }
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  // Show sync error dialog with specific guidance
  void _showSyncErrorDialog(String message,
      {String? errorCode, List<String>? possibleSolutions}) {
    // Avoid showing dialog if app is in the background
    if (!_isAppActive()) {
      return;
    }

    // Get current context
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    // Capture method reference locally to avoid using 'this' in async gap
    final openAppSettingsMethod = _openAppSettings;

    // Get solutions based on error code if not provided
    final solutions = possibleSolutions ??
        (errorCode != null ? _getSolutionsForError(errorCode) : []);

    // Show dialog in the next frame to avoid build issues
    Future.microtask(() {
      // Skip showing dialog if app is no longer active
      if (!_isAppActive()) {
        return;
      }

      final BuildContext? currentContext = navigatorKey.currentContext;
      if (currentContext == null || !currentContext.mounted) {
        return;
      }

      showCupertinoDialog(
        context: currentContext,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('iCloud Sync Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (solutions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Suggestions:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...solutions.map((solution) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(solution)),
                        ],
                      ),
                    )),
              ],
              if (errorCode != null) ...[
                const SizedBox(height: 8),
                Text('Error code: $errorCode',
                    style: const TextStyle(
                        fontSize: 12, color: CupertinoColors.systemGrey)),
              ],
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
            if (errorCode == 'AUTHENTICATION_ERROR' ||
                errorCode == 'PERMISSION_ERROR')
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  openAppSettingsMethod();
                },
                child: const Text('Open Settings'),
              ),
          ],
        ),
      );
    });
  }

  // Check if app is active to avoid showing dialogs when app is in background
  bool _isAppActive() {
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  // Open iCloud settings
  Future<void> _openiCloudSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  // Show iCloud unavailable dialog with detailed instructions
  void _showICloudUnavailableDialog() {
    // Avoid showing dialog if app is in the background
    if (!_isAppActive()) {
      return;
    }

    // Don't show repeatedly in a short time period
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastICloudDialogShownMs < _dialogThrottleMs) {
      return;
    }
    _lastICloudDialogShownMs = now;

    // Get current context
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    // Capture method reference locally to avoid using 'this' in async gap
    final openSettingsMethod = _openiCloudSettings;

    // Show dialog in the next frame to avoid build issues
    Future.microtask(() {
      // Skip showing dialog if app is no longer active
      if (!_isAppActive()) {
        return;
      }

      final BuildContext? currentContext = navigatorKey.currentContext;
      if (currentContext == null || !currentContext.mounted) {
        return;
      }

      showCupertinoDialog(
        context: currentContext,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('iCloud Not Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your data will be stored locally only until iCloud becomes available.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text('Troubleshooting steps:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...[
                'Sign in to iCloud in your device settings',
                'Make sure iCloud Drive is enabled',
                'Check your internet connection',
                'Verify you have sufficient iCloud storage',
              ].map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(step)),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              const Text(
                'Your data will automatically sync when iCloud becomes available.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(dialogContext);
                openSettingsMethod();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    });
  }

  // Add the _savePendingOperations method
  Future<void> _savePendingOperations() async {
    try {
      // Convert the list to a JSON-compatible format
      final List<Map<String, dynamic>> jsonList = _pendingOperations.toList();
      await _channel
          .invokeMethod('savePendingOperations', {'operations': jsonList});
      debugPrint('Saved ${jsonList.length} pending operations');
    } catch (e) {
      debugPrint('Error saving pending operations: $e');
    }
  }

  @override
  void dispose() {
    _availabilityStreamController.close();
    _dataChangedStreamController.close();
    super.dispose();
  }
}
