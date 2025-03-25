import 'dart:developer' as developer;

/// Simple logging utility class
class Logging {
  /// Log an informational message
  void info(String message) {
    developer.log(message, name: 'INFO');
  }

  /// Log a warning message
  void warning(String message) {
    developer.log(message, name: 'WARNING');
  }

  /// Log an error message
  void error(String message) {
    developer.log(message, name: 'ERROR');
  }

  /// Log a debug message
  void debug(String message) {
    developer.log(message, name: 'DEBUG');
  }
}

/// Global logging instance
final logging = Logging();
