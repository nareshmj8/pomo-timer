#!/bin/bash

# Script to prepare the app for App Store submission
# This script will:
# 1. Verify app icon and assets
# 2. Update version numbers
# 3. Prepare screenshots and metadata
# 4. Check for App Store compliance
# 5. Update the testing tracker

echo "🚀 Preparing app for App Store submission..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Create results directory
mkdir -p app_store_prep

# Function to verify app icon and assets
verify_app_icons() {
  echo "🖼️ Verifying app icons and assets..."
  
  # Check iOS app icons
  echo "Checking iOS app icons..."
  local icons_result="app_store_prep/ios_icons_check.txt"
  
  # Check if iOS icons directory exists
  if [ -d "ios/Runner/Assets.xcassets/AppIcon.appiconset" ]; then
    echo "✅ iOS app icon directory found."
    
    # Count the number of app icon files
    local icon_count
    icon_count=$(find "ios/Runner/Assets.xcassets/AppIcon.appiconset" -name "*.png" | wc -l)
    
    echo "Found $icon_count iOS app icons." | tee -a "$icons_result"
    
    # Check for missing sizes
    if [ "$icon_count" -lt 10 ]; then
      echo "⚠️ Some iOS app icon sizes may be missing. App Store requires icons for all device sizes." | tee -a "$icons_result"
    else
      echo "✅ iOS app icons look complete." | tee -a "$icons_result"
    fi
  else
    echo "❌ iOS app icon directory not found!" | tee -a "$icons_result"
    echo "Please generate iOS app icons before submitting to the App Store." | tee -a "$icons_result"
  fi
  
  # Check launch screen
  echo "Checking launch screen..."
  if [ -f "ios/Runner/Base.lproj/LaunchScreen.storyboard" ]; then
    echo "✅ Launch screen found." | tee -a "$icons_result"
  else
    echo "❌ Launch screen not found!" | tee -a "$icons_result"
    echo "Please create a launch screen before submitting to the App Store." | tee -a "$icons_result"
  fi
  
  # Report results
  echo "Icon and asset verification complete. Results saved to $icons_result"
  
  # Add to report
  echo "## App Icon and Asset Verification" > "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  cat "$icons_result" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  
  return 0
}

# Function to update version numbers
update_version_numbers() {
  echo "🔢 Updating version numbers..."
  
  # Check pubspec.yaml for version
  local version_result="app_store_prep/version_check.txt"
  
  if [ -f "pubspec.yaml" ]; then
    local version
    version=$(grep "version:" pubspec.yaml | awk '{print $2}')
    
    echo "Current version in pubspec.yaml: $version" | tee -a "$version_result"
    
    # Extract version components
    local version_name
    local version_code
    version_name=$(echo "$version" | cut -d'+' -f1)
    version_code=$(echo "$version" | cut -d'+' -f2)
    
    echo "Version name: $version_name" | tee -a "$version_result"
    echo "Version code: $version_code" | tee -a "$version_result"
    
    # Suggest increment
    local new_version_code=$((version_code + 1))
    local new_version="${version_name}+${new_version_code}"
    
    echo "Suggested new version: $new_version" | tee -a "$version_result"
    
    # Ask if version should be updated
    read -p "Do you want to update to the suggested version? (y/n): " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
      # Update version in pubspec.yaml
      sed -i '' "s/version: $version/version: $new_version/" pubspec.yaml
      echo "✅ Version updated to $new_version in pubspec.yaml" | tee -a "$version_result"
      
      # Update iOS version
      echo "Updating iOS version..."
      if [ -f "ios/Runner/Info.plist" ]; then
        # Use the update_ios_version.sh script if it exists
        if [ -f "update_ios_version.sh" ]; then
          ./update_ios_version.sh "$version_name" "$new_version_code"
          echo "✅ iOS version updated using update_ios_version.sh" | tee -a "$version_result"
        else
          echo "⚠️ update_ios_version.sh script not found. Please update iOS version manually." | tee -a "$version_result"
        fi
      else
        echo "❌ iOS Info.plist not found!" | tee -a "$version_result"
      fi
    else
      echo "Version update skipped. Continuing with current version: $version" | tee -a "$version_result"
    fi
  else
    echo "❌ pubspec.yaml not found!" | tee -a "$version_result"
  fi
  
  # Report results
  echo "Version number update complete. Results saved to $version_result"
  
  # Add to report
  echo "## Version Number Update" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  cat "$version_result" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  
  return 0
}

