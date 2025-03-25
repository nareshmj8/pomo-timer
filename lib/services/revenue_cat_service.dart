import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';
import 'package:pomodoro_timemaster/services/analytics_service.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';
import 'package:pomodoro_timemaster/animations/purchase_success_handler.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import 'package:pomodoro_timemaster/models/purchase_status.dart';
import 'package:pomodoro_timemaster/services/interfaces/revenue_cat_service_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logging.dart';
import 'payment_sheet_handler.dart';
import '../config/api_keys.dart';

/// Constants for product IDs
class RevenueCatProductIds {
  static const String monthlyId =
      'com.naresh.pomodorotimemaster.premium.monthly';
  static const String yearlyId = 'com.naresh.pomodorotimemaster.premium.yearly';
  static const String lifetimeId =
      'com.naresh.pomodorotimemaster.premium.lifetime';
  static const List<String> productIds = [monthlyId, yearlyId, lifetimeId];

  // RevenueCat entitlement identifier
  static const String entitlementId = 'premium';
}

/// Transaction status enum for purchase queue management
enum TransactionStatus { pending, processing, completed, failed, retrying }

/// Purchase transaction model for queue management
class PurchaseTransaction {
  final String productId;
  final DateTime timestamp;
  TransactionStatus status;
  int retryCount;
  String? error;

  PurchaseTransaction({
    required this.productId,
    required this.timestamp,
    this.status = TransactionStatus.pending,
    this.retryCount = 0,
    this.error,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString(),
      'retryCount': retryCount,
      'error': error,
    };
  }

  // Create from JSON for retrieval
  factory PurchaseTransaction.fromJson(Map<String, dynamic> json) {
    return PurchaseTransaction(
      productId: json['productId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => TransactionStatus.pending),
      retryCount: json['retryCount'] ?? 0,
      error: json['error'],
    );
  }
}

class RevenueCatService extends ChangeNotifier
    implements RevenueCatServiceInterface {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // RevenueCat offerings
  Offerings? _offerings;
  CustomerInfo? _customerInfo;

  // Purchase state
  PurchaseStatus _purchaseStatus = PurchaseStatus.notPurchased;
  SubscriptionType _activeSubscription = SubscriptionType.none;
  String _errorMessage = '';
  bool _isLoading = true;
  DateTime? _expiryDate;
  bool _devPremiumOverride = false;

  // Services
  final NotificationService _notificationService = NotificationService();

  // Variable to track initialization status
  bool _isInitialized = false;

  // Transaction queue for managing purchases
  final List<PurchaseTransaction> _transactionQueue = [];
  bool _isProcessingQueue = false;
  Timer? _queueProcessor;

  // Logger instance
  final _log = logging;

  // Getters
  @override
  Offerings? get offerings => _offerings;

  @override
  CustomerInfo? get customerInfo => _customerInfo;

  @override
  PurchaseStatus get purchaseStatus {
    // Convert our internal enum to the interface enum
    switch (_purchaseStatus) {
      case PurchaseStatus.notPurchased:
        return PurchaseStatus.notPurchased;
      case PurchaseStatus.pending:
        return PurchaseStatus.pending;
      case PurchaseStatus.purchased:
        return PurchaseStatus.purchased;
      case PurchaseStatus.purchasing:
        return PurchaseStatus.purchasing;
      case PurchaseStatus.error:
        return PurchaseStatus.error;
      case PurchaseStatus.restored:
        return PurchaseStatus.restored;
      case PurchaseStatus.notFound:
        return PurchaseStatus.notFound;
      case PurchaseStatus.expired:
        return PurchaseStatus.expired;
    }
  }

  @override
  SubscriptionType get activeSubscription {
    // Convert our internal enum to the interface enum
    switch (_activeSubscription) {
      case SubscriptionType.none:
        return SubscriptionType.none;
      case SubscriptionType.monthly:
        return SubscriptionType.monthly;
      case SubscriptionType.yearly:
        return SubscriptionType.yearly;
      case SubscriptionType.lifetime:
        return SubscriptionType.lifetime;
    }
  }

  @override
  String get errorMessage => _errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  DateTime? get expiryDate => _expiryDate;

  @override
  bool get isPremium =>
      _devPremiumOverride || _activeSubscription != SubscriptionType.none;

  /// Initialize the service
  @override
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Check if already configured to avoid duplicate initialization
      try {
        final isConfigured = await Purchases.isConfigured;
        if (isConfigured) {
          debugPrint(
              "💰 RevenueCatService: Already configured, just loading data");
          _isInitialized = true;
        } else {
          debugPrint(
              "💰 RevenueCatService: Configuring purchases for the first time");
          await _configurePurchases();
          // If configuration was successful, mark as initialized
          _isInitialized = true;
        }

        // Load data with automatic retry only if properly initialized
        if (_isInitialized) {
          bool success = false;
          String lastErrorMessage = '';

          for (int attempt = 1; attempt <= 3; attempt++) {
            try {
              debugPrint("💰 RevenueCatService: Loading data attempt $attempt");
              await _loadCustomerInfo();
              await _loadOfferings();
              success = true;
              break;
            } catch (e) {
              lastErrorMessage = e.toString();
              debugPrint(
                  "💰 RevenueCatService: Error in load attempt $attempt: $e");

              // Show non-intrusive message for intermediate retries
              if (attempt < 3 && navigatorKey.currentContext != null) {
                // Only show for the first retry to avoid spam
                if (attempt == 1) {
                  ScaffoldMessenger.of(navigatorKey.currentContext!)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Having trouble loading subscription data. Retrying...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                // Wait before retry with increasing delay
                await Future.delayed(Duration(seconds: attempt));
              }
            }
          }

          if (!success) {
            debugPrint(
                "💰 RevenueCatService: Failed to load data after 3 attempts");
            // Still try to load preferences as a fallback
            LoggingService.logError(
                'RevenueCat Service',
                'Failed to load subscription data after 3 attempts',
                Exception(lastErrorMessage));
          }
        }
      } catch (e) {
        // If configuration or initialization fails, log but don't crash
        debugPrint("💰 RevenueCatService: Error during initialization: $e");
        _isInitialized = false;
      }

      // Try to load from preferences and handle notifications regardless of RevenueCat status
      await _loadPurchasesFromPrefs();
      await _checkAndScheduleExpiryNotification();

      // Check for any pending purchases that were attempted while offline
      await checkPendingPurchases();

      // Load any pending transactions from shared preferences
      await _loadTransactionQueue();

      // Start the transaction queue processor
      _startQueueProcessor();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Fatal error initializing service', e);
      _errorMessage = 'Error initializing: $e';
      _isLoading = false;
      _isInitialized = false; // Ensure we know initialization failed
      notifyListeners();

      // Show final error dialog if all else fails but don't crash
      _showInitializationErrorDialog(e.toString());
    }
  }

