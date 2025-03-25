#!/bin/bash

# Script to run code coverage analysis using LCOV
# This script will:
# 1. Run all tests with coverage
# 2. Generate HTML and JSON reports
# 3. Update the tracking files with results

echo "🧪 Starting code coverage analysis..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Clean previous coverage data
echo "🧹 Cleaning previous coverage data..."
rm -rf coverage
mkdir -p coverage

# Run tests with coverage
echo "🔍 Running tests with coverage..."
flutter test --coverage

# Check if tests ran successfully
if [ $? -ne 0 ]; then
  echo "❌ Tests failed, but continuing with coverage analysis of what we have..."
fi

# Generate HTML report with LCOV
echo "📊 Generating LCOV HTML report..."
genhtml coverage/lcov.info -o coverage/html

# Extract coverage data
echo "📝 Extracting coverage metrics..."

# Get total coverage percentage
COVERAGE_PCT=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $4}')
echo "Overall line coverage: $COVERAGE_PCT"

# Create directories for coverage reports
mkdir -p coverage_by_module
mkdir -p coverage_report

# Generate lists of covered and uncovered files
echo "📋 Generating file lists..."
lcov --list coverage/lcov.info | grep -v "Total" | awk '{print $1}' | sort > all_files.txt

# Filter for covered files (non-zero coverage)
cat all_files.txt | while read -r file; do
  file_coverage=$(lcov --extract coverage/lcov.info "$file" --output-file /dev/null --summary 2>&1 | grep "lines" | awk '{print $4}')
  if [[ "$file_coverage" != "0.0%" ]]; then
    echo "$file" >> covered_files.txt
  else
    echo "$file" >> untested_files.txt
  fi
done

# Generate detailed report
echo "📄 Generating detailed coverage report..."
echo "# Code Coverage Report" > coverage_report.md
echo "" >> coverage_report.md
echo "Generated on: $(date)" >> coverage_report.md
echo "" >> coverage_report.md
echo "## Overall Coverage" >> coverage_report.md
echo "" >> coverage_report.md
echo "Line coverage: $COVERAGE_PCT" >> coverage_report.md
echo "" >> coverage_report.md

# Add module-specific coverage
echo "## Coverage by Module" >> coverage_report.md
echo "" >> coverage_report.md

MODULES=("models" "providers" "screens" "services" "utils" "widgets")
for module in "${MODULES[@]}"; do
  # Extract coverage for this module
  lcov --extract coverage/lcov.info "*lib/$module/*" --output-file "coverage_by_module/$module.info" 2>/dev/null
  
  # Get module coverage
  if [ -f "coverage_by_module/$module.info" ]; then
    MODULE_COVERAGE=$(lcov --summary "coverage_by_module/$module.info" 2>&1 | grep "lines" | awk '{print $4}')
    echo "### $module: $MODULE_COVERAGE" >> coverage_report.md
    echo "" >> coverage_report.md
    
    # List top 5 files with lowest coverage
    echo "Top 5 files with lowest coverage in $module:" >> coverage_report.md
    echo "" >> coverage_report.md
    echo "| File | Coverage |" >> coverage_report.md
    echo "|------|----------|" >> coverage_report.md
    
    lcov --list "coverage_by_module/$module.info" | grep -v "Total" | sort -k 2 | head -5 | \
    awk '{print "| " $1 " | " $2 " |"}' >> coverage_report.md
    echo "" >> coverage_report.md
  else
    echo "### $module: No data available" >> coverage_report.md
    echo "" >> coverage_report.md
  fi
done

# Add lists of files that need tests
echo "## Files Needing Tests" >> coverage_report.md
echo "" >> coverage_report.md
if [ -f "untested_files.txt" ]; then
  echo "The following files have 0% coverage and should be prioritized for testing:" >> coverage_report.md
  echo "" >> coverage_report.md
  echo '```' >> coverage_report.md
  cat untested_files.txt >> coverage_report.md
  echo '```' >> coverage_report.md
else
  echo "No completely untested files found." >> coverage_report.md
fi

echo "✅ Coverage analysis complete!"
echo "📊 HTML report available at: $(pwd)/coverage/html/index.html"
echo "📝 Coverage summary available at: $(pwd)/coverage_report.md"

# Update the testing tracker
echo "🔄 Updating testing tracker..."

# Mark the first task as complete in the testing_tracker.md
sed -i '' 's/- \[ \] 1.1 Run LCOV to check overall test coverage/- \[x\] 1.1 Run LCOV to check overall test coverage/' testing_tracker.md
sed -i '' 's/- \[ \] 1.2 Generate coverage report/- \[x\] 1.2 Generate coverage report/' testing_tracker.md
sed -i '' 's/- \[ \] 1.3 Identify untested files and core logic gaps/- \[x\] 1.3 Identify untested files and core logic gaps/' testing_tracker.md

# Update overall progress for task 1
sed -i '' 's/- \[ \] \*\*1. Code Coverage Analysis\*\* - 0% complete/- \[x\] \*\*1. Code Coverage Analysis\*\* - 100% complete/' testing_tracker.md

echo "🎉 All done!" 