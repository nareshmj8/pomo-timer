#!/bin/bash

# Comprehensive cleanup script to remove all duplicate splash screen files

echo "Starting splash screen cleanup process..."

# Check for duplicate splash screen files
echo "Checking for duplicate splash screen files..."

# Keep only the correct splash screen file at lib/screens/splash_screen.dart
if [ -f "lib/splash_screen.dart" ]; then
  echo "Removing duplicate splash screen file at lib/splash_screen.dart"
  rm lib/splash_screen.dart
fi

# Check for any other splash screen files in unexpected locations
find lib -name "*splash*screen*.dart" -not -path "lib/screens/splash_screen.dart" | while read file; do
  echo "Found duplicate splash screen file: $file"
  echo "Removing $file"
  rm "$file"
done

echo "Cleanup complete!"
echo "Your app should now have only one splash screen file at lib/screens/splash_screen.dart" 