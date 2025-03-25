import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/settings_section_footer.dart';
import 'widgets/settings_list_tile_container.dart';

/// Section for appearance settings
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'Appearance'),
            SettingsListTileContainer(
              child: Column(
                children: [
                  _buildThemeTile(
                    context: context,
                    settings: settings,
                  ),
                ],
              ),
            ),
            const SettingsSectionFooter(
              text: 'Choose between light and dark theme.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required SettingsProvider settings,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          CupertinoSegmentedControl<String>(
            children: const {
              'Light': Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Light'),
              ),
              'Dark': Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Dark'),
              ),
            },
            groupValue: settings.selectedTheme,
            onValueChanged: (value) {
              // Update theme
            },
          ),
        ],
      ),
    );
  }
}