  /// Show initialization error dialog
  void _showInitializationErrorDialog(String errorDetails) {
    try {
      // Only show if we have a context
      if (navigatorKey.currentContext != null) {
        // Run in the next frame to avoid build issues
        Future.delayed(Duration.zero, () {
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: const Text('Subscription Service Issue'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We\'re having trouble connecting to our subscription service. '
                    'Your existing subscription status will be preserved, but you may not be able to make new purchases at this time.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please check your internet connection and try again later.',
                    style: TextStyle(fontSize: 14),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    const Text('Error details (debug only):',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(
                      errorDetails.length > 100
                          ? '${errorDetails.substring(0, 100)}...'
                          : errorDetails,
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Retry initialization
                    initialize();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      // If showing dialog fails, just log the error
      LoggingService.logError('RevenueCat Service',
          'Failed to show initialization error dialog', e);
    }
  }

  /// Configure RevenueCat SDK
  Future<void> _configurePurchases() async {
    try {
      // Check if already configured to avoid duplicate initialization
      final isConfigured = await Purchases.isConfigured;
      if (isConfigured) {
        _log.info('RevenueCatService: Purchases already configured');
        return;
      }

      // Set up logging
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      } else {
        await Purchases.setLogLevel(LogLevel.info);
      }

      // Set API key based on platform
      String apiKey;
      if (Platform.isIOS) {
        apiKey = RevenueCatConfig.iosApiKey;
      } else if (Platform.isAndroid) {
        apiKey = RevenueCatConfig.androidApiKey;
      } else {
        throw Exception('Platform not supported');
      }

      // Configure purchases with the API key
      _log.info('RevenueCatService: Configuring Purchases with API key');
      await Purchases.configure(PurchasesConfiguration(apiKey));

      // Add listener for customer info updates
      Purchases.addCustomerInfoUpdateListener((info) {
        _log.info('RevenueCatService: Customer info updated via listener');
        _handleCustomerInfoUpdate(info);
      });

      _log.info('RevenueCatService: Purchases configured successfully');
    } catch (e) {
      _log.error(
          'RevenueCatService: Failed to configure purchases: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> forceReloadOfferings() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Force reload offerings from the server
      if (await Purchases.isConfigured) {
        await _loadOfferings();
      } else {
        await _configurePurchases();
        await _loadOfferings();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error force reloading offerings', e);
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> purchaseProduct(String productId) async {
    try {
      if (!await Purchases.isConfigured) {
        await _configurePurchases();
      }

      if (_offerings == null) {
        await _loadOfferings();
      }

      final offering = _offerings?.current;
      if (offering == null) {
        _updatePurchaseStatus(PurchaseStatus.error,
            errorMessage: 'No offerings available');
        return;
      }

      // Check for network connectivity
      try {
        // Check for network connectivity first
        final connectivityResults = await Connectivity().checkConnectivity();
        final connectivityResult = connectivityResults.isNotEmpty
            ? connectivityResults.first
            : ConnectivityResult.none;
        if (connectivityResult == ConnectivityResult.none) {
          debugPrint('No network connection. Adding to transaction queue...');
          _storePendingPurchase(productId);
          _updatePurchaseStatus(PurchaseStatus.pending,
              errorMessage:
                  'No internet connection. Purchase will be attempted when connection is restored.');
          return;
        }
      } catch (e) {
        LoggingService.logError(
            'RevenueCat Service', 'Error checking network connectivity', e);
        _updatePurchaseStatus(PurchaseStatus.error, errorMessage: e.toString());
        return;
      }

      Package? packageToPurchase;
      switch (productId) {
        case RevenueCatProductIds.monthlyId:
          packageToPurchase = offering.monthly;
          break;
        case RevenueCatProductIds.yearlyId:
          packageToPurchase = offering.annual;
          break;
        case RevenueCatProductIds.lifetimeId:
          packageToPurchase = offering.lifetime;
          break;
        default:
          _updatePurchaseStatus(PurchaseStatus.error,
              errorMessage: 'Invalid product id');
          return;
      }

      if (packageToPurchase == null) {
        _updatePurchaseStatus(PurchaseStatus.error,
            errorMessage: 'Package not found');
        return;
      }

      await purchasePackage(packageToPurchase);
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error purchasing product', e);
      _updatePurchaseStatus(PurchaseStatus.error, errorMessage: e.toString());

      // If this is a network error or any error that suggests possible recovery,
      // add to transaction queue for retry
      if (e.toString().contains('network') ||
          e.toString().contains('timeout') ||
          e.toString().contains('connection') ||
          e.toString().contains('canceled')) {
        _storePendingPurchase(productId);
      }
    }
  }

  // Store pending purchase for later processing (enhanced version)
  Future<void> _storePendingPurchase(String productId) async {
    try {
      // Create a new transaction
      final transaction = PurchaseTransaction(
        productId: productId,
        timestamp: DateTime.now(),
      );

      // Add to queue
      _transactionQueue.add(transaction);

      // Save queue
      await _saveTransactionQueue();

      LoggingService.logEvent(
          'RevenueCat Service', 'Added transaction to queue: $productId');

      // Legacy approach for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_purchase_id', productId);
      await prefs.setInt(
          'pending_purchase_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error storing pending purchase', e);
    }
  }

  // Check and process any pending purchases (enhanced version)
  Future<void> checkPendingPurchases() async {
    try {
      // First check the transaction queue (new approach)
      await processTransactionQueue();

      // Then check legacy storage for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final pendingProductId = prefs.getString('pending_purchase_id');

      if (pendingProductId != null) {
        final timestamp = prefs.getInt('pending_purchase_timestamp') ?? 0;
        final purchaseTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        // Only process if the pending purchase is not too old (48 hours)
        if (now.difference(purchaseTime).inHours < 48) {
          // Check network connectivity
          final connectivityResults = await Connectivity().checkConnectivity();
          final connectivityResult = connectivityResults.isNotEmpty
              ? connectivityResults.first
              : ConnectivityResult.none;
          if (connectivityResult != ConnectivityResult.none) {
            // Clear pending purchase before attempting to process
            await prefs.remove('pending_purchase_id');
            await prefs.remove('pending_purchase_timestamp');

            // Add to transaction queue instead of processing directly
            _storePendingPurchase(pendingProductId);
          }
        } else {
          // Clear expired pending purchase
          await prefs.remove('pending_purchase_id');
          await prefs.remove('pending_purchase_timestamp');
          LoggingService.logEvent('RevenueCat Service',
              'Cleared expired pending purchase: $pendingProductId');
        }
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error checking pending purchases', e);
    }
  }

  @override
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      _updatePurchaseStatus(PurchaseStatus.pending);

      // Make sure we have a valid context
      final context = navigatorKey.currentContext;
      if (context == null) {
        _updatePurchaseStatus(PurchaseStatus.error,
            errorMessage:
                'Unable to present purchase dialog - no valid context');
        return null;
      }

      // Use the new PaymentSheetHandler to present the payment sheet
      final result = await PaymentSheetHandler.presentPaymentSheet(
        context: context,
        package: package,
      );

      // Handle the result from the payment sheet handler
      switch (result) {
        case PaymentSheetStatus.completedSuccessfully:
          // Purchase was successful, get the latest customer info
          final purchaserInfo = await Purchases.getCustomerInfo();

          if (purchaserInfo.entitlements.all[RevenueCatProductIds.entitlementId]
                  ?.isActive ??
              false) {
            _updateSubscriptionStatusFromCustomerInfo(purchaserInfo);

            // Save purchases to prefs
            _savePurchasesToPrefs();

            // Schedule expiry notification if applicable
            _checkAndScheduleExpiryNotification();

            // Show success animation
            _showPurchaseSuccessAnimation(_activeSubscription);

            return purchaserInfo;
          } else {
            _log.warning('Purchase completed but entitlement not active');
            _updatePurchaseStatus(PurchaseStatus.error,
                errorMessage:
                    'Purchase completed but subscription not activated');
            return null;
          }

        case PaymentSheetStatus.userCancelled:
          _updatePurchaseStatus(PurchaseStatus.notPurchased);
          return null;

        case PaymentSheetStatus.failedToPresent:
          _updatePurchaseStatus(PurchaseStatus.error,
              errorMessage: 'Failed to present payment sheet');
          return null;

        case PaymentSheetStatus.error:
          _updatePurchaseStatus(PurchaseStatus.error,
              errorMessage: 'Error during payment processing');
          return null;

        default:
          _updatePurchaseStatus(PurchaseStatus.error,
              errorMessage: 'Unknown payment sheet status');
          return null;
      }
    } catch (e) {
      _log.error('Error purchasing package: $e');
      _updatePurchaseStatus(PurchaseStatus.error, errorMessage: e.toString());

      // If this is a network error or any error that suggests possible recovery,
      // add to transaction queue for retry
      if (e.toString().contains('network') ||
          e.toString().contains('timeout') ||
          e.toString().contains('connection') ||
          e.toString().contains('canceled')) {
        _storePendingPurchase(package.identifier);
      }

      return null;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Restore purchases
      final purchaserInfo = await Purchases.restorePurchases();

      // Process customer info
      _updateSubscriptionStatusFromCustomerInfo(purchaserInfo);

      // Store purchases
      _savePurchasesToPrefs();

      // Track analytics
      final analytics = AnalyticsService();
      await analytics.logEvent('purchases_restored', {
        'status': 'success',
        'subscription_type': _activeSubscription.toString(),
      });

      _isLoading = false;
      notifyListeners();

      return isPremium;
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error restoring purchases', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void enableDevPremiumAccess() {
    if (!isPremium) {
      _devPremiumOverride = true;
      notifyListeners();
      LoggingService.logWarning('RevenueCat Service',
          'Developer premium access enabled - FOR TESTING ONLY');
    }
  }

  @override
  void disableDevPremiumAccess() {
    if (_devPremiumOverride) {
      _devPremiumOverride = false;
      notifyListeners();

      final analytics = AnalyticsService();
      analytics.logEvent('Developer premium access disabled');
    }
  }

  /// Load customer info
  Future<void> _loadCustomerInfo() async {
    try {
      if (await Purchases.isConfigured) {
        _customerInfo = await Purchases.getCustomerInfo();
        _updateSubscriptionStatusFromCustomerInfo(_customerInfo!);
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error loading customer info', e);
    }
  }

  /// Load offerings from RevenueCat
  Future<void> _loadOfferings() async {
    try {
      debugPrint('💰 RevenueCatService: Loading offerings');

      // Check if Purchases is configured before attempting to load offerings
      if (!await _isPurchasesConfigured()) {
        debugPrint(
            'RevenueCatService: Purchases not configured, configuring now');
        await _configurePurchases();
        // If still not configured after an attempt, return
        if (!await _isPurchasesConfigured()) {
          debugPrint('RevenueCatService: Failed to configure Purchases');
          return;
        }
      }

      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('💰 RevenueCatService: Error loading offerings: $e');
      LoggingService.logError(
          'RevenueCat Service', 'Error loading offerings', e);
    }
  }

  /// Handle customer info updates
  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    final analytics = AnalyticsService();
    analytics.logEvent(
        'Customer info updated', {'timestamp': DateTime.now().toString()});
    _customerInfo = customerInfo;
    _updateSubscriptionStatusFromCustomerInfo(customerInfo);
    notifyListeners();
  }

  /// Update subscription status from customer info
  void _updateSubscriptionStatusFromCustomerInfo(CustomerInfo customerInfo) {
    final bool hasEntitlement = customerInfo
            .entitlements.all[RevenueCatProductIds.entitlementId]?.isActive ??
        false;

    if (hasEntitlement) {
      _purchaseStatus = PurchaseStatus.purchased;

      // Determine which subscription type is active
      final String? productId = customerInfo.entitlements
          .all[RevenueCatProductIds.entitlementId]?.productIdentifier;

      if (productId == null) {
        _activeSubscription = SubscriptionType.none;
        return;
      }

      if (productId.contains('monthly')) {
        _activeSubscription = SubscriptionType.monthly;
      } else if (productId.contains('yearly')) {
        _activeSubscription = SubscriptionType.yearly;
      } else if (productId.contains('lifetime')) {
        _activeSubscription = SubscriptionType.lifetime;
      } else {
        _activeSubscription = SubscriptionType.none;
      }

      // Check if there's an expiry date
      if (_activeSubscription != SubscriptionType.lifetime &&
          _activeSubscription != SubscriptionType.none) {
        final expiryDateValue = customerInfo.entitlements
            .all[RevenueCatProductIds.entitlementId]?.expirationDate;

        if (expiryDateValue != null) {
          try {
            // Convert the expiration date to DateTime
            _expiryDate = _parseDateTime(expiryDateValue);
          } catch (e) {
            LoggingService.logError(
                'RevenueCat Service', 'Error parsing expiry date', e);
            _expiryDate = null;
          }
        }
      }

      // Reset purchase status
      _errorMessage = '';

      final analytics = AnalyticsService();
      analytics.logEvent('subscription_status_updated', {
        'status': 'active',
        'type': _activeSubscription.toString(),
        'expiry_date': _expiryDate?.toString() ?? 'none',
      });
    } else {
      _activeSubscription = SubscriptionType.none;
      _expiryDate = null;

      if (_activeSubscription != SubscriptionType.none) {
        _purchaseStatus = PurchaseStatus.purchased;
      } else {
        _purchaseStatus = PurchaseStatus.notPurchased;
      }

      final analytics = AnalyticsService();
      analytics.logEvent('subscription_status_updated', {'status': 'inactive'});
    }
  }

  @override
  Future<void> showSubscriptionPlans(BuildContext context) async {
    if (!context.mounted) return;

    // Store mounted state before async operation
    final bool contextMounted = context.mounted;

    // Ensure offerings are loaded
    if (_offerings == null) {
      await _loadOfferings();
    }

    // Check if context is still valid after async operation
    if (!contextMounted || !context.mounted) return;

    if (_offerings?.current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Subscription options couldn\'t be loaded. Please try again later.'),
        ),
      );
      return;
    }

    // Navigate to subscription screen
    Navigator.of(context).pushNamed('/premium');
  }

  @override
  Future<void> showPremiumBenefits(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.of(context).pushNamed('/premium_benefits');
  }

  @override
  Future<void> openManageSubscriptionsPage() async {
    try {
      // Use the system-native way to open subscription management
      final url = Uri.parse(Platform.isIOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions');

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error opening manage subscriptions page', e);
    }
  }

  Future<void> scheduleExpiryNotification(
      DateTime expiryDate, String subscriptionType) async {
    try {
      await _notificationService.scheduleExpiryNotification(
          expiryDate, subscriptionType);

      // Log successful scheduling
      final analytics = AnalyticsService();
      analytics.logEvent('expiry_notification_scheduled', {
        'scheduled_for': expiryDate.toString(),
        'subscription_type': subscriptionType,
      });
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error scheduling expiry notification', e);

      // Add user-facing warning through notification service
      _showExpiryNotificationFailureWarning(expiryDate);

      // Log the failure for analytics
      final analytics = AnalyticsService();
      analytics.logEvent('expiry_notification_failed', {
        'error': e.toString(),
        'subscription_type': subscriptionType,
      });
    }
  }

  // Show a warning to the user about notification scheduling failure
  void _showExpiryNotificationFailureWarning(DateTime expiryDate) {
    try {
      // Format the expiry date for display
      final formattedDate =
          '${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}';

      // Show a warning toast or in-app notification
      if (navigatorKey.currentContext != null) {
        // Show a snackbar if we have a context
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
                'We couldn\'t schedule a reminder for your subscription expiry on $formattedDate. '
                'Please check your device settings to allow notifications.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open notification settings
                _openNotificationSettings();
              },
            ),
          ),
        );
      } else {
        // If we don't have a context, use the notification service to show a local notification
        _notificationService.showImmediateNotification(
          title: 'Subscription Reminder Issue',
          body:
              'We couldn\'t schedule a reminder for your subscription expiry. Please check the app for details.',
          payload: 'subscription_expiry_reminder_failed',
        );
      }
    } catch (e) {
      // Just log if showing the warning fails
      LoggingService.logError('RevenueCat Service',
          'Error showing notification failure warning', e);
    }
  }

  // Helper to open notification settings
  Future<void> _openNotificationSettings() async {
    try {
      await _notificationService.openNotificationSettings();
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error opening notification settings', e);
    }
  }

  Future<void> cancelExpiryNotification() async {
    try {
      await _notificationService.cancelExpiryNotification();
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error cancelling expiry notification', e);
    }
  }

  /// Get price for a specific product
  String getPriceForProduct(String productId) {
    if (_offerings == null || _offerings!.current == null) {
      return '';
    }

    final packages = _offerings!.current!.availablePackages;
    final package = packages.firstWhere(
      (p) => p.storeProduct.identifier == productId,
      orElse: () => packages.first,
    );

    return package.storeProduct.priceString;
  }

  /// Get package for a specific product
  Package? getPackageForProduct(String productId) {
    if (_offerings == null || _offerings!.current == null) {
      return null;
    }

    final packages = _offerings!.current!.availablePackages;
    try {
      return packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check access and show paywall if needed
  Future<bool> checkAccessAndShowPaywallIfNeeded(BuildContext context) async {
    if (!context.mounted) return isPremium;

    if (isPremium) {
      return true;
    }

    // Store context mounted state before async operations
    final bool contextMounted = context.mounted;

    try {
      // Check if there's a valid entitlement
      final bool hasEntitlement = _customerInfo?.entitlements
              .all[RevenueCatProductIds.entitlementId]?.isActive ??
          false;

      if (isPremium && !hasEntitlement) {
        // We have a discrepancy - let's refresh customer info
        await _loadCustomerInfo();
      }

      if (isPremium) {
        return true;
      }

      // Check if context is still valid
      if (!contextMounted || !context.mounted) return false;

      // Show premium paywall
      await showSubscriptionPlans(context);

      // Check if they purchased after seeing the paywall
      return isPremium;
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error checking premium access', e);
      return false;
    }
  }

  /// Show error dialog
  void showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Verify if the user has active premium entitlements
  Future<bool> verifyPremiumEntitlements() async {
    try {
      // Check if Purchases is configured before attempting to verify entitlements
      if (!await _isPurchasesConfigured()) {
        debugPrint(
            'RevenueCatService: Purchases not configured, configuring now');
        await _configurePurchases();
        // If still not configured after an attempt, return false
        if (!await _isPurchasesConfigured()) {
          debugPrint('RevenueCatService: Failed to configure Purchases');
          return false;
        }
      }

      final customerInfo = await Purchases.getCustomerInfo();
      // Update based on the latest customer info
      _updateSubscriptionStatusFromCustomerInfo(customerInfo);

      // Return premium status
      return isPremium; // Fall back to current status
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error verifying premium entitlements', e);
      return false;
    }
  }

  /// Debug paywall configuration and offerings
  Future<Map<String, dynamic>> debugPaywallConfiguration() async {
    final debugInfo = <String, dynamic>{
      'revenueCat_configured': await Purchases.isConfigured,
      'offerings_available': _offerings != null,
      'current_offering': _offerings?.current?.identifier,
      'available_packages': _offerings?.current?.availablePackages.length ?? 0,
      'customer_info_available': _customerInfo != null,
      'premium_active': isPremium,
      'active_subscription': _activeSubscription.toString(),
      'purchase_status': _purchaseStatus.toString(),
      'expiry_date': _expiryDate?.toString(),
    };

    if (_offerings?.current != null) {
      final packageInfo = <String, dynamic>{};

      for (final package in _offerings!.current!.availablePackages) {
        packageInfo[package.identifier] = {
          'product_id': package.storeProduct.identifier,
          'price': package.storeProduct.price,
          'price_string': package.storeProduct.priceString,
          'title': package.storeProduct.title,
          'description': package.storeProduct.description,
        };
      }

      debugInfo['packages'] = packageInfo;
    }

    return debugInfo;
  }

  /// Check if entitlement persistence is working correctly
  Future<Map<String, dynamic>> verifyEntitlementsPersistence() async {
    final prefs = await SharedPreferences.getInstance();

    final storedSubscriptionType = prefs.getString('subscription_type');
    final storedExpiryDate = prefs.getInt('expiry_date');

    final persistenceInfo = <String, dynamic>{
      'stored_subscription_type': storedSubscriptionType,
      'active_subscription': _activeSubscription.toString(),
      'match_subscription':
          _activeSubscription.toString() == storedSubscriptionType,
      'stored_expiry_date': storedExpiryDate != null
          ? DateTime.fromMillisecondsSinceEpoch(storedExpiryDate).toString()
          : null,
      'active_expiry_date': _expiryDate?.toString(),
    };

    return persistenceInfo;
  }

  /// Update purchase status
  void _updatePurchaseStatus(PurchaseStatus status, {String? errorMessage}) {
    _purchaseStatus = status;

    if (errorMessage != null) {
      _errorMessage = errorMessage;
      LoggingService.logError(
          'RevenueCat Service', 'Purchase error', Exception(errorMessage));
    } else if (status == PurchaseStatus.error && _errorMessage.isEmpty) {
      _errorMessage = 'An unknown error occurred with your purchase.';
    } else if (status != PurchaseStatus.error) {
      _errorMessage = '';
    }

    notifyListeners();
  }

  /// Show purchase success animation
  void _showPurchaseSuccessAnimation(SubscriptionType subscriptionType) {
    PurchaseSuccessHandler.showSuccessAnimationGlobal(subscriptionType);
  }

  /// Save purchases to preferences with enhanced error handling and recovery
  Future<void> _savePurchasesToPrefs() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Add a small delay on retries
        if (retryCount > 0) {
          await Future.delayed(Duration(milliseconds: 300 * retryCount));
        }

        final prefs = await SharedPreferences.getInstance();
        bool allSuccess = true;

        // Save each preference individually and track success
        if (_activeSubscription != SubscriptionType.none) {
          // Use try-catch for each operation to allow partial success
          try {
            final subscriptionSaved = await prefs.setString(
                'subscription_type', _activeSubscription.toString());
            if (!subscriptionSaved) allSuccess = false;
          } catch (e) {
            allSuccess = false;
            LoggingService.logError(
                'RevenueCat Service', 'Failed to save subscription_type', e);
          }

          if (_expiryDate != null) {
            try {
              final expirySaved = await prefs.setInt(
                  'expiry_date', _expiryDate!.millisecondsSinceEpoch);
              if (!expirySaved) allSuccess = false;
            } catch (e) {
              allSuccess = false;
              LoggingService.logError(
                  'RevenueCat Service', 'Failed to save expiry_date', e);
            }
          }

          try {
            final premiumSaved = await prefs.setBool('is_premium', true);
            if (!premiumSaved) allSuccess = false;
          } catch (e) {
            allSuccess = false;
            LoggingService.logError(
                'RevenueCat Service', 'Failed to save is_premium', e);
          }
        } else {
          try {
            // When resetting, try operations separately
            final typeSaved = await prefs.remove('subscription_type');
            final expirySaved = await prefs.remove('expiry_date');
            final premiumSaved = await prefs.setBool('is_premium', false);

            if (!typeSaved || !expirySaved || !premiumSaved) {
              allSuccess = false;
            }
          } catch (e) {
            allSuccess = false;
            LoggingService.logError(
                'RevenueCat Service', 'Failed to reset subscription data', e);
          }
        }

        // Create backup of critical subscription data
        if (allSuccess) {
          try {
            // Create a backup record with timestamp
            final backupData = {
              'subscription_type': _activeSubscription.toString(),
              'expiry_date': _expiryDate?.millisecondsSinceEpoch,
              'is_premium': _activeSubscription != SubscriptionType.none,
              'backup_timestamp': DateTime.now().millisecondsSinceEpoch,
            };

            await prefs.setString(
                'subscription_backup', jsonEncode(backupData));

            final analytics = AnalyticsService();
            analytics.logEvent('Purchases saved to prefs successfully');

            // Success - break out of retry loop
            return;
          } catch (e) {
            LoggingService.logError('RevenueCat Service',
                'Failed to create subscription backup', e);
            // Continue with retry if backup fails
          }
        }

        // If we get here, something failed - retry
        retryCount++;
        LoggingService.logWarning('RevenueCat Service',
            'Retrying preference save ($retryCount/$maxRetries)');
      } catch (e) {
        // Catches errors from SharedPreferences.getInstance() or other unexpected errors
        retryCount++;
        LoggingService.logError('RevenueCat Service',
            'Error saving purchases to prefs (attempt $retryCount)', e);
      }
    }

    // If we exhausted retries, try to show user feedback
    if (retryCount >= maxRetries) {
      LoggingService.logError('RevenueCat Service',
          'Failed to save purchases after $maxRetries attempts');

      // Show error to user if we have access to UI
      _showStorageErrorDialog(
          'We were unable to save your purchase information locally. '
          'Your purchase is still valid but you may need to restore it when you restart the app.');
    }
  }

  /// Load purchases from preferences with enhanced error handling
  Future<void> _loadPurchasesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to load direct preferences
      bool prefLoadSuccessful = false;
      SubscriptionType? loadedSubscription;
      DateTime? loadedExpiryDate;

      try {
        // Check stored preferences first for faster startup
        final storedSubscriptionType = prefs.getString('subscription_type');
        final storedExpiryDateMillis = prefs.getInt('expiry_date');

        if (storedSubscriptionType != null) {
          // Parse the subscription type enum
          loadedSubscription = SubscriptionType.values.firstWhere(
            (type) => type.toString() == storedSubscriptionType,
            orElse: () => SubscriptionType.none,
          );

          if (storedExpiryDateMillis != null) {
            loadedExpiryDate = _parseDateTime(storedExpiryDateMillis);
          }

          prefLoadSuccessful = true;
        }
      } catch (e) {
        LoggingService.logError(
            'RevenueCat Service', 'Error loading direct preferences', e);
        prefLoadSuccessful = false;
      }

      // If direct preference load failed, try to recover from backup
      if (!prefLoadSuccessful) {
        try {
          final backupJson = prefs.getString('subscription_backup');
          if (backupJson != null) {
            final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

            final backupSubscriptionType =
                backupData['subscription_type'] as String?;
            final backupExpiryDateMillis = backupData['expiry_date'] as int?;

            if (backupSubscriptionType != null) {
              loadedSubscription = SubscriptionType.values.firstWhere(
                (type) => type.toString() == backupSubscriptionType,
                orElse: () => SubscriptionType.none,
              );

              if (backupExpiryDateMillis != null) {
                loadedExpiryDate = _parseDateTime(backupExpiryDateMillis);
              }

              // Restore from backup to main prefs
              LoggingService.logEvent('RevenueCat Service',
                  'Restored subscription data from backup');

              // Try to restore main preferences
              await prefs.setString(
                  'subscription_type', backupSubscriptionType);
              if (backupExpiryDateMillis != null) {
                await prefs.setInt('expiry_date', backupExpiryDateMillis);
              }
              await prefs.setBool(
                  'is_premium', loadedSubscription != SubscriptionType.none);
            }
          }
        } catch (e) {
          LoggingService.logError(
              'RevenueCat Service', 'Failed to recover from backup', e);
        }
      }

      // Apply the loaded subscription data if available
      if (loadedSubscription != null) {
        _activeSubscription = loadedSubscription;
        _expiryDate = loadedExpiryDate;

        // Check if the subscription has expired
        if (_activeSubscription != SubscriptionType.none &&
            _activeSubscription != SubscriptionType.lifetime &&
            _expiryDate != null &&
            _expiryDate!.isBefore(DateTime.now())) {
          // Subscription has expired, reset it
          _activeSubscription = SubscriptionType.none;
          _expiryDate = null;

          // Update preferences to reflect expiration
          try {
            await prefs.remove('subscription_type');
            await prefs.remove('expiry_date');
            await prefs.setBool('is_premium', false);
          } catch (e) {
            LoggingService.logError('RevenueCat Service',
                'Failed to update expired subscription status', e);
          }
        }
      }
    } catch (e) {
      LoggingService.logError('RevenueCat Service',
          'Critical error loading purchases from prefs', e);

      // Use defaults if everything fails
      _activeSubscription = SubscriptionType.none;
      _expiryDate = null;

      // Show recovery dialog
      _showStorageErrorDialog(
          'There was a problem loading your purchase information. '
          'If you have previously purchased a subscription, you can restore it from the settings.');
    }
  }

