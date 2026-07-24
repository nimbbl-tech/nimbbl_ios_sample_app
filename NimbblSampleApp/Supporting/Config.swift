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
// Matches Android AppConstants ENVIRONMENT_* values exactly: Prod / Pre-Prod / QA.
// (Legacy `qa1` / `qa2` aliases preserved for back-compat but not shown in the picker.)
enum Environment: String, CaseIterable {
    case prod = "Prod"
    case preProd = "Pre-Prod"
    case qa = "QA"

    // Legacy raw values that may still live in UserDefaults from older builds.
    static let qa1Legacy = "QA 1"
    static let qa2Legacy = "QA 2"

    var displayName: String {
        switch self {
        case .prod: return TextConstants.prod
        case .preProd: return TextConstants.preProd
        case .qa: return TextConstants.qa
        }
    }

    /// Map any stored legacy raw value to the new single `qa` value.
    static func migrateLegacyValue(_ raw: String) -> String {
        switch raw {
        case Environment.qa1Legacy, Environment.qa2Legacy:
            return Environment.qa.rawValue
        default:
            return raw
        }
    }
}

// MARK: - Experience Enum
enum Experience: String, CaseIterable {
    case native = "Native"
    case webView = "Webview"   // matches Android AppConstants.EXPERIENCE_WEBVIEW

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
    case emi = "emi"          // new — matches Android AppConstants string "emi"
    case all = "all"

    var displayName: String {
        switch self {
        case .upi: return TextConstants.upi
        case .netbanking: return TextConstants.netbanking
        case .wallet: return TextConstants.wallet
        case .card: return TextConstants.card
        case .emi: return TextConstants.emi
        case .all: return TextConstants.allPaymentModes
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    var selectedEnvironment: String {
        get {
            let raw = string(forKey: "selectedEnvironment") ?? Environment.prod.rawValue
            return Environment.migrateLegacyValue(raw)
        }
        set { set(newValue, forKey: "selectedEnvironment") }
    }
    var selectedExperience: String {
        get { string(forKey: "selectedExperience") ?? Experience.webView.rawValue }
        set { set(newValue, forKey: "selectedExperience") }
    }
}
