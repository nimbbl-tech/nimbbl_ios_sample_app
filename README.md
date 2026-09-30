# Nimbbl iOS Sample App

A complete sample iOS application demonstrating the integration of Nimbbl payment services using the published WebView SDK (available via CocoaPods and Swift Package Manager). This sample app showcases payment integration, modern UI, and best practices for iOS development.

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

- **iOS**: 15.0+
- **Xcode**: 15.0+ (built against the iOS 27 SDK)
- **Swift**: 5.0+
- **CocoaPods**: Latest version (this sample integrates via CocoaPods; the SDK is also available via Swift Package Manager)

## 📦 SDK Versions

This sample integrates the Nimbbl **WebView SDK** (Core API SDK is pulled in
automatically).

- **2.1.0 and later** — available via **Swift Package Manager only**.
- **CocoaPods** — continues to serve the existing **2.0.x** releases (the sample's
  `Podfile` references the latest published 2.0.x). CocoaPods Trunk goes read-only
  on **2 Dec 2026**.

To try 2.1.0+, add the package via SPM (see below); to change the CocoaPods
version, edit the `Podfile` and run `pod install`.

## 🏁 Getting started

```bash
git clone https://github.com/nimbbl-tech/nimbbl_ios_sample_app.git
cd nimbbl_ios_sample_app
pod install
open NimbblSampleApp.xcworkspace
```

Select the **NimbblSampleApp** scheme and run (⌘R). The `Podfile` pulls the SDK as
a binary pod by git tag (trunk-independent). For local development against the pod
repos, set `USE_LOCAL_POD_REPOS = true` in the `Podfile`.

> The `…_pod` repos must be tagged for the release version to resolve. Until a tag
> is published, use the local toggle (`USE_LOCAL_POD_REPOS = true`).

> Prefer Swift Package Manager? The SDK is also distributed via SPM — see the
> WebView SDK's own README for adding it to your app. This sample integrates via
> CocoaPods.

## 🔧 Integrating the WebView SDK in Your App

Below is a minimal end‑to‑end example of how to add and use the `nimbbl_mobile_kit_ios_webview_sdk` in your own iOS app.

### 1. Add the SDK

The WebView SDK is available via both Swift Package Manager and CocoaPods. The
Core API SDK is pulled in automatically — you do not add it yourself.

**Swift Package Manager** — in Xcode, **File ▸ Add Package Dependencies…**:

```
https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git
```

Add the `nimbbl_mobile_kit_ios_webview_sdk` library to your app target.

**CocoaPods (legacy — 2.0.x only)** — 2.1.0+ is SPM-only; CocoaPods continues to
serve existing 2.0.x releases (Trunk goes read-only on 2 Dec 2026). In your app’s
`Podfile`:

```ruby
platform :ios, '15.0'
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
