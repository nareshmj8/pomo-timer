import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_logs_screen.dart';

/// Helper class for sandbox testing of in-app purchases
/// This class provides utilities for enabling sandbox testing mode,
/// configuring log levels, and recording test events for debugging
class SandboxTestingHelper {
  // Keys for shared preferences
  static const String _sandboxEnabledKey = 'sandbox_testing_enabled';
  static const String _sandboxLogLevelKey = 'sandbox_log_level';
  static const String _eventsKey = 'sandbox_testing_events';
  static const String _sandboxRevenueInfoFileName =
      'revenue_cat_sandbox_logs.txt';

  // Log levels
  static const String LOG_LEVEL_NORMAL = 'normal';
  static const String LOG_LEVEL_VERBOSE = 'verbose';
  static const String LOG_LEVEL_DEBUG = 'debug';

  // Get shared preferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Check if sandbox testing is enabled
  static Future<bool> isSandboxTestingEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_sandboxEnabledKey) ?? false;
  }

  /// Enable or disable sandbox testing mode
  static Future<void> setSandboxTestingEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_sandboxEnabledKey, enabled);

    // Log the change
    LoggingService.logEvent('SandboxTesting',
        'Sandbox testing ${enabled ? 'enabled' : 'disabled'}');

    debugPrint('🧪 Sandbox testing mode ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Get current sandbox log level
  static Future<String> getSandboxLogLevel() async {
    final prefs = await _getPrefs();
    return prefs.getString(_sandboxLogLevelKey) ?? 'info';
  }

  /// Set sandbox log level (debug, info, verbose)
  static Future<void> setSandboxLogLevel(String level) async {
    final prefs = await _getPrefs();
    await prefs.setString(_sandboxLogLevelKey, level);
    debugPrint('🧪 Sandbox log level set to: $level');
  }

  /// Log sandbox testing information
  static void logSandboxEvent(String category, String message) async {
    // Only log if sandbox testing is enabled
    if (await isSandboxTestingEnabled()) {
      LoggingService.logEvent('SandboxTesting: $category', message);

      // Log to dedicated file for sandbox testing
      _appendToSandboxLogFile('[$category] $message');

      // Also store events in shared preferences for UI display
      _storeEventInPrefs(category, message);

      // Log to console if in debug mode
      debugPrint('🧪 SANDBOX EVENT [$category]: $message');
    }
  }

  /// Store event in shared preferences for display in the UI
  static Future<void> _storeEventInPrefs(
      String category, String message) async {
    final prefs = await _getPrefs();

    // Get existing events
    final eventsList = prefs.getStringList(_eventsKey) ?? [];

    // Create new event with timestamp
    final timestamp = DateTime.now().toIso8601String();
    final event = json.encode({
      'timestamp': timestamp,
      'category': category,
      'message': message,
    });

    // Add to list and save
    eventsList.add(event);

    // Limit the number of events stored to prevent excessive size
    if (eventsList.length > 500) {
      eventsList.removeRange(0, eventsList.length - 500);
    }

    await prefs.setStringList(_eventsKey, eventsList);
  }

  /// Get all logged events
  static Future<List<Map<String, dynamic>>> getSandboxEvents() async {
    final prefs = await _getPrefs();
    final eventsList = prefs.getStringList(_eventsKey) ?? [];

    // Convert string list to map list
    return eventsList.map((eventString) {
      return Map<String, dynamic>.from(json.decode(eventString));
    }).toList();
  }

  /// Clear all logged events
  static Future<void> clearSandboxEvents() async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_eventsKey, []);
    debugPrint('🧪 Sandbox events cleared');
  }

  /// Helper method to get logs directory
  static Future<Directory> _getLogsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDocDir.path}/logs');

    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    return logsDir;
  }

  /// Append a message to the sandbox log file
  static Future<void> _appendToSandboxLogFile(String message) async {
    try {
      final directory = await _getLogsDirectory();
      final File file = File('${directory.path}/$_sandboxRevenueInfoFileName');

      // Add timestamp to message
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp] $message\n';

      // Create file if it doesn't exist
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Append to file
      await file.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      LoggingService.logError(
          'SandboxTesting', 'Failed to write to log file', e);
    }
  }

  /// Manual test helper: Enable sandbox testing with verbose logging
  /// and log an initial event to mark the start of manual testing
  static Future<void> initializeManualTest() async {
    debugPrint('📱 Setting up sandbox testing environment...');

    try {
      // First ensure preferences are accessible
      final prefs = await _getPrefs();

      // Set sandbox testing enabled flag directly in preferences
      await prefs.setBool(_sandboxEnabledKey, true);

      // Set the log level to verbose
      await prefs.setString(_sandboxLogLevelKey, LOG_LEVEL_VERBOSE);

      // Log both to normal logging service and to our special sandbox log
      LoggingService.logEvent('SandboxTesting',
          'Sandbox testing mode enabled with verbose logging');

      // Create a timestamped event
      final timestamp = DateTime.now().toIso8601String();
      final event = json.encode({
        'timestamp': timestamp,
        'category': 'ManualTest',
        'message': 'Starting manual sandbox testing',
      });

      // Store the event in preferences
      final eventsList = prefs.getStringList(_eventsKey) ?? [];
      eventsList.add(event);
      await prefs.setStringList(_eventsKey, eventsList);

      // Also append to log file
      await _appendToSandboxLogFile(
          '[ManualTest] Starting manual sandbox testing');

      debugPrint('');
      debugPrint('📱 MANUAL SANDBOX TESTING MODE ENABLED');
      debugPrint('---------------------------------------');
      debugPrint('🔍 You can now test in-app purchases in the sandbox');
      debugPrint('📝 All actions are being logged for review');
      debugPrint('---------------------------------------');
    } catch (e) {
      debugPrint('❌ ERROR ENABLING SANDBOX TESTING: $e');
      // Try with simpler approach as fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sandboxEnabledKey, true);
    }
  }

  /// Show the sandbox testing UI
  static Future<void> showSandboxTestingUI(BuildContext context) async {
    final bool isEnabled = await isSandboxTestingEnabled();
    final String logLevel = await getSandboxLogLevel();

    // Show a dialog to control sandbox testing
    await showDialog(
      context: context,
      builder: (context) => _SandboxTestingDialog(
        isEnabled: isEnabled,
        logLevel: logLevel,
      ),
    );
  }

  /// Simulate sandbox purchase flow with detailed logging
  static Future<void> simulateSandboxPurchase(
    BuildContext context,
    RevenueCatService revenueCatService,
    String productId,
  ) async {
    // Enable sandbox testing if not already enabled
    final bool wasEnabled = await isSandboxTestingEnabled();
    if (!wasEnabled) {
      await setSandboxTestingEnabled(true);
    }

    // Clear any previous logs
    await _clearSandboxLogs();

    // Log start of sandbox purchase test
    logSandboxEvent(
        'Purchase', 'Starting sandbox purchase test for product: $productId');

    // Show instructions dialog
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sandbox Purchase Test'),
        content: const Text(
          'This will initiate a sandbox purchase flow. Please follow these steps:\n\n'
          '1. Ensure you are logged into a sandbox test account in App Store\n'
          '2. Complete the purchase flow in the sandbox environment\n'
          '3. The app will capture detailed logs for troubleshooting\n\n'
          'You will not be charged for this purchase.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _executeSandboxPurchase(context, revenueCatService, productId);
            },
            child: const Text('Start Test'),
          ),
        ],
      ),
    );

    // Restore settings if we changed them
    if (!wasEnabled) {
      await Future.delayed(const Duration(minutes: 5));
      await setSandboxTestingEnabled(false);
    }
  }

  /// Execute the sandbox purchase with detailed logging
  static Future<void> _executeSandboxPurchase(
    BuildContext context,
    RevenueCatService revenueCatService,
    String productId,
  ) async {
    try {
      // Log attempt
      logSandboxEvent('Purchase', 'Executing sandbox purchase for $productId');

      // Log current offerings info
      if (revenueCatService.offerings != null) {
        logSandboxEvent('Offerings',
            'Current offering: ${revenueCatService.offerings!.current?.identifier}');

        final availablePackages =
            revenueCatService.offerings!.current?.availablePackages ?? [];
        for (final package in availablePackages) {
          logSandboxEvent('Package',
              '${package.identifier}: ${package.storeProduct.identifier} - ${package.storeProduct.priceString}');
        }
      } else {
        logSandboxEvent('Offerings', 'No offerings available');
      }

      // Install transaction observer for iOS
      if (Platform.isIOS) {
        logSandboxEvent('Observer', 'Installing transaction observer');
        // This would be handled by the StoreKit native code
      }

      // Log customer info before purchase
      final customerInfo = revenueCatService.customerInfo;
      if (customerInfo != null) {
        logSandboxEvent(
            'CustomerInfo', 'Customer ID: ${customerInfo.originalAppUserId}');
        logSandboxEvent('Entitlements',
            'Active entitlements: ${customerInfo.entitlements.active.keys.join(', ')}');
      } else {
        logSandboxEvent('CustomerInfo', 'No customer info available');
      }

      // Initiate purchase with callback for each step
      logSandboxEvent('Purchase', 'Initiating purchase for $productId');

      // Track purchase status changes
      final initialPurchaseStatus = revenueCatService.purchaseStatus;
      logSandboxEvent(
          'Status', 'Initial purchase status: $initialPurchaseStatus');

      // Execute the purchase
      await revenueCatService.purchaseProduct(productId);

      // Log final status
      final finalPurchaseStatus = revenueCatService.purchaseStatus;
      logSandboxEvent('Status', 'Final purchase status: $finalPurchaseStatus');

      // Log customer info after purchase
      final newCustomerInfo = revenueCatService.customerInfo;
      if (newCustomerInfo != null) {
        logSandboxEvent('CustomerInfo',
            'Updated customer ID: ${newCustomerInfo.originalAppUserId}');
        logSandboxEvent('Entitlements',
            'Updated active entitlements: ${newCustomerInfo.entitlements.active.keys.join(', ')}');
      }

      // Show the logs to the user
      await showSandboxLogs(context);
    } catch (e) {
      // Log error
      logSandboxEvent('Error', 'Error during sandbox purchase: $e');
      LoggingService.logError(
          'SandboxTesting', 'Error during sandbox purchase', e);

      // Show error dialog
      await showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Sandbox Purchase Error'),
          content: Text('An error occurred during the sandbox purchase:\n\n$e'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.pop(context);
                await showSandboxLogs(context);
              },
              child: const Text('View Logs'),
            ),
          ],
        ),
      );
    }
  }

  /// Clear sandbox logs
  static Future<void> _clearSandboxLogs() async {
    try {
      final directory = await _getLogsDirectory();
      final File file = File('${directory.path}/$_sandboxRevenueInfoFileName');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      LoggingService.logError(
          'SandboxTesting', 'Failed to clear sandbox logs', e);
    }
  }

  /// Show sandbox logs
  static Future<void> showSandboxLogs(BuildContext context) async {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SandboxTestingLogsScreen(),
      ),
    );
  }
}

/// Dialog for sandbox testing configuration
class _SandboxTestingDialog extends StatefulWidget {
  final bool isEnabled;
  final String logLevel;

  const _SandboxTestingDialog({
    required this.isEnabled,
    required this.logLevel,
  });

  @override
  _SandboxTestingDialogState createState() => _SandboxTestingDialogState();
}

class _SandboxTestingDialogState extends State<_SandboxTestingDialog> {
  late bool _isEnabled;
  late String _logLevel;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _logLevel = widget.logLevel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('StoreKit Sandbox Testing'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Enable Sandbox Testing'),
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Log Level:'),
          DropdownButton<String>(
            value: _logLevel,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'error', child: Text('Error Only')),
              DropdownMenuItem(value: 'info', child: Text('Info')),
              DropdownMenuItem(value: 'debug', child: Text('Debug')),
              DropdownMenuItem(value: 'verbose', child: Text('Verbose')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _logLevel = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await SandboxTestingHelper.setSandboxTestingEnabled(_isEnabled);
            await SandboxTestingHelper.setSandboxLogLevel(_logLevel);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
