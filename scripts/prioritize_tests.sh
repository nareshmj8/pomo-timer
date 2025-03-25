#!/bin/bash

# Script to analyze untested files and prioritize them based on:
# 1. Core functionality (services, providers)
# 2. File size (larger files likely have more complex logic)
# 3. Dependencies (files that other files depend on)

echo "🔍 Analyzing untested files to prioritize test creation..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Check if untested_files.txt exists
if [ ! -f "untested_files.txt" ]; then
  echo "❌ untested_files.txt not found. Please run the coverage analysis first."
  exit 1
fi

# Create prioritization file
PRIORITY_FILE="test_priorities.md"
echo "# Test Prioritization" > "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "Generated on: $(date)" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"

# Priority categories
echo "## High Priority (Core Services & Providers)" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "These files represent core functionality and should be tested first:" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "| File | Lines | Priority Reason |" >> "$PRIORITY_FILE"
echo "|------|-------|----------------|" >> "$PRIORITY_FILE"

# Find high priority files (services and providers)
grep -E "(services|providers)/" untested_files.txt | sort | while read -r file; do
  if [[ -f "$file" ]]; then
    LINE_COUNT=$(wc -l < "$file")
    
    # Determine priority reason
    if [[ "$file" == *"timer"* ]]; then
      REASON="Core timer functionality"
    elif [[ "$file" == *"notification"* ]]; then
      REASON="User notifications"
    elif [[ "$file" == *"iap"* || "$file" == *"revenueCat"* ]]; then
      REASON="In-app purchases"
    elif [[ "$file" == *"analytics"* ]]; then
      REASON="Analytics tracking"
    elif [[ "$file" == *"service"* ]]; then
      REASON="Core service"
    elif [[ "$file" == *"provider"* ]]; then
      REASON="State management"
    else
      REASON="Support functionality"
    fi
    
    echo "| $file | $LINE_COUNT | $REASON |" >> "$PRIORITY_FILE"
  fi
done

# Medium priority (models and utilities)
echo "" >> "$PRIORITY_FILE"
echo "## Medium Priority (Models & Utilities)" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "These files handle data structures and utility functions:" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "| File | Lines | Priority Reason |" >> "$PRIORITY_FILE"
echo "|------|-------|----------------|" >> "$PRIORITY_FILE"

grep -E "(models|utils)/" untested_files.txt | sort | while read -r file; do
  if [[ -f "$file" ]]; then
    LINE_COUNT=$(wc -l < "$file")
    
    # Determine priority reason
    if [[ "$file" == *"model"* ]]; then
      REASON="Data structure"
    elif [[ "$file" == *"utils"* || "$file" == *"helper"* ]]; then
      REASON="Utility functions"
    else
      REASON="Support functionality"
    fi
    
    echo "| $file | $LINE_COUNT | $REASON |" >> "$PRIORITY_FILE"
  fi
done

# Lower priority (UI components)
echo "" >> "$PRIORITY_FILE"
echo "## Lower Priority (UI Components)" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "These files are UI components that should be tested after core functionality:" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "| File | Lines | Component Type |" >> "$PRIORITY_FILE"
echo "|------|-------|---------------|" >> "$PRIORITY_FILE"

grep -E "(screens|widgets|components)/" untested_files.txt | sort | while read -r file; do
  if [[ -f "$file" ]]; then
    LINE_COUNT=$(wc -l < "$file")
    
    # Determine component type
    if [[ "$file" == *"screen"* ]]; then
      TYPE="Screen"
    elif [[ "$file" == *"widget"* ]]; then
      TYPE="Widget"
    elif [[ "$file" == *"component"* ]]; then
      TYPE="Component"
    else
      TYPE="UI Element"
    fi
    
    echo "| $file | $LINE_COUNT | $TYPE |" >> "$PRIORITY_FILE"
  fi
done

echo "" >> "$PRIORITY_FILE"
echo "## Next Steps" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"
echo "1. Begin by creating tests for high-priority core services and providers" >> "$PRIORITY_FILE"
echo "2. Then move to medium-priority models and utilities" >> "$PRIORITY_FILE"
echo "3. Finally test UI components with widget and integration tests" >> "$PRIORITY_FILE"
echo "" >> "$PRIORITY_FILE"

echo "✅ Test prioritization complete!"
echo "📝 Priorities available at: $(pwd)/$PRIORITY_FILE"

# Update the testing tracker
sed -i '' 's/- \[ \] 1.4 Prioritize test creation based on critical functionality/- \[x\] 1.4 Prioritize test creation based on critical functionality/' testing_tracker.md

echo "🎉 All done!" 