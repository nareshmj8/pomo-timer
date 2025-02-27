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
      return '${displayMinutes}M';
    } else if (displayMinutes == 0) {
      return '${displayHours}H';
    } else {
      return '${displayHours}H${displayMinutes}M';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayValue =
        showHours ? _formatDuration(value) : value.round().toString();
    String displayTitle = title.toUpperCase();

    // Make card height responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.12; // 12% of screen height

    return Expanded(
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey6.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 0.5,
                color: CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 24,
                color: CupertinoColors.label,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
