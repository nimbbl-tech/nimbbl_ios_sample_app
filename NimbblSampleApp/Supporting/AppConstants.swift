/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

// MARK: - API Constants
// Note: APIConstants is defined in the nimbbl_mobile_kit_ios_core_api_sdk framework
// This section is for reference only - the actual implementation is in the SDK

// MARK: - API Utils
// Note: APIUtils is defined in the nimbbl_mobile_kit_ios_core_api_sdk framework
// This section is for reference only - the actual implementation is in the SDK

// MARK: - Image Names
struct ImageNames {
    static let sonicLogo = "SonicLogo"
    static let paperPlane = "Paperplane"
    static let footerLogo = "footerlogo"
    static let infoIcon = "infoIcon"
    static let menuImg = "menuImg"
    static let hdfcImg = "hdfcImg"
    static let sbiImg = "sbiImg"
    static let kotakImg = "kotakImg"
    static let freeChargeImg = "freeChargeImg"
    static let jioMoneyImg = "jioMoneyImg"
    static let phonePeImg = "phonePeImg"
    static let upiImg = "upiImg"
}

// MARK: - System Image Names
struct SystemImageNames {
    static let gearShapeFill = "gearshape.fill"
    static let squareGrid2x2 = "square.grid.2x2"
    static let buildingColumns = "building.columns"
    static let walletPass = "wallet.pass"
    static let creditCard = "creditcard"
    static let qrCode = "qrcode"
    static let chevronDown = "chevron.down"
}

// MARK: - Text Constants
struct TextConstants {
    static let byNimbbl = "by nimbbl."
    static let paperPlane = "paper plane."
    static let payNow = "pay now"
    static let name = "name"
    static let number = "number"
    static let email = "email"
    static let orderLineItems = "order line items"
    static let headerCustomisation = "header customisation"
    static let paymentCustomisation = "payment customisation"
    static let subPaymentMode = "sub payment mode"
    static let userDetails = "user details ?"
    static let infoMessage = "this is a real transaction, any amount deducted will refunded within 7 working days"
    static let footerText = "© 2026 nimbbl by bigital technologies pvt ltd"
    
    // Payment option names
    static let allPaymentModes = "all payments modes"
    static let netbanking = "netbanking"
    static let wallet = "wallet"
    static let card = "card"
    static let upi = "upi"
    
    // Sub-payment option names
    static let allBanks = "all banks"
    static let hdfcBank = "hdfc bank"
    static let sbiBank = "sbi bank"
    static let kotakBank = "kotak bank"
    static let allWallets = "all wallets"
    static let freecharge = "freecharge"
    static let jioMoney = "jio money"
    static let phonepe = "phonepe"
    static let collectIntent = "collect + intent"
    static let collect = "collect"
    static let intent = "intent"
    static let orderSuccess = "Order Success"
    static let orderIdPrefix = "Order ID: "
    static let statusSuccessPrefix = "Status: Success\nTxn ID: "
    static let settingsTitle = "Settings"
    static let selectEnvironment = "Select an environment"
    static let selectExperience = "Select an app experience"
    static let done = "DONE"
    static let selectEnvironmentAlert = "Select Environment"
    static let selectExperienceAlert = "Select Experience"
    static let cancel = "Cancel"
    static let paymentOptionCell = "PaymentOptionCell"
    static let subPaymentOptionCell = "SubPaymentOptionCell"
    static let validationErrorTitle = "Validation Error"
    static let validationErrorMessage = "Please fill all required fields correctly."
    static let orderErrorTitle = "Order Error"
    static let errorTitle = "Error"
    static let selectCurrency = "Select Currency"
    static let ok = "OK"
    static let sampleProduct = "Sample Product"
    static let headerCustomisationPrefix = "Header Customisation: "
    static let paymentCustomisationPrefix = "Payment Customisation: "
    static let brandName = "your brand name"
    static let brandNameAndLogo = "your brand name and brand logo"
    static let brandLogo = "your brand logo"
    static let prod = "Prod"
    static let preProd = "Pre-Prod"
    static let qa1 = "QA 1"
    static let qa2 = "QA 2"
    static let native = "Native"
    static let webView = "WebView"
    static let headerOptionCell = "HeaderOptionCell"
}

// MARK: - Font Names
struct FontNames {
    static let gorditaBold = "Gordita-Bold"
    static let gorditaMedium = "Gordita-Medium"
    static let gorditaItalic = "Gordita-Italic"
}

// MARK: - Font Sizes
struct FontSizes {
    static let small: CGFloat = 10
    static let medium: CGFloat = 12
    static let regular: CGFloat = 14
    static let large: CGFloat = 16
}

// MARK: - Kerning Values
struct KerningValues {
    static let small: CGFloat = -0.24
    static let medium: CGFloat = -0.32
    static let large: CGFloat = -0.4
    static let extraLarge: CGFloat = -0.48
}

// MARK: - Color Values
struct ColorValues {
    static let customRed = UIColor(red: 0.984, green: 0.22, blue: 0.114, alpha: 1) // #FB381D
    static let customBlue1 = UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1) // #22274C
    static let customBlue2 = UIColor(red: 0.20, green: 0.23, blue: 0.44, alpha: 1) // #343B70
    static let customFooterGray = UIColor(hex: "#606060")
}

// MARK: - Validation Constants
struct ValidationConstants {
    static let minNameLength = 2
    static let minPhoneLength = 10
    static let maxPhoneLength = 15
    static let defaultAmount = "4.0"
}

// MARK: - Animation Constants
struct AnimationConstants {
    static let defaultDuration: TimeInterval = 0.3
    static let keyboardAnimationDuration: TimeInterval = 0.25
    static let buttonPressDuration: TimeInterval = 0.1
}

// MARK: - Layout Constants
struct LayoutConstants {
    static let defaultPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 12
    static let largePadding: CGFloat = 16
    static let extraLargePadding: CGFloat = 20
    static let defaultMargin: CGFloat = 20
    static let smallMargin: CGFloat = 12
    static let largeMargin: CGFloat = 28
} 

// MARK: - Debug Flag
struct DebugConfig {
    #if DEBUG
    static let debugPrintEnabled = true
    #else
    static let debugPrintEnabled = false
    #endif
} 

// MARK: - Environment URLs
struct EnvironmentUrls {
    static let prod = "https://api.nimbbl.tech/"
    static let preProd = "https://apipp.nimbbl.tech/"
    static let qa1 = "https://qa1api.nimbbl.tech/"
}
