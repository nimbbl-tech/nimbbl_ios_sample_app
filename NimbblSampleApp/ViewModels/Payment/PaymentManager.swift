/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import Foundation
import nimbbl_mobile_kit_ios_webview_sdk
import UIKit

// MARK: - Payment Data Models
struct PaymentOption {
    let icon: UIImage?
    let name: String
    let code: String
}

struct SubPaymentOption {
    let imageName: String
    let name: String
    let code: String
}

// MARK: - Payment Manager
class PaymentManager {
    static let shared = PaymentManager()
    
    // MARK: - Payment Options
    var paymentOptions: [PaymentOption] = [
        PaymentOption(icon: UIImage(systemName: "square.grid.2x2"), name: "all payments modes", code: "all"),
        PaymentOption(icon: UIImage(systemName: "building.columns"), name: "netbanking", code: "netbanking"),
        PaymentOption(icon: UIImage(systemName: "wallet.pass"), name: "wallet", code: "wallet"),
        PaymentOption(icon: UIImage(systemName: "creditcard"), name: "card", code: "card"),
        PaymentOption(icon: UIImage(systemName: "qrcode"), name: "upi", code: "upi")
    ]
    
    var netBankingSubOptions: [SubPaymentOption] = [
        SubPaymentOption(imageName: "menuImg", name: "all banks", code: "all"),
        SubPaymentOption(imageName: "hdfcImg", name: "hdfc bank", code: "hdfc"),
        SubPaymentOption(imageName: "sbiImg", name: "sbi bank", code: "sbi"),
        SubPaymentOption(imageName: "kotakImg", name: "kotak bank", code: "kotak")
    ]
    
    var walletSubOptions: [SubPaymentOption] = [
        SubPaymentOption(imageName: "menuImg", name: "all wallets", code: "all"),
        SubPaymentOption(imageName: "freeChargeImg", name: "freecharge", code: "freecharge"),
        SubPaymentOption(imageName: "jioMoneyImg", name: "jio money", code: "jiomoney"),
        SubPaymentOption(imageName: "phonePeImg", name: "phonepe", code: "phonepe")
    ]
    
    var upiSubOptions: [SubPaymentOption] = [
        SubPaymentOption(imageName: "upiImg", name: "collect + intent", code: "collect_intent"),
        SubPaymentOption(imageName: "upiImg", name: "collect", code: "collect"),
        SubPaymentOption(imageName: "upiImg", name: "intent", code: "intent")
    ]
    
    // MARK: - Payment Selection State
    var selectedPaymentOption: IconWithName?
    var selectedSubPaymentOption: ImageWithName?
    
    // MARK: - Currency Options
    let currencyOptions = ["INR", "USD", "EUR"]
    var selectedCurrency = "INR"
    
    // MARK: - Amount
    var amountValue: String = "4.0"
    
    // MARK: - User Details
    var userDetailsEnabled: Bool = false
    var userName: String = ""
    var userNumber: String = ""
    var userEmail: String = ""
    
    // Alias for compatibility with ViewController
    var userDetailsChecked: Bool {
        get { userDetailsEnabled }
        set { userDetailsEnabled = newValue }
    }
    var netBankingSubPaymentTypeList: [SubPaymentOption] { netBankingSubOptions }
    var walletSubPaymentTypeList: [SubPaymentOption] { walletSubOptions }
    var upiSubPaymentTypeList: [SubPaymentOption] { upiSubOptions }
    var headerOptions: [HeaderOption] { getHeaderOptions() }
    
    // MARK: - Header Options
    var isPersonalisedOptionsEnabled: Bool = false
    var selectedHeader: HeaderOption = .brandName
    
    // MARK: - Order Line Items
    var orderLineItemsEnabled: Bool = true // Default to enabled
    
    private init() {}
    
    // MARK: - Payment Option Management
    func getSubPaymentOptions(for paymentOption: PaymentOption) -> [SubPaymentOption] {
        switch paymentOption.code.lowercased() {
        case "netbanking":
            return netBankingSubOptions
        case "wallet":
            return walletSubOptions
        case "upi":
            return upiSubOptions
        default:
            return []
        }
    }
    
    func shouldShowSubPaymentOptions(for paymentOption: PaymentOption) -> Bool {
        return ["netbanking", "upi", "wallet"].contains(paymentOption.code.lowercased())
    }
    
    // MARK: - Header Options Management
    func updateHeaderOptions() {
        if isPersonalisedOptionsEnabled {
            selectedHeader = .brandNameAndLogo
        } else {
            selectedHeader = .brandName
        }
    }
    
    func getHeaderOptions() -> [HeaderOption] {
        if isPersonalisedOptionsEnabled {
            return [.brandNameAndLogo, .brandLogo]
        } else {
            return [.brandName]
        }
    }
    
