import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// Helper class for settings-related dialogs
class SettingsDialogs {
  /// Shows a confirmation dialog for resetting app data
  static Future<bool> showResetConfirmation(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    bool result = false;

    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Reset All Data?'),
          content: const Text(
            'This will reset all settings and data to their default values. '
            'This action cannot be undone.',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: settings.isDarkTheme
                      ? CupertinoColors.systemBlue.darkColor
                      : CupertinoColors.systemBlue,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                result = false;
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                result = true;
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    return result;
  }
}
