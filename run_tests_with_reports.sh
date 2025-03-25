#!/bin/bash

# Make sure the required packages are installed
echo "Checking dependencies..."
flutter pub get

# Run the integration tests with reporting
echo "Running integration tests with reporting..."
flutter drive --driver=test_driver/integration_test.dart --target=test/integration_tests/run_tests_with_reports.dart

# Check if the tests passed
if [ $? -eq 0 ]; then
  echo "Tests passed!"
else
  echo "Tests failed! Check the reports for details."
fi

# Print the location of the reports
echo "Reports are saved in the following locations:"
echo "- iOS/Android: <app_documents_directory>/reports/<timestamp>/"
echo "- Desktop: <downloads_directory>/reports/<timestamp>/ or <current_directory>/reports/<timestamp>/" 