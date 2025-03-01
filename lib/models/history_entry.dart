class HistoryEntry {
  final String category;
  final int duration;
  final DateTime timestamp;

  HistoryEntry({
    required this.category,
    required this.duration,
    required this.timestamp,
  });

  // Convert HistoryEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create HistoryEntry from JSON
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      category: json['category'] as String,
      duration: json['duration'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
