/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

class ThankYouVC: UIViewController {
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let statusIconView = UIImageView()
    private let statusTitleLabel = UILabel()
    private let statusMessageLabel = UILabel()
    private let orderDetailsCard = UIView()
    private let additionalDetailsCard = UIView()
    
    // Order Details Labels
    private let orderIdLabel = UILabel()
    private let transactionIdLabel = UILabel()
    private let statusLabel = UILabel()
    private let amountLabel = UILabel()
    private let invoiceIdLabel = UILabel()
    private let orderDateLabel = UILabel()
    private let detailedStatusLabel = UILabel()
    
    // Action Buttons
    private let primaryActionButton = UIButton(type: .system)
    private let secondaryActionButton = UIButton(type: .system)
    
    // Data Properties
    var paymentData: [AnyHashable: Any] = [:]
    private var parsedPaymentData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        parseAndDisplayPaymentData()
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        self.title = "Payment Status"
        if let navBar = self.navigationController?.navigationBar {
            navBar.barTintColor = .black
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            navBar.tintColor = .white
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup status section
        setupStatusSection()
        
        // Setup order details card
        setupOrderDetailsCard()
        
        // Setup additional details card
        setupAdditionalDetailsCard()
        
        // Setup action buttons
        setupActionButtons()
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupStatusSection() {
        // Status icon
        statusIconView.contentMode = .scaleAspectFit
        statusIconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusIconView)
        
        // Status title
        statusTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        statusTitleLabel.textAlignment = .center
        statusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusTitleLabel)
        
