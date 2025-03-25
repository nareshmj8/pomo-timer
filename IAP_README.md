# In-App Purchase Implementation Guide

This document provides an overview of the In-App Purchase (IAP) implementation in the Pomo Timer app.

## Overview

The IAP system in Pomo Timer allows users to purchase premium features through three subscription options:
- Monthly Subscription ($0.99/month)
- Yearly Subscription ($5.99/year)
- Lifetime Access ($14.99 one-time payment)

## Implementation Details

### Files

- `lib/services/iap_service.dart`: Core service that handles all IAP functionality
- `lib/screens/premium_screen.dart`: UI for displaying subscription options and handling purchases

### Features

- ✅ Fetching products from the App Store
- ✅ Handling purchases (monthly, yearly, lifetime)
- ✅ Managing subscription status
- ✅ On-device receipt validation
- ✅ Restoring purchases
- ✅ Unlocking premium features
- ✅ Handling subscription expiry
- ✅ Error handling

## How to Use

### 1. Setup App Store Connect

Before testing IAP functionality, you need to set up your products in App Store Connect:

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to your app > Features > In-App Purchases
3. Create three in-app purchases with the following product IDs:
   - `com.naresh.pomodorotimemaster.premium.monthly` (Auto-Renewable Subscription)
   - `com.naresh.pomodorotimemaster.premium.yearly` (Auto-Renewable Subscription)
   - `com.naresh.pomodorotimemaster.premium.lifetime` (Non-Consumable)
4. Configure pricing, descriptions, and review information

### 2. Testing IAP in Development

To test IAP during development:

1. Use a Sandbox Test Account:
   - In App Store Connect, go to Users and Access > Sandbox > Testers
   - Create a sandbox tester account
   - On your test device, sign out of your regular Apple ID
   - When prompted during testing, sign in with your sandbox account

2. Enable StoreKit Testing (iOS 14+):
   - In Xcode, go to Product > Scheme > Edit Scheme
   - Select Run > Options
   - Check "StoreKit Configuration" and select your configuration file

### 3. Using the IAP Service in Code

To check if a user has premium access:

```dart
final iapService = Provider.of<IAPService>(context, listen: false);
if (iapService.isPremium) {
  // Show premium features
} else {
  // Show basic features or prompt to upgrade
}
```

To listen for changes in subscription status:

```dart
Consumer<IAPService>(
  builder: (context, iapService, child) {
    return iapService.isPremium
      ? PremiumFeatureWidget()
      : BasicFeatureWidget();
  },
)
```

### 4. Handling Purchases

The purchase flow is handled automatically by the `IAPService` class. When a user taps the "Subscribe" button on the Premium screen, the following happens:

1. The selected product is retrieved from the available products
2. The purchase flow is initiated through the App Store
3. The purchase stream listens for updates
4. On successful purchase, the receipt is validated and the user's subscription status is updated
5. The UI is updated to reflect the new subscription status

## Troubleshooting

### Common Issues

1. **Products not loading**: Ensure your App Store Connect setup is complete and the app's bundle ID matches.

2. **Purchases not completing**: Check that you're signed in with a sandbox test account and that the account is properly configured.

3. **Receipt validation failing**: For testing, the app uses basic on-device validation. In production, consider implementing server-side validation.

### Testing Receipt Validation

For testing receipt validation without a server:

1. Make a purchase with a sandbox account
2. The app will automatically validate the receipt
3. Check the debug console for validation logs

## Production Considerations

Before releasing to production:

1. **Server-side validation**: Consider implementing server-side receipt validation for added security.

2. **Subscription management**: Provide users with clear information on how to manage their subscriptions.

3. **Restore purchases**: Ensure the "Restore Purchases" functionality works correctly across devices.

4. **Error handling**: Test various error scenarios (network issues, cancellations, etc.) to ensure a smooth user experience.

## Resources

- [Apple's In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [Flutter in_app_purchase Package](https://pub.dev/packages/in_app_purchase)
- [StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode) 