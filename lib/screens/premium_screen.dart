import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/theme_provider.dart';

// StatelessWidget for a static premium features screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen(
      {super.key}); // Constructor with optional key, marked const for optimization

  @override
  Widget build(BuildContext context) {
    // CupertinoPageScaffold provides an iOS-style page layout
    return CupertinoPageScaffold(
      backgroundColor: Provider.of<ThemeProvider>(context).backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Go Premium',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Provider.of<ThemeProvider>(context).textColor,
          ),
        ),
        backgroundColor: Provider.of<ThemeProvider>(context).backgroundColor,
        border: null,
      ),
      // SafeArea ensures content avoids system UI (e.g., notch, home indicator)
      child: SafeArea(
        // Padding adds consistent spacing around content
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 16px padding on all sides
          // Column arranges content vertically
          child: Column(
            children: [
              // Expanded takes up all available vertical space for scrollable content
              Expanded(
                // SingleChildScrollView enables scrolling if content overflows
                child: SingleChildScrollView(
                  // Inner Column for premium feature content
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to the left
                    children: [
                      const SizedBox(height: 24), // Vertical spacing at the top
                      // Centered premium icon
                      const Center(
                        child: Icon(
                          CupertinoIcons.star_fill, // Filled star icon
                          size: 80, // Large size for emphasis
                          color: CupertinoColors.systemYellow, // Yellow color
                        ),
                      ),
                      const SizedBox(height: 24), // Spacing after icon
                      // Centered title text
                      Center(
                        child: Text(
                          'Unlock Premium Features', // Main heading
                          style: TextStyle(
                            fontSize: 24, // Large text
                            fontWeight: FontWeight.bold, // Bold for emphasis
                            color:
                                Provider.of<ThemeProvider>(context).textColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 32), // Larger spacing before benefits
                      // List of premium benefits using _buildBenefitItem
                      _buildBenefitItem(
                        context,
                        CupertinoIcons.checkmark_circle_fill,
                        'Ad-free Experience',
                        'Enjoy uninterrupted focus sessions',
                      ),
                      const SizedBox(height: 16), // Spacing between items
                      _buildBenefitItem(
                        context,
                        CupertinoIcons.paintbrush_fill,
                        'Exclusive Themes',
                        'Access beautiful custom themes',
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        context,
                        CupertinoIcons.chart_bar_fill,
                        'Detailed Statistics',
                        'Get insights into your productivity',
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        context,
                        CupertinoIcons.cloud_upload_fill,
                        'Backup',
                        'Import or export your data',
                      ),
                    ],
                  ),
                ),
              ),
              // Upgrade button at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0), // Vertical padding
                child: SizedBox(
                  width: double.infinity, // Full-width button
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue, // Blue background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Vertical padding
                    onPressed: () {
                      // Placeholder for upgrade action (e.g., payment processing)
                      // TODO: Implement purchase logic here
                    },
                    pressedOpacity: 0.7, // Slightly dim when pressed
                    child: const Text(
                      'Upgrade Now', // Button text
                      style: TextStyle(
                        fontSize: 18, // Larger text
                        fontWeight: FontWeight.w600, // Semi-bold
                        color: CupertinoColors.white, // White text
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a benefit card with icon, title, and description
  Widget _buildBenefitItem(
      BuildContext context, IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16), // Inner padding for content
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      // Row arranges icon and text horizontally
      child: Row(
        children: [
          // Icon on the left
          Icon(
            icon, // Provided icon (e.g., checkmark, paintbrush)
            color: CupertinoColors.activeBlue, // Blue color
            size: 28, // Moderate size
          ),
          const SizedBox(width: 16), // Spacing between icon and text
          // Expanded ensures text takes remaining space
          Expanded(
            // Column stacks title and description vertically
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the left
              children: [
                // Benefit title
                Text(
                  title, // Main text (e.g., "Ad-free Experience")
                  style: const TextStyle(
                    fontSize: 16, // Moderate size
                    fontWeight: FontWeight.w600, // Semi-bold
                  ),
                ),
                const SizedBox(
                    height: 4), // Small gap between title and description
                // Benefit description
                Text(
                  description, // Explanation text (e.g., "Enjoy uninterrupted focus sessions")
                  style: const TextStyle(
                    fontSize: 14, // Smaller size
                    color: CupertinoColors
                        .secondaryLabel, // Gray for secondary text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
