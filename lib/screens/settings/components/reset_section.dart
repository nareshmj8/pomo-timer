import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';

/// Reset section of the settings screen
class ResetSection extends StatelessWidget {
  const ResetSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isTablet = ResponsiveUtils.isTablet(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    // Responsive sizes
    final fontSize = isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0);
    final buttonPadding = isTablet ? 18.0 : (isSmallScreen ? 14.0 : 16.0);
    final horizontalPadding = isTablet ? 20.0 : (isSmallScreen ? 12.0 : 16.0);
    final borderRadius = isTablet ? 14.0 : 12.0;

    // Increased vertical spacing between buttons for small screens
    final verticalSpacing = isSmallScreen ? 20.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Reset'),
        SizedBox(height: verticalSpacing / 2), // Add spacing after header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Reset all data button
              CupertinoButton(
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                color: settings.isDarkTheme
                    ? const Color(0xFF3B3B3D)
                    : CupertinoColors.systemRed,
                borderRadius: BorderRadius.circular(borderRadius),
                onPressed: () => _showResetConfirmation(context, 'all data'),
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Reset All Data',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: settings.isDarkTheme
                            ? CupertinoColors.systemRed
                            : CupertinoColors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: verticalSpacing / 2), // Add spacing after buttons
        SettingsUIComponents.buildSectionFooter(
          'Reset option will restore all settings and data to default values.',
        ),
        SizedBox(height: bottomPadding), // Add bottom padding
      ],
    );
  }

  void _showResetConfirmation(BuildContext context, String target) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Reset $target?'),
        content: Text(
            'This will restore $target to default values. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              _performReset(context, target, settings);
            },
          ),
        ],
      ),
    );
  }

  void _performReset(
      BuildContext context, String target, SettingsProvider settings) {
    // Handle different reset types
    switch (target) {
      case 'all data':
        settings.clearAllData();
        break;
    }

    // Show confirmation
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Complete'),
        content: Text('Your $target have been reset to default values.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
