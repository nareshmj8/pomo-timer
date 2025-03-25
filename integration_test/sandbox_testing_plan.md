# Comprehensive StoreKit Sandbox Testing Plan

## Overview
This document outlines a systematic approach to testing in-app purchases (IAP) using Apple's StoreKit sandbox environment. The testing plan focuses on validating all aspects of the purchase flow, error handling, and edge cases to ensure a robust implementation.

## Prerequisites
- iOS device with latest version
- Sandbox test account configured in App Store Connect
- Device logged into sandbox test account in App Store
- Flutter dev environment with integration_test package
- App configured with RevenueCat API keys

## Test Categories

### 1. Configuration & Environment Tests
- [x] Verify correct API keys are loaded
- [x] Confirm sandbox environment is detected
- [x] Validate app-Store connection status
- [x] Check customer info retrieval from RevenueCat
- [x] Verify offerings and product configuration

### 2. Product Loading Tests
- [x] Validate all products appear in the UI
- [x] Verify product prices display correctly
- [x] Confirm product descriptions are properly formatted
- [x] Test product filtering and categorization
- [x] Validate introductory offers and discount display

### 3. Purchase Flow Tests
- [x] Test monthly subscription purchase
- [x] Test annual subscription purchase
- [x] Test lifetime purchase
- [x] Verify purchasing with and without existing subscription
- [x] Test upgrade/downgrade subscription path
- [x] Check subscription management redirects

### 4. Transaction Queue Tests
- [x] Verify transactions are added to queue properly
- [x] Test network interruption during purchase
- [x] Validate transaction retry mechanism
- [x] Test force processing the transaction queue
- [x] Check transaction receipt validation
- [x] Verify purchases persist through app restarts

### 5. Error Handling Tests
- [x] Test cancellation during payment flow
- [x] Test timeout handling during payment
- [x] Validate billing issues error handling
- [x] Test recovery from network failures
- [x] Check for error messaging in UI
- [x] Validate payment sheet presentation failures

### 6. Subscription Status Tests
- [x] Verify active subscription state reflected in UI
- [x] Test expiration and renewal handling
- [x] Validate grace period functionality
- [x] Check for entitlement granting/revocation
- [x] Test receipt refresh mechanics

## Test Scripts
The integration tests are organized into these files:
- `sandbox_iap_test.dart`: Basic configuration and purchase tests
- `sandbox_error_test.dart`: Error handling and edge cases
- `sandbox_transaction_test.dart`: Transaction queue and persistence tests
- `manual_sandbox_test.dart`: Assisted testing with manual verification

## Running Tests
Use the provided script to run all tests on a connected iPhone:
```bash
./integration_test/run_all_sandbox_tests.sh
```

Or run individual test suites:
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/sandbox_iap_test.dart -d <device_id>
```

## Troubleshooting
If tests fail, check:
1. Sandbox account login status in App Store
2. Network connectivity
3. App logs in Settings > Premium > Sandbox Testing
4. RevenueCat dashboard for transaction status
5. StoreKit debug logs in Xcode (if running via Xcode) 