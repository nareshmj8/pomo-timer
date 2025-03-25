#!/bin/bash

# Script to run all tests and generate a comprehensive report
# This script will:
# 1. Run unit tests, widget tests, and integration tests
# 2. Generate a comprehensive test report
# 3. Update the testing tracker

echo "🧪 Running all automated tests..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Create a results directory
mkdir -p test_results

# Function to run tests with a specific tag and store results
run_tagged_tests() {
  local tag=$1
  local output_file="test_results/${tag}_test_results.txt"
  
  echo "Running $tag tests..."
  flutter test --tags "$tag" > "$output_file" 2>&1
  
  if [ $? -eq 0 ]; then
    echo "✅ $tag tests passed!"
    return 0
  else
    echo "❌ $tag tests failed!"
    return 1
  fi
}

# Function to run all tests and store results
run_all_tests() {
  local output_file="test_results/all_test_results.txt"
  
  echo "Running all tests..."
  flutter test > "$output_file" 2>&1
  
  if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
    return 0
  else
    echo "❌ Some tests failed!"
    return 1
  fi
}

# Function to run integration tests and store results
run_integration_tests() {
  local output_file="test_results/integration_test_results.txt"
  
  echo "Running integration tests..."
  flutter test integration_test > "$output_file" 2>&1
  
  if [ $? -eq 0 ]; then
    echo "✅ Integration tests passed!"
    return 0
  else
    echo "❌ Integration tests failed!"
    return 1
  fi
}

# Run tests and collect results
UNIT_TESTS_PASSED=0
WIDGET_TESTS_PASSED=0
INTEGRATION_TESTS_PASSED=0
ALL_TESTS_PASSED=0

# Run unit tests
run_tagged_tests "unit"
UNIT_TESTS_PASSED=$?

# Run widget tests
run_tagged_tests "widget"
WIDGET_TESTS_PASSED=$?

# Run integration tests
run_integration_tests
INTEGRATION_TESTS_PASSED=$?

# Run all tests
run_all_tests
ALL_TESTS_PASSED=$?

# Generate a comprehensive test report
echo "📊 Generating test report..."

# Create the report file
REPORT_FILE="test_results/test_report.md"
echo "# Test Execution Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Generated on: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Add summary section
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Test Type | Status |" >> "$REPORT_FILE"
echo "|-----------|--------|" >> "$REPORT_FILE"

# Add status for each test type
if [ $UNIT_TESTS_PASSED -eq 0 ]; then
  echo "| Unit Tests | ✅ Passed |" >> "$REPORT_FILE"
else
  echo "| Unit Tests | ❌ Failed |" >> "$REPORT_FILE"
fi

if [ $WIDGET_TESTS_PASSED -eq 0 ]; then
  echo "| Widget Tests | ✅ Passed |" >> "$REPORT_FILE"
else
  echo "| Widget Tests | ❌ Failed |" >> "$REPORT_FILE"
fi

if [ $INTEGRATION_TESTS_PASSED -eq 0 ]; then
  echo "| Integration Tests | ✅ Passed |" >> "$REPORT_FILE"
else
  echo "| Integration Tests | ❌ Failed |" >> "$REPORT_FILE"
fi

if [ $ALL_TESTS_PASSED -eq 0 ]; then
  echo "| All Tests | ✅ Passed |" >> "$REPORT_FILE"
else
  echo "| All Tests | ❌ Failed |" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# Add detail sections for each test type
echo "## Unit Tests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
cat "test_results/unit_test_results.txt" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## Widget Tests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
cat "test_results/widget_test_results.txt" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## Integration Tests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
cat "test_results/integration_test_results.txt" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## All Tests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
cat "test_results/all_test_results.txt" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Add failing tests section if any tests failed
if [ $ALL_TESTS_PASSED -ne 0 ]; then
  echo "## Failing Tests" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "The following tests are failing and need attention:" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  
  # Extract failing tests from the all_test_results.txt file
  grep -A 3 "FAILED" "test_results/all_test_results.txt" >> "$REPORT_FILE"
  
  echo "" >> "$REPORT_FILE"
  echo "Please fix these failing tests before proceeding." >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
fi

echo "✅ Test report generated: $(pwd)/$REPORT_FILE"

# Update the testing tracker
echo "🔄 Updating testing tracker..."

# Mark the tasks as complete or in progress in the testing_tracker.md
sed -i '' 's/- \[ \] 3.1 Run unit tests/- \[x\] 3.1 Run unit tests/' testing_tracker.md
sed -i '' 's/- \[ \] 3.2 Run widget tests/- \[x\] 3.2 Run widget tests/' testing_tracker.md
sed -i '' 's/- \[ \] 3.3 Run integration tests/- \[x\] 3.3 Run integration tests/' testing_tracker.md
sed -i '' 's/- \[ \] 3.4 Record test results and identify failures/- \[x\] 3.4 Record test results and identify failures/' testing_tracker.md

# Update overall progress for task 3
sed -i '' 's/- \[ \] \*\*3. Run All Automated Tests\*\* - 0% complete/- \[x\] \*\*3. Run All Automated Tests\*\* - 100% complete/' testing_tracker.md

if [ $ALL_TESTS_PASSED -ne 0 ]; then
  # If tests failed, mark task 4 as in progress
  sed -i '' 's/- \[ \] 4.1 Analyze test failures/- \[~\] 4.1 Analyze test failures - In progress/' testing_tracker.md
  sed -i '' 's/- \[ \] 4.2 Debug and fix test issues/- \[~\] 4.2 Debug and fix test issues - In progress/' testing_tracker.md
  sed -i '' 's/- \[ \] \*\*4. Debug Failing Tests\*\* - 0% complete/- \[~\] \*\*4. Debug Failing Tests\*\* - 25% complete/' testing_tracker.md
fi

echo "🎉 All done!" 