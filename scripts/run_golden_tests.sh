#!/bin/bash

# Script to run golden tests and verify that they pass

# Set the working directory to the project root
cd "$(dirname "$0")/.."

echo "==============================================="
echo "Running golden tests..."
echo "==============================================="

# Run all golden tests using the aggregator file
flutter test --no-pub test/goldens/run_all_goldens.dart

echo "==============================================="
echo "Golden tests completed!"
echo "===============================================" 