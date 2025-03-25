# Subscription Expiry Notification System

This document outlines the implementation of the Subscription Expiry Notification System for the Pomo Timer app.

## Overview

The Subscription Expiry Notification System automatically detects when a user's subscription is about to expire (3 days before expiry) and sends a local notification to remind them to renew. The system works for both monthly and yearly subscriptions, but not for lifetime subscriptions (which never expire).

## Components

### 1. Notification Service (`lib/services/notification_service.dart`)

The `NotificationService` class is responsible for:
- Initializing the notification system
- Scheduling expiry notifications
- Canceling notifications
- Handling notification taps

### 2. IAP Service Integration (`lib/services/iap_service.dart`)

The `IAPService` class has been updated to:
- Initialize the notification service
- Schedule expiry notifications when a subscription is purchased
- Cancel notifications when a subscription expires or is upgraded to lifetime
- Check for expiry notifications on app startup

## Features

### Automatic Expiry Detection

The system automatically calculates when a subscription will expire based on the purchase date:
- Monthly subscriptions expire after 30 days
- Yearly subscriptions expire after 365 days
- Lifetime subscriptions never expire

### Local Notifications

Notifications are sent 3 days before the subscription expires, with:
- A clear title indicating which subscription is expiring
- A message encouraging renewal
- A "Renew Now" action that redirects to the Premium Screen

### Background Task Support

The system is designed to work even when the app is closed:
- Notifications are scheduled using the device's alarm system
- The expiry date is stored in SharedPreferences for persistence

### Edge Case Handling

The system handles various edge cases:
- No notifications for lifetime subscribers
- Cancellation of notifications when upgrading to lifetime
- No notifications for already expired subscriptions
- Proper handling of subscription restoration

## Implementation Details

### Notification Scheduling

Notifications are scheduled using the `flutter_local_notifications` package, which provides cross-platform support for local notifications. On iOS, the system uses the `UNUserNotificationCenter` to schedule notifications.

### Timezone Handling

The system uses the `timezone` package to ensure notifications are scheduled at the correct time regardless of the user's timezone.

### Persistence

Notification information is stored in SharedPreferences to ensure persistence across app restarts.

## Testing

The notification system is covered by automated tests in `test/services/notification_service_test.dart`, which verify:
- Scheduling notifications for different subscription types
- Canceling notifications
- Edge case handling

## Future Improvements

Potential future improvements include:
- Multiple reminders (e.g., 3 days, 1 day, and day of expiry)
- A/B testing different notification messages
- Server-side validation of subscription status
- Deep linking to specific renewal options 