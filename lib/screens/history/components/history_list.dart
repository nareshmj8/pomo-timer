import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../models/history_entry.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/theme_constants.dart';
import 'history_card.dart';

class HistoryList extends StatelessWidget {
  final List<HistoryEntry> entries;
  final String searchQuery;
  final String Function(DateTime) formatDateTime;

  const HistoryList({
    super.key,
    required this.entries,
    required this.searchQuery,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final bool isLargeTablet = ResponsiveUtils.isLargeTablet(context);
    final EdgeInsets padding = ResponsiveUtils.getResponsivePadding(context);

    // Determine grid column count based on screen size
    final int gridColumnCount = isLargeTablet
        ? 3
        : isTablet
            ? 2
            : 1;

    if (entries.isEmpty) {
      return _buildEmptyState(theme, isTablet);
    }

    return gridColumnCount > 1
        // Grid layout for tablets
        ? GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumnCount,
              childAspectRatio: 2.2,
              crossAxisSpacing: ThemeConstants.mediumSpacing,
              mainAxisSpacing: ThemeConstants.mediumSpacing,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final HistoryEntry entry = entries[index];
              final String formattedTime = formatDateTime(entry.timestamp);

              if (entry.category.toLowerCase().contains(searchQuery) ||
                  formattedTime.toLowerCase().contains(searchQuery)) {
                return HistoryCard(
                  entry: entry,
                  formattedTime: formattedTime,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          )
        // List layout for phones
        : ListView.builder(
            padding: padding,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final HistoryEntry entry = entries[index];
              final String formattedTime = formatDateTime(entry.timestamp);

              if (entry.category.toLowerCase().contains(searchQuery) ||
                  formattedTime.toLowerCase().contains(searchQuery)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: HistoryCard(
                    entry: entry,
                    formattedTime: formattedTime,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
  }

  Widget _buildEmptyState(ThemeProvider theme, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: isTablet
                ? ThemeConstants.largeIconSize + 8
                : ThemeConstants.largeIconSize,
            color: theme.secondaryTextColor,
          ),
          SizedBox(
              height: isTablet
                  ? ThemeConstants.mediumSpacing
                  : ThemeConstants.smallSpacing),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: isTablet
                  ? ThemeConstants.largeFontSize
                  : ThemeConstants.mediumFontSize + 1,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: ThemeConstants.smallSpacing),
          Text(
            'Complete sessions to see them here',
            style: TextStyle(
              fontSize: isTablet
                  ? ThemeConstants.mediumFontSize
                  : ThemeConstants.mediumFontSize - 1,
              color: theme.secondaryTextColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
