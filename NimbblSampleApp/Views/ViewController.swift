/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit
import nimbbl_mobile_kit_ios_webview_sdk

class ViewController: UIViewController, NimbblCheckoutSDKDelegate {
     let paymentManager = PaymentManager.shared
    // MARK: - UI Elements
    let headerCustomisationButton = UIButton(type: .system)
    let paymentCustomisationButton = UIButton(type: .system)
    let subPaymentButton = UIButton(type: .system)
    let userDetailsStackView = UIStackView()
    let userDetailsView = UIView()
    let payNowButton = UIButton(type: .system)
    let nameTextField = UITextField()
    let numberTextField = UITextField()
    let emailTextField = UITextField()
    // MARK: - State
    // Remove local state variables and use paymentManager properties directly
    var userDetailsLabel = UILabel()
    var userDetailsSwitch = UISwitch()
    var infoImageView = UIImageView()
    var infoLabel = UILabel()
    var personalisedOptionsLabel = UILabel()
    var personalisedOptionsSwitch = UISwitch()
    var titleLabel = UILabel()
    var currencyAmountView = UIView()
    var currencyButton = UIButton()
    var amountTextField = UITextField()
    var infoView = UIView()
    var personalisedOptionsView = UIView()
    var headerCustomisationView = UIView()
    var headerCustomisationLabel = UILabel()
    var paymentCustomisationView = UIView()
    var paymentCustomisationLabel = UILabel()
    var subPaymentLabel = UILabel()
    var footerView = UIView()
    var footerLogoImageView = UIImageView()
    var footerLabel = UILabel()
    var scrollView = UIScrollView()
    var contentView = UIView()
    var headerView = UIView()
    var sonicLogoImageView = UIImageView()
    var byNimbblLabel = UILabel()
    var settingsButton = UIButton()
    var paperPlaneImageView = UIImageView()
    let headerButtonContentView = UIView()
    let headerIndicatorView = UIView()
    let headerButtonLabel = UILabel()
    var paymentOptionsWithIcons: [IconWithName] = []
    var selectedPaymentOption: IconWithName?
    var subPaymentOptionsWithIcons: [ImageWithName] = []
    var selectedSubPaymentOption: ImageWithName?
    var paymentCustomisationBottomConstraint: NSLayoutConstraint?
    var subPaymentLabelHeightConstraint: NSLayoutConstraint?
    var subPaymentButtonHeightConstraint: NSLayoutConstraint?
    // UPI app dropdown — third row, shown only when Payment=UPI + Sub=Intent.
    var upiAppLabel = UILabel()
    let upiAppButton = UIButton(type: .system)
    var upiAppLabelHeightConstraint: NSLayoutConstraint?
    var upiAppButtonHeightConstraint: NSLayoutConstraint?
    // Removed: var contentViewMinHeightConstraint: NSLayoutConstraint?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Add tap gesture to dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Set isPersonalisedOptionsOn and switch state from PaymentManager
        personalisedOptionsSwitch.isOn = paymentManager.orderLineItemsEnabled
        
        // Set selectedHeader to match the initial state
        if paymentManager.orderLineItemsEnabled {
            paymentManager.selectedHeader = HeaderOption.brandNameAndLogo
        } else {
            paymentManager.selectedHeader = HeaderOption.brandName
        }
        // Set isPersonalisedOptionsEnabled to match orderLineItemsEnabled on first launch
        paymentManager.isPersonalisedOptionsEnabled = paymentManager.orderLineItemsEnabled
        setupUI()
        setupConstraints()
        updateHeaderOptionsUI()
        updatePaymentOptionsUI()
        updateSubPaymentUI()
        updateUserDetailsUI()
        // Ensure header customisation button label is correct after switch state
        updateHeaderOptionsUI()
        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Track active text field
        [nameTextField, numberTextField, emailTextField, amountTextField].forEach { $0.delegate = self }
        
        NimbblCheckoutSDK.shared.delegate = self

        
                // Fix button z-order and remove unwanted UITableViews
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Remove any unwanted UITableViews
            for subview in self.view.subviews {
                if subview is UITableView && subview != self.scrollView {
                    subview.removeFromSuperview()
                }
            }
            

            
            // Bring all interactive elements to front
            self.view.bringSubviewToFront(self.settingsButton)
            self.view.bringSubviewToFront(self.currencyButton)
            self.view.bringSubviewToFront(self.headerCustomisationButton)
            self.view.bringSubviewToFront(self.paymentCustomisationButton)
            self.view.bringSubviewToFront(self.subPaymentButton)
            self.view.bringSubviewToFront(self.payNowButton)
            self.view.bringSubviewToFront(self.personalisedOptionsSwitch)
            self.view.bringSubviewToFront(self.userDetailsSwitch)
            self.view.bringSubviewToFront(self.amountTextField)
            self.view.bringSubviewToFront(self.nameTextField)
            self.view.bringSubviewToFront(self.numberTextField)
            self.view.bringSubviewToFront(self.emailTextField)
            
            // Force layout update
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        contentView.backgroundColor = .systemBackground

        // Header (move out of contentView)
        view.addSubview(headerView)
        headerView.backgroundColor = .black
        sonicLogoImageView.image = UIImage(named: "SonicLogo")
        sonicLogoImageView.contentMode = .scaleAspectFit
        headerView.addSubview(sonicLogoImageView)
        byNimbblLabel.text = TextConstants.byNimbbl
        byNimbblLabel.textColor = .white
        byNimbblLabel.font = UIFont(name: "Gordita-Bold", size: 10) ?? UIFont.boldSystemFont(ofSize: 10)
        let attributedText = NSMutableAttributedString(string: "by nimbbl.")
        attributedText.addAttribute(.kern, value: -0.4, range: NSRange(location: 0, length: attributedText.length))
        byNimbblLabel.attributedText = attributedText
        headerView.addSubview(byNimbblLabel)
        
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsButton.isUserInteractionEnabled = true
        view.addSubview(settingsButton)
        view.bringSubviewToFront(settingsButton)
        
        // Paper plane
        contentView.addSubview(paperPlaneImageView)
        paperPlaneImageView.image = UIImage(named: "Paperplane")
        paperPlaneImageView.contentMode = .scaleAspectFill
        
