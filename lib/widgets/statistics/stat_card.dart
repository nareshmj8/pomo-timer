import 'package:flutter/cupertino.dart';

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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? CupertinoColors.black.withOpacity(0.2)
                  : CupertinoColors.systemGrey5.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? CupertinoColors.systemGrey6.withOpacity(0.2)
                : CupertinoColors.systemGrey5.withOpacity(0.3),
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
                letterSpacing: 0.5,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              showHours ? _formatDuration(value) : value.round().toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (showHours
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGreen)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                showHours ? 'Duration' : 'Sessions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (showHours
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGreen)
                      .resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
