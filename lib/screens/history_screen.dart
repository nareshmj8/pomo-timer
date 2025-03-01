import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:intl/intl.dart';

// StatefulWidget allows the HistoryScreen to manage dynamic state (e.g., search filtering)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key}); // Constructor with optional key parameter

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState(); // Creates the state object
}

// State class managing the history list and search functionality
class _HistoryScreenState extends State<HistoryScreen> {
  // Tracks the current search input for filtering entries
  String searchQuery = ''; // Empty by default

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
  }

  // Helper method to get contrasting text color
  Color _getContrastingTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? CupertinoColors.black
        : CupertinoColors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final entries = settings.history.reversed.toList(); // Show newest first
        final contrastingTextColor =
            _getContrastingTextColor(settings.backgroundColor);

        // CupertinoPageScaffold provides an iOS-style page structure
        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          // Navigation bar at the top with a title
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: contrastingTextColor,
              ),
            ),
            backgroundColor: settings.backgroundColor.withOpacity(0.9),
            border: null,
          ),
          // SafeArea ensures content avoids system UI overlaps (e.g., notch, status bar)
          child: SafeArea(
            child: Column(
              // Arrange children vertically
              children: [
                // Search bar section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    placeholder: 'Search by date or category',
                    backgroundColor: CupertinoColors.white,
                    style: const TextStyle(color: CupertinoColors.black),
                    placeholderStyle: const TextStyle(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
                // List section that takes up remaining space
                Expanded(
                  // ListView.builder efficiently builds list items on demand
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: entries.length, // Total number of entries
                    itemBuilder: (context, index) {
                      final entry = entries[index]; // Get the current entry
                      final formattedTime = _formatDateTime(entry.timestamp);

                      // Filter: Show entry if category or timestamp matches search query
                      if (entry.category.toLowerCase().contains(searchQuery) ||
                          formattedTime.toLowerCase().contains(searchQuery)) {
                        // Styling and layout for each matching entry
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey
                                      .withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.category,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey6,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${entry.duration} min',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: CupertinoColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        CupertinoColors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // If entry doesn't match search, return an empty widget (hides it)
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
