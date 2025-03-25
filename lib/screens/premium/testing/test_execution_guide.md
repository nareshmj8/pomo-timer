# RevenueCat Integration Test Guide

This guide provides step-by-step instructions for validating the RevenueCat subscription flow, UI responsiveness, and entitlements persistence.

## Prerequisites
- Physical iOS device or simulator
- RevenueCat account with configured products
- App running in sandbox mode for testing

## Test Execution Steps

### 1. Access the Test Suite
1. Launch the app
2. Navigate to the Premium screen
3. Tap the debug button (usually in the top-right corner)
4. Select "Open Test Suite" from the debug menu

### 2. Run Comprehensive Tests
1. In the RevenueCat Test Suite screen, review the current status card
2. Tap "Run All Tests" to execute the complete test suite
3. Observe the test logs and results dialog
4. Review each test result and note any failures

### 3. Test Specific Features
If you need to focus on specific areas, use the individual test buttons:

#### Pricing & Offerings Tests
1. Tap "Test Offerings"
2. Verify that offerings are loaded successfully
3. Check that all packages and prices are displayed correctly
4. Confirm that the retry logic works when network issues occur

#### Subscription & Restore Flow Tests
1. Navigate back to the Premium screen
2. Test the purchase flow by selecting a subscription plan
3. Cancel before completing the purchase (to avoid actual charges)
4. Test the restore purchases functionality
5. Return to the test suite and verify entitlements

#### UI & Debugging Tests
1. Tap "Test UI" to verify UI responsiveness
2. Check that loading dialogs appear and disappear correctly
3. Verify that error handling works properly

### 4. Verify Entitlements Persistence
1. Tap "Test Persistence"
2. Verify that entitlements persist after app restart
3. Check that the premium status is correctly maintained

### 5. Error Handling Tests
1. Test network failure scenarios by enabling airplane mode
2. Verify that appropriate error messages are displayed
3. Test retry mechanisms when network is restored

## Expected Results

### Pricing & Offerings
- PricingContainer updates dynamically based on RevenueCat offerings
- Loading states are handled properly
- Automatic retry logic works for API failures

### Subscription & Restore Flow
- Purchase flow shows appropriate animations & state transitions
- RestorePurchasesHandler properly handles edge cases & retries
- Network failure handling works correctly
- Premium entitlements update dynamically after purchases/restores

### UI & Debugging
- RevenueCat initialization & offerings retrieval works correctly
- Entitlements persist after app restart
- UI is responsive with smooth animations & transitions
- State updates correctly when toggling test cases

## Troubleshooting
- If tests fail, check the detailed logs in the test suite
- Verify RevenueCat configuration in the dashboard
- Ensure the app is running in sandbox mode for testing
- Check network connectivity and API keys 