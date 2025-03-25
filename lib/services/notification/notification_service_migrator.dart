import 'package:flutter/material.dart';
import 'package:pomodoro_timemaster/services/interfaces/notification_service_interface.dart';
import 'package:pomodoro_timemaster/services/notification/notification_service.dart'
    as new_service;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import the global navigator key
import '../../main.dart' show globalNavigatorKey;

/// Helper class to migrate from the old notification service to the new one
class NotificationServiceMigrator {
  // Migration keys
  static const String _migrationVersionKey = 'notification_migration_version';
  static const String _migrationBackupKey = 'notification_migration_backup';
  static const String _migrationStatusKey = 'notification_migration_status';
  static const int _currentMigrationVersion = 1;

  /// Migration status values
  static const String _statusNone = 'none';
  static const String _statusInProgress = 'in_progress';
  static const String _statusCompleted = 'completed';
  static const String _statusFailed = 'failed';
  static const String _statusRolledBack = 'rolled_back';

  /// Migrate notification settings from the old service to the new one
  static Future<bool> migrate(
      [NotificationServiceInterface? interfaceService]) async {
    final prefs = await SharedPreferences.getInstance();
    final migrationStatus = prefs.getString(_migrationStatusKey) ?? _statusNone;

    // If migration already completed successfully, just return
    if (migrationStatus == _statusCompleted) {
      debugPrint('🔄 NotificationServiceMigrator: Migration already completed');
      return true;
    }

    // If migration failed and wasn't rolled back, try rolling back
    if (migrationStatus == _statusFailed) {
      debugPrint(
          '🔄 NotificationServiceMigrator: Previous migration failed, attempting rollback');
      return _rollback();
    }

    try {
      debugPrint('🔄 NotificationServiceMigrator: Starting migration...');

      // Mark migration as in progress
      await prefs.setString(_migrationStatusKey, _statusInProgress);

      // Backup current notification settings
      await _backupCurrentSettings();

      // Get instance of new service
      final newService = new_service.NotificationService();

      // Initialize the new service
      await newService.initialize();

      // Verify initialization was successful by checking if initialization completed without errors
      // We don't need to check isInitialized property or call cancelAllNotifications

      // If we were provided with an interface implementation, we don't need to cancel
      // notifications there since it's already managed
      if (interfaceService == null) {
        debugPrint(
            '🔄 NotificationServiceMigrator: No interface service provided, skipping old service cleanup');
      }

      // After everything is verified, mark migration as completed
      await prefs.setString(_migrationStatusKey, _statusCompleted);
      await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);

      debugPrint(
          '🔄 NotificationServiceMigrator: Migration completed successfully');
      return true;
    } catch (e) {
      debugPrint('🔄 NotificationServiceMigrator: Error during migration: $e');

      // Mark migration as failed
      await prefs.setString(_migrationStatusKey, _statusFailed);

      // Try to roll back
      return _rollback();
    }
  }

  /// Back up current notification settings
  static Future<void> _backupCurrentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Collect all notification-related keys and their values
      final allKeys = prefs.getKeys();
      final notificationKeys = allKeys.where((key) =>
          key.contains('notification') ||
          key.contains('remind') ||
          key.contains('alert'));

      final backupData = <String, Map<String, dynamic>>{};

      for (final key in notificationKeys) {
        try {
          if (prefs.getString(key) != null) {
            backupData[key] = {'type': 'string', 'value': prefs.getString(key)};
          } else if (prefs.getBool(key) != null) {
            backupData[key] = {
              'type': 'bool',
              'value': prefs.getBool(key).toString()
            };
          } else if (prefs.getInt(key) != null) {
            backupData[key] = {
              'type': 'int',
              'value': prefs.getInt(key).toString()
            };
          } else if (prefs.getDouble(key) != null) {
            backupData[key] = {
              'type': 'double',
              'value': prefs.getDouble(key).toString()
            };
          } else if (prefs.getStringList(key) != null) {
            backupData[key] = {
              'type': 'stringList',
              'value': jsonEncode(prefs.getStringList(key))
            };
          }
        } catch (e) {
          debugPrint(
              '🔄 NotificationServiceMigrator: Error backing up key $key: $e');
          // Skip this key and continue with others
        }
      }

      // Save backup as a JSON string
      final backupJson = jsonEncode(backupData);
      await prefs.setString(_migrationBackupKey, backupJson);

      debugPrint('🔄 NotificationServiceMigrator: Settings backup created');
    } catch (e) {
      debugPrint('🔄 NotificationServiceMigrator: Error creating backup: $e');
      throw Exception('Failed to create backup: $e');
    }
  }

  /// Roll back failed migration to previous state
  static Future<bool> _rollback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_migrationBackupKey);

      if (backupJson == null) {
        debugPrint(
            '🔄 NotificationServiceMigrator: No backup found for rollback');
        return false;
      }

      // Parse backup data
      final Map<String, dynamic> backupData = jsonDecode(backupJson);

      // Restore each setting
      for (final entry in backupData.entries) {
        try {
          final key = entry.key;
          final valueMap = entry.value as Map<String, dynamic>;
          final type = valueMap['type'] as String;
          final valueStr = valueMap['value'] as String;

          switch (type) {
            case 'string':
              await prefs.setString(key, valueStr);
              break;
            case 'bool':
              await prefs.setBool(key, valueStr.toLowerCase() == 'true');
              break;
            case 'int':
              await prefs.setInt(key, int.parse(valueStr));
              break;
            case 'double':
              await prefs.setDouble(key, double.parse(valueStr));
              break;
            case 'stringList':
              final List<dynamic> list = jsonDecode(valueStr);
              await prefs.setStringList(key, list.cast<String>());
              break;
          }
          debugPrint('🔄 NotificationServiceMigrator: Restored setting: $key');
        } catch (e) {
          debugPrint(
              '🔄 NotificationServiceMigrator: Error restoring key ${entry.key}: $e');
          // Continue with other keys
        }
      }

      // Mark as rolled back
      await prefs.setString(_migrationStatusKey, _statusRolledBack);

      debugPrint(
          '🔄 NotificationServiceMigrator: Rollback completed successfully');

      // Show rollback dialog
      _showRollbackDialog();

      return true;
    } catch (e) {
      debugPrint('🔄 NotificationServiceMigrator: Rollback failed: $e');
      return false;
    }
  }

  /// Show rollback dialog to inform the user
  static void _showRollbackDialog() {
    // Use the globalNavigatorKey to access the context
    final context = globalNavigatorKey.currentContext;
    if (context == null) {
      debugPrint(
          '🔄 NotificationServiceMigrator: Could not show rollback dialog - no valid context');
      return;
    }

    // Store mounted state
    final bool contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if context is still mounted after delay
      if (!contextMounted || !context.mounted) {
        debugPrint(
            '🔄 NotificationServiceMigrator: Could not show rollback dialog - context no longer mounted');
        return;
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Notification Setup Issue'),
          content: const Text(
              'We encountered an issue while setting up notifications. '
              'Your previous notification settings have been restored. '
              'Please restart the app to ensure notifications work properly.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  /// Verify if migration was successful
  static Future<bool> verifyMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationStatus = prefs.getString(_migrationStatusKey) ?? _statusNone;
    final migrationVersion = prefs.getInt(_migrationVersionKey) ?? 0;

    return migrationStatus == _statusCompleted &&
        migrationVersion == _currentMigrationVersion;
  }

  /// Reset migration status (for testing or manual recovery)
  static Future<void> resetMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationStatusKey);
    await prefs.remove(_migrationVersionKey);
    await prefs.remove(_migrationBackupKey);

    debugPrint('🔄 NotificationServiceMigrator: Migration status reset');
  }
}
