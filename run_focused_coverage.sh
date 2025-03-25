#!/bin/bash

# Usage info
show_usage() {
  echo "Usage: $0 [options] [test_files]"
  echo "Generate code coverage for specific test files"
  echo
  echo "Options:"
  echo "  -h, --help                Show this help message"
  echo "  -s, --service NAME        Test specific service (e.g. revenue_cat_service)"
  echo "  -p, --provider NAME       Test specific provider (e.g. timer_settings_provider)"
  echo "  -u, --ui NAME             Test specific UI component (e.g. timer_screen)"
  echo "  -a, --all                 Run all tests"
  echo "  -o, --output PATH         Output directory for report (default: coverage)"
  echo
  echo "Examples:"
  echo "  $0 -s notification_service           # Test notification service only"
  echo "  $0 -p timer_settings_provider        # Test timer settings provider only"
  echo "  $0 test/theme_test.dart              # Run specific test file(s)"
  echo "  $0 -a                                # Run all tests"
  echo
}

# Default values
OUTPUT_DIR="coverage"
ALL_TESTS=false
TEST_FILES=""

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "❌ lcov is not installed. Please install it:"
    echo "  - macOS: brew install lcov"
    echo "  - Linux: apt-get install lcov"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -s|--service)
      if [[ -n "$2" && "$2" != -* ]]; then
        # Find test files related to the service
        SERVICE_NAME="$2"
        echo "🔍 Looking for tests related to service: $SERVICE_NAME"
        # Try to find matching test files
        TEST_FILES=$(find test -type f -name "*${SERVICE_NAME}*_test.dart" | tr '\n' ' ')
        if [[ -z "$TEST_FILES" ]]; then
          echo "⚠️ No test files found for service '$SERVICE_NAME'. Creating a placeholder test file..."
          mkdir -p test/services
          cat > "test/services/${SERVICE_NAME}_test.dart" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/${SERVICE_NAME}.dart';

void main() {
  group('${SERVICE_NAME} Tests', () {
    test('TODO: Add tests for ${SERVICE_NAME}', () {
      // TODO: Implement tests
      expect(true, isTrue); // Placeholder assertion
    });
  });
}
EOF
          echo "✅ Created placeholder test file at test/services/${SERVICE_NAME}_test.dart"
          TEST_FILES="test/services/${SERVICE_NAME}_test.dart"
        else
          echo "✅ Found test files: $TEST_FILES"
        fi
        shift
      else
        echo "❌ Error: Missing service name after -s/--service option"
        exit 1
      fi
      ;;
    -p|--provider)
      if [[ -n "$2" && "$2" != -* ]]; then
        # Find test files related to the provider
        PROVIDER_NAME="$2"
        echo "🔍 Looking for tests related to provider: $PROVIDER_NAME"
        # Try to find matching test files
        TEST_FILES=$(find test -type f -name "*${PROVIDER_NAME}*_test.dart" | tr '\n' ' ')
        if [[ -z "$TEST_FILES" ]]; then
          echo "⚠️ No test files found for provider '$PROVIDER_NAME'. Creating a placeholder test file..."
          mkdir -p test/providers
          cat > "test/providers/${PROVIDER_NAME}_test.dart" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/providers/${PROVIDER_NAME}.dart';

void main() {
  group('${PROVIDER_NAME} Tests', () {
    test('TODO: Add tests for ${PROVIDER_NAME}', () {
      // TODO: Implement tests
      expect(true, isTrue); // Placeholder assertion
    });
  });
}
EOF
          echo "✅ Created placeholder test file at test/providers/${PROVIDER_NAME}_test.dart"
          TEST_FILES="test/providers/${PROVIDER_NAME}_test.dart"
        else
          echo "✅ Found test files: $TEST_FILES"
        fi
        shift
      else
        echo "❌ Error: Missing provider name after -p/--provider option"
        exit 1
      fi
      ;;
    -u|--ui)
      if [[ -n "$2" && "$2" != -* ]]; then
        # Find test files related to the UI component
        UI_NAME="$2"
        echo "🔍 Looking for tests related to UI component: $UI_NAME"
        # Try to find matching test files
        TEST_FILES=$(find test -type f -name "*${UI_NAME}*_test.dart" | tr '\n' ' ')
        if [[ -z "$TEST_FILES" ]]; then
          echo "⚠️ No test files found for UI component '$UI_NAME'. Creating a placeholder test file..."
          mkdir -p test/screens
          cat > "test/screens/${UI_NAME}_test.dart" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/screens/${UI_NAME}.dart';
