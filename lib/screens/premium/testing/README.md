# RevenueCat Testing Tools

This directory contains tools and utilities for testing the RevenueCat integration in the app.

## Overview

The testing framework provides comprehensive tools to validate:
- RevenueCat initialization and configuration
- Offerings and product pricing
- Purchase and restore flows
- Premium entitlements and features
- Network handling and error scenarios
- UI responsiveness and state transitions

## Available Tools

### 1. RevenueCatTestScreen

A dedicated UI for running tests and viewing results. Access it from the Premium Debug Menu by selecting "Open Test Suite".

Features:
- Status dashboard showing current RevenueCat state
- Buttons for running comprehensive or specific tests
- Network failure simulation tools
- Real-time test logs

### 2. RevenueCatTestHelper

A utility class that provides automated tests for RevenueCat integration.

Key methods:
- `runAutomatedTests()`: Runs a comprehensive test suite
- `_testRetryLogic()`: Tests retry mechanisms for API failures
- `_testUIResponsiveness()`: Tests UI responsiveness
- `_testErrorHandling()`: Tests error handling scenarios

### 3. NetworkFailureSimulator

A utility class for simulating network failures to test error handling.

Key methods:
- `simulateOfferingsNetworkFailure()`: Tests offerings retrieval with network failures
- `simulatePurchaseNetworkFailure()`: Tests purchase flow with network failures
- `simulateRestoreNetworkFailure()`: Tests restore process with network failures

## Test Documentation

The following files provide documentation for testing:

- `test_execution_guide.md`: Step-by-step guide for running tests
- `test_report_template.md`: Template for documenting test results
- `test_checklist.md`: Comprehensive checklist for manual testing

## How to Run Tests

1. Launch the app
2. Navigate to the Premium screen
3. Tap the debug button (usually in the top-right corner)
4. Select "Open Test Suite" from the debug menu
5. Use the test buttons to run specific tests or the full suite

## Best Practices

1. **Run in Sandbox Mode**: Always test purchases in sandbox mode to avoid real charges.
2. **Test on Real Devices**: While simulators work for basic testing, use real devices for complete validation.
3. **Document Results**: Use the provided templates to document test results.
4. **Test Edge Cases**: Pay special attention to network failures and error scenarios.
5. **Verify Persistence**: Always verify that entitlements persist after app restart.

## Troubleshooting

If tests fail, check the following:
1. RevenueCat API keys are configured correctly
2. Network connectivity is stable
3. App is running in sandbox mode
4. RevenueCat dashboard is properly configured
5. Test user accounts are set up correctly

## Adding New Tests

To add new tests:
1. Add test methods to the appropriate test class
2. Update the UI to include buttons for the new tests
3. Update documentation to reflect the new tests
4. Ensure test results are properly logged and displayed 