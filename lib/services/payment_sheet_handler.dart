import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../utils/logging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Status of a payment sheet presentation
enum PaymentSheetStatus {
  notShown,
  preparing,
  presentedSuccessfully,
  completedSuccessfully,
  userCancelled,
  failedToPresent,
  error
}

/// Handler class for payment sheet presentation to ensure payment sheets
/// are shown correctly and with proper error handling
class PaymentSheetHandler {
  // Timeout duration for payment sheet presentation
  static const Duration _paymentSheetTimeout = Duration(seconds: 10);

  // Status tracking
  static PaymentSheetStatus _currentStatus = PaymentSheetStatus.notShown;
  static Timer? _timeoutTimer;
  static Completer<PaymentSheetStatus>? _paymentCompleter;

  /// Get the current payment sheet status
  static PaymentSheetStatus get currentStatus => _currentStatus;

  /// Present a payment sheet with robust error handling and timeout detection
  static Future<PaymentSheetStatus> presentPaymentSheet({
    required BuildContext context,
    required Package package,
    bool showErrorDialog = true,
  }) async {
    // Reset state
    _resetState();
    _currentStatus = PaymentSheetStatus.preparing;

    // Check for network connectivity first
    final connectivityResults = await Connectivity().checkConnectivity();
    final connectivityResult = connectivityResults.isNotEmpty
        ? connectivityResults.first
        : ConnectivityResult.none;
    if (connectivityResult == ConnectivityResult.none) {
      _currentStatus = PaymentSheetStatus.failedToPresent;
      if (showErrorDialog && context.mounted) {
        _showNoConnectivityDialog(context);
      }
      return _currentStatus;
    }

    // Store context-based variables needed for later use when context might not be mounted
    final bool isIOS = Platform.isIOS;

    // Start timeout timer - passing a copy of BuildContext isn't reliable
    // We'll handle timeouts without direct context dependency
    _startTimeoutTimerWithoutContext();

    try {
      // Set up completer
      _paymentCompleter = Completer<PaymentSheetStatus>();

      // Log attempt
      logging.info(
          'PaymentSheet: Attempting to present payment sheet for ${package.identifier}');

      // Handle platform-specific behavior
      if (isIOS) {
        // Set up observer for sheet presentation success
        _monitorPaymentSheetPresentation();
      }

      // Trigger the payment sheet presentation
      await Purchases.purchasePackage(package).then((info) {
        // Purchase completed successfully
        _currentStatus = PaymentSheetStatus.completedSuccessfully;

        if (!_paymentCompleter!.isCompleted) {
          _paymentCompleter!.complete(_currentStatus);
        }

        _cancelTimeoutTimer();
        return _currentStatus;
      }).catchError((error) {
        // Handle specific errors
        if (error.toString().contains('cancel') ||
            error.toString().contains('cancelled')) {
          _currentStatus = PaymentSheetStatus.userCancelled;
        } else {
          _currentStatus = PaymentSheetStatus.error;
          logging.error('PaymentSheet: Error in purchase flow - $error');
        }

        if (!_paymentCompleter!.isCompleted) {
          _paymentCompleter!.complete(_currentStatus);
        }

        _cancelTimeoutTimer();

        // Show error dialog if needed and not cancelled by user
        if (showErrorDialog &&
            _currentStatus == PaymentSheetStatus.error &&
            context.mounted) {
          _showPurchaseErrorDialog(context, error.toString());
        }

        return _currentStatus;
      });

      // Wait for the operation to complete
      final result = await _paymentCompleter!.future;

      // If payment sheet timed out and we still have a valid context, show the timeout dialog
      if (result == PaymentSheetStatus.failedToPresent &&
          showErrorDialog &&
          context.mounted) {
        _showPaymentSheetTimeoutDialog(context);
      }

      return result;
    } catch (e) {
      // Handle unexpected errors
      _currentStatus = PaymentSheetStatus.error;
      _cancelTimeoutTimer();

      logging.error('PaymentSheet: Unexpected error in payment flow - $e');

      if (showErrorDialog && context.mounted) {
        _showPurchaseErrorDialog(context, e.toString());
      }

      return _currentStatus;
    }
  }

  /// Reset the state for a new payment sheet presentation
  static void _resetState() {
    _cancelTimeoutTimer();

    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.complete(PaymentSheetStatus.error);
    }

    _paymentCompleter = null;
    _currentStatus = PaymentSheetStatus.notShown;
  }

  /// Start the timeout timer without requiring a BuildContext
  static void _startTimeoutTimerWithoutContext() {
    _cancelTimeoutTimer();

    _timeoutTimer = Timer(_paymentSheetTimeout, () {
      // Only handle timeout if still in preparing state
      if (_currentStatus == PaymentSheetStatus.preparing) {
        _currentStatus = PaymentSheetStatus.failedToPresent;

        logging.error(
            'PaymentSheet: Payment sheet presentation timed out after ${_paymentSheetTimeout.inSeconds} seconds');

        if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
          _paymentCompleter!.complete(_currentStatus);
        }
      }
    });
  }

  /// Cancel the timeout timer
  static void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Monitor for successful payment sheet presentation
  /// This uses a heuristic approach since RevenueCat doesn't provide direct callbacks
  static void _monitorPaymentSheetPresentation() {
    // Mark presentation successful after a short delay
    // This is a heuristic since we don't have direct feedback when sheet is shown
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_currentStatus == PaymentSheetStatus.preparing) {
        _currentStatus = PaymentSheetStatus.presentedSuccessfully;

        // Log successful presentation
        logging.info('PaymentSheet: Payment sheet presented successfully');
      }
    });
  }

  /// Show dialog when payment sheet times out
  static void _showPaymentSheetTimeoutDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text('Purchase Problem'),
                content: const Text(
                    'The App Store payment sheet did not appear. This could be due to:\n\n'
                    '- An Apple ID issue\n'
                    '- Restrictions on this device\n'
                    '- A temporary App Store problem\n\n'
                    'Please try again or check your Apple ID settings.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('Purchase Problem'),
                content: const Text(
                    'The payment screen did not appear. This could be due to:\n\n'
                    '- A Google Play account issue\n'
                    '- Restrictions on this device\n'
                    '- A temporary Google Play problem\n\n'
                    'Please try again or check your Google Play settings.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
      );
    }
  }

  /// Show dialog for no connectivity
  static void _showNoConnectivityDialog(BuildContext context) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text('No Internet Connection'),
                content: const Text(
                    'You need an active internet connection to make purchases. '
                    'Please check your connection and try again.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('No Internet Connection'),
                content: const Text(
                    'You need an active internet connection to make purchases. '
                    'Please check your connection and try again.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
      );
    }
  }

  /// Show dialog for purchase errors
  static void _showPurchaseErrorDialog(
      BuildContext context, String errorMessage) {
    // Only show dialog if context is still valid
    if (context.mounted) {
      // Format error message to be more user-friendly
      String userMessage = 'There was a problem completing your purchase.';

      // Add more specific details based on error message
      if (errorMessage.toLowerCase().contains('network')) {
        userMessage += ' Please check your internet connection and try again.';
      } else if (errorMessage.toLowerCase().contains('billing')) {
        userMessage += ' There might be an issue with your payment method.';
      } else if (errorMessage.toLowerCase().contains('already purchased')) {
        userMessage +=
            ' You may already own this item. Try restoring purchases.';
      } else {
        userMessage += ' Please try again later.';
      }

      showDialog(
        context: context,
        builder: (context) => Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text('Purchase Not Completed'),
                content: Text(userMessage),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('Purchase Not Completed'),
                content: Text(userMessage),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
      );
    }
  }
}
