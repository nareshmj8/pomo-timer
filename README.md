# Pomodoro Timer App - iCloud Sync UI

This project implements the UI for iCloud Sync in a Pomodoro Timer app.

## Project Structure

The app is organized into several key components:

### Services

The app uses a component-based architecture for its services:

- **Notification Service**: Manages all app notifications (timer, break, subscription)
  - See `lib/services/notification/README.md` for details

- **In-App Purchase (IAP) Service**: Handles premium subscriptions and purchases
  - See `lib/services/iap/README.md` for details

- **Sync Service**: Manages data synchronization across devices using iCloud
  - See `ICLOUD_SYNC_README.md` for details

### API Keys Configuration

The app requires RevenueCat API keys for in-app purchases:

1. Copy the template file:
   ```
   cp lib/config/api_keys.template.dart lib/config/api_keys.dart
   ```

2. Edit `lib/config/api_keys.dart` and replace the placeholder values with your actual RevenueCat API keys.

3. The `api_keys.dart` file is included in `.gitignore` to ensure sensitive credentials are not committed to the repository.

### Screens

- Home Screen: Main timer interface
- Statistics Screen: Shows productivity metrics
- Settings Screen: App configuration
- Premium Screen: Subscription options

## Testing the iCloud Sync UI

To test the iCloud Sync UI:

1. Make sure you have all the required dependencies:
   ```
   flutter pub get
   ```

2. Run the app:
   ```
   flutter run
   ```

3. Navigate to the Settings screen, where you'll find the "Data Settings" option.

4. Tap on "Data Settings" to access the iCloud Sync UI.

5. Test the following functionality:
   - Toggle the iCloud Sync switch ON/OFF
   - Tap the "Sync Now" button to see the 2-second loading animation
   - Observe the "Last Synced" timestamp update
   - See the success Snackbar appear after syncing

## Alternative Testing Method

If you want to directly test just the iCloud Sync UI without navigating through the app:

1. Run the test app:
   ```
   flutter run -t lib/test_app.dart
   ```

This will directly open the Settings screen where you can access the Data Settings page.

## iCloud Sync Tests

The app includes a comprehensive test suite for verifying iCloud sync functionality:

1. To run all iCloud sync tests:
   ```
   flutter test test/integration_tests/run_all_tests.dart
   ```

2. To run tests on a real iOS device:
   ```
   ./test/integration_tests/run_icloud_tests.sh
   ```

3. For more details about the test suite, see:
   ```
   test/integration_tests/ICLOUD_SYNC_TESTS_README.md
   ```

The test suite covers:
- Initial data sync
- Offline mode sync
- Conflict resolution
- Settings sync
- Data integrity
- Background sync

## Implementation Details

- The UI is implemented using Flutter with Cupertino-style elements for iOS.
- iCloud sync is implemented using Flutter's method channels to communicate with native iOS CloudKit APIs.
- The sync service handles conflict resolution using timestamp-based strategy.
- Offline changes are queued and synced when the device comes back online.
- Background sync is supported to ensure data consistency across devices.
