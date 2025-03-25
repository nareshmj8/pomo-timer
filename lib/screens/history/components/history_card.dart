import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../models/history_entry.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/theme_constants.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final String formattedTime;

  const HistoryCard({
    super.key,
    required this.entry,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmallScreen = screenWidth < 375;

    return Container(
      padding: EdgeInsets.all(isTablet
          ? ThemeConstants.mediumSpacing
          : ThemeConstants.mediumSpacing - 4),
      decoration: BoxDecoration(
        color: theme.listTileBackgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        border: Border.all(
          color: theme.separatorColor,
          width: ThemeConstants.thinBorder,
        ),
        boxShadow: ThemeConstants.getShadow(theme.separatorColor),
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
                    fontSize: isTablet
                        ? ThemeConstants.mediumFontSize + 1
                        : ThemeConstants.mediumFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isExtraSmallScreen || isSmallScreen ? 2 : 1,
                ),
              ),
              const SizedBox(width: ThemeConstants.smallSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet
                      ? ThemeConstants.smallSpacing + 2
                      : ThemeConstants.smallSpacing,
                  vertical: isTablet
                      ? ThemeConstants.tinySpacing + 1
                      : ThemeConstants.tinySpacing,
                ),
                decoration: BoxDecoration(
                  color: theme.isDarkTheme
                      ? const Color(0xFF2C2C2E)
                      : CupertinoColors.systemGrey6,
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.mediumRadius),
                ),
                child: Text(
                  '${entry.duration} min',
                  style: TextStyle(
                    fontSize: isTablet
                        ? ThemeConstants.mediumFontSize - 2
                        : ThemeConstants.smallFontSize + 1,
                    fontWeight: FontWeight.w500,
                    color: theme.isDarkTheme
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
                  : ThemeConstants.smallSpacing - 2),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: isTablet
                  ? ThemeConstants.mediumFontSize - 2
                  : ThemeConstants.smallFontSize + 1,
              color: theme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
