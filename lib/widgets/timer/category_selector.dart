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
        Text(
          'Category:',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: settings.textColor,
            letterSpacing: -0.5,
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          color: settings.listTileBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          onPressed: () => showCupertinoModalPopup<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoActionSheet(
                title: Text(
                  'Select Category',
                  style: TextStyle(
                    color: settings.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                message: Text(
                  'Choose a category for your focus session',
                  style: TextStyle(
                    color: settings.secondaryTextColor,
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
                ),
                actions: categories
                    .map(
                      (category) => CupertinoActionSheetAction(
                        onPressed: () {
                          settings.setSelectedCategory(category);
                          Navigator.pop(context);
                        },
                        isDefaultAction: category == settings.selectedCategory,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: category == settings.selectedCategory
                                ? CupertinoColors.activeBlue
                                : settings.textColor,
                            fontSize: 17,
                            fontWeight: category == settings.selectedCategory
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: settings.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.selectedCategory,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_down,
                  size: 14,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