import '../test_app.dart';

void main() {
  group('${UI_NAME} Tests', () {
    testWidgets('TODO: Add tests for ${UI_NAME}', (WidgetTester tester) async {
      // TODO: Implement tests
      await tester.pumpWidget(
        TestApp(
          child: Container(), // Replace with your widget under test
        ),
      );
      
      // Add test expectations here
      expect(find.byType(Container), findsOneWidget); // Placeholder assertion
    });
  });
}
EOF
          echo "✅ Created placeholder test file at test/screens/${UI_NAME}_test.dart"
          TEST_FILES="test/screens/${UI_NAME}_test.dart"
        else
          echo "✅ Found test files: $TEST_FILES"
        fi
        shift
      else
        echo "❌ Error: Missing UI component name after -u/--ui option"
        exit 1
      fi
      ;;
    -a|--all)
      ALL_TESTS=true
      ;;
    -o|--output)
      if [[ -n "$2" && "$2" != -* ]]; then
        OUTPUT_DIR="$2"
        shift
      else
        echo "❌ Error: Missing path after -o/--output option"
        exit 1
      fi
      ;;
    *)
      # If not an option, treat as test file
      if [[ "$1" != -* ]]; then
        TEST_FILES="$TEST_FILES $1"
      else
        echo "❌ Error: Unknown option $1"
        show_usage
        exit 1
      fi
      ;;
  esac
  shift
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Run tests with coverage
echo "🧪 Running tests with coverage..."
set +e

if [[ "$ALL_TESTS" = true ]]; then
  flutter test --coverage
elif [[ -n "$TEST_FILES" ]]; then
  flutter test --coverage $TEST_FILES
else
  echo "❌ Error: No test files specified"
  show_usage
  exit 1
fi

TEST_RESULT=$?
set -e

# Process coverage report
if [ -f "coverage/lcov.info" ]; then
  # Basic exclude patterns
  EXCLUDE_PATTERNS="*/.pub-cache/* */flutter/* */dart-sdk/* */.dart_tool/*"
  
  # Create exclude arguments for lcov
  EXCLUDE_ARGS=""
  for pattern in $EXCLUDE_PATTERNS; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS --remove coverage/lcov.info '$pattern'"
  done
  
  # Run lcov with ignore-errors flag
  echo "🔧 Processing coverage data..."
  eval lcov --ignore-errors unused $EXCLUDE_ARGS -o "$OUTPUT_DIR/filtered_lcov.info"

  # Generate HTML report
  echo "📊 Generating HTML report..."
  genhtml "$OUTPUT_DIR/filtered_lcov.info" -o "$OUTPUT_DIR/html"

  # Calculate coverage statistics
  echo "🔎 Coverage Summary:"
  lcov --summary "$OUTPUT_DIR/filtered_lcov.info" 2>&1 | tee /tmp/coverage_summary.txt
  
  # Extract coverage percentage
  COVERAGE_PCT=$(grep "lines" /tmp/coverage_summary.txt | awk '{print $2}')

  echo ""
  echo "📈 Coverage Summary:"
  echo "------------------------------------------------"
  echo "Overall coverage: $COVERAGE_PCT"
  echo "For detailed report, open: $OUTPUT_DIR/html/index.html"
  echo ""

  # Open the report in the default browser
  if [[ "$OSTYPE" == "darwin"* ]]; then
      open "$OUTPUT_DIR/html/index.html"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      xdg-open "$OUTPUT_DIR/html/index.html"
  elif [[ "$OSTYPE" == "msys" ]]; then
      start "$OUTPUT_DIR/html/index.html"
  fi
else
  echo "❌ No coverage data was generated. This might happen if all tests were skipped or failed."
fi 