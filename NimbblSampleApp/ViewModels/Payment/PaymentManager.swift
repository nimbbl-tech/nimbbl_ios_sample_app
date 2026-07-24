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
    
    // MARK: - Payment Options (mirrors Android `payment_type` string-array)
    var paymentOptions: [PaymentOption] = [
        PaymentOption(icon: UIImage(systemName: "square.grid.2x2"), name: "all payments modes", code: "all"),
        PaymentOption(icon: UIImage(systemName: "building.columns"), name: "netbanking", code: "netbanking"),
        PaymentOption(icon: UIImage(systemName: "wallet.pass"), name: "wallet", code: "wallet"),
        PaymentOption(icon: UIImage(systemName: "creditcard"), name: "card", code: "card"),
        PaymentOption(icon: UIImage(systemName: "qrcode"), name: "upi", code: "upi"),
        // EMI enforcement — matches Android AppConstants string "emi"
        PaymentOption(icon: UIImage(systemName: "calendar"), name: "emi", code: "emi")
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

    /// UPI intent app picker — shown only when Payment=UPI + Sub=Intent.
    /// Mirrors Android `sub_payment_type_upi_intent_apps` + `getUpiAppCode`.
    ///
    /// imageName references brand-specific assets where available, fallback to
    /// `upiImg` otherwise. To get distinct logos for Google Pay and Paytm,
    /// add `gpayImg.imageset` and `paytmImg.imageset` to Assets.xcassets
    /// (Android has gpay.png + paytm.png drawables already — reuse those).
    var upiIntentAppOptions: [SubPaymentOption] = [
        SubPaymentOption(imageName: "gpayImg",    name: "Google Pay", code: "gpay"),
        SubPaymentOption(imageName: "phonePeImg", name: "PhonePe",    code: "phonepeupi"),
        SubPaymentOption(imageName: "paytmImg",   name: "Paytm",      code: "paytmupi")
    ]

    /// EMI sub-options — mirrors Android `sub_payment_type_emi` + `getEMICode`.
    /// Note: the EMI sub-code is propagated via `NimbblCheckoutOptions.emiCode`,
    /// NOT via `sub_payment_mode`, matching Android's behavior.
    var emiSubOptions: [SubPaymentOption] = [
        SubPaymentOption(imageName: "menuImg",  name: "all emis",        code: ""),
        SubPaymentOption(imageName: "menuImg",  name: "debit card emi",  code: "debit"),
        SubPaymentOption(imageName: "menuImg",  name: "credit card emi", code: "credit"),
        SubPaymentOption(imageName: "menuImg",  name: "cardless emi",    code: "cardless")
    ]

    // MARK: - Payment Selection State
    var selectedPaymentOption: IconWithName?
    var selectedSubPaymentOption: ImageWithName?
    /// Selected UPI intent app (only meaningful when Payment=UPI + Sub=Intent).
    var selectedUpiApp: SubPaymentOption?
    /// Selected EMI sub-option (only meaningful when Payment=EMI).
    var selectedEmiOption: SubPaymentOption?
    
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
    var emiSubPaymentTypeList: [SubPaymentOption] { emiSubOptions }
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
        case "emi":
            return emiSubOptions
        default:
            return []
        }
    }

    func shouldShowSubPaymentOptions(for paymentOption: PaymentOption) -> Bool {
        return ["netbanking", "upi", "wallet", "emi"].contains(paymentOption.code.lowercased())
    }

    /// True iff a UPI app sub-picker should be visible — Payment=UPI + Sub=intent.
    /// Mirrors Android's spinner-visibility condition in OrderCreateActivity.
    func shouldShowUpiAppPicker(payment: PaymentOption?, sub: SubPaymentOption?) -> Bool {
        guard let payment = payment, let sub = sub else { return false }
        return payment.code.lowercased() == "upi" && sub.code.lowercased() == "intent"
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
    /// `OrderCreateActivity.createShopOrderRequest(...)` field-by-field:
    ///   - currency, amount (as string), product_id, total_amount, amount_before_tax,
    ///     tax, additional_charges, grand_total_amount, order_line_items (Bool),
    ///     checkout_experience, payment_mode, sub_payment_mode (only when non-empty),
    ///     user (only when mobile_number is non-empty), order_line_item (array of 1).
    ///   - All keys are snake_case to match the backend contract.
    func createOrder(completion: @escaping (Result<String, Error>) -> Void) {
        let currency = selectedCurrency
        let amountString = amountValue
        // Android parses amount as Int(amount.text). iOS amountValue is a String like
        // "4.0" — use the same integer-truncation behavior.
        let amountInt = Int(Double(amountString) ?? 0)
        let productId = getProductIdForHeader()
        let checkoutExperience = "redirect"
        let paymentMode = getPaymentModeCode() ?? ""
        let subPaymentMode = getSubPaymentModeCode() ?? ""

        // Trim user inputs (Android trims via .ifEmpty { "" } pattern; iOS does the same).
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMobile = userNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        // Build request body. Order of keys mirrors Android `JSONObject.put(...)` sequence.
        var requestBody: [String: Any] = [
            "currency": currency,
            "amount": "\(amountInt)",                  // Android sends as string
            "product_id": productId,
            "total_amount": amountInt,
            "amount_before_tax": amountInt,
            "tax": 0,
            "additional_charges": 0,
            "grand_total_amount": amountInt,
            "order_line_items": true,                  // Bool — matches Android `put("order_line_items", true)`
            "checkout_experience": checkoutExperience,
            "payment_mode": paymentMode.isEmpty ? "All" : paymentMode  // mirrors Android `paymentMode.ifEmpty { "All" }`
        ]

        // sub_payment_mode — only included when non-empty (Android `if (!subPaymentMode.isNullOrEmpty())`)
        if !subPaymentMode.isEmpty {
            requestBody["sub_payment_mode"] = subPaymentMode
        }

        // User object — Android includes user ONLY when mobile_number is non-empty.
        // When mobile is empty, Android still sends `"user": {}` (empty object).
        if !trimmedMobile.isEmpty {
            requestBody["user"] = [
                "email": trimmedEmail,
                "name": trimmedName,
                "mobile_number": trimmedMobile
            ]
        } else {
            requestBody["user"] = [String: Any]()  // empty user object — matches Android `else { put("user", JSONObject()) }`
        }

        // order_line_item — singular key with array of 1, matching Android exactly.
        let amountDouble = Double(amountInt)
        requestBody["order_line_item"] = [[
            "title": "Product",
            "description": "Product description",
            "quantity": 1,
            "rate": amountDouble,
            "total_amount": amountDouble,
            "amount_before_tax": amountDouble,
            "tax": 0,
            "image_url": "",
            "sku_id": productId,
            "uom": "unit"
        ]]

        if DebugConfig.debugPrintEnabled {
            DebugLog.log("[DEBUG] createShopOrder request body (iOS): \(requestBody)")
        }

        createShopOrder(requestBody: requestBody, completion: completion)
    }

    /// Creates a shop order via the create-shop API (moved from SDK to sample app).
    private func createShopOrder(requestBody: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = SampleShopAPIUtils.getShopUrl(environmentUrl: NimbblCheckoutSDK.shared.environmentUrl)
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid shop URL", code: 0, userInfo: nil)))
            return
        }
        guard let body = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "Invalid order data", code: 0, userInfo: nil)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Structured request log — mirrors Android `logSampleApiRequest("OrderCreate-Shop", ...)`.
        SampleApiLogger.logRequest(
            tag: "OrderCreate-Shop",
            method: "POST",
            url: urlString,
            headers: ["Content-Type": "application/json"],
            body: String(data: body, encoding: .utf8)
        )

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                SampleApiLogger.logResponse(
                    tag: "OrderCreate-Shop",
                    code: -1,
                    message: "network error",
                    body: error.localizedDescription
                )
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            // Mirror Android: log every response, regardless of status code.
            let http = response as? HTTPURLResponse
            let bodyString = data.flatMap { String(data: $0, encoding: .utf8) }
            SampleApiLogger.logResponse(
                tag: "OrderCreate-Shop",
                code: http?.statusCode ?? -1,
                message: http.map { HTTPURLResponse.localizedString(forStatusCode: $0.statusCode) },
                body: bodyString
            )
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil))) }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let token = json?["token"] as? String {
                    DispatchQueue.main.async { completion(.success(token)) }
                } else if let errorPayload = json?["error"] {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Order error", code: 0, userInfo: ["error": errorPayload])))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // Helper to get productId based on header selection
    func getProductIdForHeader() -> String {
        switch selectedHeader {
        case .brandNameAndLogo:
            return "1"
        case .brandLogo:
            return "2"
        case .brandName:
            return "3"
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
        case "emi":
            return "emi"
        default:
            return ""
        }
    }

    /// Returns the EMI code (`debit` / `credit` / `cardless` / "") if the current
    /// payment mode is EMI and the user has picked a sub-option. Mirrors Android `getEMICode`.
    func getEMICode() -> String? {
        guard getPaymentModeCode()?.lowercased() == "emi" else { return nil }
        guard let subName = selectedSubPaymentOption?.name.lowercased() else { return nil }
        switch subName {
        case TextConstants.allEmis.lowercased(), "all emis":
            return ""
        case TextConstants.debitCardEmi.lowercased(), "debit card emi":
            return "debit"
        case TextConstants.creditCardEmi.lowercased(), "credit card emi":
            return "credit"
        case TextConstants.cardlessEmi.lowercased(), "cardless emi":
            return "cardless"
        default:
            return ""
        }
    }

    /// Returns the UPI app code when payment=UPI and sub=intent and the user has
    /// picked an app from the dedicated UPI app picker. Mirrors Android `getUpiAppCode`.
    func getUpiAppCode() -> String? {
        guard getPaymentModeCode()?.uppercased() == "UPI" else { return nil }
        guard let subName = selectedSubPaymentOption?.name.lowercased() else { return nil }
        guard subName == "intent" else { return nil }
        // If a UPI app was picked from the third-level picker, use that code.
        if let code = selectedUpiApp?.code, !code.isEmpty {
            return code
        }
        return nil
    }

    // Helper to get sub payment mode code (raw name, lowercased — used for the
    // generic `sub_payment_mode` body field in the shop /create-shop request).
    func getSubPaymentModeCode() -> String? {
        return selectedSubPaymentOption?.name.lowercased()
    }

    /// Returns the netbanking bank code (`hdfc` / `sbi` / `kotak`) — but only when
    /// the parent payment mode is netbanking. Returns `nil` otherwise so the
    /// SDK's `PaymentURLBuilder` doesn't append a spurious `&bank_code=` to the
    /// WebView URL when EMI/wallet/UPI is selected.
    ///
    /// Mirrors Android `getBankCode(bankName, context)` semantics: that helper
    /// returns "" for unknown names (e.g. "debit card emi"), which the SDK then
    /// skips because empty values aren't appended.
    func getBankCode() -> String? {
        guard getPaymentModeCode()?.lowercased() == "netbanking" else { return nil }
        guard let name = selectedSubPaymentOption?.name.lowercased() else { return nil }
        switch name {
        case "all banks":   return ""
        case "hdfc bank":   return "hdfc"
        case "sbi bank":    return "sbi"
        case "kotak bank":  return "kotak"
        default:            return ""
        }
    }

    /// Returns the wallet code (`freecharge` / `jio_money` / `phonepe`) — but only
    /// when the parent payment mode is wallet. Mirrors Android `getWalletCode`.
    func getWalletCode() -> String? {
        guard getPaymentModeCode()?.lowercased() == "wallet" else { return nil }
        guard let name = selectedSubPaymentOption?.name.lowercased() else { return nil }
        switch name {
        case "all wallets": return ""
        case "freecharge":  return "freecharge"
        case "jio money":   return "jio_money"   // Android uses underscore
        case "phonepe":     return "phonepe"
        default:            return ""
        }
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
