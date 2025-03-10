#!/bin/bash

# Script to remove the old splash screen file and ensure we're using the correct one

echo "Starting splash screen cleanup process..."

# Remove the old splash screen file at the root level
if [ -f "lib/splash_screen.dart" ]; then
  echo "Removing old splash screen file at lib/splash_screen.dart"
  rm lib/splash_screen.dart
  echo "Old splash screen file removed successfully!"
else
  echo "No old splash screen file found at lib/splash_screen.dart"
fi

# Verify the correct splash screen file exists
if [ -f "lib/screens/splash_screen.dart" ]; then
  echo "Correct splash screen file found at lib/screens/splash_screen.dart"
else
  echo "WARNING: Correct splash screen file not found at lib/screens/splash_screen.dart"
fi

# Check for any other splash screen files in unexpected locations
echo "Checking for any other splash screen files..."
find lib -name "*splash*screen*.dart" -not -path "lib/screens/splash_screen.dart" | while read file; do
  echo "Found additional splash screen file: $file"
  echo "Removing $file"
  rm "$file"
done

echo "Cleanup complete!"
echo "Your app should now have only one splash screen file at lib/screens/splash_screen.dart"
echo "Make sure your main.dart is importing from 'screens/splash_screen.dart'" 