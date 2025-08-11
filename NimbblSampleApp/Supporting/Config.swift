/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import Foundation
// MARK: - HeaderOption Enum
enum HeaderOption: String, CaseIterable {
    case brandName = "brandName"
    case brandNameAndLogo = "brandNameAndLogo"
    case brandLogo = "brandLogo"
    
    var displayName: String {
        switch self {
        case .brandName: return TextConstants.brandName
        case .brandNameAndLogo: return TextConstants.brandNameAndLogo
        case .brandLogo: return TextConstants.brandLogo
        }
    }
}

// MARK: - Environment Enum
enum Environment: String, CaseIterable {
    case prod = "Prod"
    case preProd = "Pre-Prod"
    case qa1 = "QA 1"
    case qa2 = "QA 2"
    
    var displayName: String {
        switch self {
        case .prod: return TextConstants.prod
        case .preProd: return TextConstants.preProd
        case .qa1: return TextConstants.qa1
        case .qa2: return TextConstants.qa2
        }
    }
}

// MARK: - Experience Enum
enum Experience: String, CaseIterable {
    case native = "Native"
    case webView = "WebView"
    
    var displayName: String {
        switch self {
        case .native: return TextConstants.native
        case .webView: return TextConstants.webView
        }
    }
}

// MARK: - PaymentMode Enum
enum PaymentMode: String, CaseIterable {
    case upi = "upi"
    case netbanking = "netbanking"
    case wallet = "wallet"
    case card = "card"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .upi: return TextConstants.upi
        case .netbanking: return TextConstants.netbanking
        case .wallet: return TextConstants.wallet
        case .card: return TextConstants.card
        case .all: return TextConstants.allPaymentModes
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    var selectedEnvironment: String {
        get { string(forKey: "selectedEnvironment") ?? Environment.prod.rawValue }
        set { set(newValue, forKey: "selectedEnvironment") }
    }
    var selectedExperience: String {
        get { string(forKey: "selectedExperience") ?? Experience.webView.rawValue }
        set { set(newValue, forKey: "selectedExperience") }
    }
} 
