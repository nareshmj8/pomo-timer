import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pomodoro_timemaster/animations/confetti_animation.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';

class PremiumSuccessModal extends StatefulWidget {
  final SubscriptionType subscriptionType;

  const PremiumSuccessModal({
    Key? key,
    required this.subscriptionType,
  }) : super(key: key);

  @override
  State<PremiumSuccessModal> createState() => _PremiumSuccessModalState();
}

class _PremiumSuccessModalState extends State<PremiumSuccessModal> {
  late ConfettiAnimation _confettiAnimation;
  bool _showModal = false;

  @override
  void initState() {
    super.initState();

    // Set confetti intensity based on subscription type
    ConfettiIntensity intensity;
    switch (widget.subscriptionType) {
      case SubscriptionType.lifetime:
        intensity = ConfettiIntensity.high;
        break;
      case SubscriptionType.yearly:
        intensity = ConfettiIntensity.medium;
        break;
      default:
        intensity = ConfettiIntensity.low;
    }

    _confettiAnimation = ConfettiAnimation(intensity: intensity);

    // Start confetti animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiAnimation.play();
    });

    // Show modal after confetti starts
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showModal = true;
      });
    });
  }

  @override
  void dispose() {
    _confettiAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return _confettiAnimation.buildConfettiWidget(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          // Dismiss modal if user taps outside
          if (_showModal) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          color: Colors.black.withAlpha((0.5 * 255).toInt()),
          child: Center(
            child: AnimatedOpacity(
              opacity: _showModal ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: _buildModalContent(context, settings),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent(BuildContext context, SettingsProvider settings) {
    final buttonColor = settings.isDarkTheme
        ? CupertinoColors.activeBlue.darkColor
        : CupertinoColors.activeBlue;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: settings.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: buttonColor.withAlpha((0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.star_fill,
              color: buttonColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            "You're now Premium!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: settings.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            _getSuccessMessage(),
            style: TextStyle(
              fontSize: 16,
              color: settings.textColor.withAlpha((0.8 * 255).toInt()),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              "Start Using Premium",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSuccessMessage() {
    switch (widget.subscriptionType) {
      case SubscriptionType.lifetime:
        return "Congratulations! You now have lifetime access to all premium features. Enjoy unlimited premium features forever!";
      case SubscriptionType.yearly:
        return "Thank you for your yearly subscription! Enjoy unlimited premium features for the next 12 months.";
      case SubscriptionType.monthly:
        return "Thank you for your monthly subscription! Enjoy unlimited premium features.";
      default:
        return "Enjoy unlimited premium features.";
    }
  }
}
