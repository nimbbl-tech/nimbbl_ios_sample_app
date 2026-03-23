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

This sample app uses the following published SDK version from CocoaPods:

- **WebView SDK**: 2.0.17

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

### 3. Open the Project

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
