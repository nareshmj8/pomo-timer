import 'package:flutter/cupertino.dart';

// StatelessWidget for a static premium features screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen(
      {super.key}); // Constructor with optional key, marked const for optimization

  @override
  Widget build(BuildContext context) {
    // CupertinoPageScaffold provides an iOS-style page layout
    return CupertinoPageScaffold(
      // Navigation bar at the top of the screen
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Go Premium'), // Title centered in the bar
        backgroundColor:
            CupertinoColors.systemBackground, // iOS white background
        border: null, // No bottom border for a clean look
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
                      const Center(
                        child: Text(
                          'Unlock Premium Features', // Main heading
                          style: TextStyle(
                            fontSize: 24, // Large text
                            fontWeight: FontWeight.bold, // Bold for emphasis
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 32), // Larger spacing before benefits
                      // List of premium benefits using _buildBenefitItem
                      _buildBenefitItem(
                        CupertinoIcons.checkmark_circle_fill, // Checkmark icon
                        'Ad-free Experience', // Benefit title
                        'Enjoy uninterrupted focus sessions', // Description
                      ),
                      const SizedBox(height: 16), // Spacing between items
                      _buildBenefitItem(
                        CupertinoIcons.paintbrush_fill, // Paintbrush icon
                        'Exclusive Themes', // Benefit title
                        'Access beautiful custom themes', // Description
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        CupertinoIcons.chart_bar_fill, // Chart icon
                        'Detailed Statistics', // Benefit title
                        'Get insights into your productivity', // Description
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        CupertinoIcons.cloud_upload_fill, // Cloud icon
                        'Backup', // Benefit title
                        'Import or export your data', // Description
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
  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16), // Inner padding for content
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6, // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
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