        // Title, currency, amount
        contentView.addSubview(titleLabel)
        titleLabel.text = TextConstants.paperPlane
        titleLabel.font = UIFont(name: "Gordita-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        let titleAttributedText = NSMutableAttributedString(string: "paper plane.")
        titleAttributedText.addAttribute(.kern, value: -0.32, range: NSRange(location: 0, length: titleAttributedText.length))
        titleLabel.attributedText = titleAttributedText
        titleLabel.textColor = .label

        contentView.addSubview(currencyAmountView)
        currencyAmountView.backgroundColor = .secondarySystemBackground
        currencyAmountView.layer.cornerRadius = 10
        currencyAmountView.layer.borderWidth = 1
        currencyAmountView.layer.borderColor = UIColor.separator.cgColor

        currencyButton.setTitle(paymentManager.selectedCurrency, for: .normal)
        currencyButton.setTitleColor(.label, for: .normal)
        currencyButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        currencyButton.addTarget(self, action: #selector(currencyTapped), for: .touchUpInside)
        currencyButton.isUserInteractionEnabled = true
        view.addSubview(currencyButton)
        view.bringSubviewToFront(currencyButton)
        
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        currencyAmountView.addSubview(divider)
        
        amountTextField.placeholder = paymentManager.amountValue
        amountTextField.font = UIFont.preferredFont(forTextStyle: .title3)
        amountTextField.textColor = .label
        amountTextField.keyboardType = .decimalPad
        amountTextField.textAlignment = .center
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        // Set placeholder color (adapts to light/dark mode)
        amountTextField.attributedPlaceholder = NSAttributedString(
            string: paymentManager.amountValue,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
        view.addSubview(amountTextField)
        view.bringSubviewToFront(amountTextField)
        
        // Info
        contentView.addSubview(infoView)
        if let infoImage = UIImage(named: "infoIcon") {
            infoImageView.image = infoImage.withRenderingMode(.alwaysTemplate)
            infoImageView.tintColor = .systemBlue
        }
        infoImageView.layer.cornerRadius = 8 // since width/height = 16
        infoImageView.clipsToBounds = true
        infoView.addSubview(infoImageView)
        infoLabel.text = TextConstants.infoMessage
        infoLabel.font = UIFont(name: "Gordita-Italic", size: 12) ?? UIFont.italicSystemFont(ofSize: 12)
        let infoAttributedText = NSMutableAttributedString(string: TextConstants.infoMessage)
        infoAttributedText.addAttribute(.kern, value: -0.24, range: NSRange(location: 0, length: infoAttributedText.length))
        infoLabel.attributedText = infoAttributedText
        infoLabel.textColor = .secondaryLabel
        infoView.addSubview(infoLabel)

        // Personalised options
        contentView.addSubview(personalisedOptionsView)
        personalisedOptionsView.addSubview(personalisedOptionsLabel)
        personalisedOptionsView.addSubview(personalisedOptionsSwitch)
        personalisedOptionsLabel.text = TextConstants.orderLineItems
        personalisedOptionsLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        personalisedOptionsLabel.textColor = .label
        personalisedOptionsView.addSubview(personalisedOptionsSwitch)
        personalisedOptionsSwitch.onTintColor = .black
        personalisedOptionsSwitch.addTarget(self, action: #selector(personalisedOptionsChanged), for: .valueChanged)
        view.addSubview(personalisedOptionsSwitch)
        view.bringSubviewToFront(personalisedOptionsSwitch)
        
        // Header customisation
        contentView.addSubview(headerCustomisationView)
        headerCustomisationLabel.text = TextConstants.headerCustomisation
        headerCustomisationLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        headerCustomisationLabel.textColor = .label
        headerCustomisationLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCustomisationView.addSubview(headerCustomisationLabel)
        headerCustomisationView.addSubview(headerCustomisationButton)

        NSLayoutConstraint.activate([
            headerCustomisationLabel.topAnchor.constraint(equalTo: headerCustomisationView.topAnchor),
            headerCustomisationLabel.leadingAnchor.constraint(equalTo: headerCustomisationView.leadingAnchor),
            headerCustomisationButton.topAnchor.constraint(equalTo: headerCustomisationLabel.bottomAnchor, constant: 4),
            headerCustomisationButton.leadingAnchor.constraint(equalTo: headerCustomisationView.leadingAnchor),
            headerCustomisationButton.trailingAnchor.constraint(equalTo: headerCustomisationView.trailingAnchor),
            headerCustomisationButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        // Add left inset to button title
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "" // No text
            config.baseBackgroundColor = .secondarySystemBackground
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 0)
            headerCustomisationButton.configuration = config
        } else {
            headerCustomisationButton.setTitle("", for: .normal)
        headerCustomisationButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
            headerCustomisationButton.backgroundColor = .secondarySystemBackground
        }
        // Always ensure no text
        headerCustomisationButton.setTitle("", for: .normal)
        
        // Payment customisation
        contentView.addSubview(paymentCustomisationView)
        paymentCustomisationLabel.text = TextConstants.paymentCustomisation
        paymentCustomisationLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        paymentCustomisationLabel.textColor = .label
        paymentCustomisationView.addSubview(paymentCustomisationLabel)

        // Remove label text from paymentCustomisationButton and subPaymentButton immediately after creation
        paymentCustomisationButton.setTitle("", for: .normal)
        subPaymentButton.setTitle("", for: .normal)
        paymentCustomisationButton.setTitleColor(.label, for: .normal)
        paymentCustomisationButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        paymentCustomisationButton.backgroundColor = .secondarySystemBackground
        paymentCustomisationButton.layer.cornerRadius = 10
        paymentCustomisationButton.layer.borderWidth = 1
        paymentCustomisationButton.layer.borderColor = UIColor.separator.cgColor
        paymentCustomisationButton.addTarget(self, action: #selector(paymentCustomisationTapped), for: .touchUpInside)
        paymentCustomisationButton.isUserInteractionEnabled = true
        view.addSubview(paymentCustomisationButton)
        view.bringSubviewToFront(paymentCustomisationButton)
        
        // Sub payment label
        subPaymentLabel.text = TextConstants.subPaymentMode
        subPaymentLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        subPaymentLabel.textColor = .label
        subPaymentLabel.translatesAutoresizingMaskIntoConstraints = false
        paymentCustomisationView.addSubview(subPaymentLabel)

        subPaymentButton.setTitle("", for: .normal)
        subPaymentButton.setTitleColor(.label, for: .normal)
        subPaymentButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        subPaymentButton.backgroundColor = .secondarySystemBackground
        subPaymentButton.layer.cornerRadius = 10
        subPaymentButton.layer.borderWidth = 1
        subPaymentButton.layer.borderColor = UIColor.separator.cgColor
        subPaymentButton.addTarget(self, action: #selector(subPaymentTapped), for: .touchUpInside)
        subPaymentButton.isUserInteractionEnabled = true
        subPaymentButton.isHidden = true
        view.addSubview(subPaymentButton)
        view.bringSubviewToFront(subPaymentButton)

        // UPI app dropdown — shown only when Payment=UPI + Sub=Intent.
        upiAppLabel.text = TextConstants.upiAppTitle
        upiAppLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        upiAppLabel.textColor = .label
        upiAppLabel.translatesAutoresizingMaskIntoConstraints = false
        upiAppLabel.isHidden = true
        paymentCustomisationView.addSubview(upiAppLabel)

        upiAppButton.setTitle("", for: .normal)
        upiAppButton.setTitleColor(.label, for: .normal)
        upiAppButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        upiAppButton.backgroundColor = .secondarySystemBackground
        upiAppButton.layer.cornerRadius = 10
        upiAppButton.layer.borderWidth = 1
        upiAppButton.layer.borderColor = UIColor.separator.cgColor
        upiAppButton.contentHorizontalAlignment = .left
        upiAppButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        upiAppButton.addTarget(self, action: #selector(upiAppTapped), for: .touchUpInside)
        upiAppButton.isUserInteractionEnabled = true
        upiAppButton.isHidden = true
        upiAppButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upiAppButton)
        view.bringSubviewToFront(upiAppButton)
        
        // User details
        contentView.addSubview(userDetailsView)
        userDetailsLabel.text = TextConstants.userDetails
        userDetailsLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        userDetailsLabel.textColor = .label
        userDetailsView.addSubview(userDetailsLabel)
        userDetailsSwitch.onTintColor = .black
        userDetailsSwitch.addTarget(self, action: #selector(userDetailsSwitchChanged), for: .valueChanged)
        view.addSubview(userDetailsSwitch)
        view.bringSubviewToFront(userDetailsSwitch)
        
        // Add text fields to stack view
        userDetailsStackView.addArrangedSubview(nameTextField)
        userDetailsStackView.addArrangedSubview(numberTextField)
        userDetailsStackView.addArrangedSubview(emailTextField)
        contentView.addSubview(userDetailsStackView)
        userDetailsStackView.axis = .vertical
        userDetailsStackView.spacing = 12
        userDetailsStackView.isHidden = true
        
        // Configure text fields
        nameTextField.placeholder = TextConstants.name
        nameTextField.font = UIFont.preferredFont(forTextStyle: .body)
        nameTextField.textColor = .label
        nameTextField.backgroundColor = .secondarySystemBackground
        nameTextField.layer.cornerRadius = 8
        nameTextField.layer.borderWidth = 2
        nameTextField.layer.borderColor = UIColor.separator.cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        nameTextField.isUserInteractionEnabled = true
        
        numberTextField.placeholder = TextConstants.number
        numberTextField.font = UIFont.preferredFont(forTextStyle: .body)
        numberTextField.textColor = .label
        numberTextField.backgroundColor = .secondarySystemBackground
        numberTextField.layer.cornerRadius = 8
        numberTextField.layer.borderWidth = 2
        numberTextField.layer.borderColor = UIColor.separator.cgColor
        numberTextField.keyboardType = .numberPad
        numberTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        numberTextField.leftViewMode = .always
        numberTextField.addTarget(self, action: #selector(numberChanged), for: .editingChanged)
        numberTextField.isUserInteractionEnabled = true
        
        emailTextField.placeholder = TextConstants.email
        emailTextField.font = UIFont.preferredFont(forTextStyle: .body)
        emailTextField.textColor = .label
        emailTextField.backgroundColor = .secondarySystemBackground
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.borderColor = UIColor.separator.cgColor
        emailTextField.keyboardType = .emailAddress
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        emailTextField.leftViewMode = .always
        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        emailTextField.isUserInteractionEnabled = true
        
        // Pay button (adaptive: dark bg + light text in light mode, light bg + dark text in dark mode)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = TextConstants.payNow
            config.baseBackgroundColor = .label
            config.baseForegroundColor = .systemBackground
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 0)
            payNowButton.configuration = config
        } else {
            payNowButton.setTitle(TextConstants.payNow, for: .normal)
            payNowButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
            payNowButton.backgroundColor = .label
        }
        payNowButton.setTitleColor(.systemBackground, for: .normal)
        payNowButton.titleLabel?.font = UIFont(name: "Gordita-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        payNowButton.layer.cornerRadius = 12
        if let imageView = payNowButton.imageView {
            imageView.tintColor = .systemBackground
        }
        payNowButton.addTarget(self, action: #selector(payNowTapped), for: .touchUpInside)
        payNowButton.isUserInteractionEnabled = true
        view.addSubview(payNowButton)
        view.bringSubviewToFront(payNowButton)
        
        // Footer
        view.addSubview(footerView)
        footerView.backgroundColor = .black
        footerLogoImageView.image = UIImage(named: "footerlogo")
        footerLogoImageView.contentMode = .scaleAspectFit
        footerView.addSubview(footerLogoImageView)
        footerLabel.text = TextConstants.footerText
        footerLabel.font = UIFont(name: "Gordita-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
        let footerAttributedText = NSMutableAttributedString(string: TextConstants.footerText)
        footerAttributedText.addAttribute(.kern, value: -0.48, range: NSRange(location: 0, length: footerAttributedText.length))
        footerAttributedText.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: footerAttributedText.length))
        footerLabel.attributedText = footerAttributedText
        footerView.addSubview(footerLabel)

        headerCustomisationButton.backgroundColor = .secondarySystemBackground
        headerCustomisationButton.layer.cornerRadius = 10
        headerCustomisationButton.layer.borderWidth = 1
        headerCustomisationButton.layer.borderColor = UIColor.separator.cgColor

        headerButtonContentView.translatesAutoresizingMaskIntoConstraints = false
        headerIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        headerButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        headerButtonLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        headerButtonLabel.textColor = .label
        headerButtonLabel.text = paymentManager.selectedHeader.displayName
        headerIndicatorView.backgroundColor = paymentManager.orderLineItemsEnabled ? UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1) : UIColor(red: 0.984, green: 0.22, blue: 0.114, alpha: 1)
        headerIndicatorView.layer.cornerRadius = 8
        headerButtonContentView.addSubview(headerIndicatorView)
        headerButtonContentView.addSubview(headerButtonLabel)
        headerCustomisationButton.addSubview(headerButtonContentView)
        NSLayoutConstraint.activate([
            headerButtonContentView.leadingAnchor.constraint(equalTo: headerCustomisationButton.leadingAnchor, constant: 8),
            headerButtonContentView.centerYAnchor.constraint(equalTo: headerCustomisationButton.centerYAnchor),
            headerIndicatorView.leadingAnchor.constraint(equalTo: headerButtonContentView.leadingAnchor),
            headerIndicatorView.centerYAnchor.constraint(equalTo: headerButtonContentView.centerYAnchor),
            headerIndicatorView.widthAnchor.constraint(equalToConstant: 16),
            headerIndicatorView.heightAnchor.constraint(equalToConstant: 16),
            headerButtonLabel.leadingAnchor.constraint(equalTo: headerIndicatorView.trailingAnchor, constant: 8),
            headerButtonLabel.trailingAnchor.constraint(equalTo: headerButtonContentView.trailingAnchor),
            headerButtonLabel.centerYAnchor.constraint(equalTo: headerButtonContentView.centerYAnchor)
        ])
        headerButtonContentView.isUserInteractionEnabled = false
        headerIndicatorView.isUserInteractionEnabled = false
        headerButtonLabel.isUserInteractionEnabled = false
        headerCustomisationButton.addTarget(self, action: #selector(headerCustomisationTapped), for: .touchUpInside)
        headerCustomisationButton.isUserInteractionEnabled = true
        view.addSubview(headerCustomisationButton)
        view.bringSubviewToFront(headerCustomisationButton)

        paymentOptionsWithIcons = paymentManager.paymentOptions.map {
            IconWithName(icon: $0.icon, name: $0.name)
        }
        selectedPaymentOption = paymentOptionsWithIcons.first
        // Remove label text from paymentCustomisationButton and subPaymentButton
        paymentCustomisationButton.setTitle("", for: .normal)
        subPaymentButton.setTitle("", for: .normal)
        updatePaymentCustomisationButtonUI()
    }
    func setupConstraints() {
        // Set translatesAutoresizingMaskIntoConstraints = false for all views
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        sonicLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        byNimbblLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        paperPlaneImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyAmountView.translatesAutoresizingMaskIntoConstraints = false
        currencyButton.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoImageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        personalisedOptionsView.translatesAutoresizingMaskIntoConstraints = false
        personalisedOptionsLabel.translatesAutoresizingMaskIntoConstraints = false
        personalisedOptionsSwitch.translatesAutoresizingMaskIntoConstraints = false
        headerCustomisationView.translatesAutoresizingMaskIntoConstraints = false
        headerCustomisationButton.translatesAutoresizingMaskIntoConstraints = false
        paymentCustomisationView.translatesAutoresizingMaskIntoConstraints = false
        paymentCustomisationLabel.translatesAutoresizingMaskIntoConstraints = false
        paymentCustomisationButton.translatesAutoresizingMaskIntoConstraints = false
        subPaymentLabel.translatesAutoresizingMaskIntoConstraints = false
        subPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        userDetailsView.translatesAutoresizingMaskIntoConstraints = false
        userDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        userDetailsSwitch.translatesAutoresizingMaskIntoConstraints = false
        userDetailsStackView.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        payNowButton.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Header (fixed at top)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 48),
            sonicLogoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            sonicLogoImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            sonicLogoImageView.widthAnchor.constraint(equalToConstant: 66),
            sonicLogoImageView.heightAnchor.constraint(equalToConstant: 24),
            byNimbblLabel.leadingAnchor.constraint(equalTo: sonicLogoImageView.trailingAnchor, constant: 4),
            byNimbblLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            settingsButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 30),
            settingsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        // Footer (fixed at bottom)
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 24),
            footerLogoImageView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
            footerLogoImageView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            footerLogoImageView.widthAnchor.constraint(equalToConstant: 20),
            footerLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            footerLabel.leadingAnchor.constraint(equalTo: footerLogoImageView.trailingAnchor, constant: 8),
            footerLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        // ScrollView between header and footer
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        // Removed: contentViewMinHeightConstraint
        
        // Paper plane
        NSLayoutConstraint.activate([
            paperPlaneImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            paperPlaneImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            paperPlaneImageView.heightAnchor.constraint(equalToConstant: 160),
            paperPlaneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paperPlaneImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        paperPlaneImageView.layer.cornerRadius = 16
        paperPlaneImageView.clipsToBounds = true
        
        // Title and currency amount
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: currencyAmountView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            currencyAmountView.topAnchor.constraint(equalTo: paperPlaneImageView.bottomAnchor, constant: 12),
            currencyAmountView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            currencyAmountView.widthAnchor.constraint(equalToConstant: 150),
            currencyAmountView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Currency button and amount text field constraints
        let divider = currencyAmountView.subviews.first { $0.backgroundColor == .separator }
        
        NSLayoutConstraint.activate([
            currencyButton.leadingAnchor.constraint(equalTo: currencyAmountView.leadingAnchor, constant: 8),
            currencyButton.centerYAnchor.constraint(equalTo: currencyAmountView.centerYAnchor),
            currencyButton.widthAnchor.constraint(equalToConstant: 48),
            divider?.leadingAnchor.constraint(equalTo: currencyButton.trailingAnchor, constant: 8) ?? currencyButton.trailingAnchor.constraint(equalTo: currencyAmountView.trailingAnchor),
            divider?.centerYAnchor.constraint(equalTo: currencyAmountView.centerYAnchor) ?? currencyButton.centerYAnchor.constraint(equalTo: currencyAmountView.centerYAnchor),
            divider?.widthAnchor.constraint(equalToConstant: 1) ?? currencyButton.widthAnchor.constraint(equalToConstant: 1),
            divider?.heightAnchor.constraint(equalToConstant: 24) ?? currencyButton.heightAnchor.constraint(equalToConstant: 24),
            amountTextField.leadingAnchor.constraint(equalTo: divider?.trailingAnchor ?? currencyButton.trailingAnchor, constant: 8),
            amountTextField.centerYAnchor.constraint(equalTo: currencyAmountView.centerYAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: currencyAmountView.trailingAnchor, constant: -8),
            amountTextField.heightAnchor.constraint(equalToConstant: 44)
        ].compactMap { $0 })
        
        // Info section
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: currencyAmountView.bottomAnchor, constant: 12),
            infoView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            infoView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
            infoImageView.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),
            infoImageView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            infoImageView.widthAnchor.constraint(equalToConstant: 16),
            infoImageView.heightAnchor.constraint(equalToConstant: 16),
            infoLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 6),
            infoLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor)
        ])
        
