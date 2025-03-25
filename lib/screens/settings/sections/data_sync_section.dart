import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../services/sync_service.dart';
import '../../../widgets/sync_status_indicator.dart';

class DataSyncSection extends StatelessWidget {
  const DataSyncSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final syncService = Provider.of<SyncService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Data Sync',
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
              _buildSyncToggle(
                context,
                'iCloud Sync',
                'Sync your data across devices',
                syncService.iCloudSyncEnabled,
                theme,
                onChanged: (value) async {
                  await syncService.setSyncEnabled(value);
                },
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              SyncNowButton(
                label: 'Sync Now',
                height: 44.0,
                onPressed:
                    syncService.isPremium ? () => syncService.syncData() : null,
              ),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SyncStatusIndicator(
                  detailed: true,
                  showProgressBar: true,
                  showBorder: true,
                  backgroundColor: Color.fromRGBO(
                    theme.backgroundColor.red,
                    theme.backgroundColor.green,
                    theme.backgroundColor.blue,
                    0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!syncService.isPremium) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                CupertinoColors.systemYellow.red,
                CupertinoColors.systemYellow.green,
                CupertinoColors.systemYellow.blue,
                0.2,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
              border: Border.all(
                color: CupertinoColors.systemYellow,
                width: 1.0,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  color: CupertinoColors.systemYellow,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Premium subscription required for iCloud sync',
                    style: TextStyle(
                      fontSize: ThemeConstants.captionFontSize,
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSyncToggle(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ThemeProvider theme, {
    bool isLast = false,
    required Function(bool) onChanged,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.listTileTextColor,
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
            CupertinoSwitch(
              value: value,
              onChanged: (bool newValue) => onChanged(newValue),
              activeTrackColor: CupertinoColors.activeBlue,
            ),
          ],
        ),
      ),
    );
  }
}