        // Status message
        statusMessageLabel.font = UIFont.systemFont(ofSize: 16)
        statusMessageLabel.textAlignment = .center
        statusMessageLabel.numberOfLines = 0
        statusMessageLabel.textColor = .secondaryLabel
        statusMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusMessageLabel)
    }
    
    private func setupOrderDetailsCard() {
        orderDetailsCard.backgroundColor = .secondarySystemBackground
        orderDetailsCard.layer.cornerRadius = 12
        orderDetailsCard.layer.shadowColor = UIColor.black.cgColor
        orderDetailsCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        orderDetailsCard.layer.shadowRadius = 4
        orderDetailsCard.layer.shadowOpacity = 0.1
        orderDetailsCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orderDetailsCard)
        
        // Order details labels
        let labels = [orderIdLabel, transactionIdLabel, statusLabel, amountLabel, invoiceIdLabel, orderDateLabel]
        for label in labels {
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            orderDetailsCard.addSubview(label)
        }
    }
    
    private func setupAdditionalDetailsCard() {
        additionalDetailsCard.backgroundColor = .secondarySystemBackground
        additionalDetailsCard.layer.cornerRadius = 12
        additionalDetailsCard.layer.shadowColor = UIColor.black.cgColor
        additionalDetailsCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        additionalDetailsCard.layer.shadowRadius = 4
        additionalDetailsCard.layer.shadowOpacity = 0.1
        additionalDetailsCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(additionalDetailsCard)
        
        // Detailed status label
        detailedStatusLabel.font = UIFont.systemFont(ofSize: 14)
        detailedStatusLabel.textColor = .secondaryLabel
        detailedStatusLabel.numberOfLines = 0
        detailedStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalDetailsCard.addSubview(detailedStatusLabel)
    }
    
    private func setupActionButtons() {
        // Primary action button
        primaryActionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        primaryActionButton.layer.cornerRadius = 8
        primaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        primaryActionButton.addTarget(self, action: #selector(handlePrimaryAction), for: .touchUpInside)
        contentView.addSubview(primaryActionButton)
        
        // Secondary action button
        secondaryActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        secondaryActionButton.layer.cornerRadius = 8
        secondaryActionButton.layer.borderWidth = 1
        secondaryActionButton.layer.borderColor = UIColor.systemBlue.cgColor
        secondaryActionButton.setTitleColor(.systemBlue, for: .normal)
        secondaryActionButton.backgroundColor = .clear
        secondaryActionButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryActionButton.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
        contentView.addSubview(secondaryActionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Status icon constraints
            statusIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statusIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            statusIconView.widthAnchor.constraint(equalToConstant: 80),
            statusIconView.heightAnchor.constraint(equalToConstant: 80),
            
            // Status title constraints
            statusTitleLabel.topAnchor.constraint(equalTo: statusIconView.bottomAnchor, constant: 16),
            statusTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status message constraints
            statusMessageLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 8),
            statusMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Order details card constraints
            orderDetailsCard.topAnchor.constraint(equalTo: statusMessageLabel.bottomAnchor, constant: 24),
            orderDetailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            orderDetailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            orderDetailsCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            // Order details labels constraints
            orderIdLabel.topAnchor.constraint(equalTo: orderDetailsCard.topAnchor, constant: 16),
            orderIdLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            orderIdLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            
            transactionIdLabel.topAnchor.constraint(equalTo: orderIdLabel.bottomAnchor, constant: 12),
            transactionIdLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            transactionIdLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: transactionIdLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            
            amountLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            amountLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            
            invoiceIdLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 12),
            invoiceIdLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            invoiceIdLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            
            orderDateLabel.topAnchor.constraint(equalTo: invoiceIdLabel.bottomAnchor, constant: 12),
            orderDateLabel.leadingAnchor.constraint(equalTo: orderDetailsCard.leadingAnchor, constant: 16),
            orderDateLabel.trailingAnchor.constraint(equalTo: orderDetailsCard.trailingAnchor, constant: -16),
            orderDateLabel.bottomAnchor.constraint(equalTo: orderDetailsCard.bottomAnchor, constant: -16),
            
            // Additional details card constraints
            additionalDetailsCard.topAnchor.constraint(equalTo: orderDetailsCard.bottomAnchor, constant: 16),
            additionalDetailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            additionalDetailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Detailed status label constraints
            detailedStatusLabel.topAnchor.constraint(equalTo: additionalDetailsCard.topAnchor, constant: 16),
            detailedStatusLabel.leadingAnchor.constraint(equalTo: additionalDetailsCard.leadingAnchor, constant: 16),
            detailedStatusLabel.trailingAnchor.constraint(equalTo: additionalDetailsCard.trailingAnchor, constant: -16),
            detailedStatusLabel.bottomAnchor.constraint(equalTo: additionalDetailsCard.bottomAnchor, constant: -16),
            
            // Action buttons constraints
            primaryActionButton.topAnchor.constraint(equalTo: additionalDetailsCard.bottomAnchor, constant: 24),
            primaryActionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            primaryActionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            primaryActionButton.heightAnchor.constraint(equalToConstant: 50),
            
            secondaryActionButton.topAnchor.constraint(equalTo: primaryActionButton.bottomAnchor, constant: 12),
            secondaryActionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondaryActionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            secondaryActionButton.heightAnchor.constraint(equalToConstant: 50),
            secondaryActionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Data Parsing and Display
    
    private func parseAndDisplayPaymentData() {
        print("ThankYouVC: parseAndDisplayPaymentData called")
        print("ThankYouVC: paymentData = \(paymentData)")
        
        // Convert [AnyHashable: Any] to [String: Any] for consistency
        parsedPaymentData = convertAnyHashableToDictionary(paymentData)
        
        print("ThankYouVC: Final parsedPaymentData = \(parsedPaymentData)")
        
        // Display order information
        displayOrderInformation()
    }
    
    private func convertAnyHashableToDictionary(_ data: [AnyHashable: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, value) in data {
            let stringKey = String(describing: key)
            
            if let dictValue = value as? [AnyHashable: Any] {
                result[stringKey] = convertAnyHashableToDictionary(dictValue)
            } else if let arrayValue = value as? [Any] {
                result[stringKey] = arrayValue
            } else {
                result[stringKey] = value
            }
        }
        
        // Check for encrypted response
        if let encryptedResponse = result["encrypted_response"] as? String {
            result["is_encrypted"] = true
            result["status"] = "encrypted"
            result["message"] = "Encrypted response received. Please handle decryption on your server."
        }
        
        return result
    }
    
    
    private func displayOrderInformation() {
        print("ThankYouVC: displayOrderInformation called")
        print("ThankYouVC: parsedPaymentData = \(parsedPaymentData)")
        
        // Check if this is an encrypted response
        let isEncrypted = parsedPaymentData["is_encrypted"] as? Bool ?? false
        if isEncrypted {
            print("ThankYouVC: Encrypted response detected")
            displayEncryptedResponse()
            return
        }
        
        // Use parsed data if available, otherwise use defaults
        let displayOrderId = parsedPaymentData["order_id"] as? String ?? parsedPaymentData["nimbbl_order_id"] as? String ?? "N/A"
        let displayStatus = parsedPaymentData["status"] as? String ?? "unknown"
        let message = parsedPaymentData["message"] as? String ?? ""
        let reason = parsedPaymentData["reason"] as? String ?? ""
        
        // Extract transaction ID from multiple possible fields, handling "<null>" strings
        let rawTransactionId = parsedPaymentData["transaction_id"] as? String ?? 
                              parsedPaymentData["nimbbl_transaction_id"] as? String ?? 
                              parsedPaymentData["nimbblTransactionId"] as? String ?? 
                              parsedPaymentData["pspTransactionId"] as? String ?? 
                              parsedPaymentData["transactionId"] as? String ?? "N/A"
        
        // Handle "<null>" strings and empty values
        let transactionId = (rawTransactionId == "<null>" || rawTransactionId.isEmpty) ? "N/A" : rawTransactionId
        
        print("ThankYouVC: displayOrderId = \(displayOrderId)")
        print("ThankYouVC: displayStatus = \(displayStatus)")
        print("ThankYouVC: message = \(message)")
        print("ThankYouVC: reason = \(reason)")
        print("ThankYouVC: rawTransactionId = \(rawTransactionId)")
        print("ThankYouVC: transactionId = \(transactionId)")
        // Extract order details from nested "order" object
        let order = parsedPaymentData["order"] as? [String: Any] ?? [:]
        print("ThankYouVC: Extracted order object = \(order)")
        
        let totalAmount = order["total_amount"] as? Double ?? 0.0
        let currency = order["currency"] as? String ?? "INR"
        let invoiceId = order["invoice_id"] as? String ?? ""
        let orderDate = order["order_date"] as? String ?? ""
        let cancellationReason = order["cancellation_reason"] as? String ?? ""
        let attempts = order["attempts"] as? Int ?? 0
        let referrerPlatform = order["referrer_platform"] as? String ?? ""
        let referrerPlatformVersion = order["referrer_platform_version"] as? String ?? ""
        let deviceUserAgent = order["device_user_agent"] as? String ?? ""
        
        // Extract device info from nested "device" object
        let device = order["device"] as? [String: Any] ?? [:]
        print("ThankYouVC: Extracted device object = \(device)")
        
        let deviceIpAddress = device["ip_address"] as? String ?? ""
        let deviceName = device["device_name"] as? String ?? ""
        let deviceOsName = device["os_name"] as? String ?? ""
        
        // Extract shipping address from nested "shipping_address" object
        let shippingAddress = order["shipping_address"] as? [String: Any] ?? [:]
        print("ThankYouVC: Extracted shipping_address object = \(shippingAddress)")
        
        let shippingCity = shippingAddress["city"] as? String ?? ""
        let shippingState = shippingAddress["state"] as? String ?? ""
        let shippingCountry = shippingAddress["country"] as? String ?? ""
        let shippingPincode = shippingAddress["pincode"] as? String ?? ""
        
        print("ThankYouVC: Extracted values - totalAmount: \(totalAmount), currency: \(currency), invoiceId: \(invoiceId), orderDate: \(orderDate)")
        
        // Update status UI
        updateStatusUI(displayStatus)
        
        // Update status title and message
        updateStatusTitleAndMessage(displayStatus, message: message)
        
        // Update order details
        orderIdLabel.text = "Order ID: \(displayOrderId)"
        statusLabel.text = "Status: \(displayStatus.capitalized)"
        updateStatusTextColor(displayStatus)
        
        // Show/hide transaction ID field based on data availability
        if transactionId != "N/A" && !transactionId.isEmpty {
            transactionIdLabel.text = "Transaction ID: \(transactionId)"
            transactionIdLabel.isHidden = false
        } else {
            transactionIdLabel.isHidden = true
        }
        
        print("ThankYouVC: Updated orderIdLabel.text = \(orderIdLabel.text ?? "nil")")
        print("ThankYouVC: Updated statusLabel.text = \(statusLabel.text ?? "nil")")
        print("ThankYouVC: Updated transactionIdLabel.text = \(transactionIdLabel.text ?? "nil")")
        
        // Show/hide amount field based on data availability
        if totalAmount > 0 {
            amountLabel.text = "Amount: \(currency) \(String(format: "%.2f", totalAmount))"
            amountLabel.isHidden = false
        } else {
            amountLabel.isHidden = true
        }
        
        // Show/hide invoice ID field based on data availability
        if !invoiceId.isEmpty {
            invoiceIdLabel.text = "Invoice ID: \(invoiceId)"
            invoiceIdLabel.isHidden = false
        } else {
            invoiceIdLabel.isHidden = true
        }
        
        // Show/hide order date field based on data availability
        let formattedDate = formatOrderDate(orderDate)
        if formattedDate != "N/A" && !orderDate.isEmpty {
            orderDateLabel.text = "Order Date: \(formattedDate)"
            orderDateLabel.isHidden = false
        } else {
            orderDateLabel.isHidden = true
        }
        
        // Update detailed status information
        updateDetailedStatus(reason: reason, cancellationReason: cancellationReason, attempts: attempts,
                           referrerPlatform: referrerPlatform, referrerPlatformVersion: referrerPlatformVersion,
                           deviceName: deviceName, deviceOsName: deviceOsName, deviceIpAddress: deviceIpAddress,
                           shippingCity: shippingCity, shippingState: shippingState, shippingCountry: shippingCountry,
                           shippingPincode: shippingPincode)
        
        // Update action buttons based on status
        updateActionButtons(displayStatus)
        
        print("ThankYouVC: Displaying order info:")
        print("ThankYouVC:   Order ID: \(displayOrderId)")
        print("ThankYouVC:   Status: \(displayStatus)")
        print("ThankYouVC:   Message: \(message)")
        print("ThankYouVC:   Reason: \(reason)")
        print("ThankYouVC:   Amount: \(currency) \(totalAmount)")
    }
    
    private func updateStatusUI(_ status: String) {
        let statusLower = status.lowercased()
        switch statusLower {
        case "success", "completed":
            statusIconView.image = UIImage(systemName: "checkmark.circle.fill")
            statusIconView.tintColor = .systemGreen
        case "failed", "error", "cancelled":
            statusIconView.image = UIImage(systemName: "xmark.circle.fill")
            statusIconView.tintColor = .systemRed
        case "encrypted":
            statusIconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusIconView.tintColor = .systemOrange
        default:
            statusIconView.image = UIImage(systemName: "questionmark.circle.fill")
            statusIconView.tintColor = .systemGray
        }
    }
    
    private func updateStatusTitleAndMessage(_ status: String, message: String) {
        let statusLower = status.lowercased()
        switch statusLower {
        case "success", "completed":
            statusTitleLabel.text = "Payment Successful"
            statusTitleLabel.textColor = .systemGreen
            statusMessageLabel.text = message.isEmpty ? "Your payment has been processed successfully" : message
        case "failed", "error":
            statusTitleLabel.text = "Payment Failed"
            statusTitleLabel.textColor = .systemRed
            statusMessageLabel.text = message.isEmpty ? "Your payment could not be processed" : message
        case "cancelled":
            statusTitleLabel.text = "Payment Cancelled"
            statusTitleLabel.textColor = .systemGray
            statusMessageLabel.text = message.isEmpty ? "Payment was cancelled" : message
        case "encrypted":
            statusTitleLabel.text = "Encrypted Response"
            statusTitleLabel.textColor = .systemOrange
            statusMessageLabel.text = message.isEmpty ? "Encrypted response received. Please handle decryption on your server." : message
        default:
            statusTitleLabel.text = "Payment Status"
            statusTitleLabel.textColor = .label
            statusMessageLabel.text = message.isEmpty ? "Payment status: \(status)" : message
        }
    }
    
    private func updateStatusTextColor(_ status: String) {
        let statusLower = status.lowercased()
        switch statusLower {
        case "success", "completed":
            statusLabel.textColor = .systemGreen
        case "failed", "error":
            statusLabel.textColor = .systemRed
        case "cancelled":
            statusLabel.textColor = .systemGray
        case "encrypted":
            statusLabel.textColor = .systemOrange
        default:
            statusLabel.textColor = .label
        }
    }
    
    private func updateDetailedStatus(reason: String, cancellationReason: String, attempts: Int,
                                    referrerPlatform: String, referrerPlatformVersion: String,
                                    deviceName: String, deviceOsName: String, deviceIpAddress: String,
                                    shippingCity: String, shippingState: String, shippingCountry: String,
                                    shippingPincode: String) {
        var detailedInfo = ""
        
        if !reason.isEmpty {
            detailedInfo += "Reason: \(reason)\n\n"
        }
        if !cancellationReason.isEmpty {
            detailedInfo += "Cancellation Reason: \(cancellationReason)\n\n"
        }
        if attempts > 0 {
            detailedInfo += "Attempts: \(attempts)\n\n"
        }
        if !referrerPlatform.isEmpty {
            detailedInfo += "Platform: \(referrerPlatform) \(referrerPlatformVersion)\n\n"
        }
        if !deviceName.isEmpty {
            detailedInfo += "Device: \(deviceName) (\(deviceOsName))\n\n"
        }
        if !deviceIpAddress.isEmpty {
            detailedInfo += "IP Address: \(deviceIpAddress)\n\n"
        }
        if !shippingCity.isEmpty {
            detailedInfo += "Shipping Address: \(shippingCity), \(shippingState), \(shippingCountry) - \(shippingPincode)"
        }
        
        // Show/hide the additional details card based on content
        if !detailedInfo.isEmpty {
            detailedStatusLabel.text = detailedInfo
            additionalDetailsCard.isHidden = false
        } else {
            additionalDetailsCard.isHidden = true
        }
    }
    
    private func displayEncryptedResponse() {
        // Update status icon and colors for encrypted response
        updateStatusUI("encrypted")
        
        // Update status title and message
        updateStatusTitleAndMessage("encrypted", message: "Encrypted response received. Please handle decryption on your server.")
        
        // Hide order details since we can't parse them
        orderDetailsCard.isHidden = true
        
        // Hide additional details
        additionalDetailsCard.isHidden = true
        
        // Update action buttons for encrypted response
        updateActionButtons("encrypted")
        
        // Log the encrypted response for debugging
        let encryptedResponse = parsedPaymentData["encrypted_response"] as? String ?? ""
        print("ThankYouVC: Encrypted response received: \(String(encryptedResponse.prefix(100)))...")
    }
    
    private func updateActionButtons(_ status: String) {
        let statusLower = status.lowercased()
        
        switch statusLower {
        case "success", "completed":
            primaryActionButton.setTitle("Continue", for: .normal)
            primaryActionButton.backgroundColor = .systemGreen
            primaryActionButton.setTitleColor(.white, for: .normal)
        case "failed", "error":
            primaryActionButton.setTitle("Try Again", for: .normal)
            primaryActionButton.backgroundColor = .systemRed
            primaryActionButton.setTitleColor(.white, for: .normal)
        case "cancelled":
            primaryActionButton.setTitle("Retry Payment", for: .normal)
            primaryActionButton.backgroundColor = .systemGray
            primaryActionButton.setTitleColor(.white, for: .normal)
        case "encrypted":
            primaryActionButton.setTitle("Continue", for: .normal)
            primaryActionButton.backgroundColor = .systemOrange
            primaryActionButton.setTitleColor(.white, for: .normal)
        default:
            primaryActionButton.setTitle("Continue", for: .normal)
            primaryActionButton.backgroundColor = .systemBlue
            primaryActionButton.setTitleColor(.white, for: .normal)
        }
        
        secondaryActionButton.setTitle("Back to Home", for: .normal)
    }
    
    private func formatOrderDate(_ orderDate: String) -> String {
        guard !orderDate.isEmpty else { return "N/A" }
        
        // Simple date formatting - you can enhance this with proper date parsing
        if orderDate.count >= 19 {
            return String(orderDate.prefix(19)) // Show only date and time part
        }
        return orderDate
    }
    
    // MARK: - Action Handlers
    
    @objc private func handlePrimaryAction() {
        let status = parsedPaymentData["status"] as? String ?? "unknown"
        let statusLower = status.lowercased()
        
        switch statusLower {
        case "failed":
            // Go back to payment screen to try again
            dismiss(animated: true)
        case "success":
            // Continue or go back to home
            dismiss(animated: true)
        case "cancelled":
            // Retry payment
            dismiss(animated: true)
        default:
            // Default action
            dismiss(animated: true)
        }
    }
    
    @objc private func handleSecondaryAction() {
        // Go back to home/main screen
        dismiss(animated: true)
    }
}
