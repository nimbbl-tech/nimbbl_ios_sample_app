# Nimbbl iOS Sample App

A complete sample iOS application demonstrating the integration of Nimbbl payment services using the published WebView SDK via Swift Package Manager (also available on CocoaPods). This sample app showcases payment integration, modern UI, and best practices for iOS development.

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
- ✅ Integration with WebView SDK 2.1.0-alpha.4 (published)
- ✅ Enhanced delegate-based callbacks
- ✅ Standardized error handling and logging
- ✅ Production-ready configuration
- ✅ Published SDK via Swift Package Manager
- ✅ Enhanced security and data handling

## 📋 Requirements

- **iOS**: 15.0+
- **Xcode**: 15.0+ (built against the iOS 27 SDK)
- **Swift**: 5.0+
- **Swift Package Manager** (bundled with Xcode — no extra tooling)

## 📦 SDK Version

This sample integrates the Nimbbl **WebView SDK** at **2.1.0-alpha.4** via **Swift
Package Manager**; the **Core API SDK** is pulled in automatically as a transitive
dependency. The SDK is also published on the **CocoaPods trunk** if you prefer Pods
(CocoaPods Trunk goes read-only on **2 Dec 2026**).

## 🏁 Getting started

```bash
git clone https://github.com/nimbbl-tech/nimbbl_ios_sample_app.git
cd nimbbl_ios_sample_app
open NimbblSampleApp.xcodeproj
```

Xcode resolves the Swift Package automatically on open — **no `pod install`, no
workspace**. Select the **NimbblSampleApp** scheme and run (⌘R).

> If packages don't resolve, use **File ▸ Packages ▸ Resolve Package Versions**.

## 🔧 Integrating the WebView SDK in Your App

Below is a minimal end‑to‑end example of how to add and use the `nimbbl_mobile_kit_ios_webview_sdk` in your own iOS app.

### 1. Add the SDK (Swift Package Manager)

In Xcode, **File ▸ Add Package Dependencies…**, enter the package URL and pin an
exact version (e.g. `2.1.0-alpha.4`):

```
https://github.com/nimbbl-tech/nimbbl_mobile_kit_ios_webview_pod.git
```

Add the **`nimbbl_mobile_kit_ios_webview_sdk`** library to your app target. The
Core API SDK is pulled in automatically — you do not add it yourself.

**Prefer CocoaPods?** The SDK is also on the trunk — add only the WebView pod and
Core resolves transitively:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'YourAppName' do
  pod 'nimbbl_mobile_kit_ios_webview_sdk', '2.1.0-alpha.4'
end
```

> ### ⚠️ Create the order on your server — never in the app
>
> The `orderToken` you pass to the SDK must be created **server-side** by calling
> Nimbbl's Create Order API with your **secret API key**, which must never ship in
> the app. Your backend returns the order token; the app only forwards it to the
> SDK. *(For convenience this sample creates orders against a demo shop backend —
> that is **not** the production pattern.)*

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
        let options = NimbblCheckoutOptions(orderToken: orderToken, paymentModeCode: nil, bankCode: nil, walletCode: nil, paymentFlow: nil, upiAppCode: nil, emiCode: nil)
        NimbblCheckoutSDK.shared.checkout(from: self, options: options)
    }

    // MARK: - NimbblCheckoutSDKDelegate
    func onCheckoutResponse(data: [AnyHashable: Any]) {
        // The result arrives as an untyped dictionary. Typical fields:
        let status        = data["status"] as? String ?? "unknown"
        let orderId       = (data["order_id"] ?? data["nimbbl_order_id"]) as? String
        let transactionId = (data["transaction_id"] ?? data["nimbbl_transaction_id"]) as? String

        switch status.lowercased() {
        case "success":          break // payment succeeded — fulfil using orderId/transactionId
        case "failed", "failure": break // payment failed — show the reason (data["reason"])
        default:                 break // pending / cancelled — treat as not yet paid
        }
        // IMPORTANT: confirm the final status server-side (webhook or order-status
        // API) before fulfilment — do not trust the client response alone.
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
