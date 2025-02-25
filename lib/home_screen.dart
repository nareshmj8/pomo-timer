// Importing necessary packages for Flutter UI, animations, and custom screens
import 'package:flutter/material.dart'; // Core Flutter Material Design widgets
import 'package:flutter/cupertino.dart'; // Cupertino (iOS-style) widgets for platform-specific icons
import 'package:pomo_timer/screens/timer_screen.dart'; // Custom TimerScreen widget
import 'package:pomo_timer/screens/statistics_screen.dart'; // Custom StatisticsScreen widget
import 'package:pomo_timer/screens/history_screen.dart'; // Custom HistoryScreen widget
import 'package:pomo_timer/screens/settings_screen.dart'; // Custom SettingsScreen widget
import 'package:pomo_timer/screens/premium_screen.dart'; // Custom PremiumScreen widget
import 'package:animations/animations.dart'; // Package for custom animations (e.g., PageTransitionSwitcher)

// Defining HomeScreen as a StatefulWidget since it manages state (e.g., selected tab index)
class HomeScreen extends StatefulWidget {
  // Constructor with an optional key for widget identification
  const HomeScreen({super.key});

  // Creates the mutable state for this widget
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State class for HomeScreen, managing navigation and animations
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Mixin provides a single AnimationController ticker
  int _selectedIndex = 0; // Initialize to 0, which is valid
  int _previousIndex =
      0; // Tracks the previously selected tab for animation direction
  late final AnimationController
      _animationController; // Controls the animation timing

  // List of screens to display based on the selected index
  final List<Widget> _screens = [
    const TimerScreen(), // Screen for the timer functionality
    const StatisticsScreen(), // Screen for viewing statistics
    const HistoryScreen(), // Screen for viewing past sessions
    const SettingsScreen(), // Screen for app settings
    const PremiumScreen(), // Screen for premium features or upsell
  ];

  // Initializes state when the widget is first created
  @override
  void initState() {
    super.initState();
    // Setting up the AnimationController with a 400ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Animation duration
      vsync: this, // Links the controller to this State object for ticking
    );
  }

  // Cleans up resources when the widget is removed from the tree
  @override
  void dispose() {
    _animationController
        .dispose(); // Disposes the AnimationController to free memory
    super.dispose(); // Calls the parent dispose method
  }

  // Builds the UI for the HomeScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main content area with animated transitions between screens
      body: PageTransitionSwitcher(
        // Defines how the transition between screens looks
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SlideTransition(
            // Animates the new screen sliding in from left or right
            position: animation.drive(
              Tween<Offset>(
                // Start position depends on whether we're moving forward or backward in tabs
                begin:
                    Offset(_previousIndex < _selectedIndex ? 1.0 : -1.0, 0.0),
                end: Offset.zero, // Ends at the center (fully visible)
              ).chain(
                  CurveTween(curve: Curves.easeInOut)), // Smooth easing curve
            ),
            // Nested SlideTransition for the outgoing screen
            child: SlideTransition(
              // Animates the old screen sliding out
              position: secondaryAnimation.drive(
                Tween<Offset>(
                  begin: Offset.zero, // Starts at center
                  // Exits to left or right based on direction
                  end:
                      Offset(_previousIndex < _selectedIndex ? -1.0 : 1.0, 0.0),
                ).chain(
                    CurveTween(curve: Curves.easeInOut)), // Smooth easing curve
              ),
              child: child, // The actual screen widget being transitioned
            ),
          );
        },
        // The current screen to display, with a unique key to trigger transitions
        child: KeyedSubtree(
          key: ValueKey<int>(
              _selectedIndex), // Key changes when index changes, triggering animation
          child: _screens[_selectedIndex], // Displays the selected screen
        ),
      ),
      // Bottom navigation bar for switching between screens
      bottomNavigationBar: NavigationBar(
        animationDuration:
            const Duration(milliseconds: 600), // Animation for selection
        selectedIndex: _selectedIndex, // Highlights the current tab
        // Called when a new destination (tab) is selected
        onDestinationSelected: (index) {
          setState(() {
            // Updates the state to rebuild the UI
            _previousIndex =
                _selectedIndex; // Stores the old index for animation
            _selectedIndex = index; // Updates to the new index
            _animationController.forward(
                from: 0); // Starts the animation from the beginning
          });
        },
        // List of navigation tabs with icons and labels
        destinations: [
          NavigationDestination(
            // Icon adapts to platform (iOS uses Cupertino, Android uses Material)
            icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoIcons.timer
                : Icons.timer),
            label: 'Timer', // Label below the icon
          ),
          NavigationDestination(
            icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoIcons.graph_square
                : Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoIcons.clock
                : Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoIcons.settings
                : Icons.settings),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoIcons.star
                : Icons.star),
            label: 'Premium',
          ),
        ],
      ),
    );
  }
}
