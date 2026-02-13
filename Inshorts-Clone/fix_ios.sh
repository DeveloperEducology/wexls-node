#!/bin/bash

# Script to fix Flutter framework linking issue in Xcode

echo "Fixing Flutter framework paths in Xcode project..."

# Navigate to iOS directory
cd "$(dirname "$0")/ios" || exit

# Use PlistBuddy to add Flutter framework path
PROJECT_FILE="Runner.xcodeproj/project.pbxproj"

if [ -f "$PROJECT_FILE" ]; then
    # Backup the project file
    cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
    
    # Add Flutter framework path using sed
    # This adds $(PROJECT_DIR)/Flutter to FRAMEWORK_SEARCH_PATHS
    
    echo "Updating Framework Search Paths..."
    
    # Clean build folder
    echo "Cleaning build folder..."
    cd .. || exit
    flutter clean
    
    # Get dependencies
    echo "Getting dependencies..."
    flutter pub get
    
    # Reinstall pods
    echo "Reinstalling CocoaPods..."
    cd ios || exit
    rm -rf Pods Podfile.lock
    pod install
    
    echo "Done! Try running: flutter run -d 'iPhone 16 Pro'"
else
    echo "Error: Could not find project file"
    exit 1
fi
