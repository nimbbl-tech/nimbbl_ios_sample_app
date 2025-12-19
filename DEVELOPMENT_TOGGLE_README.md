# Nimbbl iOS SDK Development Mode Toggle

This project includes a convenient script to toggle between local development and production modes for the Nimbbl iOS SDKs.

## Overview

The `toggle_dev_mode.sh` script allows you to easily switch between:
- **Production Mode**: Uses published SDK versions from CocoaPods
- **Local Development Mode**: Uses local SDK source files for development and testing

## Usage

### Basic Commands

```bash
# Show current development mode
./toggle_dev_mode.sh status

# Switch to local development mode
./toggle_dev_mode.sh local

# Switch to production mode
./toggle_dev_mode.sh prod

# Show help
./toggle_dev_mode.sh help
```

### Advanced Commands

```bash
# Switch to local mode and install pods automatically
./toggle_dev_mode.sh local install

# Switch to production mode and install pods automatically
./toggle_dev_mode.sh prod install

# Clean and reinstall pods (useful for troubleshooting)
./toggle_dev_mode.sh local clean
./toggle_dev_mode.sh prod clean

# Show SDK version information
./toggle_dev_mode.sh versions

# Install pods only (without changing mode)
./toggle_dev_mode.sh install
```

## What the Script Does

### Local Development Mode
When switching to local development mode, the script:

1. **Updates Podfile**:
   - Comments out published SDK: `# pod 'nimbbl_mobile_kit_ios_webview_sdk', '~> 1.0.13'`
   - Uncomments local SDKs: 
     - `pod 'nimbbl_mobile_kit_ios_core_api_sdk', :path => '../nimbbl_mobile_kit_ios_core_api_sdk'`
     - `pod 'nimbbl_mobile_kit_ios_webview_sdk', :path => '../nimbbl_mobile_kit_ios_webview_sdk'`

2. **Uses Pre-configured Podspecs**:
   - Podspecs are already configured for local development
   - Uses `version.properties` files for version management
   - Automatically uses source files for local development

### Production Mode
When switching to production mode, the script:

1. **Updates Podfile**:
   - Uncomments published SDK: `pod 'nimbbl_mobile_kit_ios_webview_sdk', '~> 1.0.13'`
   - Comments out local SDKs

2. **Uses Published SDKs**:
   - Downloads published SDK versions from CocoaPods
   - WebView SDK version: 1.0.13
   - Core API SDK version: 1.5.10 (included as dependency)

## Semantic Versioning

The SDKs now use centralized version management:

### Version Properties Files
- `../nimbbl_mobile_kit_ios_core_api_sdk/version.properties`
- `../nimbbl_mobile_kit_ios_webview_sdk/version.properties`

### Current Versions
- **WebView SDK**: 1.0.13
- **Core API SDK**: 1.5.10

### Version Management Scripts
- `../nimbbl_mobile_kit_ios_core_api_sdk/scripts/update_version.sh`
- `../nimbbl_mobile_kit_ios_webview_sdk/scripts/update_version.sh`

## Prerequisites

- Make sure you're in the `nimbbl_ios_sample_app` directory when running the script
- Ensure you have CocoaPods installed: `sudo gem install cocoapods`
- Make sure the local SDK directories exist:
  - `../nimbbl_mobile_kit_ios_core_api_sdk/`
  - `../nimbbl_mobile_kit_ios_webview_sdk/`

## Workflow Examples

### Starting Local Development

```bash
# 1. Switch to local development mode
./toggle_dev_mode.sh local install

# 2. Open the workspace in Xcode
open NimbblSampleApp.xcworkspace

# 3. Make changes to SDK files in the local directories
# 4. Build and test your changes
```

### Switching Back to Production

```bash
# 1. Switch to production mode
./toggle_dev_mode.sh prod install

# 2. Open the workspace in Xcode
open NimbblSampleApp.xcworkspace

# 3. Test with published SDK versions
```

### Checking Current Mode and Versions

```bash
# Check what mode you're currently in
./toggle_dev_mode.sh status

# Check SDK version information
./toggle_dev_mode.sh versions
```

### Troubleshooting Pod Issues

```bash
# If you encounter pod issues, clean and reinstall
./toggle_dev_mode.sh local clean
# or
./toggle_dev_mode.sh prod clean
```

## Troubleshooting

### Module Not Found Error
If you get "No such module" errors after switching modes:

1. Clean the build folder in Xcode: `Product > Clean Build Folder`
2. Delete derived data: `Product > Clean Build Folder`
3. Run `./toggle_dev_mode.sh [mode] clean` to clean and reinstall pods
4. Rebuild the project

### Pod Installation Issues
If pod installation fails:

1. Use the clean option: `./toggle_dev_mode.sh [mode] clean`
2. Or manually:
   ```bash
   rm -rf Pods
   rm -f Podfile.lock
   pod install
   ```

### Script Permission Issues
If the script is not executable:

```bash
chmod +x toggle_dev_mode.sh
```

### Version Mismatch Issues
If you encounter version-related issues:

1. Check current versions: `./toggle_dev_mode.sh versions`
2. Verify `version.properties` files exist in SDK directories
3. Ensure you're using the latest script version

## File Structure

```
nimbbl_ios_sample_app/
├── toggle_dev_mode.sh              # Toggle script
├── DEVELOPMENT_TOGGLE_README.md    # This file
├── Podfile                         # CocoaPods configuration
├── Podfile.lock                    # Locked dependencies
├── Podfile.production              # Production configuration example
├── NimbblSampleApp.xcworkspace     # Xcode workspace
└── NimbblSampleApp/                # Sample app source
    └── ViewModels/
        └── Payment/
            └── PaymentManager.swift # Uses the SDK

../nimbbl_mobile_kit_ios_core_api_sdk/    # Local core API SDK
├── version.properties                    # Version configuration
├── scripts/
│   ├── update_version.sh                 # Version management script
│   └── read_version.sh                   # Version reading script
└── nimbbl_mobile_kit_ios_core_api_sdk.podspec

../nimbbl_mobile_kit_ios_webview_sdk/     # Local webview SDK
├── version.properties                    # Version configuration
├── scripts/
│   ├── update_version.sh                 # Version management script
│   └── read_version.sh                   # Version reading script
└── nimbbl_mobile_kit_ios_webview_sdk.podspec
```

## Key Changes from Previous Version

### What Changed
1. **Removed Podspec Modification**: Script no longer modifies podspec files
2. **Updated Version Numbers**: All versions updated to current releases
3. **Added Semantic Versioning**: SDKs now use `version.properties` files
4. **Simplified Logic**: Script only modifies Podfile, podspecs are pre-configured
5. **Added Clean Option**: New `clean` command for troubleshooting

### What Remains the Same
- Basic command structure (`local`, `prod`, `status`)
- Podfile modification logic
- Installation and help commands

### Benefits of New Approach
- **More Reliable**: No complex podspec modification
- **Version Consistency**: Centralized version management
- **Easier Maintenance**: Podspecs are pre-configured
- **Better Troubleshooting**: Clean install option available

## Notes

- Always use `NimbblSampleApp.xcworkspace` instead of `NimbblSampleApp.xcodeproj` when working with CocoaPods
- The script automatically handles all configuration changes needed for both modes
- You can safely run the script multiple times - it's idempotent
- The script includes error checking and colored output for better user experience
- Podspecs are pre-configured and don't need modification
- Version information is managed through `version.properties` files