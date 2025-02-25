import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

class TimerSettingsScreen extends StatelessWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Timer Settings'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 24),
              _buildSectionHeader('Session Cycle'),
              _buildSessionCounter(context, settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSliderTile(String title, String value, double sliderValue,
      double min, double max, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(value)],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCounter(BuildContext context, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sessions before long break'),
          GestureDetector(
            onTap: () => _showSessionPicker(context, settings),
            child: Row(
              children: [
                Text(
                  settings.sessionsBeforeLongBreak.toString(),
                  style: const TextStyle(color: CupertinoColors.activeBlue),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: CupertinoColors.activeBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionPicker(BuildContext context, SettingsProvider settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                onSelectedItemChanged: (index) =>
                    settings.setSessionsBeforeLongBreak(index + 1),
                scrollController: FixedExtentScrollController(
                  initialItem: settings.sessionsBeforeLongBreak - 1,
                ),
                children: List.generate(
                  8,
                  (index) => Center(
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
