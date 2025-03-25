import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/theme_constants.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Theme',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: themeProvider.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: AppTheme.availableThemes.map((theme) {
              final isSelected = theme.name == currentTheme.name;
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => themeProvider.setTheme(theme.name),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: theme != AppTheme.availableThemes.last
                          ? BorderSide(
                              color: themeProvider.separatorColor,
                              width: 0.5,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.separatorColor,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          theme.name,
                          style: TextStyle(
                            color: themeProvider.listTileTextColor,
                            fontSize: ThemeConstants.bodyFontSize,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          CupertinoIcons.check_mark,
                          color: themeProvider.textColor,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