    // MARK: - Payment Flow
    func createOrderRequest() -> [String: Any] {
        var orderLineItems: [[String: Any]] = []
        orderLineItems.append([
            "name": "Sample Product",
            "quantity": 1,
            "amount": Double(amountValue) ?? 1.0,
            "currency": selectedCurrency
        ])
        
        var requestBody: [String: Any] = [
            "amount": Double(amountValue) ?? 1.0,
            "currency": selectedCurrency,
            "order_line_items": orderLineItems
        ]
        
        if userDetailsEnabled {
            requestBody["user"] = [
                "first_name": userName,
                "mobile_number": userNumber,
                "email": userEmail
            ]
        }
        
        return requestBody
    }
    
    // MARK: - Order Creation (Business Logic)
    func createOrder(completion: @escaping (Result<String, Error>) -> Void) {
        let currency = selectedCurrency
        let amount = amountValue
        let productId = getProductIdForHeader()
        let orderLineItems = orderLineItemsEnabled // Use the property
        let checkoutExperience = "redirect"
        let paymentMode = getPaymentModeCode() ?? ""
        let subPaymentMode = getSubPaymentModeCode() ?? ""
        
        // Build request body with snake_case keys
        var requestBody: [String: Any] = [
            "currency": currency,
            "amount": amount,
            "product_id": productId,
            "orderLineItems": orderLineItems,
            "checkout_experience": checkoutExperience,
            "payment_mode": paymentMode,
            "subPaymentMode": subPaymentMode
        ]
        
        // Only include user object if user details are enabled and valid
        if userDetailsEnabled {
            let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedNumber = userNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Only add user object if at least one field has data
            if !trimmedName.isEmpty || !trimmedNumber.isEmpty || !trimmedEmail.isEmpty {
                let userDict: [String: Any] = [
                    "email": trimmedEmail,
                    "name": trimmedName,
                    "mobile_number": trimmedNumber
                ]
                requestBody["user"] = userDict
            }
        }
        
        if DebugConfig.debugPrintEnabled {
            print("[DEBUG] createShopOrder request body (iOS): \(requestBody)")
        }
        
        // Only pass user object to API if it exists in request body
        let userDict: [String: Any]? = requestBody["user"] as? [String: Any]
        
        NimbblCheckoutSDK.shared.createShopOrder(
            currency: currency,
            amount: amount,
            productId: productId,
            orderLineItems: orderLineItems,
            checkoutExperience: checkoutExperience,
            paymentMode: paymentMode,
            subPaymentMode: subPaymentMode,
            user: userDict
        ) { result in
            switch result {
            case .success(let json):
                if let token = json["token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "No token in response", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Helper to get productId based on header selection
    func getProductIdForHeader() -> String {
        switch selectedHeader {
        case .brandNameAndLogo:
            return "11"
        case .brandLogo:
            return "12"
        case .brandName:
            return "13"
        }
    }

    // Helper to get payment mode code (matches Flutter mapping)
    func getPaymentModeCode() -> String? {
        guard let name = selectedPaymentOption?.name.lowercased() else { return nil }
        switch name {
        case "all payments modes":
            return ""
        case "netbanking":
            return "Netbanking"
        case "wallet":
            return "Wallet"
        case "card":
            return "card"
        case "upi":
            return "UPI"
        default:
            return ""
        }
    }

    // Helper to get sub payment mode code
    func getSubPaymentModeCode() -> String? {
        return selectedSubPaymentOption?.name.lowercased()
    }
    

    // Helper to get payment flow (matches Flutter mapping)
    func getPaymentFlow(upiModeName: String) -> String {
        switch upiModeName.lowercased() {
        case "collect + intent":
            return "phonepe"
        case "collect":
            return "collect"
        case "intent":
            return "intent"
        default:
            return ""
        }
    }
    
    // Helper to get display name for payment option
    func displayName(for paymentOption: PaymentOption) -> String {
        switch paymentOption.code.lowercased() {
        case "all": return TextConstants.allPaymentModes
        case "netbanking": return TextConstants.netbanking
        case "wallet": return TextConstants.wallet
        case "card": return TextConstants.card
        case "upi": return TextConstants.upi
        default: return paymentOption.name
        }
    }
    // Helper to get display name for sub payment option
    func displayName(for subPaymentOption: SubPaymentOption) -> String {
        switch subPaymentOption.code.lowercased() {
        case "all": return TextConstants.allBanks
        case "hdfc": return TextConstants.hdfcBank
        case "sbi": return TextConstants.sbiBank
        case "kotak": return TextConstants.kotakBank
        case "freecharge": return TextConstants.freecharge
        case "jiomoney": return TextConstants.jioMoney
        case "phonepe": return TextConstants.phonepe
        case "collect_intent": return TextConstants.collectIntent
        case "collect": return TextConstants.collect
        case "intent": return TextConstants.intent
        default: return subPaymentOption.name
        }
    }
    
    // MARK: - Validation
    func validateUserDetails() -> Bool {
        guard userDetailsEnabled else { return true }
        
        if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        if userNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        if userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        
        return true
    }
    
    func validateAmount() -> Bool {
        guard let amount = Double(amountValue), amount > 0 else {
            return false
        }
        return true
    }
    
} 
