import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';
import 'package:pomo_timer/providers/theme_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final entries = settings.history.reversed.toList(); // Show newest first

        // CupertinoPageScaffold provides an iOS-style page structure
        return CupertinoPageScaffold(
          // Navigation bar at the top with a title
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Provider.of<ThemeProvider>(context).textColor,
              ),
            ),
            backgroundColor:
                Provider.of<ThemeProvider>(context).backgroundColor,
            border: null,
          ),
          // SafeArea ensures content avoids system UI overlaps (e.g., notch, status bar)
          child: SafeArea(
            child: Column(
              // Arrange children vertically
              children: [
                // Search bar section
                Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Consistent padding around search bar
                  child: CupertinoSearchTextField(
                    // Updates searchQuery and rebuilds UI when text changes
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value
                            .toLowerCase(); // Normalize to lowercase for filtering
                      });
                    },
                    placeholder:
                        'Search by date or category', // Hint text in the search field
                  ),
                ),
                // List section that takes up remaining space
                Expanded(
                  // ListView.builder efficiently builds list items on demand
                  child: ListView.builder(
                    itemCount: entries.length, // Total number of entries
                    itemBuilder: (context, index) {
                      final entry = entries[index]; // Get the current entry
                      final formattedTime = _formatDateTime(entry.timestamp);

                      // Filter: Show entry if category or timestamp matches search query
                      if (entry.category.toLowerCase().contains(searchQuery) ||
                          formattedTime.toLowerCase().contains(searchQuery)) {
                        // Styling and layout for each matching entry
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, // Horizontal spacing
                            vertical: 8.0, // Vertical spacing between items
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                                12), // Inner padding for content
                            // Box decoration for rounded corners and background
                            decoration: BoxDecoration(
                              color: CupertinoColors
                                  .systemGrey6, // Light gray background
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                            // Column to stack entry details vertically
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Align text to the left
                              children: [
                                // Category text, bold and prominent
                                Text(
                                  entry.category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Provider.of<ThemeProvider>(context)
                                        .textColor,
                                  ),
                                ),
                                const SizedBox(height: 4), // Small vertical gap
                                // Duration text, styled as secondary info
                                Text(
                                  '${entry.duration} minutes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Provider.of<ThemeProvider>(context)
                                        .textColor
                                        .withValues(alpha: 204),
                                  ),
                                ),
                                const SizedBox(height: 4), // Small vertical gap
                                // Timestamp text, smaller and secondary
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Provider.of<ThemeProvider>(context)
                                        .textColor
                                        .withValues(alpha: 204),
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
