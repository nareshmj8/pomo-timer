import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/screens/premium/controllers/premium_controller.dart';
import 'package:pomodoro_timemaster/screens/premium/widgets/premium_debug_menu.dart';
import 'package:pomodoro_timemaster/screens/premium/views/premium_screen_view.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_logs_screen.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/automated_sandbox_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium screen that allows users to subscribe to premium features
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PremiumController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize controller
    _controller = PremiumController(
      animationController: _animationController,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );

    // Initialize RevenueCat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final revenueCatService =
          Provider.of<RevenueCatService>(context, listen: false);
      _controller.initializeRevenueCat(revenueCatService);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revenueCatService = Provider.of<RevenueCatService>(context);
    final isPremium = revenueCatService.isPremium;

    // Add this at the end of the build method, before returning the main widget
    List<Widget> bottomWidgets = [];

    // Add debug options if needed, but removing sandbox testing buttons
    if (kDebugMode) {
      // Debug buttons can be added here if needed in the future
      // But we're removing the sandbox testing buttons as requested
    }

    return PremiumScreenView(
      controller: _controller,
      revenueCatService: revenueCatService,
      isPremium: isPremium,
      onClose: () => Navigator.of(context).pop(),
      onDebugPaywall: _debugPaywall,
      bottomWidgets: bottomWidgets,
    );
  }

  /// Debug the paywall configuration
  void _debugPaywall() {
    final revenueCatService =
        Provider.of<RevenueCatService>(context, listen: false);
    showPremiumDebugMenu(context, revenueCatService, _controller);
  }
}
