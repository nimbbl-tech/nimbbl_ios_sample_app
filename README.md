# Nimbbl iOS Sample App

A complete sample iOS application demonstrating the integration of Nimbbl payment services using both the Core API SDK and WebView SDK.

## 📱 Overview

This sample app showcases how to integrate Nimbbl payment services into your iOS application. It demonstrates:

- **Complete payment checkout flow**
- **Integration with both Core API SDK and WebView SDK**
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
- ✅ Integration with Core API SDK
- ✅ Integration with WebView SDK
- ✅ Delegate-based callbacks
- ✅ Error handling and logging
- ✅ Build scripts for development
- ✅ Production-ready configuration

## 📋 Requirements

- **iOS**: 13.0+
- **Xcode**: 12.0+
- **Swift**: 5.0+
- **CocoaPods**: Latest version

## �� Installation

### 1. Clone the Repository

```bash
git clone https://github.com/nimbbl-tech/nimbbl_ios_sample_app.git
cd nimbbl_ios_sample_app
```

### 2. Install Dependencies

The sample app uses local SDK dependencies. Make sure you have the following repositories cloned in the same directory:

```bash
# Clone Core API SDK
git clone https://bitbucket.org/nimbbl-tech/nimbbl_mobile_kit_ios_core_api_sdk.git

# Clone WebView SDK
git clone https://bitbucket.org/nimbbl-tech/nimbbl_mobile_kit_ios_webview_sdk.git
```

### 3. Install CocoaPods Dependencies

```bash
pod install
```

### 4. Open the Project

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
NimbblSampleApp/
├── App/
│   ├── AppDelegate.swift
│   ├── LaunchScreen.storyboard
│   └── NimbblCheckout-Bridging-Header.h
├── Extensions/
│   ├── UIColor+Hex.swift
│   ├── UIComponents.swift
│   └── ViewController+UITextFieldDelegate.swift
├── Models/
│   ├── IconWithName.swift
│   └── ImageWithName.swift
├── Resources/
│   └── Assets.xcassets/
├── Supporting/
│   ├── AppConstants.swift
│   ├── CODE_ORGANIZATION.md
│   └── Config.swift
├── ViewModels/
│   ├── Payment/
│   │   └── PaymentManager.swift
│   └── User/
│       └── UserDetailsManager.swift
├── Views/
│   ├── Payment/
│   │   ├── HeaderOptionsBottomSheetViewController.swift
│   │   ├── PaymentOptionsBottomSheetViewController.swift
│   │   └── SubPaymentOptionsBottomSheetViewController.swift
│   ├── Settings/
│   │   └── SettingsViewController.swift
│   ├── ThankYou/
│   │   └── ThankYouVC.swift
│   └── ViewController.swift
├── Podfile
├── Podfile.production
├── build_without_sandbox.sh
└── clean_project.rb
```

## 🔧 Configuration

### Environment Setup

The sample app supports multiple environments:

```swift
// Development Environment
let devUrl = "https://api-qa1.nimbbl.tech"

// Production Environment
let prodUrl = "https://api.nimbbl.tech"
```

### SDK Integration

The sample app demonstrates integration with both SDKs:

```swift
// Core API SDK Integration
import nimbbl_mobile_kit_ios_core_api_sdk

let sdk = NimbblCoreApiSDK.shared
sdk.updateOrderDetails(token: orderToken, orderId: orderId) { result in
    // Handle response
}

// WebView SDK Integration
import nimbbl_mobile_kit_ios_webview_sdk

NimbblCheckoutSDK.shared.delegate = self
let options = NimbblCheckoutOptions()
options.orderToken = "your_order_token"
NimbblCheckoutSDK.shared.checkout(from: self, options: options)
```

## 🎨 Customization

### UI Customization

The sample app includes various customization options:

- **Header Options**: Customize checkout header appearance
- **Payment Options**: Configure available payment methods
- **Amount & Currency**: Set payment amount and currency
- **User Details**: Collect customer information

### Payment Flow Customization

```swift
// Customize checkout options
let options = NimbblCheckoutOptions()
options.orderToken = orderToken
options.amount = amount
options.currency = currency
options.customerName = customerName
options.customerEmail = customerEmail
options.customerPhone = customerPhone

// Start checkout
NimbblCheckoutSDK.shared.checkout(from: self, options: options)
```

## 🔍 Debugging

### Build Scripts

The project includes helpful build scripts:

```bash
# Build without code signing (for development)
./build_without_sandbox.sh

# Clean project
ruby clean_project.rb
```

### Logging

The sample app includes comprehensive logging:

```swift
// Enable debug logging
LogUtil.debugLog(tag: "SampleApp", message: "Debug message")

// Error logging
LogUtil.errorLog(tag: "SampleApp", message: "Error occurred")
```

## 📚 Documentation

- [Core API SDK Documentation](../nimbbl_mobile_kit_ios_core_api_sdk/README.md)
- [WebView SDK Documentation](../nimbbl_mobile_kit_ios_webview_sdk/README.md)
- [Code Organization](NimbblSampleApp/Supporting/CODE_ORGANIZATION.md)

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure all SDK repositories are cloned
   - Run `pod install` to install dependencies
   - Clean build folder (⌘+Shift+K)

2. **Runtime Errors**
   - Check network connectivity
   - Verify API endpoints in settings
   - Check console logs for error messages

3. **Payment Issues**
   - Verify order token is valid
   - Check payment amount and currency
   - Ensure proper delegate implementation

### Getting Help

- **Documentation**: Check the SDK documentation
- **Issues**: Report issues on GitHub
- **Support**: Contact support@nimbbl.com

## 🚀 Production Deployment

### Before Production

1. **Update API endpoints** to production URLs
2. **Configure code signing** for App Store distribution
3. **Test thoroughly** on physical devices
4. **Review security** settings and configurations

### Build Configuration

```bash
# Production build
xcodebuild -workspace NimbblSampleApp.xcworkspace \
           -scheme NimbblSampleApp \
           -configuration Release \
           -destination 'generic/platform=iOS' \
           archive
```

## 📄 License

This sample app is provided as-is for demonstration purposes. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For support and questions:

- **Email**: support@nimbbl.com
- **Website**: https://nimbbl.com
- **Documentation**: [Nimbbl Developer Docs](https://docs.nimbbl.com)

---

**Happy Coding! 🎉**
