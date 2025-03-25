#!/bin/bash

echo "🔍 Generating code coverage report for Pomodoro TimeKeeper..."

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "❌ lcov is not installed. Please install it:"
    echo "  - macOS: brew install lcov"
    echo "  - Linux: apt-get install lcov"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Create coverage directory if it doesn't exist
mkdir -p coverage

# Run only the standalone tests that don't depend on platform plugins
echo "🧪 Running standalone tests with coverage..."
set +e
flutter test --coverage test/widget_test.dart test/theme_test.dart
TEST_RESULT=$?
set -e

# Warn if tests failed but continue to generate the report
if [ $TEST_RESULT -ne 0 ]; then
  echo "⚠️ Some tests failed, but we'll still generate a coverage report."
fi

# Process LCOV info to exclude irrelevant files
echo "🔧 Processing coverage data..."
if [ -f "coverage/lcov.info" ]; then
  # Basic exclude patterns
  EXCLUDE_PATTERNS="*/.pub-cache/* */flutter/* */dart-sdk/* */.dart_tool/*"
  
  # Create exclude arguments for lcov
  EXCLUDE_ARGS=""
  for pattern in $EXCLUDE_PATTERNS; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS --remove coverage/lcov.info '$pattern'"
  done
  
  # Run lcov with ignore-errors flag
  eval lcov --ignore-errors unused $EXCLUDE_ARGS -o coverage/filtered_lcov.info

  # Generate HTML report from filtered LCOV data
  echo "📊 Generating HTML report..."
  genhtml coverage/filtered_lcov.info -o coverage/html

  # Calculate total coverage percentage
  echo "🔎 Coverage Summary:"
  lcov --summary coverage/filtered_lcov.info 2>&1 | tee /tmp/coverage_summary.txt
  
  # Extract coverage percentage
  COVERAGE_PCT=$(grep "lines" /tmp/coverage_summary.txt | awk '{print $2}')

  echo ""
  echo "📈 Coverage Summary:"
  echo "------------------------------------------------"
  echo "Overall coverage: $COVERAGE_PCT"
  echo "For detailed report, open: coverage/html/index.html"
  echo ""

  # List all Dart files and their coverage
  echo "🧾 Coverage by file:"
  lcov --list coverage/filtered_lcov.info

  # Find completely untested files
  echo ""
  echo "❌ Completely untested files (0% coverage):"
  lcov --list coverage/filtered_lcov.info | grep " 0.0%" | awk '{print $1}'

  # Count files with coverage
  echo ""
  echo "🔍 Files coverage statistics:"
  # Get count of files with any coverage (exclude header and footer lines)
  COVERED_FILES_COUNT=$(lcov --list coverage/filtered_lcov.info | grep -v "Total" | grep -v "Filename" | grep -v "^$" | grep -v "===" | wc -l | tr -d ' ')
  
  # Get count of files with non-zero coverage
  FILES_WITH_COVERAGE=$(lcov --list coverage/filtered_lcov.info | grep -v " 0.0%" | grep -v "Total" | grep -v "Filename" | grep -v "^$" | grep -v "===" | wc -l | tr -d ' ')
  
  # Count all Dart files in lib directory
  TOTAL_FILES_COUNT=$(find lib -name "*.dart" -not -path "*/generated/*" | wc -l | tr -d ' ')
  
  # Calculate and display percentages
  PERCENT_COVERED=$(echo "scale=2; ($FILES_WITH_COVERAGE / $TOTAL_FILES_COUNT) * 100" | bc)
  
  echo "Files with non-zero coverage: $FILES_WITH_COVERAGE / $TOTAL_FILES_COUNT ($PERCENT_COVERED%)"
  echo "Files tracked by coverage tool: $COVERED_FILES_COUNT"
  echo "Files with 0% coverage: $(($COVERED_FILES_COUNT - $FILES_WITH_COVERAGE))"
  echo "Files not tracked by tests: $(($TOTAL_FILES_COUNT - $COVERED_FILES_COUNT))"

  # Open the report in the default browser
  if [[ "$OSTYPE" == "darwin"* ]]; then
      open coverage/html/index.html
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      xdg-open coverage/html/index.html
  elif [[ "$OSTYPE" == "msys" ]]; then
      start coverage/html/index.html
  fi
else
  echo "❌ No coverage data was generated. This might happen if all tests were skipped or failed."
fi 