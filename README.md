# Nimbbl iOS Sample App

A complete sample iOS application demonstrating the integration of Nimbbl payment services using the published WebView SDK from CocoaPods. This sample app showcases payment integration, modern UI, and best practices for iOS development.

## 📱 Overview

This sample app showcases how to integrate Nimbbl payment services into your iOS application. It demonstrates:

- **Complete payment checkout flow**
- **Integration with WebView SDK (includes Core API SDK)**
- **Modern UI with payment customization options**
- **Error handling and user feedback**
- **Settings and configuration management**

## 🚀 Features

### Payment Integration
- ✅ Complete checkout flow implementation
- ✅ Order creation and management
- ✅ Payment processing with WebView interface
- ✅ Success and error handling
- ✅ Transaction status tracking

### UI/UX Features
- ✅ Modern, intuitive interface
- ✅ Payment amount customization
- ✅ Currency selection (INR, USD, etc.)
- ✅ Payment method customization
- ✅ Header customization options
- ✅ User details collection
- ✅ Settings management

### Technical Features
- ✅ Integration with Core API SDK v2.0.17 (published)
- ✅ Integration with WebView SDK v2.0.17 (published)
- ✅ Enhanced delegate-based callbacks
- ✅ Standardized error handling and logging
- ✅ Production-ready configuration
- ✅ Published SDKs from CocoaPods
- ✅ Enhanced security and data handling

## 📋 Requirements

- **iOS**: 13.0+
- **Xcode**: 12.0+
- **Swift**: 5.0+
- **CocoaPods**: Latest version

## 📦 SDK Versions

This sample app uses the following published SDK versions from CocoaPods:

- **WebView SDK**: 2.0.17
- **Core API SDK**: 2.0.17 (automatically included as a dependency)

To update to a different version, modify the version in `Podfile` and run `pod install`.

## �� Installation

### 1. Clone the Repository

```bash
git clone https://github.com/nimbbl-tech/nimbbl_ios_sample_app.git
cd nimbbl_ios_sample_app
```

### 2. Install CocoaPods Dependencies

The sample app uses published SDKs from CocoaPods. Simply run:

```bash
pod install
```

This will automatically install:
- `nimbbl_mobile_kit_ios_webview_sdk` (2.0.17)
- `nimbbl_mobile_kit_ios_core_api_sdk` (2.0.17) - automatically included as a dependency

### 3. Open the Project

```bash
open NimbblSampleApp.xcworkspace
```

## 🎯 Usage

### Running the Sample App

1. **Open the workspace** in Xcode
2. **Select your target device** (iPhone Simulator or physical device)
3. **Build and run** the project (⌘+R)

### Sample App Features

#### 1. Payment Configuration
- **Amount**: Set payment amount (default: ₹100)
- **Currency**: Select currency (INR, USD, etc.)
- **Payment Options**: Customize payment methods
- **Header Options**: Customize checkout header

#### 2. User Details
- **Name**: Customer name
- **Phone**: Contact number
- **Email**: Email address
- **Toggle**: Enable/disable user details collection

#### 3. Payment Flow
1. **Configure payment** settings
2. **Tap "Pay Now"** to start checkout
3. **Complete payment** in the WebView interface
4. **View results** (success/error)

#### 4. Settings
- **Environment URL**: Configure API endpoints
- **QA Environment**: Switch between environments

## 📁 Project Structure

```
nimbbl_ios_sample_app/
├── NimbblSampleApp/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── LaunchScreen.storyboard
│   │   └── NimbblCheckout-Bridging-Header.h
│   ├── Extensions/
│   │   ├── UIColor+Hex.swift
│   │   ├── UIComponents.swift
│   │   └── ViewController+UITextFieldDelegate.swift
│   ├── Models/
│   │   ├── IconWithName.swift
│   │   └── ImageWithName.swift
│   ├── Resources/
│   │   └── Assets.xcassets/
│   ├── Supporting/
│   │   ├── AppConstants.swift
│   │   └── Config.swift
│   ├── ViewModels/
│   │   ├── Payment/
│   │   │   └── PaymentManager.swift
│   │   └── User/
│   │       └── UserDetailsManager.swift
│   ├── Views/
│   │   ├── Payment/
│   │   │   ├── HeaderOptionsBottomSheetViewController.swift
│   │   │   ├── PaymentOptionsBottomSheetViewController.swift
│   │   │   └── SubPaymentOptionsBottomSheetViewController.swift
│   │   ├── Settings/
│   │   │   └── SettingsViewController.swift
│   │   ├── ThankYou/
│   │   │   └── ThankYouVC.swift
│   │   └── ViewController.swift
│   ├── Info.plist
│   └── README.md
├── Podfile
└── README.md
```

## 🔧 Configuration

For detailed WebView SDK configuration and integration steps, see the full integration guide in `NimbblSampleApp/README.md`:

- **File**: `NimbblSampleApp/README.md`
- **Title**: “Nimbbl iOS WebView SDK Integration Guide”
- **Contents**: Installation via CocoaPods, import steps, Swift/Objective‑C usage examples, Info.plist `LSApplicationQueriesSchemes` configuration, order token generation, troubleshooting, and API parameter reference.

This top-level README focuses on the sample app overview and project structure; refer to the integration guide above when you integrate the SDK into your own app.
