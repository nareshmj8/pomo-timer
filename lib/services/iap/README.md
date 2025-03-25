# In-App Purchase (IAP) Service

This directory contains the implementation of the In-App Purchase service for the Pomodoro TimeMaster app. The service is responsible for managing premium subscriptions and purchases.

## Architecture

The IAP service is structured using a component-based architecture to improve maintainability and separation of concerns:

- **`iap_service.dart`**: Main entry point that exports all IAP components
- **`iap_models.dart`**: Contains models and constants for IAP functionality
- **`iap_service_core.dart`**: Core implementation of the IAP service
- **`iap_purchase_handler.dart`**: Handles purchase flow and verification
- **`iap_receipt_handler.dart`**: Manages receipt validation
- **`iap_purchase_verifier.dart`**: Verifies purchase authenticity
- **`iap_subscription_manager.dart`**: Manages subscription status and expiry

## Usage

To use the IAP service in your code, import the main service:

```dart
import 'package:pomodoro_timemaster/services/iap/iap_service.dart';
```

Then, obtain an instance of the service through dependency injection or directly:

```dart
final iapService = Provider.of<IAPService>(context);
// or
final iapService = IAPService();
```

### Checking Subscription Status

```dart
// Check if user has an active subscription
final isSubscribed = iapService.isSubscriptionActive;

// Get the current subscription type
final subscriptionType = iapService.activeSubscriptionType;

// Check if a specific feature is available
if (iapService.isFeatureAvailable(PremiumFeature.unlimitedSessions)) {
  // Use premium feature
}
```

### Making Purchases

```dart
// Purchase a monthly subscription
await iapService.purchaseSubscription(SubscriptionType.monthly);

// Purchase a yearly subscription
await iapService.purchaseSubscription(SubscriptionType.yearly);

// Purchase a lifetime subscription
await iapService.purchaseSubscription(SubscriptionType.lifetime);

// Restore previous purchases
await iapService.restorePurchases();
```

### Handling Purchase Events

```dart
// Listen for purchase status changes
iapService.addListener(() {
  final status = iapService.purchaseStatus;
  
  if (status == PurchaseStatus.purchased) {
    // Show success message
  } else if (status == PurchaseStatus.error) {
    // Show error message
  }
});
```

## Adding New Subscription Types

To add a new subscription type:

1. Add the new type to the `SubscriptionType` enum in `iap_models.dart`
2. Add the product ID in the `IAPProductIds` class
3. Update the `purchaseSubscription` method in `iap_service_core.dart` to handle the new type
4. Update the UI to display the new subscription option 