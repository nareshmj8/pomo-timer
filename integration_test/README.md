# Integration Tests for Pomodoro Timer App

This directory contains integration tests for the Pomodoro Timer app. These tests verify that the app's key user flows work correctly from end to end.

## Test Structure

The integration tests are organized by user flow:

1. **Timer Flow Tests** (`timer_flow_test.dart`) - Tests the core timer functionality:
   - Starting, pausing, and resuming timer sessions
   - Transitioning between work sessions and breaks
   - Resetting the timer
   - Verifying timer state persistence

2. **Subscription Flow Tests** (`subscription_flow_test.dart`) - Tests the premium subscription functionality:
   - Loading and displaying subscription offerings
   - Purchasing premium subscriptions
   - Restoring previous purchases
   - Handling network failures during purchase

3. **Task Management Tests** (`task_management_test.dart`) - Tests the task management functionality:
   - Adding new tasks
   - Marking tasks as completed
   - Deleting tasks

4. **Notification Tests** (`notification_test.dart`) - Tests notification handling:
   - Showing timer completion notifications
   - Showing break completion notifications
   - Scheduling subscription expiry notifications
   - Checking notification permissions

## Running Tests

### Running Individual Tests

To run a specific test file:

```bash
flutter test integration_test/timer_flow_test.dart
```

### Running All Tests

To run all integration tests:

```bash
flutter test integration_test/integration_test.dart
```

### StoreKit Sandbox IAP Testing

To test in-app purchases using the StoreKit sandbox environment, follow these steps:

1. Connect your iOS device to your development machine
2. Ensure you have a valid sandbox test account in App Store Connect
3. Sign in with your sandbox test account on your iOS device
4. Run the sandbox IAP tests with:

```
flutter test integration_test/sandbox_iap_test.dart -d your_device_id
```

> **Important:** These tests interact with the real StoreKit sandbox environment. No actual charges will be made, but you'll see real payment sheets and purchase flows.

The sandbox IAP tests validate:
- Sandbox account detection
- Product loading in the sandbox environment
- Transaction queue functionality
- Payment sheet presentation

### UI Testing

To run UI tests:

```
flutter test integration_test/timer_flow_test.dart
```

### Subscription Flow Testing

To test the subscription purchase flow:

```
flutter test integration_test/subscription_flow_test.dart
```

> Note: This runs with mock purchases and does not interact with the real App Store.

### iCloud Sync Testing

To test iCloud sync functionality:

```
flutter test integration_test/icloud_sync_test.dart
```

## Test Implementation Notes

- The tests use mocks for external dependencies like RevenueCat to avoid real API calls.
- The notification tests use a standalone test app to avoid conflicts with the singleton NotificationService.
- The tests clear app state (SharedPreferences) before each test to ensure a clean environment.

## Troubleshooting

If tests fail with errors related to the Flutter binding or singleton initialization:
1. Make sure to use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` at the start of each test file
2. Consider using mocks or test-specific implementations for services that are implemented as singletons
3. Clear SharedPreferences and other persistence mechanisms between tests 