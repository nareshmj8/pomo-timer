import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../services/revenue_cat_service.dart';
import '../../../services/payment_sheet_handler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// A button that triggers a purchase with robust error handling and
/// transaction queue support for network failures
class RobustPurchaseButton extends StatefulWidget {
  /// Product to purchase
  final String productId;

  /// Button text
  final String label;

  /// Icon to display (optional)
  final IconData? icon;

  /// Button style
  final ButtonStyle? style;

  /// Text style
  final TextStyle? textStyle;

  /// Button size
  final Size? size;

  /// Callback when purchase completes successfully
  final Function? onPurchaseCompleted;

  /// Button constructor
  const RobustPurchaseButton({
    Key? key,
    required this.productId,
    required this.label,
    this.icon,
    this.style,
    this.textStyle,
    this.size,
    this.onPurchaseCompleted,
  }) : super(key: key);

  @override
  State<RobustPurchaseButton> createState() => _RobustPurchaseButtonState();
}

class _RobustPurchaseButtonState extends State<RobustPurchaseButton> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    final revenueCatService =
        Provider.of<RevenueCatService>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size?.width ?? double.infinity,
          height: widget.size?.height ?? 48,
          child: ElevatedButton(
            style: widget.style ??
                ElevatedButton.styleFrom(
                  backgroundColor: CupertinoColors.activeBlue,
                  foregroundColor: Colors.white,
                ),
            onPressed: _isLoading
                ? null
                : () => _handlePurchase(context, revenueCatService),
            child: _isLoading ? _buildLoadingState() : _buildDefaultState(),
          ),
        ),
        if (_statusMessage.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: widget.textStyle,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Text('Processing...', style: widget.textStyle),
      ],
    );
  }

  Future<void> _handlePurchase(
      BuildContext context, RevenueCatService revenueCatService) async {
    // Find the appropriate package for the product ID
    final offerings = revenueCatService.offerings;
    if (offerings == null || offerings.current == null) {
      _showError('Offerings not available');
      return;
    }

    // Get the package
    Package? packageToPurchase;

    switch (widget.productId) {
      case RevenueCatProductIds.monthlyId:
        packageToPurchase = offerings.current!.monthly;
        break;
      case RevenueCatProductIds.yearlyId:
        packageToPurchase = offerings.current!.annual;
        break;
      case RevenueCatProductIds.lifetimeId:
        packageToPurchase = offerings.current!.lifetime;
        break;
      default:
        _showError('Invalid product ID');
        return;
    }

    if (packageToPurchase == null) {
      _showError('Package not found');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Preparing purchase...';
    });

    try {
      // Use the payment sheet handler for robust error handling
      final result = await PaymentSheetHandler.presentPaymentSheet(
        context: context,
        package: packageToPurchase,
      );

      // Handle the result
      switch (result) {
        case PaymentSheetStatus.completedSuccessfully:
          setState(() {
            _statusMessage = 'Purchase successful!';
            _isLoading = false;
          });

          // Notify listeners of successful purchase
          if (widget.onPurchaseCompleted != null) {
            widget.onPurchaseCompleted!();
          }
          break;

        case PaymentSheetStatus.userCancelled:
          setState(() {
            _statusMessage = 'Purchase cancelled';
            _isLoading = false;
          });
          break;

        case PaymentSheetStatus.failedToPresent:
          setState(() {
            _statusMessage = 'Could not show payment sheet';
            _isLoading = false;
          });
          _showError(
              'Payment sheet could not be presented. Your purchase has been queued for retry when conditions improve.');
          break;

        case PaymentSheetStatus.error:
          setState(() {
            _statusMessage = 'Error during purchase';
            _isLoading = false;
          });
          _showError(
              'There was an error processing your purchase. Your purchase has been queued for retry.');
          break;

        default:
          setState(() {
            _statusMessage = '';
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '';
        _isLoading = false;
      });
      _showError('Purchase error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _statusMessage = message;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: CupertinoColors.systemRed,
      ),
    );
  }
}
