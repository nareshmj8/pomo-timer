import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

class TimerSettingsScreen extends StatelessWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) => CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        navigationBar: const CupertinoNavigationBar(
          middle: Text(
            'Timer Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
          backgroundColor: CupertinoColors.black,
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.white,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Timer Durations'),
                _buildSliderTile(
                  'Session Duration',
                  '${settings.sessionDuration.round()} min',
                  settings.sessionDuration,
                  1.0,
                  120.0,
                  (value) => settings.setSessionDuration(value),
                ),
                _buildSliderTile(
                  'Short Break',
                  '${settings.shortBreakDuration.round()} min',
                  settings.shortBreakDuration,
                  1,
                  30,
                  (value) => settings.setShortBreakDuration(value),
                ),
                _buildSliderTile(
                  'Long Break',
                  '${settings.longBreakDuration.round()} min',
                  settings.longBreakDuration,
                  5,
                  45,
                  (value) => settings.setLongBreakDuration(value),
                ),
                _buildSectionHeader('Session Cycle'),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoListTile(
                    title: const Text(
                      'Sessions before long break',
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.white,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _showSessionsPicker(context, settings),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            settings.sessionsBeforeLongBreak.toString(),
                            style: const TextStyle(
                              fontSize: 17,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 32.0,
        bottom: 10.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    double sliderValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.white,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: CupertinoColors.white,
          ),
        ],
      ),
    );
  }

  void _showSessionsPicker(BuildContext context, SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          color: CupertinoColors.black,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: CupertinoColors.black,
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.white,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: CupertinoColors.black,
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
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.white,
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
}