  // Helper method to show a storage error dialog
  void _showStorageErrorDialog(String message) {
    try {
      // Use the service's own navigatorKey
      if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Storage Issue'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to restore purchases
                  // In a real implementation this would use named routes
                  // For now just close the dialog to fix the linter error
                  // Navigator.of(context).pushNamed('/settings/purchases/restore');
                },
                child: const Text('Restore Purchase'),
              ),
            ],
          ),
        );
      } else {
        // Just log if we can't show a dialog
        LoggingService.logError('RevenueCat Service',
            'Unable to show dialog - no valid context', null);
      }
    } catch (e) {
      // If showing dialog fails, just log the error
      LoggingService.logError(
          'RevenueCat Service', 'Failed to show storage error dialog', e);
    }
  }

  /// Check and schedule expiry notification if needed
  Future<void> _checkAndScheduleExpiryNotification() async {
    try {
      // Cancel any existing expiry notification
      await cancelExpiryNotification();

      // Only schedule for non-lifetime subscriptions
      if (_activeSubscription != SubscriptionType.none &&
          _activeSubscription != SubscriptionType.lifetime &&
          _expiryDate != null) {
        // Calculate when to show the notification (3 days before expiry)
        final notificationDate = _expiryDate!.subtract(const Duration(days: 3));

        // Only schedule if the notification date is in the future
        if (notificationDate.isAfter(DateTime.now())) {
          // Schedule the notification
          await scheduleExpiryNotification(
            notificationDate,
            _activeSubscription.toString(),
          );

          final analytics = AnalyticsService();
          analytics.logEvent('Scheduled expiry notification', {
            'expiry_date': _expiryDate.toString(),
            'notification_date': notificationDate.toString(),
          });
        }
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error checking expiry notification', e);
    }
  }

  /// Get RevenueCat offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      debugPrint(
          '💰 RevenueCatService: Attempting to get offerings before initialization');
      // Try to initialize first before fetching offerings
      await initialize();

      // If initialization failed, return null instead of crashing
      if (!_isInitialized) {
        debugPrint(
            '💰 RevenueCatService: Cannot get offerings - initialization failed');
        return null;
      }
    }

    try {
      // Check if Purchases is configured before attempting to get offerings
      if (!await _isPurchasesConfigured()) {
        debugPrint(
            'RevenueCatService: Purchases not configured, configuring now');
        await _configurePurchases();
        // If still not configured after an attempt, return null
        if (!await _isPurchasesConfigured()) {
          debugPrint('RevenueCatService: Failed to configure Purchases');
          return null;
        }
      }

      if (_offerings == null) {
        await _loadOfferings();
      }
      return _offerings;
    } catch (e) {
      debugPrint('💰 RevenueCatService: Error getting offerings: $e');
      return null;
    }
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
    _queueProcessor?.cancel();
    super.dispose();
  }

  /// Fix convert string to DateTime function
  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return null;
    }

    try {
      if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        LoggingService.logWarning('RevenueCat Service',
            'Expiry date value is an unexpected type: ${dateValue.runtimeType}');
        return null;
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error parsing expiry date', e);
      return null;
    }
  }

  /// Opens the subscription management page for the user
  Future<void> openSubscriptionManagementPage() async {
    try {
      // Implement with your RevenueCat SDK call
      LoggingService.logEvent(
          'subscription', 'Opening subscription management page');
      // If you have a different implementation available, use that instead
      // For now, we're providing a simple implementation
      return;
    } catch (e) {
      LoggingService.logEvent(
          'error', 'Error opening subscription management page: $e');
    }
  }

  String get statusText {
    switch (_purchaseStatus) {
      case PurchaseStatus.notPurchased:
        return 'Not Purchased';
      case PurchaseStatus.error:
        return _errorMessage.isEmpty ? 'Error' : _errorMessage;
      case PurchaseStatus.pending:
        return 'Pending';
      case PurchaseStatus.purchased:
        return 'Purchased';
      case PurchaseStatus.purchasing:
        return 'Processing...';
      case PurchaseStatus.notFound:
        return 'Product Not Found';
      case PurchaseStatus.restored:
        return 'Restored';
      case PurchaseStatus.expired:
        return 'Expired';
    }
  }

  // Helper method to safely check if purchases is configured
  Future<bool> _isPurchasesConfigured() async {
    try {
      return await Purchases.isConfigured;
    } catch (e) {
      debugPrint(
          'RevenueCatService: Error checking if purchases is configured: $e');
      return false;
    }
  }

  // Load transaction queue from persistent storage
  Future<void> _loadTransactionQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('transaction_queue');

      if (queueJson != null && queueJson.isNotEmpty) {
        final List<dynamic> queueData = jsonDecode(queueJson);
        _transactionQueue.clear();

        for (var item in queueData) {
          _transactionQueue.add(PurchaseTransaction.fromJson(item));
        }

        debugPrint(
            'RevenueCatService: Loaded ${_transactionQueue.length} transactions from storage');

        // Filter out completed transactions older than 24 hours
        _cleanupOldTransactions();
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error loading transaction queue', e);
    }
  }

  // Save transaction queue to persistent storage
  Future<void> _saveTransactionQueue() async {
    try {
      // Filter out completed transactions older than 24 hours first
      _cleanupOldTransactions();

      final prefs = await SharedPreferences.getInstance();
      final queueData = _transactionQueue.map((tx) => tx.toJson()).toList();
      await prefs.setString('transaction_queue', jsonEncode(queueData));
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error saving transaction queue', e);
    }
  }

  // Remove old completed transactions to prevent the queue from growing indefinitely
  void _cleanupOldTransactions() {
    final now = DateTime.now();
    _transactionQueue.removeWhere((tx) =>
        tx.status == TransactionStatus.completed &&
        now.difference(tx.timestamp).inHours > 24);
  }

  // Start the queue processor timer
  void _startQueueProcessor() {
    _queueProcessor?.cancel();
    _queueProcessor = Timer.periodic(const Duration(seconds: 30), (_) {
      processTransactionQueue();
    });

    // Process immediately as well
    processTransactionQueue();
  }

  // Process the transaction queue
  Future<void> processTransactionQueue() async {
    // Don't process if already processing or queue is empty
    if (_isProcessingQueue || _transactionQueue.isEmpty) {
      return;
    }

    _isProcessingQueue = true;

    try {
      // Check for network connectivity first
      final connectivityResults = await Connectivity().checkConnectivity();
      final connectivityResult = connectivityResults.isNotEmpty
          ? connectivityResults.first
          : ConnectivityResult.none;
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('No network connection. Adding to transaction queue...');
        _isProcessingQueue = false;
        return;
      }

      // Process transactions in FIFO order
      for (int i = 0; i < _transactionQueue.length; i++) {
        final transaction = _transactionQueue[i];

        // Skip already completed transactions
        if (transaction.status == TransactionStatus.completed) {
          continue;
        }

        // Skip transactions that have failed too many times
        if (transaction.retryCount >= 5) {
          transaction.status = TransactionStatus.failed;
          continue;
        }

        // Process the transaction
        try {
          debugPrint(
              'RevenueCatService: Processing transaction ${transaction.productId}');
          transaction.status = TransactionStatus.processing;

          // Attempt to process the purchase
          await purchaseProduct(transaction.productId);

          // If we got here without exceptions, mark as completed
          transaction.status = TransactionStatus.completed;
          debugPrint(
              'RevenueCatService: Transaction ${transaction.productId} completed successfully');
        } catch (e) {
          transaction.status = TransactionStatus.retrying;
          transaction.retryCount++;
          transaction.error = e.toString();
          debugPrint(
              'RevenueCatService: Transaction ${transaction.productId} failed: $e (retry ${transaction.retryCount}/5)');
        }

        // Save queue state after each transaction
        await _saveTransactionQueue();
      }
    } catch (e) {
      LoggingService.logError(
          'RevenueCat Service', 'Error processing transaction queue', e);
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Get the current transaction queue items for UI display
  List<Map<String, dynamic>> getTransactionQueueItems() {
    // Create a list of transactions in a format suitable for UI display
    return _transactionQueue.map((tx) {
      return {
        'productId': tx.productId,
        'status': tx.status.toString().split('.').last,
        'date': DateTime.fromMillisecondsSinceEpoch(
                tx.timestamp.millisecondsSinceEpoch)
            .toString()
            .substring(0, 16),
        'retryCount': tx.retryCount,
        'error': tx.error,
      };
    }).toList();
  }

  /// Check if a specific product is currently in the transaction queue
  bool isProductInTransactionQueue(String productId) {
    return _transactionQueue.any((tx) =>
        tx.productId == productId && tx.status != TransactionStatus.completed);
  }

  /// Force process the transaction queue
  Future<void> forceProcessTransactionQueue() async {
    await processTransactionQueue();
  }
}
