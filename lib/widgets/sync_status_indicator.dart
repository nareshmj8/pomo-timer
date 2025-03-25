import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';

/// A widget that displays the current sync status with visual feedback
class SyncStatusIndicator extends StatefulWidget {
  /// Whether to show the detailed view with text and progress
  final bool detailed;

  /// Whether to show the progress bar
  final bool showProgressBar;

  /// Size of the indicator icon
  final double iconSize;

  /// Custom style for the status text
  final TextStyle? statusTextStyle;

  /// Custom style for the detail text
  final TextStyle? detailTextStyle;

  /// Optional background color
  final Color? backgroundColor;

  /// Whether to show a border around the widget
  final bool showBorder;

  /// Radius of the border corners
  final double borderRadius;

  /// Create a sync status indicator with various customization options
  const SyncStatusIndicator({
    Key? key,
    this.detailed = true,
    this.showProgressBar = true,
    this.iconSize = 24.0,
    this.statusTextStyle,
    this.detailTextStyle,
    this.backgroundColor,
    this.showBorder = false,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for loading indicators
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncProgress>(
      stream: Provider.of<SyncService>(context, listen: false).progressStream,
      initialData:
          Provider.of<SyncService>(context, listen: false).getCurrentProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data;

        if (progress == null) {
          return const SizedBox.shrink();
        }

        return _buildIndicator(context, progress);
      },
    );
  }

  Widget _buildIndicator(BuildContext context, SyncProgress progress) {
    final Widget content = widget.detailed
        ? _buildDetailedIndicator(context, progress)
        : _buildSimpleIndicator(context, progress);

    if (widget.showBorder) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: progress.getStatusColor().withAlpha(128),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: widget.backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: content,
      );
    }

    return widget.backgroundColor != null
        ? Container(
            color: widget.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: content,
          )
        : content;
  }

  Widget _buildSimpleIndicator(BuildContext context, SyncProgress progress) {
    return _buildStatusIcon(progress);
  }

  Widget _buildDetailedIndicator(BuildContext context, SyncProgress progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusIcon(progress),
            const SizedBox(width: 8),
            Text(
              progress.statusMessage.isNotEmpty
                  ? progress.statusMessage
                  : progress.getStatusText(),
              style: widget.statusTextStyle ??
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progress.getStatusColor(),
                    fontSize: 14,
                  ),
            ),
          ],
        ),
        if (progress.detailMessage.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            progress.detailMessage,
            style: widget.detailTextStyle ??
                TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
          ),
        ],
        if (widget.showProgressBar && progress.progressPercentage > 0) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.progressPercentage,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor:
                AlwaysStoppedAnimation<Color>(progress.getStatusColor()),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIcon(SyncProgress progress) {
    switch (progress.status) {
      case SyncStatus.synced:
        return Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: CupertinoColors.activeGreen,
          size: widget.iconSize,
        );

      case SyncStatus.failed:
        return Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          color: CupertinoColors.systemRed,
          size: widget.iconSize,
        );

      case SyncStatus.waitingForConnection:
        return Icon(
          CupertinoIcons.wifi_exclamationmark,
          color: CupertinoColors.systemOrange,
          size: widget.iconSize,
        );

      case SyncStatus.preparing:
      case SyncStatus.uploading:
      case SyncStatus.downloading:
      case SyncStatus.merging:
      case SyncStatus.finalizing:
        return SizedBox(
          width: widget.iconSize,
          height: widget.iconSize,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _SyncIndicatorPainter(
                  progress: progress.progressPercentage,
                  color: progress.getStatusColor(),
                  animationValue: _animationController.value,
                ),
              );
            },
          ),
        );

      case SyncStatus.notSynced:
        return Icon(
          CupertinoIcons.cloud,
          color: CupertinoColors.systemGrey,
          size: widget.iconSize,
        );
    }
  }
}

