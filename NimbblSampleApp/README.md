# Nimbbl iOS WebView SDK Integration Guide

Welcome to the Nimbbl iOS WebView SDK! This guide will help you integrate Nimbbl's payment experience into your iOS app quickly and easily.

## Table of Contents
1. [Installation](#1-installation-cocoapods)
2. [Import the SDK](#2-import-the-sdk)
3. [Usage Examples](#3-usage-examples)
4. [Configuration](#4-configuration)
5. [Order Token Generation](#5-order-token-generation)
6. [Troubleshooting](#6-troubleshooting)
7. [Support](#7-support)

---

## 1. Installation (CocoaPods)

Add the following to your app's `Podfile`:

```
pod 'nimbbl_mobile_kit_ios_webview_sdk', :git => 'https://github.com/yourorg/nimbbl_mobile_kit_ios_webview_sdk.git', :tag => '1.0.0'
```

> **Note:** You do **not** need to add the Core API SDK separately. It is included automatically as a dependency.

Then run:

```
pod install
```

Open the `.xcworkspace` file in Xcode.

---

## 2. Import the SDK

In your Swift or Objective-C files:

**Swift:**
```swift
import nimbbl_mobile_kit_ios_webview_sdk
```

**Objective-C:**
```objc
#import <nimbbl_mobile_kit_ios_webview_sdk/nimbbl_mobile_kit_ios_webview_sdk-Swift.h>
```

---

## 3. Usage Examples

### Basic Integration (Swift)
```swift
import nimbbl_mobile_kit_ios_webview_sdk

class MyViewController: UIViewController, NimbblCheckoutSDKDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        NimbblCheckoutSDK.shared.delegate = self
    }
    
    func startCheckout() {
        let options = NimbblCheckoutOptions(
            orderToken: "<order_token>", 
            paymentModeCode: "UPI", 
            bankCode: nil, 
            walletCode: nil, 
            paymentFlow: nil
        )
        NimbblCheckoutSDK.shared.checkout(from: self, options: options)
    }
    
    // MARK: - NimbblCheckoutSDKDelegate
    func onPaymentSuccess(_ response: [AnyHashable : Any]) {
        print("Payment successful: \(response)")
        // Handle payment success
        // response contains order details, transaction ID, etc.
    }
    
    func onError(_ error: String) {
        print("Payment failed: \(error)")
        // Handle payment failure
    }
}
```



### Objective-C Integration
```objc
#import <nimbbl_mobile_kit_ios_webview_sdk/nimbbl_mobile_kit_ios_webview_sdk-Swift.h>

@interface MyViewController () <NimbblCheckoutSDKDelegate>
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NimbblCheckoutSDK shared].delegate = self;
}

- (void)startCheckout {
    NSDictionary *options = @{ 
        @"orderToken": @"<order_token>", 
        @"paymentModeCode": @"UPI" 
    };
    [[NimbblCheckoutSDK shared] checkoutFrom:self options:options];
}

// MARK: - NimbblCheckoutSDKDelegate
- (void)onPaymentSuccess:(NSDictionary<id, id> *)response {
    NSLog(@"Payment successful: %@", response);
    // Handle payment success
}

- (void)onError:(NSString *)error {
    NSLog(@"Payment failed: %@", error);
    // Handle payment failure
}

@end
```



---

## 4. Configuration

### UPI/Wallet App Support
To enable UPI and wallet app detection and deep linking, you **must** add the following to your app's `Info.plist` under the root `<dict>`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>Bandhan</string>
    <string>BHIM</string>
    <string>CanaraMobility</string>
    <string>CentUPI</string>
    <string>com.amazon.mobile.shopping</string>
    <string>com.ausmallfinancebank.aupay.bhimupi</string>
    <string>com.jkbank.bhimjkbankupi</string>
    <string>com.rbl.rblimplicitjourney</string>
    <string>com.syndicate.syndupi</string>
    <string>com.vijayabank.UPI</string>
    <string>cred</string>
    <string>dbin</string>
    <string>freecharge</string>
    <string>gpay</string>
    <string>hdfcnewbb</string>
    <string>imobileapp</string>
    <string>in.cointab.app</string>
    <string>in.fampay.app</string>
    <string>kvb.app.upiapp</string>
    <string>lotza</string>
    <string>mobikwik</string>
    <string>money.bullet</string>
    <string>myairtel</string>
    <string>myJio</string>
    <string>paytm</string>
    <string>payzapp</string>
    <string>phonepe</string>
    <string>truecaller</string>
    <string>ucoupi</string>
    <string>upi</string>
    <string>upibillpay</string>
    <string>whatsapp</string>
    <string>www.citruspay.com</string>
    <string>paytmmp</string>
</array>
```

**Why is this needed?**
- iOS requires all URL schemes you want to query with `canOpenURL:` to be declared in your app's Info.plist.
- Without this, your app will not be able to detect or open UPI/wallet apps for payment.
- This configuration enables the SDK to check which UPI apps are installed and provide them as payment options.

**Supported Apps**
The configuration includes support for:
- **UPI Apps**: BHIM, PhonePe, Google Pay, Paytm, etc.
- **Wallet Apps**: Freecharge, Mobikwik, CRED, etc.
- **Bank Apps**: HDFC, ICICI, SBI, etc.

**Adding New Apps**
To support additional UPI or wallet apps, simply add their URL scheme to the array:

```xml
<string>newappscheme</string>
```

**Testing UPI Integration**
After adding the configuration:
1. Build and run your app
2. Navigate to the payment screen
3. Verify that installed UPI apps appear in the payment options
4. Test deep linking by selecting a UPI app

**Troubleshooting UPI Issues**
If UPI apps are not appearing:
1. Verify the URL schemes are correctly added to Info.plist
2. Check that the UPI apps are actually installed on the device
3. Ensure you're testing on a physical device (simulator may not have UPI apps)
4. Check console logs for any URL scheme related errors

### Payment Mode Codes
Supported payment modes:
- `UPI` - UPI payments
- `CARD` - Credit/Debit cards
- `NETBANKING` - Net banking
- `WALLET` - Digital wallets

---

## 5. Order Token Generation

The order token is a JWT (JSON Web Token) that contains encrypted order information. For production apps, order tokens should be generated on your backend for security reasons.

### Backend Integration
Your backend should create orders using Nimbbl's API and return the order token to your app:

```swift
// Order token from your backend
let orderToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // From your backend

// Initialize checkout with the order token
let options = NimbblCheckoutOptions(
    orderToken: orderToken,
    paymentModeCode: "UPI",
    bankCode: nil,
    walletCode: nil,
    paymentFlow: nil
)
NimbblCheckoutSDK.shared.checkout(from: self, options: options)
```

### Security Best Practices
- ✅ Generate order tokens on your backend
- ✅ Validate order tokens before processing payments
- ✅ Use HTTPS for all API communications
- ✅ Implement proper error handling
- ❌ Never expose API keys in client-side code

---

## 6. Troubleshooting

### Common Issues

**Module not found?**
- Make sure you opened the `.xcworkspace` and not the `.xcodeproj`
- Run `pod install` again
- Clean build folder (Cmd+Shift+K)

**Build errors?**
- Ensure iOS deployment target is 13.0 or higher
- Check that Swift version is 5.0 or higher
- Run `pod install` and clean build folder

**Objective-C integration issues?**
- Ensure you import the `-Swift.h` header
- Use the `ObjC`-suffixed methods for Objective-C
- Check that your bridging header is properly configured

**Payment not working?**
- Verify your order token is valid and not expired
- Check network connectivity
- Ensure UPI apps are properly configured in Info.plist
- Verify the order token format (should be a valid JWT)

**WebView not loading?**
- Check internet connectivity
- Verify the order token format
- Ensure the order token is not expired
- Check that the order status is valid

**UPI apps not appearing?**
- Verify URL schemes are correctly added to Info.plist
- Check that UPI apps are actually installed on the device
- Ensure you're testing on a physical device (simulator may not have UPI apps)
- Check console logs for any URL scheme related errors

### Production Checklist
Before going live, ensure:
- ✅ Order tokens are generated on your backend
- ✅ HTTPS is used for all API communications
- ✅ UPI apps are properly configured in Info.plist
- ✅ Error handling is implemented
- ✅ Payment callbacks are properly handled
- ✅ App is tested on physical devices

---

## 7. API Parameters Reference

### NimbblCheckoutOptions Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `orderToken` | String | ✅ **Mandatory** | JWT token containing order information |
| `paymentModeCode` | String | ❌ Optional | Payment mode (UPI, CARD, NETBANKING, WALLET) |
| `bankCode` | String | ❌ Optional | Bank code for net banking payments |
| `walletCode` | String | ❌ Optional | Wallet code for wallet payments |
| `paymentFlow` | String | ❌ Optional | Payment flow type |

### Payment Mode Codes

| Code | Description | Required Parameters |
|------|-------------|-------------------|
| `UPI` | UPI payments | None |
| `CARD` | Credit/Debit cards | None |
| `NETBANKING` | Net banking | `bankCode` |
| `WALLET` | Digital wallets | `walletCode` |

---

## 8. Support

For help, contact the Nimbbl support team at [support@nimbbl.tech](mailto:support@nimbbl.tech).

### Additional Resources
- [Nimbbl API Documentation](https://docs.nimbbl.tech)
- [iOS SDK GitHub Repository](https://github.com/nimbbl/nimbbl_mobile_kit_ios_webview_sdk)
- [Sample App](https://github.com/nimbbl/nimbbl-ios-sample-app)

---

Happy integrating! 