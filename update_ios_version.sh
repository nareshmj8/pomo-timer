#!/bin/bash

cd ios
xcrun agvtool new-version -all 13.0

# Update the IPHONEOS_DEPLOYMENT_TARGET in the project.pbxproj file
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 12.0;/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/g' Runner.xcodeproj/project.pbxproj

echo "Updated iOS deployment target to 13.0" 