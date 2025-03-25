import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

/// An animated tile for theme selection
class AnimatedThemeTile extends StatefulWidget {
  final String name;
  final Color color;
  final LinearGradient? gradient;
  final Color? textColor;
  final List<BoxShadow>? boxShadow;

  const AnimatedThemeTile({
    super.key,
    required this.name,
    required this.color,
    this.gradient,
    this.textColor,
    this.boxShadow,
  });

  @override
  State<AnimatedThemeTile> createState() => _AnimatedThemeTileState();
}

class _AnimatedThemeTileState extends State<AnimatedThemeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSelected = settings.selectedTheme == widget.name;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        settings.setTheme(widget.name);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: widget.gradient == null ? widget.color : null,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.boxShadow,
            border: isSelected
                ? Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.textColor ??
                        (widget.color.computeLuminance() > 0.5
                            ? CupertinoColors.black
                            : CupertinoColors.white),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
