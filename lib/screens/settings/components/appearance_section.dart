import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/screens/settings/components/settings_ui_components.dart';
import 'package:pomodoro_timemaster/widgets/premium_feature_blur.dart';

/// Appearance section of the settings screen
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUIComponents.buildSectionHeader('Appearance'),
        SettingsUIComponents.buildListTileContainer(
          child: PremiumFeatureBlur(
            featureName: 'Custom Themes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Choose a theme for your app',
                    style: TextStyle(
                      fontSize: 14,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildThemeTile(
                        name: 'Light',
                        color: CupertinoColors.white,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CupertinoColors.white,
                            CupertinoColors.systemGrey6,
                          ],
                        ),
                        textColor: CupertinoColors.label,
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey5
                                .withAlpha((0.5 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      _buildThemeTile(
                        name: 'Dark',
                        color: const Color(0xFF1C1C1E),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1C1C1E),
                            Color(0xFF2C2C2E),
                          ],
                        ),
                        textColor: CupertinoColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C1C1E)
                                .withAlpha((0.3 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      _buildThemeTile(
                        name: 'Citrus Orange',
                        color: const Color(0xFFFFD9A6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD9A6)
                                .withAlpha((0.3 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      _buildThemeTile(
                        name: 'Rose Quartz',
                        color: const Color(0xFFF8C8D7),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF8C8D7)
                                .withAlpha((0.3 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      _buildThemeTile(
                        name: 'Seafoam Green',
                        color: const Color(0xFFD9F2E6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD9F2E6)
                                .withAlpha((0.3 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      _buildThemeTile(
                        name: 'Lavender Mist',
                        color: const Color(0xFFE6D9F2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE6D9F2)
                                .withAlpha((0.3 * 255).toInt()),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SettingsUIComponents.buildSectionFooter(
          'Choose a theme that matches your style.',
        ),
      ],
    );
  }

  /// Builds a theme selection tile with animation and haptic feedback
  Widget _buildThemeTile({
    required String name,
    required Color color,
    LinearGradient? gradient,
    Color? textColor,
    List<BoxShadow>? boxShadow,
  }) {
    return _AnimatedThemeTile(
      name: name,
      color: color,
      gradient: gradient,
      textColor: textColor,
      boxShadow: boxShadow,
    );
  }
}

/// Stateful widget for animated theme tile
class _AnimatedThemeTile extends StatefulWidget {
  final String name;
  final Color color;
  final LinearGradient? gradient;
  final Color? textColor;
  final List<BoxShadow>? boxShadow;

  const _AnimatedThemeTile({
    required this.name,
    required this.color,
    this.gradient,
    this.textColor,
    this.boxShadow,
  });

  @override
  State<_AnimatedThemeTile> createState() => _AnimatedThemeTileState();
}

class _AnimatedThemeTileState extends State<_AnimatedThemeTile>
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
