# iCloud Sync Integration Tests

This directory contains automated integration tests for the iCloud sync feature in the Pomodoro Timer app.

## Test Overview

The tests verify the following key scenarios:

1. **Data Save to iCloud**: Verifies that Pomodoro session data is successfully saved to iCloud.
2. **Data Fetch from iCloud**: Ensures that data can be fetched from iCloud and is consistent across devices.
3. **Conflict Resolution**: Tests that conflicts are properly resolved using the latest timestamp approach.
4. **Offline Queue**: Verifies that operations are queued when offline and processed when online.
5. **Background Sync**: Tests that data syncs automatically in the background.
6. **iCloud Availability**: Ensures the app handles iCloud unavailability gracefully.

## Test Files

- `icloud_sync_test.dart`: Basic tests for the core sync functionality
- `multi_device_sync_test.dart`: Advanced tests simulating multiple devices
- `cloudkit_native_test.dart`: Tests for the native CloudKit implementation
- `background_sync_test.dart`: Tests for background sync functionality
- `run_all_tests.dart`: Runner to execute all tests

## Running the Tests

### Run All Tests

```bash
flutter test test/integration_tests/run_all_tests.dart
```

### Run Individual Test Files

```bash
flutter test test/integration_tests/icloud_sync_test.dart
flutter test test/integration_tests/multi_device_sync_test.dart
flutter test test/integration_tests/cloudkit_native_test.dart
flutter test test/integration_tests/background_sync_test.dart
```

## Test Implementation Details

These tests use mock method channels to simulate CloudKit behavior without requiring actual iCloud access. This allows for reliable, repeatable testing of the sync logic.

Key testing strategies:

1. **Mock CloudKit Service**: Simulates CloudKit operations using method channels
2. **Mock Devices**: Simulates multiple devices syncing with the same iCloud account
3. **Conflict Simulation**: Tests timestamp-based conflict resolution
4. **Offline Mode**: Simulates network connectivity changes
5. **Error Handling**: Tests graceful handling of various error conditions

## Adding New Tests

To add new tests:

1. Create a new test file in this directory
2. Import the necessary services and test utilities
3. Set up mock method channels as needed
4. Write test cases for the specific functionality
5. Add the new test file to `run_all_tests.dart`

## Test Coverage

These tests cover:

- ✅ Core sync functionality
- ✅ Multi-device scenarios
- ✅ Conflict resolution
- ✅ Offline operation
- ✅ Background sync
- ✅ Error handling

## Notes for Production Testing

While these tests provide good coverage of the sync logic, it's still recommended to perform manual testing on real devices with actual iCloud accounts before releasing to production. 