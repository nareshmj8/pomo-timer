#!/bin/bash

# Script to run all StoreKit sandbox tests on a connected iOS device
# This script will run all the test suites sequentially

# Set text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   COMPREHENSIVE SANDBOX TESTING SUITE      ${NC}"
echo -e "${BLUE}============================================${NC}"

# Detect iPhone device ID
DEVICE_ID=$(flutter devices | grep -i 'iPhone' | grep -v 'simulator' | head -1 | awk -F'•' '{print $2}' | tr -d ' ')

if [ -z "$DEVICE_ID" ]; then
  echo -e "${RED}⚠️ No iPhone device found. Please connect your iPhone and ensure it's recognized by Flutter.${NC}"
  exit 1
fi

echo -e "${GREEN}📱 Found iPhone device: $DEVICE_ID${NC}"
echo -e "${YELLOW}🧪 Running StoreKit Sandbox tests...${NC}"

# Print instructions for successful testing
echo ""
echo -e "${BLUE}=== IMPORTANT INSTRUCTIONS ===${NC}"
echo "1. Ensure you are signed in with a sandbox test account in App Store"
echo "2. Keep the device unlocked during testing"
echo "3. When payment sheets appear, use the sandbox test account credentials"
echo "4. Do not interrupt the test until it completes"
echo -e "${BLUE}===========================${NC}"
echo ""

# Wait for user confirmation
read -p "Are you ready to proceed? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Test cancelled. Exiting..."
  exit 0
fi

# Create an array of test files
TEST_FILES=(
  "integration_test/sandbox_iap_test.dart"
  "integration_test/sandbox_error_test.dart"
  "integration_test/sandbox_transaction_test.dart"
)

# Track success/failure counts
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_TESTS=()

# Run each test suite
for test_file in "${TEST_FILES[@]}"; do
  echo ""
  echo -e "${YELLOW}📋 Running test suite: $(basename "$test_file")${NC}"
  echo ""
  
  # Run the test with timeout to prevent hanging
  flutter drive --driver=test_driver/integration_test.dart --target="$test_file" -d "$DEVICE_ID"
  
  # Check the result
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test suite $(basename "$test_file") completed successfully!${NC}"
    ((SUCCESS_COUNT++))
  else
    echo -e "${RED}❌ Test suite $(basename "$test_file") failed.${NC}"
    ((FAILURE_COUNT++))
    FAILED_TESTS+=("$(basename "$test_file")")
  fi
  
  # Brief pause between test suites
  echo "Pausing for 5 seconds before next test suite..."
  sleep 5
done

# Finally, run the manual test for interactive testing if requested
echo ""
echo -e "${BLUE}Do you want to run the manual sandbox test suite?${NC}"
echo "This will launch the app and enable sandbox testing for 5 minutes"
echo "to allow you to perform manual testing while logs are captured."
read -p "Run manual tests? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}🧪 Running manual sandbox testing...${NC}"
  flutter drive --driver=test_driver/integration_test.dart --target=integration_test/manual_sandbox_test.dart -d "$DEVICE_ID"
fi

# Summary
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   SANDBOX TESTING RESULTS                 ${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}✅ Successful test suites: $SUCCESS_COUNT${NC}"
echo -e "${RED}❌ Failed test suites: $FAILURE_COUNT${NC}"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}Failed test suites:${NC}"
  for failed_test in "${FAILED_TESTS[@]}"; do
    echo -e "${RED}- $failed_test${NC}"
  done
fi

echo ""
echo -e "${BLUE}To view detailed logs, check the Settings screen and tap on 'Sandbox Testing' option.${NC}"
echo -e "${GREEN}All test results are also logged in the device console.${NC}"
echo "" 