import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/settings_provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/themed_container.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/theme_constants.dart';
import 'components/history_list.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String searchQuery = '';

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settings, theme, _) {
        final entries = settings.history.reversed.toList();
        final isTablet = ResponsiveUtils.isTablet(context);

        return CupertinoPageScaffold(
          backgroundColor: theme.backgroundColor,
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'History',
              style: TextStyle(
                fontSize: isTablet
                    ? ThemeConstants.mediumFontSize + 1
                    : ThemeConstants.mediumFontSize,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: theme.backgroundColor.withAlpha(217),
            border: Border(
              bottom: BorderSide(
                color: theme.separatorColor,
                width: ThemeConstants.thinBorder,
              ),
            ),
          ),
          child: ThemedContainer(
            child: SafeArea(
              child: Column(
                children: [
                  _buildSearchField(theme, isTablet),
                  Expanded(
                    child: HistoryList(
                      entries: entries,
                      searchQuery: searchQuery,
                      formatDateTime: _formatDateTime,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(ThemeProvider theme, bool isTablet) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding.horizontal,
        vertical: ThemeConstants.smallSpacing + 4,
      ),
      child: CupertinoSearchTextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        placeholder: 'Search by date or category',
        backgroundColor: theme.listTileBackgroundColor,
        style: TextStyle(
          color: theme.textColor,
          fontSize: isTablet
              ? ThemeConstants.mediumFontSize - 1
              : ThemeConstants.smallFontSize + 1,
        ),
        placeholderStyle: TextStyle(
          color: theme.secondaryTextColor,
          fontSize: isTablet
              ? ThemeConstants.mediumFontSize - 1
              : ThemeConstants.smallFontSize + 1,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ThemeConstants.smallSpacing,
          vertical: isTablet
              ? ThemeConstants.smallSpacing
              : ThemeConstants.tinySpacing + 2,
        ),
      ),
    );
  }
}
