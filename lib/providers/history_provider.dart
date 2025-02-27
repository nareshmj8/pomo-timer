import 'package:flutter/foundation.dart';
import '../models/history_entry.dart';

class HistoryProvider with ChangeNotifier {
  final List<HistoryEntry> _history = [];
  List<HistoryEntry> get history => _history;

  void addEntry(HistoryEntry entry) {
    _history.add(entry);
    notifyListeners();
  }

  // Add any other history-related methods
}
