import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double value;
  final bool showHours;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.showHours,
  });

  String _formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();
    int displayHours = totalMinutes ~/ 60;
    int displayMinutes = totalMinutes % 60;

    if (displayHours == 0) {
      return '${displayMinutes}m';
    } else if (displayMinutes == 0) {
      return '${displayHours}h';
    } else {
      return '${displayHours}h ${displayMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 18.0,
            ),
            decoration: BoxDecoration(
              color: settings.listTileBackgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: settings.separatorColor.withOpacity(0.12),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: settings.separatorColor.withOpacity(0.15),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.2,
                    color: settings.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  showHours ? _formatDuration(value) : value.round().toString(),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: settings.textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (showHours
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGreen)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (showHours
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGreen)
                          .withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    showHours ? 'Duration' : 'Sessions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: showHours
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGreen,
                      letterSpacing: -0.3,
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
}
