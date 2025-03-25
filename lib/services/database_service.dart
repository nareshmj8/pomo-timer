import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logging_service.dart';
import 'interfaces/database_service_interface.dart';

/// Database service that provides CRUD operations for the app's data
/// Implements integrity checks and transaction support
class DatabaseService extends ChangeNotifier
    implements DatabaseServiceInterface {
  static const String databaseName = 'pomodoro_timer.db';
  static const int databaseVersion = 1;
  static final DatabaseService _instance = DatabaseService._internal();

  // Tables
  static const String historyTable = 'history';
  static const String statisticsTable = 'statistics';
  static const String settingsTable = 'settings';

  // Integrity check keys
  static const String lastIntegrityCheckKey = 'last_database_integrity_check';
  static const String dbHashKey = 'database_hash';
  static const String backupCreatedKey = 'database_backup_created';

  // Global navigator key for showing dialogs
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Database? _database;
  bool _isInitialized = false;
  bool _isCorrupted = false;
  final List<Map<String, dynamic>> _pendingOperations = [];

  // Getters
  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isCorrupted => _isCorrupted;

  // Factory constructor
  factory DatabaseService() => _instance;

  // Private constructor
  DatabaseService._internal();

  /// Get the database instance
  @override
  Future<Database> get database async {
    if (_database != null && _isInitialized) {
      return _database!;
    }

    // Initialize database if it's not available
    await initialize();
    return _database!;
  }

  /// Initialize the database and perform integrity checks
  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('💾 DatabaseService: Already initialized, skipping');
      return;
    }

    try {
      // Get application documents directory
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, databaseName);

      debugPrint('💾 DatabaseService: Initializing database at $path');

      // Check if we need to restore from backup
      final bool shouldRestore = await _shouldRestoreFromBackup();
      if (shouldRestore) {
        await _restoreFromBackup();
      }

      // Open the database with options
      _database = await openDatabase(
        path,
        version: databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: (db) async {
          debugPrint('💾 DatabaseService: Database opened');
          // Perform integrity check after opening
          await _performIntegrityCheck(db);
        },
      );

      _isInitialized = true;
      notifyListeners();

      // Process any pending operations
      if (_pendingOperations.isNotEmpty) {
        await _processPendingOperations();
      }

      // Create a backup after successful initialization
      await _createBackup();
    } catch (e) {
      _isInitialized = false;
      debugPrint('💾 DatabaseService: Error initializing database: $e');
      LoggingService.logError(
          'Database Service', 'Error initializing database', e);

      // Show error dialog
      _showDatabaseErrorDialog(
          'Failed to initialize database. Some features may not work properly.');

      // Try to recover
      await _attemptRecovery();
    }
  }

  /// Create a new database schema
  Future<void> _createDatabase(Database db, int version) async {
    debugPrint(
        '💾 DatabaseService: Creating new database schema (version $version)');

    // Use a transaction to create all tables
    await db.transaction((txn) async {
      // History table
      await txn.execute('''
        CREATE TABLE $historyTable (
          id TEXT PRIMARY KEY,
          date INTEGER NOT NULL,
          duration INTEGER NOT NULL,
          isCompleted INTEGER NOT NULL,
          category TEXT,
          notes TEXT,
          createdAt INTEGER NOT NULL,
          modifiedAt INTEGER NOT NULL
        )
      ''');

      // Statistics table
      await txn.execute('''
        CREATE TABLE $statisticsTable (
          date TEXT PRIMARY KEY,
          totalPomodoros INTEGER NOT NULL,
          totalDuration INTEGER NOT NULL,
          data TEXT NOT NULL
        )
      ''');

      // Settings table
      await txn.execute('''
        CREATE TABLE $settingsTable (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');

      // Create indexes for performance
      await txn
          .execute('CREATE INDEX idx_history_date ON $historyTable (date)');
      await txn.execute(
          'CREATE INDEX idx_history_category ON $historyTable (category)');
    });

    // Initial integrity hash
    await _saveIntegrityHash(db);
  }

  /// Upgrade database schema to a newer version
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    debugPrint(
        '💾 DatabaseService: Upgrading database from v$oldVersion to v$newVersion');

    // Create backup before upgrading
    await _createBackup();

    // Use a transaction for the upgrade
    await db.transaction((txn) async {
      if (oldVersion < 2) {
        // For future upgrades to version 2
        // await txn.execute('ALTER TABLE $historyTable ADD COLUMN newColumn TEXT');
      }

      // Add more version upgrade paths as needed
    });

    // Update integrity hash after upgrade
    await _saveIntegrityHash(db);
  }

  /// Perform a database integrity check
  Future<bool> _performIntegrityCheck(Database db) async {
    try {
      debugPrint('💾 DatabaseService: Performing integrity check');

      // Check if we recently performed an integrity check (don't do it too often)
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(lastIntegrityCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // If we did a check in the last 24 hours, skip it
      if (now - lastCheck < const Duration(hours: 24).inMilliseconds) {
        debugPrint(
            '💾 DatabaseService: Skipping integrity check (done recently)');
        return true;
      }

      // Calculate current database hash
      final currentHash = await _calculateDatabaseHash(db);

      // Get stored hash
      final storedHash = prefs.getString(dbHashKey);

      // If there's no stored hash, this might be first run, so save current hash
      if (storedHash == null) {
        await _saveIntegrityHash(db);
        return true;
      }

      // Compare hashes to check integrity
      if (currentHash != storedHash) {
        debugPrint(
            '💾 DatabaseService: Integrity check failed - hash mismatch');
        _isCorrupted = true;

        // Show corruption dialog and attempt recovery
        _showDatabaseCorruptionDialog();
        await _attemptRecovery();
        return false;
      }

      // Update last check timestamp
      await prefs.setInt(lastIntegrityCheckKey, now);
      debugPrint('💾 DatabaseService: Integrity check passed');
      return true;
    } catch (e) {
      debugPrint('💾 DatabaseService: Error during integrity check: $e');
      LoggingService.logError(
          'Database Service', 'Error during integrity check', e);

      // Assume corruption if we can't verify
      _isCorrupted = true;
      _showDatabaseCorruptionDialog();
      return false;
    }
  }

  /// Calculate a hash of the database for integrity checking
  Future<String> _calculateDatabaseHash(Database db) async {
    final StringBuffer buffer = StringBuffer();

    // Get table schemas
    final tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    for (final table in tables) {
      final tableName = table['name'] as String;

      // Skip SQLite internal tables
      if (tableName.startsWith('sqlite_') || tableName.startsWith('android_')) {
        continue;
      }

      // Add table schema to the hash
      final tableInfo = await db.rawQuery("PRAGMA table_info($tableName)");
      buffer.write('TABLE:$tableName\n');

      for (final column in tableInfo) {
        buffer.write('${column['name']}-${column['type']}-${column['pk']}\n');
      }

      // Add row count from each table
      final countResult =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      buffer.write('ROWS:$count\n');
    }

    // Generate MD5 hash of the combined schema and row counts
    final bytes = utf8.encode(buffer.toString());
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Save the current database hash for future integrity checks
  Future<void> _saveIntegrityHash(Database db) async {
    try {
      final hash = await _calculateDatabaseHash(db);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(dbHashKey, hash);
      await prefs.setInt(
          lastIntegrityCheckKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('💾 DatabaseService: Saved integrity hash: $hash');
    } catch (e) {
      debugPrint('💾 DatabaseService: Error saving integrity hash: $e');
      LoggingService.logError(
          'Database Service', 'Error saving integrity hash', e);
    }
  }

  /// Create a backup of the database
  ///
  /// Returns true if backup was successful
  @override
  Future<bool> createBackup() async {
    return _createBackup();
  }

  /// Internal method to create a backup of the database
  Future<bool> _createBackup() async {
    try {
      final db = await database;

      // Get application documents directory
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String dbPath = join(documentsDirectory.path, databaseName);
      final String backupPath =
          join(documentsDirectory.path, '${databaseName}_backup');

      // Close the database to ensure all writes are flushed
      await db.close();
      _database = null;

      // Copy database file to backup location
      final File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);

        // Record backup creation time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            backupCreatedKey, DateTime.now().millisecondsSinceEpoch);

        debugPrint(
            '💾 DatabaseService: Created database backup at $backupPath');

        // Reopen the database
        _database = await openDatabase(dbPath, version: databaseVersion);
        return true;
      }

      // Reopen the database even if backup failed
      _database = await openDatabase(dbPath, version: databaseVersion);
      return false;
    } catch (e) {
      debugPrint('💾 DatabaseService: Error creating backup: $e');
      LoggingService.logError('Database Service', 'Error creating backup', e);

      // Try to reopen the database
      _database = null;
      await initialize();
      return false;
    }
  }

  /// Check if we should restore from backup
  Future<bool> _shouldRestoreFromBackup() async {
    if (!_isCorrupted) return false;

    try {
      // Check if backup exists and is newer than corruption detection
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String backupPath =
          join(documentsDirectory.path, '${databaseName}_backup');
      final File backupFile = File(backupPath);

      if (await backupFile.exists()) {
        final prefs = await SharedPreferences.getInstance();
        final backupTime = prefs.getInt(backupCreatedKey) ?? 0;

        // Only use backup if it's not too old (< 7 days)
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - backupTime < const Duration(days: 7).inMilliseconds) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('💾 DatabaseService: Error checking backup status: $e');
      return false;
    }
  }

  /// Restore database from backup
  ///
  /// Returns true if restoration was successful
  @override
  Future<bool> restoreFromBackup() async {
    return _restoreFromBackup();
  }

  /// Internal method to restore database from backup
  Future<bool> _restoreFromBackup() async {
    try {
      // Get paths
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String dbPath = join(documentsDirectory.path, databaseName);
      final String backupPath =
          join(documentsDirectory.path, '${databaseName}_backup');

      // Check if backup exists
      final File backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        debugPrint('💾 DatabaseService: No backup file found at $backupPath');
        return false;
      }

      // Close database if open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete corrupted database
      final File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // Copy backup to main database location
      await backupFile.copy(dbPath);
      debugPrint('💾 DatabaseService: Restored database from backup');

      // Reset corruption flag
      _isCorrupted = false;
      _showRestoreSuccessDialog();

      return true;
    } catch (e) {
      debugPrint('💾 DatabaseService: Error restoring from backup: $e');
      LoggingService.logError(
          'Database Service', 'Error restoring from backup', e);
      return false;
    }
  }

  /// Attempt to recover from database corruption
  Future<void> _attemptRecovery() async {
    try {
      // First try to restore from backup
      if (await _shouldRestoreFromBackup()) {
        final success = await _restoreFromBackup();
        if (success) {
          _isCorrupted = false;
          return;
        }
      }

      // If restoration failed, try to recreate the database
      await _recreateDatabase();
    } catch (e) {
      debugPrint('💾 DatabaseService: Error during recovery attempt: $e');
      LoggingService.logError(
          'Database Service', 'Error during recovery attempt', e);
    }
  }

  /// Recreate the database from scratch (last resort recovery)
  Future<void> _recreateDatabase() async {
    try {
      debugPrint(
          '💾 DatabaseService: Attempting to recreate database from scratch');

      // Get database path
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      final String dbPath = join(documentsDirectory.path, databaseName);

      // Close database if open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Delete corrupted database
      final File dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // Create a new database
      _database = await openDatabase(
        dbPath,
        version: databaseVersion,
        onCreate: _createDatabase,
      );

      _isInitialized = true;
      _isCorrupted = false;

      // Show recovery dialog
      _showRecoveryDialog();

      notifyListeners();
    } catch (e) {
      debugPrint('💾 DatabaseService: Failed to recreate database: $e');
      LoggingService.logError(
          'Database Service', 'Failed to recreate database', e);

      // Set as not initialized since recovery failed
      _isInitialized = false;
      _isCorrupted = true;

      // Show critical error dialog
      _showCriticalErrorDialog();
    }
  }

  /// Execute database operation with transaction support
  @override
  Future<T> executeWithTransaction<T>({
    required Future<T> Function(Transaction txn) operation,
    bool exclusive = false,
    String? operationName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isCorrupted) {
      throw Exception('Cannot execute operation on corrupted database');
    }

    final db = await database;

    try {
      final resultFuture = exclusive
          ? db.transaction(operation, exclusive: true)
          : db.transaction(operation);

      // Execute and return result
      final result = await resultFuture;
      return result;
    } catch (e) {
      debugPrint(
          '💾 DatabaseService: Error in database transaction${operationName != null ? ' ($operationName)' : ''}: $e');
      LoggingService.logError(
          'Database Service',
          'Transaction error${operationName != null ? ' in $operationName' : ''}',
          e);

      // Queue operation for retry if it's a transient error
      if (e is DatabaseException && _isTransientError(e)) {
        _queueOperation({
          'operation': operationName ?? 'unknown',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          // Additional context would be stored here
        });
      }

      // Rethrow for caller to handle
      rethrow;
    }
  }

  /// Check if an error is transient and can be retried
  bool _isTransientError(DatabaseException error) {
    final errorMsg = error.toString().toLowerCase();

    // Common transient SQLite errors
    return errorMsg.contains('database is locked') ||
        errorMsg.contains('busy') ||
        errorMsg.contains('no such table') ||
        errorMsg.contains('disk i/o error') ||
        errorMsg.contains('database disk image is malformed');
  }

  /// Queue an operation for later retry
  void _queueOperation(Map<String, dynamic> operation) {
    _pendingOperations.add(operation);
    debugPrint(
        '💾 DatabaseService: Operation queued for retry: ${operation['operation']}');
  }

  /// Process pending operations
  Future<void> _processPendingOperations() async {
    // Implementation would depend on specific operations that were queued
    // This is a placeholder for actual implementation
    debugPrint(
        '💾 DatabaseService: Processing ${_pendingOperations.length} pending operations');
    _pendingOperations.clear();
  }

  /// Show database corruption dialog
  void _showDatabaseCorruptionDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Store the BuildContext's mounted status in a variable before the async gap
    final contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if the context is still valid after the async gap
      if (contextMounted && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Database Issue Detected'),
            content: const Text(
                'There seems to be an issue with your data. The app will attempt to restore '
                'from a backup or create a fresh database. Some recent data may be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Show successful restore dialog
  void _showRestoreSuccessDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Store the BuildContext's mounted status in a variable before the async gap
    final contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if the context is still valid after the async gap
      if (contextMounted && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Data Restored'),
            content: const Text(
                'Your data has been successfully restored from a backup.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Show database error dialog
  void _showDatabaseErrorDialog(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Store the BuildContext's mounted status in a variable before the async gap
    final contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if the context is still valid after the async gap
      if (contextMounted && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Database Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Show recovery dialog
  void _showRecoveryDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Store the BuildContext's mounted status in a variable before the async gap
    final contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if the context is still valid after the async gap
      if (contextMounted && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Data Reset'),
            content: const Text(
                'Due to a data issue, we had to reset your database. '
                'Your previous data could not be recovered. You\'re starting with a fresh database.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Show critical error dialog
  void _showCriticalErrorDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Store the BuildContext's mounted status in a variable before the async gap
    final contextMounted = context.mounted;

    Future.delayed(Duration.zero, () {
      // Check if the context is still valid after the async gap
      if (contextMounted && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Critical Database Error'),
            content: const Text('A critical error occurred with the database. '
                'The app cannot continue to function properly. '
                'Please restart the app and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Force quit the app or navigate to a special error screen
                  exit(0);
                },
                child: const Text('Quit App'),
              ),
            ],
          ),
        );
      }
    });
  }

  /// Close the database
  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }
}
