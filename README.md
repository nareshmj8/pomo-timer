# Pomodoro Timer App - iCloud Sync UI

This project implements the UI for iCloud Sync in a Pomodoro Timer app.

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

## Implementation Details

- The UI is implemented using Flutter with Cupertino-style elements for iOS.
- Sync state is currently stored using SharedPreferences.
- The code is structured to easily replace SharedPreferences with actual iCloud sync in the future.
