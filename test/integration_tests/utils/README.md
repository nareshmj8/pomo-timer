# Test Reporting System for Pomodoro Timer App

This directory contains utilities for generating comprehensive test reports for the Pomodoro Timer app's integration tests, particularly focusing on CloudKit/iCloud sync functionality.

## Features

- Automatic generation of HTML and text reports
- Saving reports in a specified folder
- Optional auto-opening of reports on test failure
- Integration with the existing test suite
- Automatic screenshot captures for failed tests
- Simple visualization of test results

## Components

### TestReporter

The `TestReporter` class handles:
- Recording test results
- Generating HTML and text reports
- Saving screenshots for failed tests

### TestRunner

The `TestRunner` class provides:
- A wrapper around Flutter's test framework
- Integration with the TestReporter
- Methods for running tests with reporting capabilities

## Usage

To use the test reporting system in your tests:

```dart
import 'utils/test_runner.dart';
import 'utils/test_reporter.dart';

void main() async {
  // Initialize test runner
  final testRunner = TestRunner();
  await testRunner.initialize();

  // Use reportingTest instead of regular test
  testRunner.reportingTest('My test case', () async {
    // Your test code here
    expect(1 + 1, equals(2));
  });

  // Generate reports after all tests are complete
  await testRunner.generateReports();
}
```

## Report Locations

Reports are saved in the following locations:

- **iOS/Android**: `<app_documents_directory>/reports/<timestamp>/`
- **Desktop**: `<downloads_directory>/reports/<timestamp>/` or `<current_directory>/reports/<timestamp>/`

Each test run creates a new directory with a timestamp to avoid overwriting previous reports.

## Report Types

- **HTML Report**: A comprehensive report with test details, error messages, screenshots, and a visual chart of results.
- **Text Report**: A simple text-based report for environments where HTML viewing is not available.

## Screenshots

For failed tests, the system attempts to capture a screenshot and include it in the report. This feature is particularly useful for UI-related failures.

## Auto-Opening Reports

By default, the HTML report will automatically open in the default browser if any tests fail. This behavior can be disabled by setting `openReportOnFailure` to `false` when creating the `TestRunner`.

```dart
final testRunner = TestRunner(openReportOnFailure: false);
```

## Example

See `comprehensive_icloud_sync_test_with_reports.dart` for a complete example of how to use the test reporting system with the existing iCloud sync tests. 