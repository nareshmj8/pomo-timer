import 'package:flutter/cupertino.dart';

class StatisticsHeader extends StatelessWidget {
  final String selectedCategory;
  final bool showHours;
  final Function(String) onCategoryChanged;
  final Function(bool) onShowHoursChanged;

  const StatisticsHeader({
    super.key,
    required this.selectedCategory,
    required this.showHours,
    required this.onCategoryChanged,
    required this.onShowHoursChanged,
  });

  void _showCategoryPicker(BuildContext context) {
    final categories = ['All Categories', 'Work', 'Study', 'Life'];

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Category'),
          actions: categories
              .map(
                (category) => CupertinoActionSheetAction(
                  onPressed: () {
                    onCategoryChanged(category);
                    Navigator.pop(context);
                  },
                  child: Text(category),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category:',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.black,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showCategoryPicker(context),
                child: Row(
                  children: [
                    Text(
                      selectedCategory,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
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
        ),
        _buildToggleButtons(),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
              'Hours', showHours, () => onShowHoursChanged(true)),
          _buildToggleButton(
              'Sessions', !showHours, () => onShowHoursChanged(false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isSelected
              ? CupertinoColors.activeBlue
              : CupertinoColors.inactiveGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
