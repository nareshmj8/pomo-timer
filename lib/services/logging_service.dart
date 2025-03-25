import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for logging events in the app, particularly for IAP events.
class LoggingService {
  static const String _logKey = 'app_logs';
  static const int _maxLogEntries = 100;

  /// Logs an event with the given type, message, and optional data.
  ///
  /// @param type The type of event (e.g., 'purchase', 'error', 'restore')
  /// @param message A descriptive message about the event
  /// @param data Optional additional data related to the event
  static Future<void> logEvent(String type, String message,
      [Map<String, dynamic>? data]) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = {
        'timestamp': timestamp,
        'type': type,
        'message': message,
        'data': data,
      };

      // Print to console in debug mode
      if (kDebugMode) {
        print(
            '📝 LOG [$type]: $message ${data != null ? '- ${jsonEncode(data)}' : ''}');
      }

      // Store in SharedPreferences
      await _storeLog(logEntry);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event: $e');
      }
    }
  }

  /// Logs an error event with the given source, message, and optional exception.
  ///
  /// @param source The source of the error (e.g., class or service name)
  /// @param message A descriptive message about the error
  /// @param error Optional exception or error object
  static Future<void> logError(String source, String message,
      [dynamic error]) async {
    try {
      final data = <String, dynamic>{
        'source': source,
        if (error != null) 'error': error.toString(),
        if (error is Error) 'stackTrace': StackTrace.current.toString(),
      };

      // Print to console in debug mode
      if (kDebugMode) {
        print('❌ ERROR [$source]: $message ${error != null ? '- $error' : ''}');
        if (error is Error) {
          print(StackTrace.current);
        }
      }

      // Store in SharedPreferences
      await logEvent('error', message, data);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging error event: $e');
      }
    }
  }

  /// Logs a warning event with the given source and message.
  ///
  /// @param source The source of the warning (e.g., class or service name)
  /// @param message A descriptive message about the warning
  static Future<void> logWarning(String source, String message) async {
    try {
      final data = <String, dynamic>{
        'source': source,
      };

      // Print to console in debug mode
      if (kDebugMode) {
        print('⚠️ WARNING [$source]: $message');
      }

      // Store in SharedPreferences
      await logEvent('warning', message, data);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging warning event: $e');
      }
    }
  }

  /// Logs a purchase event with product details.
  static Future<void> logPurchase(
      String productId, String price, bool isSuccess,
      [String? errorMessage]) async {
    final data = {
      'productId': productId,
      'price': price,
      'isSuccess': isSuccess,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };

    await logEvent(
      isSuccess ? 'purchase_success' : 'purchase_failed',
      isSuccess
          ? 'Purchase completed: $productId'
          : 'Purchase failed: $productId',
      data,
    );
  }

  /// Logs a purchase restoration event.
  static Future<void> logRestore(bool isSuccess,
      [String? errorMessage, List<String>? restoredProducts]) async {
    final data = {
      'isSuccess': isSuccess,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (restoredProducts != null) 'restoredProducts': restoredProducts,
    };

    await logEvent(
      isSuccess ? 'restore_success' : 'restore_failed',
      isSuccess
          ? 'Purchases restored successfully'
          : 'Failed to restore purchases',
      data,
    );
  }

  /// Logs a subscription expiration event.
  static Future<void> logSubscriptionExpired(
      String subscriptionType, DateTime expiryDate) async {
    final data = {
      'subscriptionType': subscriptionType,
      'expiryDate': expiryDate.toIso8601String(),
    };

    await logEvent(
      'subscription_expired',
      'Subscription expired: $subscriptionType',
      data,
    );
  }

  /// Stores a log entry in SharedPreferences.
  static Future<void> _storeLog(Map<String, dynamic> logEntry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_logKey) ?? [];

      // Add new log entry
      logs.add(jsonEncode(logEntry));

      // Trim logs if they exceed the maximum number of entries
      if (logs.length > _maxLogEntries) {
        logs = logs.sublist(logs.length - _maxLogEntries);
      }

      // Save logs back to SharedPreferences
      await prefs.setStringList(_logKey, logs);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing log: $e');
      }
    }
  }

  /// Retrieves all logs from SharedPreferences.
  static Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList(_logKey) ?? [];

      return logs
          .map((log) => jsonDecode(log) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving logs: $e');
      }
      return [];
    }
  }

  /// Clears all logs from SharedPreferences.
  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing logs: $e');
      }
    }
  }
}