        // Personalised options
        NSLayoutConstraint.activate([
            personalisedOptionsView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 12),
            personalisedOptionsView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            personalisedOptionsView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            personalisedOptionsView.heightAnchor.constraint(equalToConstant: 44),
            personalisedOptionsLabel.leadingAnchor.constraint(equalTo: personalisedOptionsView.leadingAnchor),
            personalisedOptionsLabel.centerYAnchor.constraint(equalTo: personalisedOptionsView.centerYAnchor),
            personalisedOptionsLabel.trailingAnchor.constraint(equalTo: personalisedOptionsSwitch.leadingAnchor, constant: -8),
            personalisedOptionsSwitch.trailingAnchor.constraint(equalTo: personalisedOptionsView.trailingAnchor),
            personalisedOptionsSwitch.centerYAnchor.constraint(equalTo: personalisedOptionsView.centerYAnchor)
        ])
        
        // Header customisation
        NSLayoutConstraint.activate([
            headerCustomisationView.topAnchor.constraint(equalTo: personalisedOptionsView.bottomAnchor, constant: 12),
            headerCustomisationView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            headerCustomisationView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            headerCustomisationView.heightAnchor.constraint(equalToConstant: 60),
            headerCustomisationLabel.topAnchor.constraint(equalTo: headerCustomisationView.topAnchor),
            headerCustomisationLabel.leadingAnchor.constraint(equalTo: headerCustomisationView.leadingAnchor),
            headerCustomisationButton.topAnchor.constraint(equalTo: headerCustomisationLabel.bottomAnchor, constant: 4),
            headerCustomisationButton.leadingAnchor.constraint(equalTo: headerCustomisationView.leadingAnchor),
            headerCustomisationButton.trailingAnchor.constraint(equalTo: headerCustomisationView.trailingAnchor),
            headerCustomisationButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        // Payment customisation
        // Remove fixed height, use single bottom constraint
        paymentCustomisationBottomConstraint = paymentCustomisationView.bottomAnchor.constraint(equalTo: upiAppButton.bottomAnchor)
        paymentCustomisationBottomConstraint?.priority = .required
        paymentCustomisationBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            paymentCustomisationView.topAnchor.constraint(equalTo: headerCustomisationView.bottomAnchor, constant: 12),
            paymentCustomisationView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            paymentCustomisationView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            paymentCustomisationLabel.topAnchor.constraint(equalTo: paymentCustomisationView.topAnchor),
            paymentCustomisationLabel.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            paymentCustomisationButton.topAnchor.constraint(equalTo: paymentCustomisationLabel.bottomAnchor, constant: 4),
            paymentCustomisationButton.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            paymentCustomisationButton.trailingAnchor.constraint(equalTo: paymentCustomisationView.trailingAnchor),
            paymentCustomisationButton.heightAnchor.constraint(equalToConstant: 44),
            subPaymentLabel.topAnchor.constraint(equalTo: paymentCustomisationButton.bottomAnchor, constant: 16),
            subPaymentLabel.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            subPaymentButton.topAnchor.constraint(equalTo: subPaymentLabel.bottomAnchor, constant: 4),
            subPaymentButton.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            subPaymentButton.trailingAnchor.constraint(equalTo: paymentCustomisationView.trailingAnchor),
            // UPI app dropdown — anchored below sub-payment button. Heights collapse to 0
            // when hidden (Payment != UPI or Sub != Intent).
            upiAppLabel.topAnchor.constraint(equalTo: subPaymentButton.bottomAnchor, constant: 16),
            upiAppLabel.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            upiAppLabel.trailingAnchor.constraint(equalTo: paymentCustomisationView.trailingAnchor),
            upiAppButton.topAnchor.constraint(equalTo: upiAppLabel.bottomAnchor, constant: 4),
            upiAppButton.leadingAnchor.constraint(equalTo: paymentCustomisationView.leadingAnchor),
            upiAppButton.trailingAnchor.constraint(equalTo: paymentCustomisationView.trailingAnchor)
        ])
        
        // Add and store height constraints for sub payment label and button
        subPaymentLabelHeightConstraint = subPaymentLabel.heightAnchor.constraint(equalToConstant: 20)
        subPaymentLabelHeightConstraint?.isActive = true
        subPaymentButtonHeightConstraint = subPaymentButton.heightAnchor.constraint(equalToConstant: 44)
        subPaymentButtonHeightConstraint?.isActive = true
        // UPI app dropdown heights — start at 0 (collapsed); expanded by updateUpiAppUI().
        upiAppLabelHeightConstraint = upiAppLabel.heightAnchor.constraint(equalToConstant: 0)
        upiAppLabelHeightConstraint?.isActive = true
        upiAppButtonHeightConstraint = upiAppButton.heightAnchor.constraint(equalToConstant: 0)
        upiAppButtonHeightConstraint?.isActive = true
        
        // User details
        NSLayoutConstraint.activate([
            userDetailsView.topAnchor.constraint(equalTo: paymentCustomisationView.bottomAnchor, constant: 12),
            userDetailsView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            userDetailsView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            userDetailsView.heightAnchor.constraint(equalToConstant: 44),
            userDetailsLabel.leadingAnchor.constraint(equalTo: userDetailsView.leadingAnchor),
            userDetailsLabel.centerYAnchor.constraint(equalTo: userDetailsView.centerYAnchor),
            userDetailsLabel.trailingAnchor.constraint(equalTo: userDetailsSwitch.leadingAnchor, constant: -8),
            userDetailsSwitch.trailingAnchor.constraint(equalTo: userDetailsView.trailingAnchor),
            userDetailsSwitch.centerYAnchor.constraint(equalTo: userDetailsView.centerYAnchor),
            // Stack view constraints
            userDetailsStackView.topAnchor.constraint(equalTo: userDetailsView.bottomAnchor, constant: 4),
            userDetailsStackView.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            userDetailsStackView.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            // Pay button constraints - position relative to stack view
            payNowButton.topAnchor.constraint(equalTo: userDetailsStackView.bottomAnchor, constant: 12),
            payNowButton.leadingAnchor.constraint(equalTo: paperPlaneImageView.leadingAnchor),
            payNowButton.trailingAnchor.constraint(equalTo: paperPlaneImageView.trailingAnchor),
            payNowButton.heightAnchor.constraint(equalToConstant: 48),
            payNowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Set text field heights
        nameTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        numberTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Footer
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 24),
            footerLogoImageView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
            footerLogoImageView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            footerLogoImageView.widthAnchor.constraint(equalToConstant: 20),
            footerLogoImageView.heightAnchor.constraint(equalToConstant: 20),
            footerLabel.leadingAnchor.constraint(equalTo: footerLogoImageView.trailingAnchor, constant: 8),
            footerLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
    }
    // MARK: - Actions
    @objc func settingsTapped() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("=== SETTINGS BUTTON TAPPED! ===")
        }
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .fullScreen // or .fullScreen if you prefer
        present(navController, animated: true)
    }
    @objc func currencyTapped() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("=== CURRENCY BUTTON TAPPED! ===")
        }
        let alert = UIAlertController(title: TextConstants.selectCurrency, message: nil, preferredStyle: .actionSheet)
        for currency in paymentManager.currencyOptions {
            alert.addAction(UIAlertAction(title: currency, style: .default) { _ in
                self.paymentManager.selectedCurrency = currency
                self.currencyButton.setTitle(currency, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: TextConstants.cancel, style: .cancel))
        present(alert, animated: true)
    }
    @objc func amountChanged() {
        paymentManager.amountValue = amountTextField.text ?? ""
    }
    @objc func personalisedOptionsChanged() {
        paymentManager.orderLineItemsEnabled = personalisedOptionsSwitch.isOn
        paymentManager.isPersonalisedOptionsEnabled = personalisedOptionsSwitch.isOn // Keep header options in sync
        if DebugConfig.debugPrintEnabled {
            DebugLog.log("[DEBUG] orderLineItemsEnabled set to \(personalisedOptionsSwitch.isOn)")
        }
        if paymentManager.orderLineItemsEnabled {
            paymentManager.selectedHeader = HeaderOption.brandNameAndLogo
        } else {
            paymentManager.selectedHeader = HeaderOption.brandName
        }
        updateHeaderOptionsUI()
    }
    @objc func headerCustomisationTapped() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("=== HEADER CUSTOMISATION BUTTON TAPPED! ===")
        }
        let colorIndicators: [UIColor] = [
            UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1), // #22274C
            UIColor(red: 0.20, green: 0.23, blue: 0.44, alpha: 1)  // #343B70
        ]
        let bottomSheet = HeaderOptionsBottomSheetViewController(
            options: paymentManager.headerOptions.map { $0.displayName },
            colorIndicators: colorIndicators,
            selectedOption: paymentManager.selectedHeader.displayName
        ) { [weak self] selected in
            if let newHeader = PaymentManager.shared.headerOptions.first(where: { $0.displayName == selected }) {
                self?.paymentManager.selectedHeader = newHeader
            }
            if DebugConfig.debugPrintEnabled {
                DebugLog.log("[DEBUG] Header option selected: \(selected)")
            }
            self?.updateHeaderOptionsUI()
        }
        present(bottomSheet, animated: true)
    }
    @objc func paymentCustomisationTapped() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("=== PAYMENT CUSTOMISATION BUTTON TAPPED! ===")
        }
        let bottomSheet = PaymentOptionsBottomSheetViewController(
            options: paymentOptionsWithIcons,
            selectedOption: selectedPaymentOption?.name
        ) { [weak self] selected in
            self?.selectedPaymentOption = selected
            self?.paymentManager.selectedPaymentOption = selected // Sync with PaymentManager
            self?.updatePaymentCustomisationButtonUI()
            // Update sub payment options based on selection
            if selected.name.lowercased() == "netbanking" {
                self?.subPaymentOptionsWithIcons = self?.paymentManager.netBankingSubPaymentTypeList.map { ImageWithName(imageName: $0.imageName, name: $0.name) } ?? []
                self?.selectedSubPaymentOption = self?.subPaymentOptionsWithIcons.first
                self?.paymentManager.selectedSubPaymentOption = self?.selectedSubPaymentOption // Sync
            } else if selected.name.lowercased() == "wallet" {
                self?.subPaymentOptionsWithIcons = self?.paymentManager.walletSubPaymentTypeList.map { ImageWithName(imageName: $0.imageName, name: $0.name) } ?? []
                self?.selectedSubPaymentOption = self?.subPaymentOptionsWithIcons.first
                self?.paymentManager.selectedSubPaymentOption = self?.selectedSubPaymentOption // Sync
            } else if selected.name.lowercased() == "upi" {
                self?.subPaymentOptionsWithIcons = self?.paymentManager.upiSubPaymentTypeList.map { ImageWithName(imageName: $0.imageName, name: $0.name) } ?? []
                self?.selectedSubPaymentOption = self?.subPaymentOptionsWithIcons.first
                self?.paymentManager.selectedSubPaymentOption = self?.selectedSubPaymentOption // Sync
            } else if selected.name.lowercased() == "emi" {
                self?.subPaymentOptionsWithIcons = self?.paymentManager.emiSubPaymentTypeList.map { ImageWithName(imageName: $0.imageName, name: $0.name) } ?? []
                self?.selectedSubPaymentOption = self?.subPaymentOptionsWithIcons.first
                self?.paymentManager.selectedSubPaymentOption = self?.selectedSubPaymentOption
                self?.paymentManager.selectedEmiOption = self?.paymentManager.emiSubPaymentTypeList.first
            } else {
                self?.subPaymentOptionsWithIcons = []
                self?.selectedSubPaymentOption = nil
                self?.paymentManager.selectedSubPaymentOption = nil // Sync
            }
            self?.updateSubPaymentUI()
            self?.updateSubPaymentButtonUI()
        }
        present(bottomSheet, animated: true)
    }
    @objc func subPaymentTapped() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("Sub payment button tapped")
        }
        guard !subPaymentOptionsWithIcons.isEmpty else { return }
        let bottomSheet = SubPaymentOptionsBottomSheetViewController(
            options: subPaymentOptionsWithIcons,
            selectedOption: selectedSubPaymentOption?.name
        ) { [weak self] selected in
            guard let self = self else { return }
            self.selectedSubPaymentOption = selected
            self.paymentManager.selectedSubPaymentOption = selected // Sync with PaymentManager
            if self.selectedPaymentOption?.name.lowercased() == "emi" {
                self.paymentManager.selectedEmiOption = self.paymentManager.emiSubPaymentTypeList.first {
                    $0.name == selected.name
                }
            }
            self.updateSubPaymentButtonUI()
            // Re-evaluate UPI app row visibility — shows the dropdown on the main screen
            // when Payment=UPI + Sub=Intent.
            self.updateUpiAppUI()
        }
        present(bottomSheet, animated: true)
    }
    @objc func userDetailsSwitchChanged() {
        paymentManager.userDetailsChecked = userDetailsSwitch.isOn
        updateUserDetailsUI()
    }
    @objc func nameChanged() {
        paymentManager.userName = nameTextField.text ?? ""
    }
    @objc func numberChanged() {
        paymentManager.userNumber = numberTextField.text ?? ""
    }
    @objc func emailChanged() {
        paymentManager.userEmail = emailTextField.text ?? ""
    }

    
    @objc func payNowTapped() {
        if DebugConfig.debugPrintEnabled {
            DebugLog.log("[DEBUG] payNowTapped called")
        }
        // Validate user input
        guard paymentManager.validateUserDetails(), paymentManager.validateAmount() else {
            if DebugConfig.debugPrintEnabled {
                DebugLog.log("[DEBUG] Validation failed")
            }
            showAlert(title: TextConstants.validationErrorTitle, message: TextConstants.validationErrorMessage)
            return
        }
        if DebugConfig.debugPrintEnabled {
            DebugLog.log("[DEBUG] Validation passed")
        }
        
        // Check app mode to determine which SDK to use
        let appMode = UserDefaults.standard.string(forKey: "SAMPLE_APP_MODE") ?? "Webview"
        
        if appMode == "Native" {
            // Native SDK flow - SDK not available
            showAlert(title: "Native SDK", message: "Native SDK is not available in this build")
        } else {
            // Use WebView SDK (existing flow)
            startWebViewPayment()
        }
    }
    
    private func startWebViewPayment() {
        payNowButton.isEnabled = false
        // 1. Resolve configured base URL from Settings — Prod / Pre-Prod / QA-edited.
        let env = UserDefaults.standard.selectedEnvironment
        var configuredBaseUrl: String? = nil
        if env == Environment.qa.rawValue {
            // Use the user-edited QA URL, falling back to qa3.
            configuredBaseUrl = UserDefaults.standard.qaEnvironmentUrl
            if configuredBaseUrl?.isEmpty != false { configuredBaseUrl = EnvironmentUrls.qa }
        } else {
            switch env {
            case Environment.prod.rawValue: configuredBaseUrl = EnvironmentUrls.prod
            case Environment.preProd.rawValue: configuredBaseUrl = EnvironmentUrls.preProd
            default: configuredBaseUrl = EnvironmentUrls.prod
            }
        }

        // 2. SDK env URL — keeps raw IP for WebView.
        let sdkEnvUrl = SampleShopAPIUtils.resolveSdkEnvironmentUrl(configuredBaseUrl: configuredBaseUrl)
        NimbblCheckoutSDK.shared.environmentUrl = sdkEnvUrl

        // 3. SDK debug-logging flag from Settings.
        NimbblCheckoutSDK.shared.setDebugLoggingEnabled(
            NSNumber(value: UserDefaults.standard.debugLogsEnabled)
        )

        // 4. Branch order creation: access-token path uses Core API v3 directly.
        let accessToken = UserDefaults.standard.accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !accessToken.isEmpty {
            createOrderViaV3(configuredBaseUrl: configuredBaseUrl ?? "", accessToken: accessToken)
            return
        }

        // 5. No access token → existing shop-proxy path.
        paymentManager.createOrder { [weak self] result in
            DispatchQueue.main.async {
                self?.payNowButton.isEnabled = true
            }
            switch result {
            case .success(let token):
                // Print all selected values for debug (like Flutter)
                if DebugConfig.debugPrintEnabled {
                    let selectedValues: [String: Any?] = [
                        "orderToken": token,
                        "amount": self?.paymentManager.amountValue,
                        "currency": self?.paymentManager.selectedCurrency,
                        "paymentModeCode": self?.paymentManager.getPaymentModeCode(),
                        "bankCode": self?.paymentManager.getSubPaymentModeCode(),
                        "walletCode": self?.paymentManager.getSubPaymentModeCode(),
                        "userName": self?.paymentManager.userName,
                        "userNumber": self?.paymentManager.userNumber,
                        "userEmail": self?.paymentManager.userEmail,
                        "header": self?.paymentManager.selectedHeader.displayName,
                        "subPayment": self?.paymentManager.selectedSubPaymentOption?.name,
                        "isPersonalisedOptionsOn": self?.paymentManager.orderLineItemsEnabled
                    ]
                    DebugLog.log("[DEBUG] Selected values for checkout: \(selectedValues)")
                }
                let paymentModeCode = self?.paymentManager.getPaymentModeCode()
                let paymentFlow: String? = (paymentModeCode == "UPI")
                    ? self?.paymentManager.getPaymentFlow(upiModeName: self?.paymentManager.selectedSubPaymentOption?.name ?? "")
                    : nil
                // UPI intent app code — only when payment=UPI + sub=intent.
                let upiAppCode = self?.paymentManager.selectedUpiApp?.code
                // EMI code — only when payment=EMI.
                let emiCode = self?.paymentManager.selectedEmiOption?.code
                let options = NimbblCheckoutOptions(
                    orderToken: token,
                    paymentModeCode: paymentModeCode,
                    // bankCode / walletCode are filtered per-payment-mode:
                    // - bankCode is non-nil only when payment=netbanking
                    // - walletCode is non-nil only when payment=wallet
                    // Otherwise nil, so the SDK URL builder won't append spurious params
                    // (this fixes the previous bug where EMI/UPI selections also injected
                    //  `&bank_code=` and `&wallet_code=` into the WebView URL).
                    bankCode: self?.paymentManager.getBankCode(),
                    walletCode: self?.paymentManager.getWalletCode(),
                    paymentFlow: paymentFlow,
                    upiAppCode: (upiAppCode?.isEmpty == false) ? upiAppCode : nil,
                    emiCode: (emiCode?.isEmpty == false) ? emiCode : nil
                )
                if DebugConfig.debugPrintEnabled {
                    DebugLog.log("[DEBUG] Checkout options: \(options)")
                    DebugLog.log("Selected header: \(self?.paymentManager.selectedHeader ?? .brandName), Product ID: \(self?.paymentManager.getProductIdForHeader() ?? "")")
                }
                
                // Use delegate-based checkout
                DispatchQueue.main.async {
                    NimbblCheckoutSDK.shared.checkout(from: self!, options: options)
                }
            case .failure(let error):
                if DebugConfig.debugPrintEnabled {
                    DebugLog.log("[DEBUG] Order creation failed: \(error.localizedDescription)")
                }
                
                // Extract API error message if available
                var errorMessage = error.localizedDescription
                let nsError = error as NSError
                if let apiError = nsError.userInfo["error"] as? [String: Any],
                   let errorDetails = apiError["error"] as? [String: Any],
                   let consumerMessage = errorDetails["nimbbl_consumer_message"] as? String {
                    errorMessage = consumerMessage
                }
                
                DispatchQueue.main.async {
                    self?.showAlert(title: TextConstants.orderErrorTitle, message: errorMessage)
                }
            }
        }
    }

    // MARK: - Core API v3 path
    /**
     * When the user has configured an access token in Settings, the sample app
     * calls Core API v3 `/api/v3/create-order` directly (Bearer-authenticated)
     * instead of the shop-proxy /create-shop endpoint.
     */
    private func createOrderViaV3(configuredBaseUrl: String, accessToken: String) {
        // The v3 endpoint must hit a public Nimbbl host even when WebView env is an IP.
        // `resolveShopBaseUrl` does the IP→qa3 fallback.
        let apiBaseUrl = SampleShopAPIUtils.resolveShopBaseUrl(configuredBaseUrl: configuredBaseUrl)

        // Pull the same inputs the shop-proxy path uses.
        let amountStr = (paymentManager.amountValue as NSString).floatValue
        let totalAmount = Int(amountStr)
        let firstName = paymentManager.userName
        let email = paymentManager.userEmail
        let mobile = paymentManager.userNumber
        let productId = paymentManager.getProductIdForHeader()
        let paymentMode = paymentManager.getPaymentModeCode() ?? ""
        let subPaymentMode = paymentManager.getSubPaymentModeCode()

        OrderV3Client.create(
            apiBaseUrl: apiBaseUrl,
            accessToken: accessToken,
            totalAmount: totalAmount,
            emailId: email,
            firstName: firstName,
            mobileNumber: mobile,
            productId: productId,
            paymentMode: paymentMode,
            subPaymentMode: subPaymentMode
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.payNowButton.isEnabled = true
            }
            switch result {
            case .success(let v3):
                let paymentModeCode = self?.paymentManager.getPaymentModeCode()
                let paymentFlow: String? = (paymentModeCode == "UPI")
                    ? self?.paymentManager.getPaymentFlow(upiModeName: self?.paymentManager.selectedSubPaymentOption?.name ?? "")
                    : nil
                // Derive UPI app code (Payment=UPI + Sub=Intent + picked app) and EMI code
                // (Payment=EMI + picked sub-option) via PaymentManager helpers.
                let upiAppCode = self?.paymentManager.getUpiAppCode()
                let emiCode = self?.paymentManager.getEMICode()
                let options = NimbblCheckoutOptions(
                    orderToken: v3.token,
                    paymentModeCode: paymentModeCode,
                    // bankCode / walletCode are filtered per-payment-mode:
                    // - bankCode is non-nil only when payment=netbanking
                    // - walletCode is non-nil only when payment=wallet
                    // Otherwise nil, so the SDK URL builder won't append spurious params
                    // (this fixes the previous bug where EMI/UPI selections also injected
                    //  `&bank_code=` and `&wallet_code=` into the WebView URL).
                    bankCode: self?.paymentManager.getBankCode(),
                    walletCode: self?.paymentManager.getWalletCode(),
                    paymentFlow: paymentFlow,
                    upiAppCode: (upiAppCode?.isEmpty == false) ? upiAppCode : nil,
                    emiCode: (emiCode?.isEmpty == false) ? emiCode : nil
                )
                if DebugConfig.debugPrintEnabled {
                    DebugLog.log("[DEBUG] v3 checkout options: \(options)")
                }
                DispatchQueue.main.async {
                    NimbblCheckoutSDK.shared.checkout(from: self!, options: options)
                }

            case .failure(let error):
                let message: String
                switch error {
                case .invalidURL(let url): message = "Invalid v3 URL: \(url)"
                case .http(let status, let body):
                    // Try to parse Nimbbl error envelope.
                    if let bodyStr = body,
                       let bodyData = bodyStr.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
                       let err = json["error"] as? [String: Any],
                       let consumer = err["nimbbl_consumer_message"] as? String {
                        message = consumer
                    } else {
                        message = "v3 create-order failed (HTTP \(status))"
                    }
                case .network(let e): message = "Network error: \(e.localizedDescription)"
                case .decoding(let s): message = s
                }
                DispatchQueue.main.async {
                    self?.showAlert(title: TextConstants.orderErrorTitle, message: message)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: TextConstants.ok, style: .default))
        present(alert, animated: true)
    }
    

    // MARK: - UI Updates
    func updateHeaderOptionsUI() {
        headerButtonLabel.text = paymentManager.selectedHeader.displayName
        // Update the indicator color based on the selected header and personalised state
        if paymentManager.orderLineItemsEnabled {
            if paymentManager.selectedHeader == .brandNameAndLogo {
                headerIndicatorView.backgroundColor = UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1) // #22274C
            } else if paymentManager.selectedHeader == .brandLogo {
                headerIndicatorView.backgroundColor = UIColor(red: 0.20, green: 0.23, blue: 0.44, alpha: 1) // #343B70
            }
        } else {
            headerIndicatorView.backgroundColor = UIColor(red: 0.984, green: 0.22, blue: 0.114, alpha: 1) // #FB381D
        }
        // Remove any previous chevron icon
        headerCustomisationButton.subviews.forEach {
            if let imageView = $0 as? UIImageView, imageView.image == UIImage(systemName: "chevron.down") {
                imageView.removeFromSuperview()
            }
        }
        // Add dropdown chevron icon only if not present
        if !headerCustomisationButton.subviews.contains(where: { ($0 as? UIImageView)?.image == UIImage(systemName: "chevron.down") }) {
            let dropdownIcon = UIImageView(image: UIImage(systemName: "chevron.down"))
            dropdownIcon.contentMode = .scaleAspectFit
            dropdownIcon.translatesAutoresizingMaskIntoConstraints = false
            dropdownIcon.tintColor = .label
            headerCustomisationButton.addSubview(dropdownIcon)
            NSLayoutConstraint.activate([
                dropdownIcon.trailingAnchor.constraint(equalTo: headerCustomisationButton.trailingAnchor, constant: -8),
                dropdownIcon.centerYAnchor.constraint(equalTo: headerCustomisationButton.centerYAnchor),
                dropdownIcon.widthAnchor.constraint(equalToConstant: 16),
                dropdownIcon.heightAnchor.constraint(equalToConstant: 16)
            ])
            dropdownIcon.isUserInteractionEnabled = false
        }
        headerCustomisationButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
    }
    func updatePaymentOptionsUI() {
        // Update the payment button title to reflect the selected payment method
        // Show/hide sub-payment options if needed
        updateSubPaymentUI()
    }
    func updateSubPaymentUI() {
        let shouldShow = ["netbanking", "upi", "wallet", "emi"].contains(selectedPaymentOption?.name.lowercased() ?? "")
        // Always keep height constraints active
        subPaymentLabelHeightConstraint?.isActive = true
        subPaymentButtonHeightConstraint?.isActive = true
        // Set isHidden and height together
        subPaymentLabel.isHidden = !shouldShow
        subPaymentButton.isHidden = !shouldShow
        subPaymentLabelHeightConstraint?.constant = shouldShow ? 20 : 0
        subPaymentButtonHeightConstraint?.constant = shouldShow ? 44 : 0
        if shouldShow {
            updateSubPaymentButtonUI()
        }
        // The UPI app row only shows when payment=UPI + sub=intent — re-evaluate now.
        updateUpiAppUI()
    }

    /// Show/hide the UPI app dropdown based on Payment=UPI + Sub=Intent.
    func updateUpiAppUI() {
        let paymentName = selectedPaymentOption?.name.lowercased() ?? ""
        let subName = selectedSubPaymentOption?.name.lowercased() ?? ""
        let shouldShow = (paymentName == "upi") && (subName == "intent")

        upiAppLabelHeightConstraint?.isActive = true
        upiAppButtonHeightConstraint?.isActive = true
        upiAppLabel.isHidden = !shouldShow
        upiAppButton.isHidden = !shouldShow
        upiAppLabelHeightConstraint?.constant = shouldShow ? 20 : 0
        upiAppButtonHeightConstraint?.constant = shouldShow ? 44 : 0

        if shouldShow {
            updateUpiAppButtonUI()
        }
        view.layoutIfNeeded()
    }

    /// Sync the UPI app button — builds a custom container with brand icon + label
    /// + dropdown chevron, mirroring the visual pattern used by
    /// `updateSubPaymentButtonUI()` and `updatePaymentCustomisationButtonUI()`.
    /// Font is **Gordita-Medium 14pt** to match the other dropdowns exactly.
    ///
    /// When nothing is selected yet, shows the generic `upiImg` placeholder so the
    /// button never appears empty.
    func updateUpiAppButtonUI() {
        let selected = paymentManager.selectedUpiApp
        let title = selected?.name ?? "Select UPI app"

        // Clear any previously-added subviews (matches the other update methods).
        upiAppButton.subviews.forEach {
            if $0 != upiAppButton.titleLabel {
                $0.removeFromSuperview()
            }
        }
        // Reset any image/insets from earlier implementations.
        upiAppButton.setTitle("", for: .normal)
        upiAppButton.setImage(nil, for: .normal)
        upiAppButton.imageEdgeInsets = .zero
        upiAppButton.titleEdgeInsets = .zero

        // Resolve which asset to display. Brand assets render in original colors
        // (NOT template) so brand logos keep their colors. Falls back to `upiImg`
        // when the brand asset isn't bundled (Google Pay / Paytm until you drop in PNGs).
        let assetCandidates: [String]
        if let assetName = selected?.imageName {
            assetCandidates = [assetName, "upiImg"]
        } else {
            assetCandidates = ["upiImg"]
        }
        let iconImage = assetCandidates
            .lazy
            .compactMap { UIImage(named: $0)?.withRenderingMode(.alwaysOriginal) }
            .first

        // Build the same icon + label + chevron container the other dropdowns use.
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: iconImage)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconView)

        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Dropdown chevron at the trailing edge — exactly like subPaymentButton.
        let dropdownIcon = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdownIcon.contentMode = .scaleAspectFit
        dropdownIcon.translatesAutoresizingMaskIntoConstraints = false
        dropdownIcon.tintColor = .label
        upiAppButton.addSubview(dropdownIcon)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -32),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])

        upiAppButton.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: upiAppButton.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: upiAppButton.trailingAnchor),
            container.topAnchor.constraint(equalTo: upiAppButton.topAnchor),
            container.bottomAnchor.constraint(equalTo: upiAppButton.bottomAnchor),
            dropdownIcon.trailingAnchor.constraint(equalTo: upiAppButton.trailingAnchor, constant: -8),
            dropdownIcon.centerYAnchor.constraint(equalTo: upiAppButton.centerYAnchor),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 16),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        container.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        dropdownIcon.isUserInteractionEnabled = false
    }

    @objc func upiAppTapped() {
        let options = paymentManager.upiIntentAppOptions
        let picker = UpiAppPickerBottomSheetViewController(
            options: options,
            selectedCode: paymentManager.selectedUpiApp?.code
        ) { [weak self] selected in
            self?.paymentManager.selectedUpiApp = selected
            self?.updateUpiAppButtonUI()
            if DebugConfig.debugPrintEnabled {
                DebugLog.log("[DEBUG] UPI app picked: \(selected.name) (code: \(selected.code))")
            }
        }
        present(picker, animated: true)
    }
    func updateUserDetailsUI() {
        userDetailsStackView.isHidden = !paymentManager.userDetailsChecked
        userDetailsStackView.isUserInteractionEnabled = paymentManager.userDetailsChecked
        userDetailsStackView.spacing = paymentManager.userDetailsChecked ? 12 : 0
        // Hide text fields when stack view is hidden (not strictly necessary, but for safety)
        userDetailsStackView.arrangedSubviews.forEach { $0.isHidden = !paymentManager.userDetailsChecked }
        // Removed: contentViewMinHeightConstraint logic
        // No minimum height constraint, scrolling will work naturally
        view.layoutIfNeeded()
    }


    // Update the payment customisation button to show icon and label
    func updatePaymentCustomisationButtonUI() {
        guard let selected = selectedPaymentOption else { return }
        // Remove all subviews except the titleLabel
        paymentCustomisationButton.subviews.forEach {
            if $0 != paymentCustomisationButton.titleLabel {
                $0.removeFromSuperview()
            }
        }
        // Remove label text
        paymentCustomisationButton.setTitle("", for: .normal)
        // Create a container for icon and label
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: selected.icon?.withRenderingMode(.alwaysTemplate))
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .label
        container.addSubview(iconView)

        let label = UILabel()
        label.text = selected.name
        label.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Add dropdown chevron icon
        let dropdownIcon = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdownIcon.contentMode = .scaleAspectFit
        dropdownIcon.translatesAutoresizingMaskIntoConstraints = false
        dropdownIcon.tintColor = .label
        paymentCustomisationButton.addSubview(dropdownIcon)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])

        paymentCustomisationButton.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: paymentCustomisationButton.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: paymentCustomisationButton.trailingAnchor),
            container.topAnchor.constraint(equalTo: paymentCustomisationButton.topAnchor),
            container.bottomAnchor.constraint(equalTo: paymentCustomisationButton.bottomAnchor),
            dropdownIcon.trailingAnchor.constraint(equalTo: paymentCustomisationButton.trailingAnchor, constant: -8),
            dropdownIcon.centerYAnchor.constraint(equalTo: paymentCustomisationButton.centerYAnchor),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 16),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        // Disable interaction for subviews so button tap works
        container.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
        dropdownIcon.isUserInteractionEnabled = false
        
        // Ensure button target is still active
        paymentCustomisationButton.removeTarget(nil, action: nil, for: .allEvents)
        paymentCustomisationButton.addTarget(self, action: #selector(paymentCustomisationTapped), for: .touchUpInside)
        paymentCustomisationButton.isUserInteractionEnabled = true
    }

    // Update the sub payment button to show icon and label
    func updateSubPaymentButtonUI() {
        guard let selected = selectedSubPaymentOption else { return }
        // Remove all subviews except the titleLabel
        subPaymentButton.subviews.forEach {
            if $0 != subPaymentButton.titleLabel {
                $0.removeFromSuperview()
            }
        }
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconImage = UIImage(named: selected.imageName)?.withRenderingMode(.alwaysTemplate)
        let iconView = UIImageView(image: iconImage)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .label
        container.addSubview(iconView)

        let label = UILabel()
        label.text = selected.name
        label.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        // Add dropdown chevron icon
        let dropdownIcon = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdownIcon.contentMode = .scaleAspectFit
        dropdownIcon.translatesAutoresizingMaskIntoConstraints = false
        dropdownIcon.tintColor = .label
        subPaymentButton.addSubview(dropdownIcon)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            container.heightAnchor.constraint(equalToConstant: 44)
        ])

        subPaymentButton.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: subPaymentButton.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: subPaymentButton.trailingAnchor),
            container.topAnchor.constraint(equalTo: subPaymentButton.topAnchor),
            container.bottomAnchor.constraint(equalTo: subPaymentButton.bottomAnchor),
            dropdownIcon.trailingAnchor.constraint(equalTo: subPaymentButton.trailingAnchor, constant: -8),
            dropdownIcon.centerYAnchor.constraint(equalTo: subPaymentButton.centerYAnchor),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 16),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        container.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
        dropdownIcon.isUserInteractionEnabled = false
        
        // Ensure button target is still active
        subPaymentButton.removeTarget(nil, action: nil, for: .allEvents)
        subPaymentButton.addTarget(self, action: #selector(subPaymentTapped), for: .touchUpInside)
        subPaymentButton.isUserInteractionEnabled = true
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func dismissKeyboard() {
        if DebugConfig.debugPrintEnabled {
        DebugLog.log("Dismiss keyboard gesture triggered")
        }
        view.endEditing(true)
    }
    
    // MARK: - NimbblCheckoutSDKDelegate
    func onCheckoutResponse(data: [AnyHashable: Any]) {
        DebugLog.log("[SAMPLE APP] Checkout response received: \(data)")

        // Reading the checkout result.
        // The SDK delivers the outcome as an untyped [AnyHashable: Any].
        // These are the fields a merchant typically acts on:
        let status        = data["status"] as? String ?? "unknown"
        let orderId       = (data["order_id"] ?? data["nimbbl_order_id"]) as? String
        // transaction_id arrives under one of a few keys depending on the flow:
        let transactionId = (data["transaction_id"]
                             ?? data["nimbbl_transaction_id"]
                             ?? data["pspTransactionId"]) as? String
        let reason        = (data["message"] ?? data["reason"]) as? String

        switch status.lowercased() {
        case "success":
            // Payment succeeded — fulfil the order using orderId / transactionId.
            DebugLog.log("[SAMPLE APP] Payment SUCCESS — order=\(orderId ?? "-"), txn=\(transactionId ?? "-")")
        case "failed", "failure":
            DebugLog.log("[SAMPLE APP] Payment FAILED — \(reason ?? "no reason")")
        default:
            // pending / cancelled / unknown — treat as not-yet-paid.
            DebugLog.log("[SAMPLE APP] Payment \(status) — confirm the final state via your server")
        }
        // IMPORTANT: never grant fulfilment on the client response alone — always
        // verify the final payment status server-side (webhook or order-status API)
        // before shipping goods or crediting the customer.

        // Dismiss any presented view controllers (e.g., checkout webview)
        if let presented = self.presentedViewController {
            DebugLog.log("[SAMPLE APP] Dismissing presented view controller")
            presented.dismiss(animated: false) {
                DebugLog.log("[SAMPLE APP] Presented view controller dismissed, showing ThankYou page")
                self.showThankYouVC(data: data)
            }
        } else {
            DebugLog.log("[SAMPLE APP] No presented view controller, showing ThankYou page directly")
            self.showThankYouVC(data: data)
        }
    }
    
    private func showThankYouVC(data: [AnyHashable: Any]) {
        let thankYouVC = ThankYouVC()
        
        // Pass the data directly to ThankYouVC
        thankYouVC.paymentData = data
        DebugLog.log("[SAMPLE APP] Data passed to ThankYouVC: \(data)")
        
        thankYouVC.modalPresentationStyle = .fullScreen
        self.present(thankYouVC, animated: true) {
            DebugLog.log("[SAMPLE APP] ThankYou page presented successfully")
        }
    }
    


} // End of ViewController class


