import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import '../utils/responsive_utils.dart';
import '../utils/theme_constants.dart';
import '../models/history_entry.dart';

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
        final List<HistoryEntry> entries =
            settings.history.reversed.toList(); // Show newest first

        // Get screen size and orientation information
        final screenSize = MediaQuery.of(context).size;
        final bool isTablet = ResponsiveUtils.isTablet(context);
        final bool isLargeTablet = ResponsiveUtils.isLargeTablet(context);
        // Unused variable
        // final bool isSmallScreen = ResponsiveUtils.isSmallScreen(context);
        final bool isExtraSmallScreen = screenSize.width < 375;
        final bool isLandscape = screenSize.width > screenSize.height;

        // Adjust padding based on screen size
        final EdgeInsets padding = EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveHorizontalPadding(context)
              .horizontal,
          vertical: isExtraSmallScreen ? 8.0 : 12.0,
        );

        // Determine grid column count based on screen size and orientation
        final int gridColumnCount = isLargeTablet
            ? isLandscape
                ? 5 // Large tablet landscape - 5 columns
                : 4 // Large tablet portrait - 4 columns
            : isTablet
                ? isLandscape
                    ? 4 // Regular tablet landscape - 4 columns
                    : 3 // Regular tablet portrait - 3 columns
                : isLandscape && screenSize.width >= 600
                    ? 3 // Large phone landscape - 3 columns
                    : isLandscape && !isExtraSmallScreen
                        ? 2 // Normal phone landscape and not extra small - 2 columns
                        : 1; // Phone portrait or extra small landscape - 1 column

        // Scale grid aspect ratio based on screen size for better density
        final double gridAspectRatio = isLargeTablet
            ? isLandscape
                ? 2.8
                : 2.5
            : isTablet
                ? isLandscape
                    ? 2.6
                    : 2.3
                : isLandscape
                    ? 2.5
                    : 2.2;

        // Adjust font sizes based on screen size
        final titleFontSize = isTablet
            ? ThemeConstants.mediumFontSize + 1
            : isExtraSmallScreen
                ? ThemeConstants.smallFontSize + 2
                : ThemeConstants.mediumFontSize;

        return CupertinoPageScaffold(
          backgroundColor: settings.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'History',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: settings.textColor,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: settings.backgroundColor
                .withAlpha(217), // 0.85 opacity is approximately 217 alpha
            border: Border(
              bottom: BorderSide(
                color: settings.separatorColor,
                width: ThemeConstants.thinBorder,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding.horizontal,
                    vertical: isTablet ? 16.0 : 12.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSearchTextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      placeholder: 'Search by date or category',
                      backgroundColor: settings.listTileBackgroundColor,
                      style: TextStyle(
                        color: settings.textColor,
                        fontSize: isTablet ? 16.0 : 15.0,
                      ),
                      placeholderStyle: TextStyle(
                        color: settings.secondaryTextColor,
                        fontSize: isTablet ? 16.0 : 15.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: ThemeConstants.smallSpacing,
                        vertical: isTablet ? 12.0 : 10.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? _buildEmptyState(settings, isTablet, isExtraSmallScreen)
                      : gridColumnCount > 1
                          // Grid layout for tablets or landscape mode
                          ? GridView.builder(
                              padding: padding,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumnCount,
                                childAspectRatio: gridAspectRatio,
                                crossAxisSpacing: isExtraSmallScreen
                                    ? ThemeConstants.smallSpacing
                                    : isTablet
                                        ? ThemeConstants.mediumSpacing + 4
                                        : ThemeConstants.mediumSpacing,
                                mainAxisSpacing: isExtraSmallScreen
                                    ? ThemeConstants.smallSpacing
                                    : isTablet
                                        ? ThemeConstants.mediumSpacing + 4
                                        : ThemeConstants.mediumSpacing,
                              ),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final HistoryEntry entry = entries[index];
                                final String formattedTime =
                                    _formatDateTime(entry.timestamp);

                                if (entry.category
                                        .toLowerCase()
                                        .contains(searchQuery) ||
                                    formattedTime
                                        .toLowerCase()
                                        .contains(searchQuery)) {
                                  return _buildHistoryCard(entry, formattedTime,
                                      settings, isTablet, isExtraSmallScreen);
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            )
                          // List layout for phones in portrait
                          : ListView.builder(
                              padding: padding,
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final HistoryEntry entry = entries[index];
                                final String formattedTime =
                                    _formatDateTime(entry.timestamp);

                                if (entry.category
                                        .toLowerCase()
                                        .contains(searchQuery) ||
                                    formattedTime
                                        .toLowerCase()
                                        .contains(searchQuery)) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom:
                                            isExtraSmallScreen ? 8.0 : 12.0),
                                    child: _buildHistoryCard(
                                        entry,
                                        formattedTime,
                                        settings,
                                        isTablet,
                                        isExtraSmallScreen),
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

  // Helper method to build the empty state
  Widget _buildEmptyState(
      SettingsProvider settings, bool isTablet, bool isExtraSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: isTablet
                ? ThemeConstants.largeIconSize + 8
                : isExtraSmallScreen
                    ? ThemeConstants.mediumIconSize + 4
                    : ThemeConstants.largeIconSize,
            color: settings.secondaryTextColor,
          ),
          SizedBox(
              height: isTablet
                  ? ThemeConstants.mediumSpacing
                  : isExtraSmallScreen
                      ? ThemeConstants.smallSpacing - 2
                      : ThemeConstants.smallSpacing),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: isTablet
                  ? ThemeConstants.largeFontSize
                  : isExtraSmallScreen
                      ? ThemeConstants.mediumFontSize
                      : ThemeConstants.mediumFontSize + 1,
              fontWeight: FontWeight.w600,
              color: settings.textColor,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(
              height: isExtraSmallScreen
                  ? ThemeConstants.smallSpacing - 4
                  : ThemeConstants.smallSpacing),
          Text(
            'Complete sessions to see them here',
            style: TextStyle(
              fontSize: isTablet
                  ? ThemeConstants.mediumFontSize
                  : isExtraSmallScreen
                      ? ThemeConstants.smallFontSize + 1
                      : ThemeConstants.mediumFontSize - 1,
              color: settings.secondaryTextColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a history card
  Widget _buildHistoryCard(HistoryEntry entry, String formattedTime,
      SettingsProvider settings, bool isTablet, bool isExtraSmallScreen) {
    final cardPadding = isTablet
        ? ThemeConstants.mediumSpacing
        : isExtraSmallScreen
            ? ThemeConstants.smallSpacing
            : ThemeConstants.mediumSpacing - 4;

    final categoryFontSize = isTablet
        ? ThemeConstants.mediumFontSize + 1
        : isExtraSmallScreen
            ? ThemeConstants.smallFontSize + 2
            : ThemeConstants.mediumFontSize;

    final timeFontSize = isTablet
        ? ThemeConstants.mediumFontSize - 2
        : isExtraSmallScreen
            ? ThemeConstants.smallFontSize
            : ThemeConstants.smallFontSize + 1;

    final durationFontSize = isTablet
        ? ThemeConstants.mediumFontSize - 2
        : isExtraSmallScreen
            ? ThemeConstants.smallFontSize
            : ThemeConstants.smallFontSize + 1;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: settings.listTileBackgroundColor,
        borderRadius: BorderRadius.circular(isExtraSmallScreen
            ? ThemeConstants.smallRadius
            : ThemeConstants.mediumRadius),
        border: Border.all(
          color: settings.separatorColor,
          width: ThemeConstants.thinBorder,
        ),
        boxShadow: ThemeConstants.getShadow(settings.separatorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.category,
                  style: TextStyle(
                    fontSize: categoryFontSize,
                    fontWeight: FontWeight.w600,
                    color: settings.textColor,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isExtraSmallScreen ? 2 : 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet
                      ? ThemeConstants.smallSpacing + 2
                      : isExtraSmallScreen
                          ? ThemeConstants.smallSpacing - 2
                          : ThemeConstants.smallSpacing,
                  vertical: isTablet
                      ? ThemeConstants.tinySpacing + 1
                      : isExtraSmallScreen
                          ? ThemeConstants.tinySpacing - 1
                          : ThemeConstants.tinySpacing,
                ),
                decoration: BoxDecoration(
                  color: settings.isDarkTheme
                      ? const Color(0xFF2C2C2E)
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(isExtraSmallScreen
                      ? ThemeConstants.smallRadius
                      : ThemeConstants.mediumRadius),
                ),
                child: Text(
                  '${entry.duration} min',
                  style: TextStyle(
                    fontSize: durationFontSize,
                    fontWeight: FontWeight.w500,
                    color: settings.isDarkTheme
                        ? CupertinoColors.systemGrey.withAlpha(
                            (ThemeConstants.highOpacity * 255).round())
                        : CupertinoColors.systemGrey.darkColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height: isTablet
                  ? ThemeConstants.smallSpacing
                  : isExtraSmallScreen
                      ? ThemeConstants.smallSpacing - 4
                      : ThemeConstants.smallSpacing - 2),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: timeFontSize,
              color: settings.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
