import 'package:flutter/cupertino.dart';

class ToggleButtons extends StatelessWidget {
  final bool showHours;
  final Function(bool) onToggle;

  const ToggleButtons({
    super.key,
    required this.showHours,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton('Hours', showHours, () => onToggle(true)),
        _buildToggleButton('Sessions', !showHours, () => onToggle(false)),
      ],
    );
  }

  Widget _buildToggleButton(
      String text, bool isActive, VoidCallback onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isActive
              ? CupertinoColors.activeBlue
              : CupertinoColors.inactiveGray,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
