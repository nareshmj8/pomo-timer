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

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: settings.backgroundColor.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(
                color: settings.separatorColor,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    placeholder: 'Search by date or category',
                    backgroundColor: settings.listTileBackgroundColor,
                    style: TextStyle(color: settings.textColor),
                    placeholderStyle: TextStyle(
                      color: settings.secondaryTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 48,
                                color: settings.secondaryTextColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No history yet',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: settings.textColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete sessions to see them here',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: settings.secondaryTextColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final formattedTime =
                                _formatDateTime(entry.timestamp);

                            if (entry.category
                                    .toLowerCase()
                                    .contains(searchQuery) ||
                                formattedTime
                                    .toLowerCase()
                                    .contains(searchQuery)) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: settings.listTileBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: settings.separatorColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            entry.category,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: settings.textColor,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: settings.isDarkTheme
                                                  ? const Color(0xFF2C2C2E)
                                                  : CupertinoColors.systemGrey6,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${entry.duration} min',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: settings.isDarkTheme
                                                    ? CupertinoColors.systemGrey
                                                        .withOpacity(0.9)
                                                    : CupertinoColors
                                                        .systemGrey.darkColor,
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
                                          color: settings.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
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
