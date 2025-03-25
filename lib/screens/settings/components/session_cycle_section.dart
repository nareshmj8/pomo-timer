import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';

/// Session cycle section of the settings screen
class SessionCycleSection extends StatefulWidget {
  const SessionCycleSection({Key? key}) : super(key: key);

  @override
  SessionCycleSectionState createState() => SessionCycleSectionState();
}

class SessionCycleSectionState extends State<SessionCycleSection> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Session Cycle'),
        SettingsUIComponents.buildListTileContainer(
          child: CupertinoListTile(
            title: Text(
              'Sessions before long break',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: settings.listTileTextColor,
                letterSpacing: -0.3,
              ),
            ),
            trailing: GestureDetector(
              onTap: () => _showSessionsPicker(context, settings),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.sessionsBeforeLongBreak.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: settings.isDarkTheme
                        ? CupertinoColors.activeBlue.darkColor
                        : CupertinoColors.activeBlue,
                  ),
                ],
              ),
            ),
          ),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Number of focus sessions to complete before taking a long break.',
        ),
      ],
    );
  }

  /// Shows a sessions picker
  void _showSessionsPicker(BuildContext context, SettingsProvider settings) {
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
                    handlePickerChange(index);
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

  /// Handles picker value change - used directly in tests
  void handlePickerChange(int index) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setSessionsBeforeLongBreak(index + 1);
  }
}
