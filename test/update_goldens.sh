#!/bin/bash

# Script to update golden test files and generate coverage report

echo "Updating golden test files..."

# Update timer screen goldens individually
flutter test --update-goldens test/goldens/screens/timer_screen_test.dart

# Update history screen goldens
flutter test --update-goldens test/goldens/screens/history_screen_test.dart

# Update premium screen goldens
flutter test --update-goldens test/goldens/screens/premium_screen_test.dart

# Update settings screen goldens
flutter test --update-goldens test/goldens/screens/settings_screen_test.dart

echo "Golden tests updated."

echo "Generating coverage report..."
flutter test --coverage
flutter pub global run test_cov_console
echo "Coverage report generated."

echo "Done." 