import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// SplashScreen widget that displays a smooth transition from the native iOS splash screen.
///
/// This implementation ensures a seamless transition from the native iOS splash screen
/// by positioning the Flutter logo exactly where the native logo appears.
/// This creates a continuous experience without any jarring logo jumps or disappearances.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _brandingFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Remove the native splash screen
    FlutterNativeSplash.remove();

    // Optimize for performance by setting system UI overlay style
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    // Set up animation controller with precise timing for smooth animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create fade-in animation for the background
    // Start at 1.0 to match the native splash screen background
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Create fade-in animation for the logo
    // Starting at 1.0 opacity since it should already be visible from native splash
    _logoFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    // Create fade-in animation for the branding text
    _brandingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    // Start the animation immediately
    _animationController.forward();

    // Navigate to home screen after animation completes
    // Using a slightly longer delay to ensure smooth transition
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness from CupertinoTheme
    final brightness = CupertinoTheme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Set background color based on theme
    final backgroundColor = isDarkMode
        ? const Color(0xFF121212) // Dark gray for dark mode
        : CupertinoColors.white;

    // Set text color based on theme
    final textColor = isDarkMode
        ? CupertinoColors.white
        : const Color(0xFF333333); // Dark gray for light mode

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      // Disable focus traversal to prevent focus issues during splash screen
      child: ExcludeFocus(
        excluding: true,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with fade animation
                    // Positioned exactly where the native splash screen logo appears
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isDarkMode)
                              BoxShadow(
                                color: const Color(0xFF3D5AFE)
                                    .withAlpha((0.3 * 255).toInt()),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/appstore.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // App name with fade animation
                    FadeTransition(
                      opacity: _brandingFadeAnimation,
                      child: Text(
                        'Pomodoro TimeMaster',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline with fade animation
                    FadeTransition(
                      opacity: _brandingFadeAnimation,
                      child: Text(
                        'Master Your Time, Master Your Life',
                        style: TextStyle(
                          color: textColor.withAlpha((0.7 * 255).toInt()),
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