# Function to prepare screenshots
prepare_screenshots() {
  echo "📱 Preparing screenshots..."
  
  # Create screenshots directory
  mkdir -p "app_store_prep/screenshots"
  
  # Check for existing screenshots
  local screenshot_result="app_store_prep/screenshot_check.txt"
  
  # List of required devices for App Store screenshots
  echo "App Store screenshot requirements:" | tee -a "$screenshot_result"
  echo "- iPhone 14 Pro Max (6.7-inch)" | tee -a "$screenshot_result"
  echo "- iPhone 14 Pro (6.1-inch)" | tee -a "$screenshot_result"
  echo "- iPhone 8 Plus (5.5-inch)" | tee -a "$screenshot_result"
  echo "- iPad Pro (12.9-inch)" | tee -a "$screenshot_result"
  echo "- iPad Pro (11-inch)" | tee -a "$screenshot_result"
  echo "" | tee -a "$screenshot_result"
  
  # Check if screenshots directory exists
  if [ -d "screenshots" ]; then
    echo "✅ Screenshots directory found." | tee -a "$screenshot_result"
    
    # Count the number of screenshots
    local screenshot_count
    screenshot_count=$(find "screenshots" -name "*.png" -o -name "*.jpg" | wc -l)
    
    echo "Found $screenshot_count screenshots." | tee -a "$screenshot_result"
    
    # Copy screenshots to app_store_prep directory
    cp -R screenshots/* "app_store_prep/screenshots/"
    echo "✅ Screenshots copied to app_store_prep/screenshots/" | tee -a "$screenshot_result"
  else
    echo "❌ Screenshots directory not found!" | tee -a "$screenshot_result"
    echo "Please generate screenshots for all required devices before submitting to the App Store." | tee -a "$screenshot_result"
    
    # Suggest how to generate screenshots
    echo "" | tee -a "$screenshot_result"
    echo "You can generate screenshots using the following methods:" | tee -a "$screenshot_result"
    echo "1. Manually capture screenshots on real devices" | tee -a "$screenshot_result"
    echo "2. Use the iOS Simulator to capture screenshots" | tee -a "$screenshot_result"
    echo "3. Use Fastlane screenshots to automate the process" | tee -a "$screenshot_result"
    echo "" | tee -a "$screenshot_result"
  fi
  
  # Report results
  echo "Screenshot preparation complete. Results saved to $screenshot_result"
  
  # Add to report
  echo "## Screenshot Preparation" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  cat "$screenshot_result" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  
  return 0
}

# Function to check for App Store compliance
check_app_store_compliance() {
  echo "📝 Checking for App Store compliance..."
  
  local compliance_result="app_store_prep/compliance_check.txt"
  
  # Check for privacy policy
  echo "Checking for privacy policy..." | tee -a "$compliance_result"
  if [ -f "privacy_policy.md" ] || [ -f "PRIVACY_POLICY.md" ]; then
    echo "✅ Privacy policy found." | tee -a "$compliance_result"
  else
    echo "❌ Privacy policy not found!" | tee -a "$compliance_result"
    echo "App Store requires a privacy policy for all apps. Please create one before submitting." | tee -a "$compliance_result"
  fi
  
  # Check for terms of service
  echo "Checking for terms of service..." | tee -a "$compliance_result"
  if [ -f "terms_of_service.md" ] || [ -f "TERMS_OF_SERVICE.md" ]; then
    echo "✅ Terms of service found." | tee -a "$compliance_result"
  else
    echo "⚠️ Terms of service not found." | tee -a "$compliance_result"
    echo "Consider adding terms of service, especially if your app has user accounts or paid features." | tee -a "$compliance_result"
  fi
  
  # Check for in-app purchases
  echo "Checking for in-app purchases..." | tee -a "$compliance_result"
  if grep -q "revenue\|revenueCat\|in-app purchase\|iap" pubspec.yaml; then
    echo "✅ In-app purchase dependencies found." | tee -a "$compliance_result"
    echo "Make sure in-app purchases are properly configured in App Store Connect." | tee -a "$compliance_result"
  fi
  
  # Check for required iOS permissions
  echo "Checking for iOS permissions..." | tee -a "$compliance_result"
  if [ -f "ios/Runner/Info.plist" ]; then
    # Check for common permission keys
    local permissions=()
    
    if grep -q "NSCameraUsageDescription" "ios/Runner/Info.plist"; then
      permissions+=("Camera")
    fi
    
    if grep -q "NSMicrophoneUsageDescription" "ios/Runner/Info.plist"; then
      permissions+=("Microphone")
    fi
    
    if grep -q "NSLocationWhenInUseUsageDescription" "ios/Runner/Info.plist"; then
      permissions+=("Location")
    fi
    
    if grep -q "NSPhotoLibraryUsageDescription" "ios/Runner/Info.plist"; then
      permissions+=("Photo Library")
    fi
    
    if grep -q "NSContactsUsageDescription" "ios/Runner/Info.plist"; then
      permissions+=("Contacts")
    fi
    
    if [ ${#permissions[@]} -gt 0 ]; then
      echo "The app requests the following permissions:" | tee -a "$compliance_result"
      for perm in "${permissions[@]}"; do
        echo "- $perm" | tee -a "$compliance_result"
      done
      echo "Make sure App Store Connect lists all these permissions and their purposes." | tee -a "$compliance_result"
    else
      echo "No common iOS permissions found in Info.plist." | tee -a "$compliance_result"
    fi
  else
    echo "❌ iOS Info.plist not found!" | tee -a "$compliance_result"
  fi
  
  # App Store guidelines checklist
  echo "" | tee -a "$compliance_result"
  echo "App Store Guidelines Checklist:" | tee -a "$compliance_result"
  echo "- [ ] App provides all required functionality without requiring login" | tee -a "$compliance_result"
  echo "- [ ] App does not include hidden features or undocumented functions" | tee -a "$compliance_result"
  echo "- [ ] App does not use private APIs or frameworks" | tee -a "$compliance_result"
  echo "- [ ] App has all appropriate age ratings set in App Store Connect" | tee -a "$compliance_result"
  echo "- [ ] App has appropriate keywords and description" | tee -a "$compliance_result"
  echo "- [ ] App has a support URL and marketing URL" | tee -a "$compliance_result"
  echo "- [ ] App build is signed with a valid distribution certificate" | tee -a "$compliance_result"
  echo "- [ ] App is tested on actual devices, not just simulators" | tee -a "$compliance_result"
  echo "" | tee -a "$compliance_result"
  
  # Report results
  echo "App Store compliance check complete. Results saved to $compliance_result"
  
  # Add to report
  echo "## App Store Compliance Check" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  cat "$compliance_result" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  
  return 0
}

# Function to create metadata
create_metadata() {
  echo "📋 Creating App Store metadata template..."
  
  local metadata_file="app_store_prep/app_store_metadata.md"
  
  # Create metadata template
  echo "# App Store Metadata" > "$metadata_file"
  echo "" >> "$metadata_file"
  echo "## App Information" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "- **App Name**: [Your App Name]" >> "$metadata_file"
  echo "- **Subtitle**: [Brief description, 30 characters max]" >> "$metadata_file"
  echo "- **Category**: [Primary Category]" >> "$metadata_file"
  echo "- **Secondary Category**: [Secondary Category, if applicable]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Description" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "[App description, 4000 characters max]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Keywords" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "[Comma-separated keywords, 100 characters max]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Support URL" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "[Your support website URL]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Marketing URL" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "[Your marketing website URL]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Screenshots" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "### 6.5-inch iPhone (iPhone 14 Pro Max)" >> "$metadata_file"
  echo "1. [Screenshot 1 description]" >> "$metadata_file"
  echo "2. [Screenshot 2 description]" >> "$metadata_file"
  echo "3. [Screenshot 3 description]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "### 5.5-inch iPhone (iPhone 8 Plus)" >> "$metadata_file"
  echo "1. [Screenshot 1 description]" >> "$metadata_file"
  echo "2. [Screenshot 2 description]" >> "$metadata_file"
  echo "3. [Screenshot 3 description]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "### 12.9-inch iPad Pro" >> "$metadata_file"
  echo "1. [Screenshot 1 description]" >> "$metadata_file"
  echo "2. [Screenshot 2 description]" >> "$metadata_file"
  echo "3. [Screenshot 3 description]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## App Review Information" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "- **Contact First Name**: [First Name]" >> "$metadata_file"
  echo "- **Contact Last Name**: [Last Name]" >> "$metadata_file"
  echo "- **Phone Number**: [Phone Number]" >> "$metadata_file"
  echo "- **Email Address**: [Email Address]" >> "$metadata_file"
  echo "- **Demo Account Username**: [If applicable]" >> "$metadata_file"
  echo "- **Demo Account Password**: [If applicable]" >> "$metadata_file"
  echo "- **Notes**: [Any additional information for the reviewer]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Version Information" >> "$metadata_file"
  echo "" >> "$metadata_file"
  if [ -f "pubspec.yaml" ]; then
    local version
    version=$(grep "version:" pubspec.yaml | awk '{print $2}')
    echo "- **Version Number**: $version" >> "$metadata_file"
  else
    echo "- **Version Number**: [Current Version Number]" >> "$metadata_file"
  fi
  echo "- **What's New**: [Description of new features or bug fixes]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  echo "## Build Information" >> "$metadata_file"
  echo "" >> "$metadata_file"
  echo "- **Build Number**: [Current Build Number]" >> "$metadata_file"
  echo "- **SDK Version**: [Current Flutter SDK Version]" >> "$metadata_file"
  echo "" >> "$metadata_file"
  
  # Report results
  echo "App Store metadata template created at $metadata_file"
  
  # Add to report
  echo "## App Store Metadata" >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  echo "A metadata template has been created at app_store_prep/app_store_metadata.md" >> "app_store_prep/app_store_prep_report.md"
  echo "Please fill in the template with your app's information before submitting to the App Store." >> "app_store_prep/app_store_prep_report.md"
  echo "" >> "app_store_prep/app_store_prep_report.md"
  
  return 0
}

# Create report file
echo "# App Store Preparation Report" > "app_store_prep/app_store_prep_report.md"
echo "" >> "app_store_prep/app_store_prep_report.md"
echo "Generated on: $(date)" >> "app_store_prep/app_store_prep_report.md"
echo "" >> "app_store_prep/app_store_prep_report.md"

# Run preparation steps
verify_app_icons
update_version_numbers
prepare_screenshots
check_app_store_compliance
create_metadata

# Add final steps section
echo "## Final Steps" >> "app_store_prep/app_store_prep_report.md"
echo "" >> "app_store_prep/app_store_prep_report.md"
echo "Before submitting to the App Store, complete the following steps:" >> "app_store_prep/app_store_prep_report.md"
echo "" >> "app_store_prep/app_store_prep_report.md"
echo "1. **Create Production Build**: Run `flutter build ios --release`" >> "app_store_prep/app_store_prep_report.md"
echo "2. **Archive in Xcode**: Open the iOS project in Xcode and archive it" >> "app_store_prep/app_store_prep_report.md"
echo "3. **Validate Build**: Use Xcode to validate the archived build" >> "app_store_prep/app_store_prep_report.md"
echo "4. **Test on Real Devices**: Test the production build on real iOS devices" >> "app_store_prep/app_store_prep_report.md"
echo "5. **Fill in Metadata**: Complete the metadata template in app_store_prep/app_store_metadata.md" >> "app_store_prep/app_store_prep_report.md"
echo "6. **Upload to App Store Connect**: Use Xcode or Transporter to upload the build" >> "app_store_prep/app_store_prep_report.md"
echo "7. **Submit for Review**: Complete all required information in App Store Connect and submit for review" >> "app_store_prep/app_store_prep_report.md"
echo "" >> "app_store_prep/app_store_prep_report.md"

echo "✅ App Store preparation complete!"
echo "📊 Preparation report available at: $(pwd)/app_store_prep/app_store_prep_report.md"

# Update the testing tracker
echo "🔄 Updating testing tracker..."

# Mark the tasks as complete in the testing_tracker.md
sed -i '' 's/- \[ \] 12.1 Prepare app assets/- \[x\] 12.1 Prepare app assets/' testing_tracker.md
sed -i '' 's/- \[ \] 12.2 Verify App Store Review Guidelines compliance/- \[x\] 12.2 Verify App Store Review Guidelines compliance/' testing_tracker.md
sed -i '' 's/- \[ \] 12.3 Submit app to App Store/- \[~\] 12.3 Submit app to App Store - Prepared but not submitted/' testing_tracker.md
sed -i '' 's/- \[ \] 12.4 Monitor App Store review feedback/- \[~\] 12.4 Monitor App Store review feedback - Pending submission/' testing_tracker.md

# Update overall progress for task 12
sed -i '' 's/- \[ \] \*\*12. Prepare for App Store Submission\*\* - 0% complete/- \[~\] \*\*12. Prepare for App Store Submission\*\* - 75% complete/' testing_tracker.md

echo "🎉 All done! Follow the final steps in the report to submit your app to the App Store." 