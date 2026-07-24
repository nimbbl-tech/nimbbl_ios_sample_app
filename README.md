# Nimbbl iOS Sample App

A complete sample iOS application demonstrating the integration of Nimbbl payment services using the published WebView SDK from CocoaPods. This sample app showcases payment integration, modern UI, and best practices for iOS development.

## 📱 Overview

This sample app showcases how to integrate Nimbbl payment services into your iOS application. It demonstrates:

- **Complete payment checkout flow**
- **Integration with WebView SDK**
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
- ✅ Integration with WebView SDK **2.1.0-alpha.1** (local) or **2.0.17** (published)
- ✅ Enhanced delegate-based callbacks
- ✅ Standardized error handling and logging
- ✅ Local or published SDKs via CocoaPods (`USE_LOCAL_SDKS` in `Podfile`)
- ✅ Enhanced security and data handling

## 📋 Requirements

- **iOS**: 13.0+
- **Xcode**: 12.0+
- **Swift**: 5.0+
- **CocoaPods**: Latest version

## 📦 SDK Versions

Controlled by `USE_LOCAL_SDKS` in `Podfile` (default: `true`):

| Mode | WebView SDK | Core API SDK |
|------|-------------|--------------|
| **Local** (`USE_LOCAL_SDKS = true`) | `../nimbbl_mobile_kit_ios_webview_sdk` (2.1.0-alpha.1) | `../nimbbl_mobile_kit_ios_core_api_sdk` (2.1.0-alpha.1) |
| **Published** (`USE_LOCAL_SDKS = false`) | CocoaPods `2.0.17` | pulled in as a dependency |

Clone the iOS SDK repos as siblings of this sample app when using local mode. After changing `Podfile`, run `pod install`.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/nimbbl-tech/nimbbl_ios_sample_app.git
cd nimbbl_ios_sample_app
```

### 2. Install CocoaPods Dependencies

```bash
pod install
```

### 3. Open the Workspace

Always open the **workspace** (not the `.xcodeproj`):

```bash
open NimbblSampleApp.xcworkspace
```

## 🎯 Usage

### Running the Sample App

1. **Open the workspace** in Xcode
2. **Select your target device** (iPhone Simulator or physical device)
3. **Build and run** the project (⌘+R)

## 🔧 Integrating the WebView SDK in Your App

Below is a minimal end‑to‑end example of how to add and use the `nimbbl_mobile_kit_ios_webview_sdk` in your own iOS app.

### 1. Add the Pod

In your app’s `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourAppName' do
  pod 'nimbbl_mobile_kit_ios_webview_sdk', '~> 2.0.17'
end
```

Then run:

```bash
pod install
open YourAppName.xcworkspace
```

### 2. Import and Initialize

In the view controller from which you want to start checkout:

```swift
import nimbbl_mobile_kit_ios_webview_sdk

class MyViewController: UIViewController, NimbblCheckoutSDKDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        NimbblCheckoutSDK.shared.delegate = self
    }

    func startCheckout(with orderToken: String) {
        let options = NimbblCheckoutOptions(orderToken: orderToken, paymentModeCode: nil, bankCode: nil, walletCode: nil, paymentFlow: nil)
        NimbblCheckoutSDK.shared.checkout(from: self, options: options)
    }

    // MARK: - NimbblCheckoutSDKDelegate
    func onCheckoutResponse(data: [AnyHashable: Any]) {
        // Handle checkout response (success, failure, cancel, etc.)
    }
}
```

### 3. Configure UPI/Wallet URL Schemes

Add the following under the root `<dict>` in your app’s `Info.plist` to allow UPI/wallet app detection:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>credpay</string>
    <string>gpay</string>
    <string>mobikwik</string>
    <string>phonepe</string>
    <string>paytmmp</string>
    <string>navipay</string>
    <string>super</string>
    <string>popclubapp</string>
    <string>amazonpay</string>
    <string>kotak811</string>
    <string>bhim</string>
    <string>jupiter</string>
</array>
```

With these three steps (Podfile, import/usage, and `Info.plist` schemes), you have a working WebView SDK integration similar to what this sample app uses.
