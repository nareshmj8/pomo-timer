import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CloudKitService extends ChangeNotifier {
  static const MethodChannel _channel =
      MethodChannel('com.naresh.pomoTimer/cloudkit');
  bool _isAvailable = false;
  bool _isInitialized = false;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;

  // Initialize CloudKit service
  Future<void> initialize() async {
    try {
      _isAvailable = await isICloudAvailable();
      _isInitialized = true;

      if (_isAvailable) {
        // Subscribe to CloudKit changes
        await subscribeToChanges();

        // Process any pending operations
        await processPendingOperations();
      }

      notifyListeners();
    } catch (e) {
      print('Error initializing CloudKit: $e');
      _isAvailable = false;
      _isInitialized = false;
    }
  }

  // Save data to CloudKit
  Future<bool> saveData(Map<String, dynamic> data) async {
    if (!_isAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('saveData', data);
      return result ?? false;
    } catch (e) {
      print('Error saving to CloudKit: $e');
      return false;
    }
  }

  // Fetch data from CloudKit
  Future<Map<String, dynamic>?> fetchData() async {
    if (!_isAvailable) return null;

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('fetchData');
      if (result != null) {
        return result.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    } catch (e) {
      print('Error fetching from CloudKit: $e');
      return null;
    }
  }

  // Check if iCloud is available
  Future<bool> isICloudAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isICloudAvailable');
      return result ?? false;
    } catch (e) {
      print('Error checking iCloud availability: $e');
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
      print('Error subscribing to changes: $e');
      return false;
    }
  }

  // Process pending operations
  Future<bool> processPendingOperations() async {
    if (!_isAvailable) return false;

    try {
      final result =
          await _channel.invokeMethod<bool>('processPendingOperations');
      return result ?? false;
    } catch (e) {
      print('Error processing pending operations: $e');
      return false;
    }
  }

  // Update iCloud availability status
  void updateAvailability(bool available) {
    if (_isAvailable != available) {
      _isAvailable = available;
      notifyListeners();
    }
  }
}
