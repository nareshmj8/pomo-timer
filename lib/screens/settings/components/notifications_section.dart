import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';
import 'package:pomodoro_timemaster/utils/responsive_utils.dart';

/// Notifications section of the settings screen
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    // Responsive font sizes
    final fontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Notifications'),
        SettingsUIComponents.buildListTileContainer(
          child: Column(
            children: [
              CupertinoListTile(
                title: Text(
                  'Sound',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: settings.listTileTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: settings.soundEnabled,
                  onChanged: (value) => settings.setSoundEnabled(value),
                  activeTrackColor: settings.isDarkTheme
                      ? CupertinoColors.activeBlue.darkColor
                      : CupertinoColors.activeBlue,
                ),
              ),
              if (settings.soundEnabled) ...[
                const Divider(
                  height: 0.5,
                  indent: 16,
                ),
                CupertinoListTile(
                  title: Text(
                    'Sound Type',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: settings.listTileTextColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getSoundName(settings.notificationSoundType),
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          color: settings.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        CupertinoIcons.forward,
                        color: settings.secondaryTextColor,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => _showSoundPicker(context, settings),
                ),
                const Divider(
                  height: 0.5,
                  indent: 16,
                ),
                CupertinoListTile(
                  title: Text(
                    'Test Sound',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: settings.listTileTextColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  trailing: Icon(
                    CupertinoIcons.play_fill,
                    color: settings.isDarkTheme
                        ? CupertinoColors.activeBlue.darkColor
                        : CupertinoColors.activeBlue,
                    size: 20,
                  ),
                  onTap: () => settings.testNotificationSound(),
                ),
              ],
            ],
          ),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Control sound alerts when sessions end. iOS system sounds are used for notifications.',
        ),
      ],
    );
  }

  /// Show a picker for notification sound types
  void _showSoundPicker(BuildContext context, SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: settings.isDarkTheme
              ? CupertinoColors.systemBackground.darkColor
              : CupertinoColors.systemBackground,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    magnification: 1.2,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: settings.notificationSoundType,
                    ),
                    onSelectedItemChanged: (int selectedItem) {
                      settings.setNotificationSoundType(selectedItem);
                    },
                    children: List<Widget>.generate(
                      _soundNames.length,
                      (int index) {
                        return Center(
                          child: Text(
                            _soundNames[index],
                            style: TextStyle(
                              color: settings.textColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get the sound name from the sound type index
  String _getSoundName(int soundType) {
    if (soundType >= 0 && soundType < _soundNames.length) {
      return _soundNames[soundType];
    }
    return _soundNames[0];
  }

  /// List of available iOS system sound names
  static const List<String> _soundNames = [
    'Tri-tone',
    'Chime',
    'Glass',
    'Horn',
    'Bell',
    'Electronic',
    'Ascending',
    'Descending',
  ];
}