/// Custom painter for the animated sync indicator
class _SyncIndicatorPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double animationValue;

  _SyncIndicatorPainter({
    required this.progress,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = color.withAlpha(51) // 0.2 * 255 ≈ 51
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw rotating arc
    final startAngle = 2 * pi * animationValue;
    final sweepAngle = pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw progress indicator if needed
    if (progress > 0) {
      final progressArcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SyncIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue;
  }
}

/// A button that triggers a sync operation and shows current sync status
class SyncNowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double height;
  final double? width;
  final bool showIcon;

  const SyncNowButton({
    Key? key,
    this.onPressed,
    this.label = 'Sync Now',
    this.height = 40,
    this.width,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncProgress>(
      stream: Provider.of<SyncService>(context, listen: false).progressStream,
      initialData:
          Provider.of<SyncService>(context, listen: false).getCurrentProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data;

        final syncService = Provider.of<SyncService>(context, listen: false);
        final bool isEnabled = progress?.isEnabled ?? false;
        final bool isPremium = progress?.isPremium ?? false;
        final bool isSyncing = progress?.status == SyncStatus.preparing ||
            progress?.status == SyncStatus.uploading ||
            progress?.status == SyncStatus.downloading ||
            progress?.status == SyncStatus.merging ||
            progress?.status == SyncStatus.finalizing;

        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: isEnabled
                ? (isSyncing
                    ? CupertinoColors.activeBlue.withAlpha(204)
                    : CupertinoColors.activeBlue)
                : CupertinoColors.systemGrey4,
            disabledColor: CupertinoColors.systemGrey4,
            borderRadius: BorderRadius.circular(10),
            onPressed: (isEnabled && isPremium && !isSyncing)
                ? () {
                    if (onPressed != null) {
                      onPressed!();
                    } else {
                      syncService.syncData();
                    }
                  }
                : null,
            child: isSyncing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        progress?.statusMessage ?? 'Syncing...',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showIcon) ...[
                        const Icon(
                          CupertinoIcons.arrow_2_circlepath,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// A small widget that shows a sync indicator in the app bar or bottom bar
class SyncStatusBadge extends StatelessWidget {
  final bool showDetails;
  final double size;
  final VoidCallback? onTap;

  const SyncStatusBadge({
    Key? key,
    this.showDetails = false,
    this.size = 16.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: StreamBuilder<SyncProgress>(
        stream: Provider.of<SyncService>(context, listen: false).progressStream,
        initialData: Provider.of<SyncService>(context, listen: false)
            .getCurrentProgress(),
        builder: (context, snapshot) {
          final progress = snapshot.data;

          if (progress == null || !progress.isEnabled) {
            return const SizedBox.shrink();
          }

          final bool isSyncing = progress.status == SyncStatus.preparing ||
              progress.status == SyncStatus.uploading ||
              progress.status == SyncStatus.downloading ||
              progress.status == SyncStatus.merging ||
              progress.status == SyncStatus.finalizing;

          if (showDetails && isSyncing) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: size,
                    height: size,
                    child: CupertinoActivityIndicator(radius: size / 2.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    progress.statusMessage.isNotEmpty
                        ? progress.statusMessage
                        : 'Syncing',
                    style: TextStyle(
                      fontSize: size * 0.75,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (progress.status == SyncStatus.failed) {
            return Tooltip(
              message: 'Sync failed: ${progress.errorMessage}',
              child: Icon(
                CupertinoIcons.exclamationmark_circle_fill,
                color: CupertinoColors.systemRed,
                size: size,
              ),
            );
          }

          if (progress.status == SyncStatus.waitingForConnection) {
            return Tooltip(
              message: 'Waiting for connection to sync',
              child: Icon(
                CupertinoIcons.wifi_exclamationmark,
                color: CupertinoColors.systemOrange,
                size: size,
              ),
            );
          }

          if (isSyncing) {
            return SizedBox(
              width: size,
              height: size,
              child: CupertinoActivityIndicator(radius: size / 2.5),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
