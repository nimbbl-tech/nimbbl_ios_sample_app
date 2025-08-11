#!/bin/bash

# Build script to bypass sandbox permission issues
echo "Building NimbblSampleApp with sandbox workarounds..."

# Clean derived data
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/NimbblSampleApp-*

# Clean build folder
echo "Cleaning build folder..."
xcodebuild clean -workspace NimbblSampleApp.xcworkspace -scheme NimbblSampleApp

# Build with specific settings to avoid sandbox issues
echo "Building project..."
xcodebuild build \
  -workspace NimbblSampleApp.xcworkspace \
  -scheme NimbblSampleApp \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -derivedDataPath ~/Library/Developer/Xcode/DerivedData/NimbblSampleApp-custom \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  ENABLE_BITCODE=NO \
  COPY_PHASE_STRIP=NO \
  STRIP_INSTALLED_PRODUCT=NO

echo "Build completed!"
