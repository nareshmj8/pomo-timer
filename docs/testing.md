# Testing Guide for Pomodoro TimeKeeper

This document provides information about the testing infrastructure for the Pomodoro TimeKeeper app, including unit tests, widget tests, integration tests, and golden tests.

## Test Types

### Unit Tests
Test individual functions and classes in isolation. Located in the `test/` directory.

### Widget Tests
Test individual widgets and their interactions. Located in the `test/widgets/` directory.

### Golden Tests
Verify UI appearance by comparing widget screenshots against "golden" reference images. Located in the `test/goldens/` directory.

### Integration Tests
Test user flows and interactions across multiple screens. Located in the `integration_test/` directory.

## Running Tests

### Running Unit and Widget Tests
```bash
flutter test test/
```

### Running Golden Tests
Golden tests verify that the UI appearance matches the expected "golden" images. These tests are sensitive to pixel-level changes, so they need to be run on the same device configuration as when they were created.

To run golden tests without updating the reference images:
```bash
./scripts/run_golden_tests.sh
```

### Updating Golden Tests
When you intentionally make UI changes, you'll need to update the golden images:
```bash
./scripts/update_golden_tests.sh
```

This script will:
1. Update all golden test images
2. Run all tests with coverage enabled
3. Generate an HTML coverage report

### Running Integration Tests
Integration tests should be run individually to avoid conflicts:

```bash
flutter test integration_test/timer_flow_test.dart
flutter test integration_test/task_management_test.dart
flutter test integration_test/subscription_flow_test.dart
```

## Testing Best Practices

1. **Mock Dependencies**: Use mock implementations for services and providers to isolate tests.
2. **Test Edge Cases**: Include tests for error states and edge conditions.
3. **Maintainable Golden Tests**: Keep golden tests focused on consistent visual elements.
4. **Test Coverage**: Aim for high test coverage, especially for core business logic.

## Mock Service Adapters

For services that don't extend `ChangeNotifier` but need to be used in a `Provider` context during testing, use the `ServiceProvider` class from `test/goldens/test_provider_adapters.dart`.

Example:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
    ServiceProvider<NotificationService>.value(
        value: mockNotificationService, child: const SizedBox()),
  ],
  child: MyWidget(),
);
```

## Coverage Reports

After running tests with coverage, view the HTML report at:
```
coverage/html/index.html
``` 