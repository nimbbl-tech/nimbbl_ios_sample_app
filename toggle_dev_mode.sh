#!/bin/bash

# Nimbbl iOS SDK Development Mode Toggle Script
# This script allows you to easily switch between local development and production modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in the right directory
check_directory() {
    if [ ! -f "Podfile" ]; then
        print_error "Podfile not found. Please run this script from the nimbbl_ios_sample_app directory."
        exit 1
    fi
}

# Function to show current mode
show_current_mode() {
    print_status "Checking current development mode..."
    
    if grep -q "^  pod 'nimbbl_mobile_kit_ios_webview_sdk', :path" Podfile; then
        print_success "Current mode: LOCAL DEVELOPMENT"
        print_status "Using local SDK source files"
        print_status "WebView SDK: Local source files"
        print_status "Core API SDK: Local source files"
    elif grep -q "^  pod 'nimbbl_mobile_kit_ios_webview_sdk', '~>" Podfile; then
        print_success "Current mode: PRODUCTION"
        print_status "Using published SDK versions"
        print_status "WebView SDK: ~> 1.0.13"
        print_status "Core API SDK: ~> 1.5.10 (via WebView SDK dependency)"
    else
        print_warning "Current mode: UNKNOWN"
        print_status "No SDK configuration found in Podfile"
    fi
}

# Function to switch to local development mode
switch_to_local() {
    print_status "Switching to LOCAL DEVELOPMENT mode..."
    
    # Update Podfile - comment out published SDK and uncomment local SDKs
    sed -i '' 's/^  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.12'\''/  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.12'\''/' Podfile
    sed -i '' 's/^  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.13'\''/  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.13'\''/' Podfile
    sed -i '' 's/^  # pod '\''nimbbl_mobile_kit_ios_core_api_sdk'\''/  pod '\''nimbbl_mobile_kit_ios_core_api_sdk'\''/' Podfile
    sed -i '' 's/^  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', :path/  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', :path/' Podfile
    
    print_success "Configuration updated for LOCAL DEVELOPMENT mode"
    print_status "Podfile updated to use local SDK source files"
    print_status "Note: Podspecs are already configured for local development"
}

# Function to switch to production mode
switch_to_production() {
    print_status "Switching to PRODUCTION mode..."
    
    # Update Podfile - uncomment published SDK and comment out local SDKs
    sed -i '' 's/^  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.12'\''/  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.12'\''/' Podfile
    sed -i '' 's/^  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.13'\''/  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', '\''~> 1.0.13'\''/' Podfile
    sed -i '' 's/^  pod '\''nimbbl_mobile_kit_ios_core_api_sdk'\''/  # pod '\''nimbbl_mobile_kit_ios_core_api_sdk'\''/' Podfile
    sed -i '' 's/^  pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', :path/  # pod '\''nimbbl_mobile_kit_ios_webview_sdk'\'', :path/' Podfile
    
    print_success "Configuration updated for PRODUCTION mode"
    print_status "Podfile updated to use published SDK versions"
    print_status "Note: Podspecs are already configured for production"
}

# Function to install pods
install_pods() {
    print_status "Installing pods..."
    pod install
    print_success "Pods installed successfully"
}

# Function to clean and reinstall pods
clean_install_pods() {
    print_status "Cleaning and reinstalling pods..."
    
    # Remove existing pods
    if [ -d "Pods" ]; then
        print_status "Removing existing Pods directory..."
        rm -rf Pods
    fi
    
    if [ -f "Podfile.lock" ]; then
        print_status "Removing Podfile.lock..."
        rm -f Podfile.lock
    fi
    
    # Install fresh
    pod install
    print_success "Pods cleaned and reinstalled successfully"
}

# Function to show version information
show_version_info() {
    print_status "SDK Version Information:"
    
    # Check WebView SDK version
    if [ -f "../nimbbl_mobile_kit_ios_webview_sdk/version.properties" ]; then
        webview_version=$(grep "^SDK_VERSION=" ../nimbbl_mobile_kit_ios_webview_sdk/version.properties | cut -d'=' -f2)
        print_status "Local WebView SDK Version: $webview_version"
    else
        print_warning "WebView SDK version.properties not found"
    fi
    
    # Check Core API SDK version
    if [ -f "../nimbbl_mobile_kit_ios_core_api_sdk/version.properties" ]; then
        core_version=$(grep "^SDK_VERSION=" ../nimbbl_mobile_kit_ios_core_api_sdk/version.properties | cut -d'=' -f2)
        print_status "Local Core API SDK Version: $core_version"
    else
        print_warning "Core API SDK version.properties not found"
    fi
    
    print_status "Production WebView SDK Version: 1.0.13"
    print_status "Production Core API SDK Version: 1.5.10"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  local         Switch to local development mode"
    echo "  prod          Switch to production mode"
    echo "  status        Show current development mode"
    echo "  install       Install pods after switching mode"
    echo "  clean         Clean and reinstall pods"
    echo "  versions      Show SDK version information"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 local              # Switch to local development mode"
    echo "  $0 prod               # Switch to production mode"
    echo "  $0 local install      # Switch to local mode and install pods"
    echo "  $0 prod clean         # Switch to production mode and clean install"
    echo "  $0 status             # Show current mode"
    echo "  $0 versions           # Show version information"
    echo ""
    echo "Notes:"
    echo "  - Podspecs are pre-configured for both modes"
    echo "  - Script only modifies Podfile configuration"
    echo "  - Use 'clean' option if you encounter pod issues"
}

# Main script logic
main() {
    check_directory
    
    case "${1:-}" in
        "local")
            switch_to_local
            if [ "$2" = "install" ]; then
                install_pods
            elif [ "$2" = "clean" ]; then
                clean_install_pods
            fi
            ;;
        "prod")
            switch_to_production
            if [ "$2" = "install" ]; then
                install_pods
            elif [ "$2" = "clean" ]; then
                clean_install_pods
            fi
            ;;
        "status")
            show_current_mode
            ;;
        "install")
            install_pods
            ;;
        "clean")
            clean_install_pods
            ;;
        "versions")
            show_version_info
            ;;
        "help"|"-h"|"--help"|"")
            show_usage
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"