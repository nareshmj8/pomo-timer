# Sandbox Testing Checklist for In-App Purchases

This document provides a comprehensive checklist for testing in-app purchases in the StoreKit sandbox environment.

## Prerequisites

Before beginning testing, ensure:

- [x] You are signed into a sandbox test account on your device (not your regular Apple ID)
- [x] Your app has the sandbox testing mode enabled (use the "Enable Sandbox Testing" button)
- [x] You have a stable internet connection
- [x] Your RevenueCat API keys are configured correctly

## Basic Purchase Flow Tests

### 1. Products Loading

- [ ] Verify all products load correctly with proper titles and prices
- [ ] Verify product descriptions are displayed correctly
- [ ] Verify introductory pricing information is shown if applicable
- [ ] Verify localized pricing is shown correctly

### 2. Purchase Initiation

- [ ] Verify tapping "Subscribe" or "Purchase" shows the Apple payment sheet
- [ ] Verify the payment sheet shows correct product information
- [ ] Verify the sandbox account email is pre-filled

### 3. Purchase Completion

- [ ] Verify successful purchase is processed correctly
- [ ] Verify UI updates to reflect premium status
- [ ] Verify appropriate success message is shown
- [ ] Verify premium features are unlocked

### 4. Subscription Management

- [ ] Verify user can see their active subscription status
- [ ] Verify subscription expiration date is shown correctly
- [ ] Verify renewal information is displayed

## Error Handling Tests

### 1. Network Interruption

- [ ] Test purchase with airplane mode enabled mid-purchase
- [ ] Verify transaction is queued for later processing
- [ ] Verify app handles reconnection gracefully
- [ ] Verify transaction completes when connectivity is restored

### 2. User Cancellation

- [ ] Cancel purchase from payment sheet
- [ ] Verify app returns to previous state gracefully
- [ ] Verify appropriate message is shown
- [ ] Verify no unexpected side effects

### 3. Payment Sheet Timeout

- [ ] Let payment sheet time out without user action
- [ ] Verify app handles timeout gracefully
- [ ] Verify user is notified appropriately
- [ ] Verify transaction is not left in a corrupted state

### 4. Invalid Sandbox Account

- [ ] Test with non-sandbox Apple ID
- [ ] Verify appropriate error message
- [ ] Test with sandbox account that has payment issues
- [ ] Verify error handling is user-friendly

## Advanced Tests

### 1. Subscription Renewal

- [ ] Verify auto-renewable subscription renewal
- [ ] Test renewal at different intervals (only possible with specific sandbox test accounts)
- [ ] Verify renewal notifications are shown
- [ ] Verify subscription continues to work after renewal

### 2. Subscription Expiration

- [ ] Verify graceful handling of subscription expiration
- [ ] Verify appropriate messaging for expired subscriptions
- [ ] Verify UI updates correctly for expired subscription
- [ ] Verify renewal flow works for expired subscriptions

### 3. Subscription Upgrade/Downgrade

- [ ] Test upgrading from monthly to yearly
- [ ] Test downgrading from yearly to monthly
- [ ] Verify proration is handled correctly
- [ ] Verify subscription level changes at the appropriate time

### 4. Restore Purchases

- [ ] Test restore purchases functionality
- [ ] Verify all eligible purchases are restored
- [ ] Verify UI updates correctly after restore
- [ ] Verify appropriate success/failure messages

### 5. App Restart Scenarios

- [ ] Complete purchase and immediately force-close the app
- [ ] Verify purchase is still active on restart
- [ ] Start purchase and force-close during payment sheet
- [ ] Verify no side effects on restart

### 6. Multiple Device Testing

- [ ] Purchase on one device and verify it syncs to another
- [ ] Verify subscription status updates across devices
- [ ] Verify restore purchases works across devices

## Testing Different Sandbox Account Behaviors

### 1. Normal Account

- [ ] Test with normal sandbox account
- [ ] Verify standard purchase flow works

### 2. Ask To Buy Account

- [ ] Test with "Ask to Buy" enabled sandbox account
- [ ] Verify deferred purchase flow is handled correctly

### 3. Declined Transaction Account

- [ ] Test with account set to decline transactions
- [ ] Verify error handling works correctly
- [ ] Verify recovery suggestions are appropriate

### 4. Interrupted Transaction Account

- [ ] Test with account that causes interrupted transactions
- [ ] Verify retry mechanism works

## Testing Transaction Queue

### 1. Queue Management

- [ ] Verify transaction queue is processed on app launch
- [ ] Verify interrupted transactions are stored in queue
- [ ] Verify queue processing retry mechanism
- [ ] Check multiple queued transactions are handled correctly

### 2. Force Queue Processing

- [ ] Add transaction to queue manually (if possible)
- [ ] Test force processing the queue
- [ ] Verify appropriate success/failure indicators

## Documentation

After completing testing, document:

- [ ] Any bugs or issues discovered
- [ ] Performance of error handling mechanisms
- [ ] Areas that need improvement
- [ ] User experience observations

## Test Results Reporting

Use a standard format to document each test:

```
Test: [Name of test]
Date: [Test date]
Tester: [Your name]
Device: [iPhone model, iOS version]
Result: [PASS/FAIL/PARTIAL]
Notes: [Observations, issues, screenshots]
```

## Interpreting Sandbox Behavior

Note that the sandbox environment has some specific behaviors that differ from production:

1. Subscriptions renew much more quickly (minutes instead of months)
2. Some sandbox accounts have special behaviors (always decline, etc.)
3. The sandbox may occasionally experience outages or service disruptions
4. Receipt validation may behave differently in sandbox

Keep these differences in mind when interpreting test results.

## Troubleshooting Common Sandbox Issues

- If payment sheet doesn't appear, verify sandbox account is logged in
- If receipt validation fails, check if you're using the correct environment setting
- If prices appear incorrect, check your StoreKit configuration
- If renewals don't work, verify you're using the correct sandbox test account

## Final Verification

After all tests are complete:

- [ ] Review logs for any unexpected errors
- [ ] Verify analytics tracking is working (if applicable)
- [ ] Verify receipt validation is working (if applicable)
- [ ] Perform a final purchase flow to confirm everything works end-to-end 