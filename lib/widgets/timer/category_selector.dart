import 'package:flutter/cupertino.dart';
import '../../providers/settings_provider.dart';

class CategorySelector extends StatelessWidget {
  final SettingsProvider settings;
  final List<String> categories;

  const CategorySelector({
    super.key,
    required this.settings,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Category:',
          style: TextStyle(
            fontSize: 17,
            color: CupertinoColors.label,
          ),
        ),
        GestureDetector(
          onTap: () => showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: const Text('Select Category'),
                actions: categories
                    .map(
                      (category) => CupertinoActionSheetAction(
                        onPressed: () {
                          settings.setSelectedCategory(category);
                          Navigator.pop(context);
                        },
                        child: Text(
                          category,
                          style: TextStyle(color: CupertinoColors.black),
                        ),
                      ),
                    )
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: CupertinoColors.systemRed)),
                ),
              );
            },
          ),
          child: Row(
            children: [
              Text(
                settings.selectedCategory,
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
