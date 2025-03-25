import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// Utility class for showing dialogs and toasts in settings screens
class SettingsDialogs {
  /// Shows a toast notification
  static void showToast(BuildContext context, String message) {
    debugPrint('🍞 TOAST: Showing toast: $message');

    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withAlpha(242),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    debugPrint('🍞 TOAST: Toast inserted into overlay');

    // Keep toast visible for slightly longer
    Future.delayed(const Duration(seconds: 3), () {
      overlay.remove();
      debugPrint('🍞 TOAST: Toast removed');
    });
  }

  /// Shows a confirmation dialog for resetting app data
  static void showResetConfirmation(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Reset All Settings?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: settings.textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'This will reset all settings to their default values. Your data will be permanently deleted and cannot be recovered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settings.textColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: settings.isDarkTheme
                    ? const Color(0xFF2C2C2E)
                    : CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResetItem('Timer settings'),
                  _buildResetItem('Break durations'),
                  _buildResetItem('Session counts'),
                  _buildResetItem('Theme preferences'),
                  _buildResetItem('Sound settings'),
                  _buildResetItem('History data'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.activeBlue.darkColor
                    : CupertinoColors.activeBlue,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              // Store context before async operation
              final navigatorContext = context;

              // Close the dialog immediately before async operation
              Navigator.pop(navigatorContext);

              // Clear all saved data
              await settings.clearAllData();

              // Show toast only if still mounted
              if (navigatorContext.mounted) {
                showToast(navigatorContext, 'All settings have been reset');
              }
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.systemRed.darkColor
                    : CupertinoColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a sessions picker
  static void showSessionsPicker(
      BuildContext context, SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          color: settings.isDarkTheme
              ? CupertinoColors.systemBackground.darkColor
              : CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: settings.isDarkTheme
                      ? const Color(0xFF1C1C1E)
                      : CupertinoColors.systemGrey6,
                  border: Border(
                    bottom: BorderSide(
                      color: settings.separatorColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: settings.isDarkTheme
                              ? CupertinoColors.activeBlue.darkColor
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  onSelectedItemChanged: (int index) {
                    settings.setSessionsBeforeLongBreak(index + 1);
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: settings.sessionsBeforeLongBreak - 1,
                  ),
                  children: List<Widget>.generate(8, (index) {
                    return Center(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: settings.textColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper for reset dialog items
  static Widget _buildResetItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.circle_fill,
            size: 6,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
