import 'package:flutter/cupertino.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  void _showCategoryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Category'),
          actions: categories
              .map((category) => CupertinoActionSheetAction(
                    onPressed: () {
                      onCategoryChanged(category);
                      Navigator.pop(context);
                    },
                    child: Text(category),
                  ))
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Category:',
            style: TextStyle(fontSize: 16, color: CupertinoColors.black),
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
    );
  }
}
