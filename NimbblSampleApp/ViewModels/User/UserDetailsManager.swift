/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

// MARK: - User Details Manager
class UserDetailsManager {
    static let shared = UserDetailsManager()
    
    // MARK: - User Details
    var isEnabled: Bool = false
    var name: String = ""
    var number: String = ""
    var email: String = ""
    
    // MARK: - Text Fields
    weak var nameTextField: UITextField?
    weak var numberTextField: UITextField?
    weak var emailTextField: UITextField?
    weak var stackView: UIStackView?
    weak var switchControl: UISwitch?
    
    private init() {}
    
    // MARK: - Setup
    func setupTextFields(name: UITextField, number: UITextField, email: UITextField, stack: UIStackView, switchControl: UISwitch) {
        self.nameTextField = name
        self.numberTextField = number
        self.emailTextField = email
        self.stackView = stack
        self.switchControl = switchControl
        
        configureTextFields()
    }
    
    private func configureTextFields() {
        nameTextField?.configurePaymentTextField()
        nameTextField?.placeholder = "name"
        nameTextField?.keyboardType = .default
        nameTextField?.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        
        numberTextField?.configurePaymentTextField()
        numberTextField?.placeholder = "number"
        numberTextField?.keyboardType = .numberPad
        numberTextField?.addTarget(self, action: #selector(numberChanged), for: .editingChanged)
        
        emailTextField?.configurePaymentTextField()
        emailTextField?.placeholder = "email"
        emailTextField?.keyboardType = .emailAddress
        emailTextField?.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func nameChanged() {
        name = nameTextField?.text ?? ""
    }
    
    @objc private func numberChanged() {
        number = numberTextField?.text ?? ""
    }
    
    @objc private func emailChanged() {
        email = emailTextField?.text ?? ""
    }
    
    // MARK: - Toggle User Details
    func toggleUserDetails() {
        isEnabled = switchControl?.isOn ?? false
        updateUI()
    }
    
    private func updateUI() {
        stackView?.isHidden = !isEnabled
        stackView?.isUserInteractionEnabled = isEnabled
        stackView?.spacing = isEnabled ? UIConstants.spacing : 0
        
        // Hide text fields when stack view is hidden
        stackView?.arrangedSubviews.forEach { $0.isHidden = !isEnabled }
    }
    
    // MARK: - Validation
    func validateUserDetails() -> (isValid: Bool, errorMessage: String?) {
        guard isEnabled else { return (true, nil) }
        
        // Validate name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            return (false, "Name is required")
        }
        
        if trimmedName.count < 2 {
            return (false, "Name must be at least 2 characters")
        }
        
        // Validate number
        let trimmedNumber = number.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNumber.isEmpty {
            return (false, "Phone number is required")
        }
        
        if !isValidPhoneNumber(trimmedNumber) {
            return (false, "Please enter a valid phone number")
        }
        
        // Validate email
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            return (false, "Email is required")
        }
        
        if !isValidEmail(trimmedEmail) {
            return (false, "Please enter a valid email address")
        }
        
        return (true, nil)
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Basic phone number validation - can be enhanced based on requirements
        let phoneRegex = "^[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
} 
