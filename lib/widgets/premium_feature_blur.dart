import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/utils/theme_constants.dart';

class PremiumFeatureBlur extends StatelessWidget {
  final Widget child;
  final String featureName;
  final double blurAmount;
  final VoidCallback? onTap;

  const PremiumFeatureBlur({
    super.key,
    required this.child,
    required this.featureName,
    this.blurAmount = 5.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RevenueCatService>(
      builder: (context, revenueCatService, _) {
        // If user is premium, show the feature without blur
        if (revenueCatService.isPremium) {
          return child;
        }

        // Otherwise, show blurred version with upgrade prompt
        return Stack(
          children: [
            // Blurred content
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurAmount,
                sigmaY: blurAmount,
              ),
              child: child,
            ),

            // Overlay to make it tap-able
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap ??
                      () {
                        // Show premium upgrade dialog
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Premium Feature'),
                            content: Text(
                                '$featureName is available with Premium. Upgrade to unlock this feature.'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Not Now'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                child: const Text('Upgrade'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate to premium screen
                                  Navigator.of(context).pushNamed('/premium');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground
                            .withAlpha(ThemeConstants.opacityToAlpha(0.7)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CupertinoColors.activeBlue,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.lock,
                            color: CupertinoColors.activeBlue,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Premium Feature',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
