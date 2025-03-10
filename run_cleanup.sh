#!/bin/bash

# Make the cleanup script executable
chmod +x cleanup_splash.sh

# Run the cleanup script
./cleanup_splash.sh

# Verify the correct splash screen file exists
if [ -f "lib/screens/splash_screen.dart" ]; then
  echo "✅ Correct splash screen file exists at lib/screens/splash_screen.dart"
else
  echo "❌ ERROR: Splash screen file not found at lib/screens/splash_screen.dart"
  exit 1
fi

# Verify the old splash screen file is gone
if [ -f "lib/splash_screen.dart" ]; then
  echo "❌ ERROR: Old splash screen file still exists at lib/splash_screen.dart"
  exit 1
else
  echo "✅ Old splash screen file successfully removed"
fi

# Check for any other splash screen files
other_files=$(find lib -name "*splash*screen*.dart" -not -path "lib/screens/splash_screen.dart")
if [ -n "$other_files" ]; then
  echo "❌ ERROR: Found other splash screen files:"
  echo "$other_files"
  exit 1
else
  echo "✅ No other splash screen files found"
fi

# Verify the import in main.dart
if grep -q "import 'screens/splash_screen.dart';" lib/main.dart; then
  echo "✅ main.dart is correctly importing from 'screens/splash_screen.dart'"
else
  echo "❌ ERROR: main.dart is not importing the correct splash screen file"
  exit 1
fi

echo ""
echo "🎉 All checks passed! Your splash screen implementation is correct."
echo "Your app should now show only one splash screen with your app logo from assets/app-logo.png" 