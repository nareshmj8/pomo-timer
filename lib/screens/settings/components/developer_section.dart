import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/sections/iap_diagnostics_section.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

/// Developer section of the settings screen
class DeveloperSection extends StatelessWidget {
  const DeveloperSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Developer'),
        _buildListTileContainer(
          context: context,
          children: [
            _buildPremiumToggle(context),
            _buildNavigationTile(
              context: context,
              title: 'IAP Testing',
              onTap: () {
                Navigator.of(context).pushNamed('/iap_test');
              },
            ),
            _buildNavigationTile(
              context: context,
              title: 'RevenueCat Testing',
              onTap: () {
                Navigator.of(context).pushNamed('/revenue_cat_test');
              },
            ),
            _buildNavigationTile(
              context: context,
              title: 'IAP Diagnostics',
              onTap: () {
                _showIAPDiagnostics(context);
              },
            ),
          ],
        ),
        _buildSectionFooter('Tools for testing and development.'),
      ],
    );
  }

  Widget _buildPremiumToggle(BuildContext context) {
    return Consumer<RevenueCatService>(
      builder: (context, revenueCatService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Premium Access (Dev)',
                style: TextStyle(fontSize: 16),
              ),
              CupertinoSwitch(
                value: revenueCatService.isPremium,
                onChanged: (value) {
                  _toggleDevPremiumAccess(context, value);
                },
                activeTrackColor: CupertinoColors.activeBlue,
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDevPremiumAccess(BuildContext context, bool enable) {
    final revenueCatService =
        Provider.of<RevenueCatService>(context, listen: false);

    if (enable) {
      // Show confirmation dialog
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Enable Premium Access'),
          content: const Text(
              'This will enable premium features for development purposes only. '
              'This setting is for testing and will not persist after app restart.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Enable'),
              onPressed: () {
                revenueCatService.enableDevPremiumAccess();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      revenueCatService.disableDevPremiumAccess();
    }
  }

  void _showIAPDiagnostics(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: settings.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'IAP Diagnostics',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: settings.textColor,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              'Close',
              style: TextStyle(
                color: settings.isDarkTheme
                    ? CupertinoColors.activeBlue.darkColor
                    : CupertinoColors.activeBlue,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: settings.backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: settings.separatorColor,
              width: 0.5,
            ),
          ),
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            child: IAPDiagnosticsSection(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 35, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildListTileContainer({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionFooter(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
