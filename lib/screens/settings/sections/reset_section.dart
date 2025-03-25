import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../providers/settings_provider.dart';
import '../utils/settings_dialogs.dart';

class ResetSection extends StatelessWidget {
  const ResetSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Reset',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              _buildResetButton(
                context,
                'Reset Statistics',
                'Clear all statistics data',
                theme,
                onReset: _resetStatistics,
              ),
              _buildResetButton(
                context,
                'Reset Settings',
                'Restore default settings',
                theme,
                isLast: true,
                onReset: _resetSettings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Reset statistics data
  void _resetStatistics(BuildContext context) {
    debugPrint('🔴 RESET: Beginning statistics reset...');
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    debugPrint('🔴 RESET: Retrieved settings provider');

    // Store context to use after async operation
    final navigatorContext = context;

    // Close the dialog immediately
    Navigator.pop(navigatorContext);
    debugPrint('🔴 RESET: Dialog closed');

    try {
      // Direct approach - call clearAllStatistics first which we'll implement
      // Clear history which will reset statistics
      debugPrint('🔴 RESET: Attempting to clear history...');
      settings.clearHistory();
      debugPrint('🔴 RESET: Statistics reset successful');

      // Directly call to update statistics provider
      settings.refreshData();
      debugPrint('🔴 RESET: Refreshed data');

      // Show confirmation toast
      if (navigatorContext.mounted) {
        debugPrint('🔴 RESET: Showing success toast');
        SettingsDialogs.showToast(
            navigatorContext, 'Statistics data has been reset');
      } else {
        debugPrint('🔴 RESET: Context no longer mounted, cannot show toast');
      }
    } catch (e) {
      debugPrint('🔴 RESET: Error resetting statistics: $e');
      debugPrint('🔴 RESET: Stack trace: ${StackTrace.current}');
      if (navigatorContext.mounted) {
        SettingsDialogs.showToast(
            navigatorContext, 'Error resetting statistics: $e');
      }
    }
  }

  // Reset all settings to default values
  void _resetSettings(BuildContext context) async {
    debugPrint('🔵 RESET: Beginning settings reset...');
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    debugPrint('🔵 RESET: Retrieved settings provider');

    // Store context to use after async operation
    final navigatorContext = context;

    // Close the dialog immediately
    Navigator.pop(navigatorContext);
    debugPrint('🔵 RESET: Dialog closed');

    try {
      debugPrint(
          '🔵 RESET: Calling clearAllData method as a more direct approach');
      // Direct approach to reset everything including settings and history
      await settings.clearAllData();
      debugPrint('🔵 RESET: clearAllData completed');

      // Ensure UI is refreshed
      settings.refreshData();
      debugPrint('🔵 RESET: Refreshed data');

      // Show confirmation toast
      if (navigatorContext.mounted) {
        debugPrint('🔵 RESET: Showing success toast');
        SettingsDialogs.showToast(
            navigatorContext, 'Settings have been restored to defaults');
      } else {
        debugPrint('🔵 RESET: Context no longer mounted, cannot show toast');
      }
    } catch (e) {
      debugPrint('🔵 RESET: Error resetting settings: $e');
      debugPrint('🔵 RESET: Stack trace: ${StackTrace.current}');
      if (navigatorContext.mounted) {
        SettingsDialogs.showToast(
            navigatorContext, 'Error resetting settings: $e');
      }
    }
  }

  Widget _buildResetButton(
    BuildContext context,
    String title,
    String subtitle,
    ThemeProvider theme, {
    bool isLast = false,
    required Function(BuildContext) onReset,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: !isLast
              ? BorderSide(
                  color: theme.separatorColor,
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16.0),
        onPressed: () {
          debugPrint('Reset button tapped: $title');
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text('Are you sure you want to $subtitle?'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () {
                    debugPrint('Cancel tapped for: $title');
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('Reset'),
                  onPressed: () {
                    debugPrint('Reset confirmed for: $title');
                    onReset(context);
                  },
                ),
              ],
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: ThemeConstants.bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: ThemeConstants.captionFontSize,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.right_chevron,
              color: theme.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
