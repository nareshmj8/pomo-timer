#!/bin/bash

# Script to run iCloud sync tests on a real iOS device

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running iCloud Sync Tests for Pomodoro Timer App${NC}"
echo -e "${YELLOW}===============================================${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed. Please install Flutter and try again.${NC}"
    exit 1
fi

# Check if a device is connected
DEVICES=$(flutter devices)
if [[ $DEVICES != *"ios"* ]]; then
    echo -e "${RED}No iOS device detected. Please connect an iOS device and try again.${NC}"
    echo -e "${YELLOW}Available devices:${NC}"
    echo "$DEVICES"
    exit 1
fi

# Run tests
echo -e "${YELLOW}Running comprehensive iCloud sync tests...${NC}"
flutter test --device-id=ios test/integration_tests/comprehensive_icloud_sync_test.dart

# Check if the tests passed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Comprehensive iCloud sync tests passed!${NC}"
else
    echo -e "${RED}Comprehensive iCloud sync tests failed.${NC}"
    exit 1
fi

echo -e "${YELLOW}Running all iCloud sync tests...${NC}"
flutter test --device-id=ios test/integration_tests/run_all_tests.dart

# Check if the tests passed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}All iCloud sync tests passed!${NC}"
else
    echo -e "${RED}Some iCloud sync tests failed.${NC}"
    exit 1
fi

echo -e "${GREEN}All tests completed successfully!${NC}"
exit 0 