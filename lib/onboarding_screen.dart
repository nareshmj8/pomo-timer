import 'package:flutter/material.dart'; // Core Flutter widgets (e.g., Icons, Text)
import 'package:carousel_slider/carousel_slider.dart'; // Carousel slider package
import 'package:flutter/cupertino.dart'; // iOS-style widgets (e.g., CupertinoButton)

// Stateful widget for onboarding screen with dynamic state (carousel index)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key}); // Constructor with optional key

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState(); // Creates state
}

// State class managing carousel and UI
class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0; // Tracks the current slide index
  final CarouselSliderController _controller =
      CarouselSliderController(); // Controls carousel navigation
  // List of slides with title, description, and icon data
  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Boost Your Focus', // Slide 1 title
      'description':
          'Use the Pomodoro technique to maximize productivity.', // Slide 1 description
      'icon': Icons.timer_outlined, // Material icon for timer
    },
    {
      'title': 'Track Your Progress', // Slide 2 title
      'description':
          'View detailed stats for daily, weekly, and monthly sessions.', // Slide 2 description
      'icon': Icons.bar_chart, // Material icon for stats
    },
    {
      'title': 'Customize Your Experience', // Slide 3 title
      'description':
          'Adjust durations, pick calming themes, and more.', // Slide 3 description
      'icon': Icons.settings, // Material icon for settings
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen dimensions
    final padding =
        MediaQuery.of(context).padding; // Get system padding (e.g., notch)

    // CupertinoPageScaffold provides an iOS-style base layout
    return CupertinoPageScaffold(
      child: Stack(
        // Stack layers carousel, dots, skip, and navigation buttons
        children: [
          // CarouselSlider.builder creates a scrollable carousel
          CarouselSlider.builder(
            itemCount: _slides.length, // Number of slides
            carouselController:
                _controller, // Links to controller for programmatic navigation
            itemBuilder: (context, index, realIndex) {
              // Builds each slide's content
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        size.width * 0.08), // Responsive horizontal padding
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  children: [
                    Icon(
                      _slides[index]['icon'], // Slide-specific icon
                      size: size.width *
                          0.25, // Responsive icon size (25% of screen width)
                      color: Colors.blueAccent, // Blue color for icon
                    ),
                    SizedBox(
                        height:
                            size.height * 0.02), // Responsive vertical spacing
                    Text(
                      _slides[index]
                          ['title']!, // Slide title (non-null assertion)
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width *
                            0.06, // Responsive font size (6% of width)
                        fontWeight: FontWeight.bold, // Bold text
                        decoration: TextDecoration.none, // No underline
                      ),
                      textAlign: TextAlign.center, // Centered text
                    ),
                    SizedBox(height: size.height * 0.02), // Spacing
                    Text(
                      _slides[index]['description']!, // Slide description
                      textAlign: TextAlign.center, // Centered text
                      style: TextStyle(
                        fontSize:
                            size.width * 0.04, // Smaller responsive font size
                        color: Colors.black,
                        fontWeight: FontWeight.normal, // Regular weight
                        decoration: TextDecoration.none, // No underline
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: size.height, // Full screen height
              viewportFraction: 1.0, // Each slide takes full width
              onPageChanged: (index, reason) {
                // Update current index when slide changes
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),

          // Dot indicators showing carousel progress
          Positioned(
            bottom: size.height * 0.15, // 15% from bottom
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center dots horizontally
              children: _slides.asMap().entries.map((entry) {
                // Create a dot for each slide
                return Container(
                  width: size.width * 0.02, // Small responsive width
                  height: size.width * 0.02, // Small responsive height
                  margin: EdgeInsets.symmetric(
                      horizontal: size.width * 0.01), // Spacing between dots
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Circular shape
                    color: Colors.blue.withAlpha(
                      _currentIndex == entry.key
                          ? 229
                          : 102, // Opaque for current, semi-transparent for others
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Skip button at top-right
          Positioned(
            top: padding.top +
                size.height * 0.02, // Below top padding, 2% from top
            right: size.width * 0.05, // 5% from right edge
            child: CupertinoButton(
              padding: EdgeInsets.zero, // No extra padding
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/home'), // Navigate to home screen
              child: Text(
                'Skip', // Button text
                style: TextStyle(
                  color: CupertinoColors.activeBlue, // Blue text
                  fontSize: size.width * 0.04, // Responsive font size
                ),
              ),
            ),
          ),

          // Navigation button (Next or Done) at bottom-right
          Positioned(
            bottom: size.height * 0.05, // 5% from bottom
            right: size.width * 0.05, // 5% from right
            child: _currentIndex == _slides.length - 1
                ? CupertinoButton(
                    // Done button on last slide
                    padding:
                        EdgeInsets.all(size.width * 0.04), // Responsive padding
                    color: CupertinoColors.activeBlue, // Blue background
                    borderRadius: BorderRadius.circular(
                        size.width * 0.06), // Rounded corners
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/home'), // Go to home
                    child: Icon(
                      CupertinoIcons.check_mark, // Checkmark icon
                      color: CupertinoColors.white, // White icon
                      size: size.width * 0.06, // Responsive size
                    ),
                  )
                : CupertinoButton(
                    // Next button on earlier slides
                    padding:
                        EdgeInsets.all(size.width * 0.04), // Responsive padding
                    color: CupertinoColors.activeBlue, // Blue background
                    borderRadius: BorderRadius.circular(
                        size.width * 0.06), // Rounded corners
                    onPressed: () {
                      // Move to next slide with animation
                      _controller.nextPage(
                        duration: const Duration(
                            milliseconds: 300), // 300ms transition
                        curve: Curves.linear, // Linear animation curve
                      );
                    },
                    child: Icon(
                      CupertinoIcons.chevron_right, // Right arrow icon
                      color: CupertinoColors.white, // White icon
                      size: size.width * 0.06, // Responsive size
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
