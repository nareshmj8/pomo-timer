#!/bin/bash

# Script to update golden tests and generate coverage report

# Set the working directory to the project root
cd "$(dirname "$0")/.."

echo "==============================================="
echo "Updating golden tests and generating coverage..."
echo "==============================================="

# Create directories for coverage reports if they don't exist
mkdir -p coverage

# First run the golden tests with the --update-goldens flag to update
# the golden files with the current UI
echo "Updating golden test images..."
flutter test --update-goldens --no-pub test/goldens

# Then run the tests with coverage enabled
echo "Running tests with coverage..."
flutter test --no-pub --coverage test/

# Generate coverage report
echo "Generating HTML coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "==============================================="
echo "Coverage report generated!"
echo "Open coverage/html/index.html to view report"
echo "===============================================" 