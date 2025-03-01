// Importing necessary packages for Flutter UI, animations, and custom screens
import 'package:flutter/material.dart'; // Core Flutter Material Design widgets
import 'package:flutter/cupertino.dart'; // Cupertino (iOS-style) widgets for platform-specific icons
import 'package:pomo_timer/screens/timer_screen.dart'; // Custom TimerScreen widget
import 'package:pomo_timer/screens/statistics_screen.dart'; // Custom StatisticsScreen widget
import 'package:pomo_timer/screens/history_screen.dart'; // Custom HistoryScreen widget
import 'package:pomo_timer/screens/settings_screen.dart'; // Custom SettingsScreen widget
import 'package:pomo_timer/screens/premium_screen.dart'; // Custom PremiumScreen widget
import 'package:animations/animations.dart'; // Package for custom animations (e.g., PageTransitionSwitcher)
import 'package:provider/provider.dart';
import 'package:pomo_timer/providers/settings_provider.dart';

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
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: settings.backgroundColor,
          body: PageTransitionSwitcher(
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: Offset(
                        _previousIndex < _selectedIndex ? 1.0 : -1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: SlideTransition(
                  position: secondaryAnimation.drive(
                    Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(
                          _previousIndex < _selectedIndex ? -1.0 : 1.0, 0.0),
                    ).chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: settings.selectedTheme == 'Light'
                      ? CupertinoColors.separator
                      : settings.backgroundColor
                          .withAlpha(77), // 0.3 * 255 ≈ 77
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              backgroundColor: settings.selectedTheme == 'Light'
                  ? CupertinoColors.systemBackground
                  : settings.backgroundColor,
              surfaceTintColor: Colors.transparent,
              indicatorColor: settings.selectedTheme == 'Light'
                  ? CupertinoColors.systemFill
                  : settings.backgroundColor.withAlpha(77),
              shadowColor: Colors.transparent,
              height: 65,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _previousIndex = _selectedIndex;
                  _selectedIndex = index;
                  _animationController.forward(from: 0);
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    CupertinoIcons.timer,
                    color: _selectedIndex == 0
                        ? CupertinoColors.activeBlue
                        : settings.selectedTheme == 'Light'
                            ? CupertinoColors.inactiveGray
                            : settings.textColor
                                .withAlpha(204), // 0.8 * 255 ≈ 204
                  ),
                  label: 'Timer',
                ),
                NavigationDestination(
                  icon: Icon(
                    CupertinoIcons.graph_square,
                    color: _selectedIndex == 1
                        ? CupertinoColors.activeBlue
                        : settings.selectedTheme == 'Light'
                            ? CupertinoColors.inactiveGray
                            : settings.textColor.withAlpha(204),
                  ),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(
                    CupertinoIcons.clock,
                    color: _selectedIndex == 2
                        ? CupertinoColors.activeBlue
                        : settings.selectedTheme == 'Light'
                            ? CupertinoColors.inactiveGray
                            : settings.textColor.withAlpha(204),
                  ),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(
                    CupertinoIcons.settings,
                    color: _selectedIndex == 3
                        ? CupertinoColors.activeBlue
                        : settings.selectedTheme == 'Light'
                            ? CupertinoColors.inactiveGray
                            : settings.textColor.withAlpha(204),
                  ),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Icon(
                    CupertinoIcons.star,
                    color: _selectedIndex == 4
                        ? CupertinoColors.activeBlue
                        : settings.selectedTheme == 'Light'
                            ? CupertinoColors.inactiveGray
                            : settings.textColor.withAlpha(204),
                  ),
                  label: 'Premium',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
