/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

// MARK: - UI Component Extensions
extension UIButton {
    func configurePaymentButton() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.isUserInteractionEnabled = true
    }
    
    func configurePayNowButton() {
        self.setTitle(TextConstants.payNow, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.gorditaMedium(size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        self.backgroundColor = .black
        self.layer.cornerRadius = 12
        self.isUserInteractionEnabled = true
    }
}

extension UITextField {
    func configurePaymentTextField() {
        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.leftViewMode = .always
        self.isUserInteractionEnabled = true
    }
    
    func configureAmountTextField() {
        self.font = UIFont.preferredFont(forTextStyle: .title3)
        self.textColor = .black
        self.keyboardType = .decimalPad
        self.textAlignment = .center
        self.attributedPlaceholder = NSAttributedString(
            string: "4.0",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
}

extension UILabel {
    func configureTitleLabel() {
        self.font = UIFont.gorditaBold(size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        self.textColor = .black
    }
    
    func configureInfoLabel() {
        self.font = UIFont.gorditaItalic(size: 12) ?? UIFont.italicSystemFont(ofSize: 12)
    }
    
    func configureSectionLabel() {
        self.font = UIFont.gorditaMedium(size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        self.textColor = .black
    }
}

// MARK: - UI Constants
struct UIConstants {
    static let cornerRadius: CGFloat = 10
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1
    static let thickBorderWidth: CGFloat = 2
    static let spacing: CGFloat = 12
    static let smallSpacing: CGFloat = 4
    static let largeSpacing: CGFloat = 16
    static let buttonHeight: CGFloat = 44
    static let payButtonHeight: CGFloat = 48
    static let textFieldHeight: CGFloat = 44
    static let headerHeight: CGFloat = 48
    static let footerHeight: CGFloat = 24
    static let paperPlaneHeight: CGFloat = 160
    static let iconSize: CGFloat = 20
    static let smallIconSize: CGFloat = 16
    static let dropdownIconSize: CGFloat = 16
}

// MARK: - Color Extensions
extension UIColor {
    static let customGray = UIColor.gray.withAlphaComponent(0.3)
    static let customBlack = UIColor.black
    static let customWhite = UIColor.white
    static let customRed = UIColor(red: 0.984, green: 0.22, blue: 0.114, alpha: 1) // #FB381D
    static let customBlue1 = UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1) // #22274C
    static let customBlue2 = UIColor(red: 0.20, green: 0.23, blue: 0.44, alpha: 1) // #343B70
    static let customFooterGray = UIColor(hex: "#606060")
}

// MARK: - Font Extensions
extension UIFont {
    static func gorditaBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Gordita-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func gorditaMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Gordita-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func gorditaItalic(size: CGFloat) -> UIFont {
        return UIFont(name: "Gordita-Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
}

// MARK: - Attributed String Extensions
extension NSMutableAttributedString {
    func addKerning(_ value: CGFloat) {
        self.addAttribute(.kern, value: value, range: NSRange(location: 0, length: self.length))
    }
    
    func setColor(_ color: UIColor) {
        self.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: self.length))
    }
} 
