# iCloud Sync Implementation

This document provides an overview of the iCloud sync implementation in the Pomodoro Timer app, which is a premium-only feature.

## Architecture

The iCloud sync feature is implemented using the following components:

1. **SyncService**: Manages the sync process and state, including enabling/disabling sync, checking premium status, and handling sync errors.
2. **SyncDataHandler**: Handles the actual data synchronization between local storage and iCloud, including retrieving local data, updating local data from cloud, and resolving conflicts.
3. **CloudKitService**: Provides a wrapper around the native CloudKit API, handling the communication with iCloud.

## Premium-Only Implementation

The iCloud sync feature is implemented as a premium-only feature, with the following key aspects:

1. **Default Disabled**: iCloud sync is disabled by default for all users.
2. **Premium Check**: Before enabling sync, the app checks if the user has a valid premium subscription.
3. **Premium Status Listener**: The app listens for changes in premium status and automatically disables sync if premium status is lost.
4. **UI Restrictions**: The UI prevents non-premium users from enabling sync and shows appropriate premium upgrade prompts.

## Key Files

- `lib/services/sync_service.dart`: Main service for managing sync process and state.
- `lib/services/sync/sync_data_handler.dart`: Handles data synchronization and conflict resolution.
- `lib/services/cloudkit_service.dart`: Wrapper around native CloudKit API.
- `lib/screens/settings/data_settings_page.dart`: UI for managing sync settings.
- `lib/screens/settings/testing/icloud_sync_test_helper.dart`: Helper for testing sync functionality.
- `lib/screens/settings/testing/icloud_sync_test_screen.dart`: Screen for running automated tests.
- `lib/screens/settings/testing/validation_checklist.md`: Checklist for validating sync functionality.

## Implementation Details

### Premium Status Verification

```dart
// Check if user is premium before enabling
if (enabled && !_revenueCatService.isPremium) {
  _errorMessage = _premiumRequiredMessage;
  notifyListeners();
  return;
}
```

### Premium Status Listener

```dart
// Listen for premium status changes
_revenueCatService.addListener(_onPremiumStatusChanged);

// Handle premium status changes
void _onPremiumStatusChanged() {
  if (!_revenueCatService.isPremium && _iCloudSyncEnabled) {
    // If user lost premium status but has sync enabled, disable it
    setSyncEnabled(false);
    _errorMessage = _premiumRequiredMessage;
    notifyListeners();
  }
}
```

### UI Restrictions

```dart
// Show premium upgrade dialog
void _showPremiumUpgradeDialog() {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
            'iCloud Sync is a premium feature. Upgrade to Premium to sync your data across devices.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Upgrade'),
            onPressed: () {
              Navigator.of(context).pop();
              // Get RevenueCatService from provider
              final revenueCatService = Provider.of<RevenueCatService>(
                  context,
                  listen: false);
              // Show paywall
              revenueCatService.presentPaywall();
            },
          ),
        ],
      );
    },
  );
}
```

## Testing

The iCloud sync feature includes comprehensive testing capabilities:

1. **Unit Tests**: Tests for individual components like SyncService, SyncDataHandler, and CloudKitService.
2. **Integration Tests**: Tests for the interaction between components, including premium status verification.
3. **Automated Tests**: In-app tests that can be run to validate sync functionality.
4. **Validation Checklist**: A comprehensive checklist for manual validation of the sync feature.

## Troubleshooting

Common issues and their solutions:

1. **Sync Not Working**: Ensure the user has a valid premium subscription and iCloud is available.
2. **Sync Failing**: Check network connectivity and iCloud availability.
3. **Data Not Syncing**: Ensure the data is properly formatted and doesn't exceed size limits.
4. **Premium Status Not Recognized**: Ensure the RevenueCatService is properly initialized and the user's subscription is valid.

## Future Improvements

Potential future improvements to the iCloud sync feature:

1. **Conflict Resolution UI**: Add a UI for resolving conflicts when the same data is modified on multiple devices.
2. **Selective Sync**: Allow users to choose which data to sync.
3. **Sync History**: Show a history of sync operations and their results.
4. **Background Sync**: Implement background sync to keep data up-to-date even when the app is not in use. 