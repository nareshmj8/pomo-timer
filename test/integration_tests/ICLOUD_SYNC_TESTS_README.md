# iCloud Sync Tests for Pomodoro Timer App

This directory contains automated tests for verifying the iCloud sync functionality in the Pomodoro Timer app. The tests cover various aspects of iCloud sync, including initial data sync, offline mode sync, conflict resolution, settings sync, data integrity, and background sync.

## Test Structure

The test suite is organized into several files:

1. **comprehensive_icloud_sync_test.dart** - A comprehensive test suite that covers all aspects of iCloud sync in a well-structured format.
2. **icloud_sync_test.dart** - Basic iCloud sync tests.
3. **multi_device_sync_test.dart** - Tests for syncing data between multiple devices.
4. **background_sync_test.dart** - Tests for background sync functionality.
5. **cloudkit_native_test.dart** - Tests for native CloudKit functionality.
6. **run_all_tests.dart** - A runner that executes all test suites.

## Running the Tests

### Prerequisites

- Flutter SDK installed and configured
- Xcode (for iOS testing)
- iOS Simulator or physical iOS device

### Running All Tests

To run all iCloud sync tests, use the following command from the project root:

```bash
flutter test test/integration_tests/run_all_tests.dart
```

### Running Individual Test Suites

To run a specific test suite, use one of the following commands:

```bash
# Run comprehensive tests
flutter test test/integration_tests/comprehensive_icloud_sync_test.dart

# Run basic iCloud sync tests
flutter test test/integration_tests/icloud_sync_test.dart

# Run multi-device sync tests
flutter test test/integration_tests/multi_device_sync_test.dart

# Run background sync tests
flutter test test/integration_tests/background_sync_test.dart

# Run CloudKit native tests
flutter test test/integration_tests/cloudkit_native_test.dart
```

## Test Coverage

The test suite covers the following scenarios:

### 1. Initial Data Sync Test
- Adding sample timer data and confirming it syncs successfully
- Verifying data appears correctly after closing and reopening the app

### 2. Offline Mode Sync Test
- Adding new timer data while the device is offline
- Confirming that data syncs correctly once the device reconnects to the internet

### 3. Conflict Resolution Test
- Modifying timer data on one device
- Modifying the same data differently on another device before sync
- Verifying that the latest edit wins (timestamp-based conflict resolution)

### 4. Settings Sync Test
- Testing that app settings (sound, theme, etc.) sync correctly across devices

### 5. Data Integrity Test
- Verifying that no duplicate, corrupted, or missing entries occur after multiple sync cycles

### 6. Background Sync Test
- Confirming that timers added while the app is in the background are successfully synced when the app becomes active

## Mocking Strategy

The tests use Flutter's testing framework to mock the iCloud behavior:

1. **Mock Method Channel**: The tests mock the platform channel used for CloudKit operations.
2. **Mock Shared Preferences**: SharedPreferences are mocked to simulate local storage.
3. **Mock Network Conditions**: Tests simulate online and offline states.
4. **Mock iCloud Availability**: Tests simulate iCloud becoming available or unavailable.

## Troubleshooting

If you encounter issues running the tests:

1. Make sure you have the latest Flutter SDK installed.
2. Run `flutter pub get` to ensure all dependencies are up to date.
3. Check that the iOS simulator is running (for iOS-specific tests).
4. Verify that the project has the correct entitlements for iCloud capabilities.

## Notes for iOS-Specific Behavior

- The tests are designed to comply with Apple's iCloud guidelines.
- Background sync tests simulate the behavior of iOS background app refresh.
- The conflict resolution strategy follows Apple's recommended approach of using timestamps for determining the latest changes.

## Adding New Tests

When adding new tests:

1. Follow the existing test structure and naming conventions.
2. Use descriptive test names that clearly indicate what is being tested.
3. Add appropriate comments to explain the test steps.
4. Update this README if necessary to reflect new test capabilities. 