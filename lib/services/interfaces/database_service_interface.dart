import 'package:sqflite/sqflite.dart';

/// Interface for database services
///
/// This interface allows for dependency injection and easier testing
/// by decoupling the implementation from the code that uses it.
abstract class DatabaseServiceInterface {
  /// Initialize the database and perform integrity checks
  ///
  /// Returns void but ensures the database is ready for use
  Future<void> initialize();

  /// Get the database instance
  ///
  /// Returns the initialized database instance
  Future<Database> get database;

  /// Get whether the database has been initialized
  bool get isInitialized;

  /// Get whether the database is corrupted
  bool get isCorrupted;

  /// Execute database operation with transaction support
  ///
  /// [operation] is the function to execute within the transaction
  /// [exclusive] sets whether this is an exclusive transaction
  /// [operationName] is an optional name for logging/debugging
  Future<T> executeWithTransaction<T>({
    required Future<T> Function(Transaction txn) operation,
    bool exclusive,
    String? operationName,
  });

  /// Create a backup of the database
  ///
  /// Returns true if backup was successful
  Future<bool> createBackup();

  /// Restore database from backup
  ///
  /// Returns true if restoration was successful
  Future<bool> restoreFromBackup();

  /// Close the database
  Future<void> close();
}
