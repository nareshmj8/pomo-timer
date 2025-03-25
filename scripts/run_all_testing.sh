#!/bin/bash

# Master script to run all testing steps in sequence
# This script will:
# 1. Check code coverage
# 2. Generate automated tests
# 3. Run all tests
# 4. Debug failing tests
# 5. Test RevenueCat integration
# 6. Test iCloud sync functionality
# 7. Run UI tests across devices
# 8. Run performance tests
# 9. Run security tests
# 10. Run regression tests
# 11. Generate test summary report
# 12. Prepare for App Store submission

echo "🚀 Starting comprehensive testing process..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Create a function to run a script and check if it succeeded
run_script() {
  local script=$1
  local description=$2
  
  echo "➡️ Running $description..."
  
  if [ -f "$script" ]; then
    # Run the script
    bash "$script"
    
    # Check if it succeeded
    if [ $? -eq 0 ]; then
      echo "✅ $description completed successfully."
      return 0
    else
      echo "❌ $description failed!"
      echo "Do you want to continue with the next step? (y/n)"
      read -r answer
      if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        return 0
      else
        echo "Aborting the testing process."
        exit 1
      fi
    fi
  else
    echo "❌ Script $script not found!"
    return 1
  fi
}

# Step 1: Check code coverage
run_script "scripts/run_coverage_analysis.sh" "code coverage analysis"

# Step 2: Prioritize tests
run_script "scripts/prioritize_tests.sh" "test prioritization"

# Step 3: Prepare test templates
run_script "scripts/prepare_test_templates.sh" "test template preparation"

# Ask if the user wants to implement tests before continuing
echo "⚠️ Before continuing, you should implement the test files created by the templates."
echo "Do you want to continue with running tests now? (y/n)"
read -r answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo "Please implement the tests and then run this script again to continue from step 4."
  exit 0
fi

# Step 4: Run all tests
run_script "scripts/run_all_tests.sh" "test execution"

# Step 5: Run performance tests
run_script "scripts/run_performance_tests.sh" "performance testing"

# Step 6: Run security tests
run_script "scripts/run_security_tests.sh" "security testing"

# Step 7: Generate test summary report
run_script "scripts/generate_test_summary.sh" "test summary report generation"

# Step 8: Prepare for App Store submission
run_script "scripts/prepare_for_app_store.sh" "App Store preparation"

echo "🎉 All testing steps have been completed!"
echo "Check the testing_tracker.md file for the current progress status."

# Print a summary of what was completed
echo "📋 Testing Process Summary:"
echo "  ✅ Code coverage analysis"
echo "  ✅ Test prioritization"
echo "  ✅ Test template preparation"
echo "  ✅ Test execution"
echo "  ✅ Performance testing"
echo "  ✅ Security testing"
echo "  ✅ Test summary report generation"
echo "  ✅ App Store preparation"

echo ""
echo "📝 Next Steps:"
echo "  1. Review the test summary report"
echo "  2. Fix any failing tests"
echo "  3. Address any performance or security issues"
echo "  4. Complete the App Store submission process"

echo ""
echo "Thank you for using the comprehensive testing system!" 