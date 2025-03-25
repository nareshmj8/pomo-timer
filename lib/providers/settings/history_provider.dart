import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/history_entry.dart';

/// Manages history data and operations
class HistoryProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const String _historyKey = 'history';

  // History data
  List<HistoryEntry> _history = [];

  HistoryProvider(this._prefs) {
    _loadHistory();
  }

  /// Get history entries
  List<HistoryEntry> get history => _history;

  /// Load history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      // First try to get history as a string list (new format)
      final historyJsonList = _prefs.getStringList(_historyKey);
      if (historyJsonList != null) {
        _history = historyJsonList
            .map((json) => HistoryEntry.fromJson(jsonDecode(json)))
            .toList();
      } else {
        // Fallback to string format (old format or from tests)
        final historyJsonString = _prefs.getString(_historyKey);
        if (historyJsonString != null) {
          try {
            final List<dynamic> parsedList = jsonDecode(historyJsonString);
            _history =
                parsedList.map((item) => HistoryEntry.fromJson(item)).toList();
          } catch (e) {
            debugPrint('Error parsing history from string: $e');
            _history = [];
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history = [];
    }
    notifyListeners();
  }

  /// Public method to reload history data
  Future<void> reloadHistory() async {
    await _loadHistory();
  }

  /// Save history to SharedPreferences
  Future<void> saveHistory() async {
    final historyJson =
        _history.map((entry) => jsonEncode(entry.toJson())).toList();
    await _prefs.setStringList(_historyKey, historyJson);
  }

  /// Add a new history entry
  void addHistoryEntry(HistoryEntry entry) {
    _history.add(entry);
    saveHistory();
    notifyListeners();
  }

  /// Clear all history
  void clearHistory() {
    debugPrint('🧹 HISTORY_PROVIDER: Starting clearHistory...');
    try {
      // Clear the in-memory history list
      _history.clear();
      debugPrint('🧹 HISTORY_PROVIDER: In-memory history cleared');

      // Remove history from SharedPreferences
      _prefs.remove(_historyKey);
      debugPrint('🧹 HISTORY_PROVIDER: History removed from SharedPreferences');

      // Also clear any saved entries
      saveHistory();
      debugPrint('🧹 HISTORY_PROVIDER: History saved (empty)');

      // Notify listeners of the change
      notifyListeners();
      debugPrint('🧹 HISTORY_PROVIDER: Listeners notified');

      debugPrint('🧹 HISTORY_PROVIDER: clearHistory completed successfully');
    } catch (e) {
      debugPrint('❌ HISTORY_PROVIDER: Error in clearHistory: $e');
      debugPrint('❌ HISTORY_PROVIDER: Stack trace: ${StackTrace.current}');
      // Re-throw to allow handling by caller
      rethrow;
    }
  }

  /// Delete a specific history entry
  void deleteHistoryEntry(HistoryEntry entry) {
    _history.removeWhere((e) =>
        e.category == entry.category &&
        e.duration == entry.duration &&
        e.timestamp.isAtSameMomentAs(entry.timestamp));
    saveHistory();
    notifyListeners();
  }

  /// Get history entries for a specific category
  List<HistoryEntry> getHistoryByCategory(String category) {
    if (category == 'All Categories') {
      return _history;
    }
    return _history.where((entry) => entry.category == category).toList();
  }

  /// Get history entries for a specific date range
  List<HistoryEntry> getHistoryByDateRange(DateTime start, DateTime end) {
    return _history
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  /// Get total duration for a specific category
  int getTotalDurationByCategory(String category) {
    if (category == 'All Categories') {
      return _history.fold(0, (sum, entry) => sum + entry.duration);
    }
    return _history
        .where((entry) => entry.category == category)
        .fold(0, (sum, entry) => sum + entry.duration);
  }

  /// Get total sessions for a specific category
  int getTotalSessionsByCategory(String category) {
    if (category == 'All Categories') {
      return _history.length;
    }
    return _history.where((entry) => entry.category == category).length;
  }
}
