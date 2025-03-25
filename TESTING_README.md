# Pomodoro Timer Testing Framework

This testing framework provides a comprehensive system for testing the Pomodoro Timer app before submission to the App Store. It follows the testing roadmap outlined in `final_testing.txt`.

## Overview

The testing framework is designed to:

1. Analyze code coverage to identify untested areas
2. Generate and run automated tests
3. Test critical features like RevenueCat integration and iCloud sync
4. Perform performance and security testing
5. Generate comprehensive reports
6. Prepare the app for App Store submission

## Getting Started

### Prerequisites

- Flutter development environment set up
- LCOV installed for code coverage analysis
- Xcode for iOS testing and App Store submission

### Quick Start

Run the master script to execute all testing steps in sequence:

```bash
./scripts/run_all_testing.sh
```

This will guide you through the entire testing process from code coverage analysis to App Store preparation.

## Available Scripts

### Analysis Scripts

- `scripts/run_coverage_analysis.sh`: Analyzes code coverage using LCOV
- `scripts/prioritize_tests.sh`: Prioritizes which tests to write based on coverage data

### Test Generation and Execution

- `scripts/prepare_test_templates.sh`: Creates test templates for high-priority services
- `scripts/run_all_tests.sh`: Runs all tests and generates reports

### Feature Testing

- `integration_test/icloud_sync_test.dart`: Tests iCloud sync functionality
- `test/services/iap_service_test.dart`: Tests RevenueCat integration
- `test/theme/dark_mode_test.dart`: Tests dark mode compatibility

### Performance and Security

- `scripts/run_performance_tests.sh`: Tests app performance (startup time, memory usage, etc.)
- `scripts/run_security_tests.sh`: Tests app security (secure storage, etc.)

### Reporting and Submission

- `scripts/generate_test_summary.sh`: Generates a comprehensive test summary report
- `scripts/prepare_for_app_store.sh`: Prepares the app for App Store submission

## Testing Workflow

1. **Code Coverage Analysis**: Run `scripts/run_coverage_analysis.sh` to identify untested code
2. **Test Prioritization**: Run `scripts/prioritize_tests.sh` to determine which tests to write first
3. **Test Template Generation**: Run `scripts/prepare_test_templates.sh` to generate test templates
4. **Test Implementation**: Implement the test files created by the templates
5. **Test Execution**: Run `scripts/run_all_tests.sh` to run all tests
6. **Performance Testing**: Run `scripts/run_performance_tests.sh` to test app performance
7. **Security Testing**: Run `scripts/run_security_tests.sh` to test app security
8. **Test Summary**: Run `scripts/generate_test_summary.sh` to generate a comprehensive report
9. **App Store Preparation**: Run `scripts/prepare_for_app_store.sh` to prepare for submission

## Progress Tracking

The `testing_tracker.md` file tracks the progress of the testing process. Each script updates this file as it completes its tasks.

## Report Locations

- Code coverage report: `coverage_report.md`
- Test prioritization: `test_priorities.md`
- Test results: `test_results/test_report.md`
- Performance report: `performance_results/performance_summary.md`
- Security report: `security_results/security_summary.md`
- Test summary report: `test_summary/test_summary_report.md`
- App Store preparation report: `app_store_prep/app_store_prep_report.md`

## Custom Testing

If you need to run specific parts of the testing process, you can run the individual scripts as needed.

### Example: Running Only Performance Tests

```bash
./scripts/run_performance_tests.sh
```

### Example: Preparing for App Store without Running Tests

```bash
./scripts/prepare_for_app_store.sh
```

## Troubleshooting

### Script Permission Issues

If you encounter permission issues when running the scripts, make sure they are executable:

```bash
chmod +x scripts/*.sh
```

### Test Failures

If tests fail, check the test reports in the `test_results` directory for details on what failed and why.

## Contributing

To add new tests or improve existing ones:

1. Create new test files in the appropriate directories
2. Update the testing tracker to reflect the new tests
3. Run the tests to ensure they work correctly

## License

This testing framework is provided as part of the Pomodoro Timer app and is subject to the same license terms. 