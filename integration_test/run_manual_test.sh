#!/bin/bash

# Script to run manual sandbox testing on a connected iOS device

# Detect iPhone device ID
DEVICE_ID=$(flutter devices | grep -i 'iPhone' | grep -v 'simulator' | head -1 | awk -F'•' '{print $2}' | tr -d ' ')

if [ -z "$DEVICE_ID" ]; then
  echo "⚠️ No iPhone device found. Please connect your iPhone and ensure it's recognized by Flutter."
  exit 1
fi

echo "📱 Found iPhone device: $DEVICE_ID"
echo "🧪 Running manual sandbox testing helper..."

# Print instructions for successful testing
echo ""
echo "=== IMPORTANT INSTRUCTIONS ==="
echo "1. Ensure you are signed in with a sandbox test account in App Store"
echo "2. Keep the device unlocked during testing"
echo "3. The test will navigate to Premium screen and enable sandbox testing"
echo "4. You'll have 5 minutes to perform manual testing while logs are captured"
echo "==========================="
echo ""

# Wait for user confirmation
read -p "Are you ready to proceed? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Test cancelled. Exiting..."
  exit 0
fi

# Run the test
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/manual_sandbox_test.dart \
  -d $DEVICE_ID

# Check the result
if [ $? -eq 0 ]; then
  echo "✅ Manual sandbox testing completed successfully!"
else
  echo "❌ Manual sandbox testing failed."
fi

# Instructions for reviewing logs
echo ""
echo "To view detailed logs, check the Settings > Premium screen and tap on 'Sandbox Testing' option."
echo "" 