import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../screens/premium/testing/sandbox_testing_helper.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final revenueCatService =
        Provider.of<RevenueCatService>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'About',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              _buildAboutItem(
                context,
                'Version',
                '1.0.0',
                theme,
              ),
              _buildAboutItem(
                context,
                'Rate App',
                'Leave a review on the App Store',
                theme,
                showChevron: true,
                onTap: () {
                  // Handle rate app flow
                },
              ),
              _buildAboutItem(
                context,
                'Privacy Policy',
                'Read our privacy policy',
                theme,
                showChevron: true,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              _buildAboutItem(
                context,
                'Terms of Service',
                'Read our terms of service',
                theme,
                showChevron: true,
                onTap: () {
                  // Navigate to terms of service
                },
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Developer',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: Column(
            children: [
              _buildAboutItem(
                context,
                'StoreKit Testing',
                'Test in-app purchases in sandbox mode',
                theme,
                showChevron: true,
                onTap: () {
                  SandboxTestingHelper.showSandboxTestingUI(context);
                },
              ),
              _buildAboutItem(
                context,
                'Test Monthly Subscription',
                'Run a sandbox purchase test for monthly plan',
                theme,
                showChevron: true,
                onTap: () {
                  SandboxTestingHelper.simulateSandboxPurchase(context,
                      revenueCatService, RevenueCatProductIds.monthlyId);
                },
              ),
              _buildAboutItem(
                context,
                'View Sandbox Logs',
                'View detailed logs from purchase tests',
                theme,
                showChevron: true,
                onTap: () {
                  SandboxTestingHelper.showSandboxLogs(context);
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    String title,
    String subtitle,
    ThemeProvider theme, {
    bool showChevron = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: !isLast
              ? BorderSide(
                  color: theme.separatorColor,
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16.0),
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.listTileTextColor,
                      fontSize: ThemeConstants.bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: ThemeConstants.captionFontSize,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                CupertinoIcons.right_chevron,
                color: theme.secondaryTextColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
