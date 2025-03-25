import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../services/revenue_cat_service.dart';

class PurchaseSafetySection extends StatelessWidget {
  final RevenueCatService revenueCatService;

  const PurchaseSafetySection({
    Key? key,
    required this.revenueCatService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Purchase Safety',
            style: TextStyle(
              fontSize: ThemeConstants.headingFontSize,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
            border: Border.all(
              color: CupertinoColors.activeBlue.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_shield_fill,
                      color: CupertinoColors.activeBlue,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transaction Safety System',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your purchases are protected by our transaction queue system which ensures that purchases are completed even if:',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  theme,
                  'Network fails during purchase',
                  'Your purchase will automatically retry when connection is restored',
                ),
                _buildFeatureItem(
                  theme,
                  'App is closed unexpectedly',
                  'Transactions resume when you restart the app',
                ),
                _buildFeatureItem(
                  theme,
                  'Payment sheet fails to appear',
                  'We detect and retry with better error messages',
                ),
                _buildFeatureItem(
                  theme,
                  'Server timeouts occur',
                  'Up to 5 automatic retries with backoff timing',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.listTileBackgroundColor,
            borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(16.0),
            onPressed: () {
              _showTransactionQueueStatus(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.doc_text_search,
                  color: CupertinoColors.activeBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'View Transaction Status',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: ThemeConstants.bodyFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: const Text('Force Process Queue'),
          subtitle: const Text('Process any pending purchases now'),
          trailing: const Icon(Icons.sync),
          onTap: () {
            _forceProcessQueue(context);
          },
        ),
      ],
    );
  }

  void _showTransactionQueueStatus(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => _TransactionQueueStatusDialog(
        revenueCatService: revenueCatService,
      ),
    );
  }

  void _forceProcessQueue(BuildContext context) async {
    // Show confirmation dialog
    final bool shouldProcess = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Process Transaction Queue'),
            content: const Text(
                'This will force processing of any pending transactions. Continue?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Process'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldProcess) {
      // Force process the queue
      await revenueCatService.forceProcessTransactionQueue();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction queue processed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildFeatureItem(
    ThemeProvider theme,
    String title,
    String subtitle, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: CupertinoColors.activeGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.secondaryTextColor,
                    fontSize: 12,
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

class _TransactionQueueStatusDialog extends StatelessWidget {
  final RevenueCatService revenueCatService;

  const _TransactionQueueStatusDialog({
    required this.revenueCatService,
  });

  @override
  Widget build(BuildContext context) {
    // Get real transaction queue data
    final List<Map<String, dynamic>> queueItems =
        revenueCatService.getTransactionQueueItems();

    return CupertinoActionSheet(
      title: const Text('Transaction Queue Status'),
      message: const Text(
          'All purchases are safely tracked and will retry automatically if interrupted.'),
      actions: [
        if (queueItems.isEmpty)
          CupertinoActionSheetAction(
            onPressed: () {},
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'No pending transactions',
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
          )
        else
          ...queueItems.map((item) => _buildTransactionItem(context, item)),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> item) {
    final IconData icon;
    final Color color;

    final String status = item['status'] as String? ?? 'unknown';

    // Handle new status enum values from our transaction queue
    switch (status.toLowerCase()) {
      case 'completed':
        icon = CupertinoIcons.checkmark_circle_fill;
        color = CupertinoColors.activeGreen;
        break;
      case 'pending':
      case 'preparing':
        icon = CupertinoIcons.clock_fill;
        color = CupertinoColors.systemOrange;
        break;
      case 'processing':
        icon = CupertinoIcons.arrow_clockwise;
        color = CupertinoColors.activeBlue;
        break;
      case 'retrying':
        icon = CupertinoIcons.arrow_counterclockwise;
        color = CupertinoColors.systemOrange;
        break;
      case 'failed':
        icon = CupertinoIcons.exclamationmark_circle_fill;
        color = CupertinoColors.systemRed;
        break;
      default:
        icon = CupertinoIcons.circle;
        color = CupertinoColors.systemGrey;
    }

    final String retries = item['retryCount']?.toString() ?? '0';
    final bool hasError =
        (item['error'] != null && item['error'].toString().isNotEmpty);

    return CupertinoActionSheetAction(
      onPressed: () {
        // Show full error details if there is an error
        if (hasError) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Transaction Error Details'),
              content: Text(item['error'] as String? ?? 'Unknown error'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProductName(item['productId'] ?? 'Unknown Product'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${status.toUpperCase()} • ${item['date'] ?? 'Unknown date'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    if (int.parse(retries) > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '• Retries: $retries',
                        style: TextStyle(
                          fontSize: 12,
                          color: int.parse(retries) > 3
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasError)
            const Icon(
              CupertinoIcons.info_circle,
              color: CupertinoColors.systemRed,
              size: 16,
            ),
        ],
      ),
    );
  }

  // Convert product ID to a more user-friendly name
  String _getProductName(String productId) {
    if (productId.contains('monthly')) {
      return 'Monthly Premium';
    } else if (productId.contains('yearly')) {
      return 'Yearly Premium';
    } else if (productId.contains('lifetime')) {
      return 'Lifetime Premium';
    }
    return productId;
  }
}
