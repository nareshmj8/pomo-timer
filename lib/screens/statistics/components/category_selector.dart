import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';

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
        final theme = context.watch<ThemeProvider>().currentTheme;
        return CupertinoActionSheet(
          title:
              Text('Select Category', style: TextStyle(color: theme.textColor)),
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
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Category:',
            style: TextStyle(fontSize: 16, color: theme.textColor),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showCategoryPicker(context),
            child: Row(
              children: [
                Text(
                  selectedCategory,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: theme.textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
