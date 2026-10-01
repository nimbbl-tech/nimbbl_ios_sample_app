/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit
import nimbbl_mobile_kit_ios_webview_sdk

class SettingsViewController: UIViewController {
    // MARK: - State
    // Environment options — Prod/Pre-Prod/QA.
    let environments = [Environment.prod.rawValue, Environment.preProd.rawValue, Environment.qa.rawValue]
    let experiences = Experience.allCases.map { $0.rawValue }
    var selectedEnvironment: String = UserDefaults.standard.selectedEnvironment
    var selectedExperience: String = UserDefaults.standard.selectedExperience
    var qaUrl: String {
        get {
            let v = UserDefaults.standard.qaEnvironmentUrl
            return v.isEmpty ? EnvironmentUrls.qa : v
        }
        set {
            UserDefaults.standard.qaEnvironmentUrl = newValue
        }
    }
    let qaUrlTextField = UITextField()

    // MARK: - Debug section (hidden until user taps header 7 times within 2s)
    let debugSectionStack = UIStackView()
    let accessTokenLabel = UILabel()
    let accessTokenField = UITextField()
    let accessTokenClear = UIButton(type: .system)
    let sdkDebugLogsLabel = UILabel()
    let sdkDebugLogsSwitch = UISwitch()
    let viewDebugLogsButton = UIButton(type: .system)

    private var debugTapCount = 0
    private var lastDebugTapTime: TimeInterval = 0
    
    // MARK: - Dynamic Constraints
    var experienceLabelTopConstraint: NSLayoutConstraint?
    var experienceLabelTopConstraintWithGap: NSLayoutConstraint?
    // MARK: - UI
    let scrollView = UIScrollView()
    let contentView = UIView()
    // Header
    let headerView = UIView()
    let backButton = UIButton()
    let titleLabel = UILabel()
    // Add missing UI elements
    let environmentLabel = UILabel()
    let environmentButton = UIButton(type: .system)
    let experienceLabel = UILabel()
    let experienceButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    let environmentUnderline = UIView()
    let experienceUnderline = UIView()
    // Gap views
    let gap1 = UIView()
    let gap2 = UIView()
    let gap3 = UIView()
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        setupDebugSection()
        setupDebugUnlockGesture()
    }

    // MARK: - Debug section setup

    private func setupDebugSection() {
        // Container stack
        debugSectionStack.axis = .vertical
        debugSectionStack.spacing = 12
        debugSectionStack.alignment = .fill
        debugSectionStack.distribution = .fill
        debugSectionStack.translatesAutoresizingMaskIntoConstraints = false
        debugSectionStack.isHidden = !UserDefaults.standard.debugMenuUnlocked
        contentView.addSubview(debugSectionStack)

        // Access token row
        accessTokenLabel.text = TextConstants.accessTokenTitle
        accessTokenLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        accessTokenLabel.textColor = .label

        accessTokenField.placeholder = TextConstants.accessTokenPlaceholder
        accessTokenField.text = UserDefaults.standard.accessToken
        accessTokenField.font = UIFont.preferredFont(forTextStyle: .body)
        accessTokenField.textColor = .label
        accessTokenField.backgroundColor = .secondarySystemBackground
        accessTokenField.layer.cornerRadius = 8
        accessTokenField.layer.borderWidth = 1
        accessTokenField.layer.borderColor = UIColor.separator.cgColor
        accessTokenField.autocorrectionType = .no
        accessTokenField.autocapitalizationType = .none
        accessTokenField.addTarget(self, action: #selector(accessTokenChanged), for: .editingChanged)
        let leftPad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        accessTokenField.leftView = leftPad
        accessTokenField.leftViewMode = .always

        accessTokenClear.setTitle(TextConstants.clear, for: .normal)
        accessTokenClear.setTitleColor(.systemRed, for: .normal)
        accessTokenClear.addTarget(self, action: #selector(accessTokenCleared), for: .touchUpInside)
        accessTokenClear.isHidden = accessTokenField.text?.isEmpty != false

        let tokenRow = UIStackView(arrangedSubviews: [accessTokenField, accessTokenClear])
        tokenRow.axis = .horizontal
        tokenRow.spacing = 8
        tokenRow.alignment = .center
        tokenRow.distribution = .fill
        accessTokenField.translatesAutoresizingMaskIntoConstraints = false
        accessTokenField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // SDK debug logs row
        sdkDebugLogsLabel.text = TextConstants.sdkDebugLogsLabel
        sdkDebugLogsLabel.font = UIFont.preferredFont(forTextStyle: .body)
        sdkDebugLogsLabel.textColor = .label
        sdkDebugLogsSwitch.isOn = UserDefaults.standard.debugLogsEnabled
        sdkDebugLogsSwitch.addTarget(self, action: #selector(sdkDebugLogsToggled), for: .valueChanged)
        let switchRow = UIStackView(arrangedSubviews: [sdkDebugLogsLabel, UIView(), sdkDebugLogsSwitch])
        switchRow.axis = .horizontal
        switchRow.spacing = 8
        switchRow.alignment = .center

        // View debug logs row
        viewDebugLogsButton.setTitle(TextConstants.viewDebugLogs, for: .normal)
        viewDebugLogsButton.contentHorizontalAlignment = .left
        viewDebugLogsButton.addTarget(self, action: #selector(viewDebugLogsTapped), for: .touchUpInside)

        debugSectionStack.addArrangedSubview(accessTokenLabel)
        debugSectionStack.addArrangedSubview(tokenRow)
        debugSectionStack.addArrangedSubview(switchRow)
        debugSectionStack.addArrangedSubview(viewDebugLogsButton)

        NSLayoutConstraint.activate([
            debugSectionStack.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 24),
            debugSectionStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            debugSectionStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            debugSectionStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupDebugUnlockGesture() {
        // 7 taps on the header within 2s unlocks the debug section.
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        tap.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tap)
        headerView.isUserInteractionEnabled = true
    }

    @objc private func headerTapped() {
        let now = Date().timeIntervalSince1970
        if now - lastDebugTapTime > 2.0 {
            debugTapCount = 0
        }
        lastDebugTapTime = now
        debugTapCount += 1

        if debugTapCount >= 7 && !UserDefaults.standard.debugMenuUnlocked {
            UserDefaults.standard.debugMenuUnlocked = true
            debugSectionStack.isHidden = false
            // Quick toast-style confirmation
            let alert = UIAlertController(
                title: nil,
                message: TextConstants.debugOptionsUnlocked,
                preferredStyle: .alert
            )
            present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }

    @objc private func accessTokenChanged() {
        accessTokenClear.isHidden = accessTokenField.text?.isEmpty != false
    }

    @objc private func accessTokenCleared() {
        accessTokenField.text = ""
        accessTokenClear.isHidden = true
    }

    @objc private func sdkDebugLogsToggled() {
        // Commit immediately on toggle — this is a UISwitch, so the new state
        // must survive a Back / swipe-down exit, not just Done. Persistence and
        // SDK propagation happen together so the next checkout (and the next
        // app launch) read the same value.
        let isOn = sdkDebugLogsSwitch.isOn
        UserDefaults.standard.debugLogsEnabled = isOn
        NimbblCheckoutSDK.shared.setDebugLoggingEnabled(NSNumber(value: isOn))
    }

    @objc private func viewDebugLogsTapped() {
        let vc = DebugLogsViewController()
        if navigationController != nil {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            present(UINavigationController(rootViewController: vc), animated: true)
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
    // MARK: - UI Setup
    func setupUI() {
        // Add all subviews to contentView before any constraints
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        // Header
        contentView.addSubview(headerView)
        contentView.addSubview(environmentLabel)
        contentView.addSubview(environmentButton)
        contentView.addSubview(environmentUnderline)
        contentView.addSubview(qaUrlTextField)
        contentView.addSubview(experienceLabel)
        contentView.addSubview(experienceButton)
        contentView.addSubview(experienceUnderline)
        contentView.addSubview(doneButton)
        // Add gap views
        gap1.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(gap1)
        gap2.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(gap2)
        gap3.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(gap3)
        // Set up properties for all views (as before)
        headerView.backgroundColor = .black
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        titleLabel.text = TextConstants.settingsTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        headerView.addSubview(titleLabel)
        environmentLabel.text = TextConstants.selectEnvironment
        environmentLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        environmentLabel.textColor = .label
        environmentLabel.isHidden = false
        environmentButton.setTitle(selectedEnvironment, for: .normal)
        environmentButton.setTitleColor(.label, for: .normal)
        environmentButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        environmentButton.contentHorizontalAlignment = .left
        environmentButton.backgroundColor = .secondarySystemBackground
        environmentButton.layer.cornerRadius = 10
        environmentButton.layer.borderWidth = 1
        environmentButton.layer.borderColor = UIColor.separator.cgColor
        environmentButton.addTarget(self, action: #selector(environmentTapped), for: .touchUpInside)
        let environmentChevron = UIImageView()
        environmentChevron.image = UIImage(systemName: "chevron.down")
        environmentChevron.tintColor = .secondaryLabel
        environmentChevron.translatesAutoresizingMaskIntoConstraints = false
        environmentButton.addSubview(environmentChevron)
        environmentUnderline.backgroundColor = UIColor.separator
        qaUrlTextField.placeholder = "Enter QA environment URL"
        qaUrlTextField.text = qaUrl
        qaUrlTextField.font = UIFont.preferredFont(forTextStyle: .body)
        qaUrlTextField.textColor = .label
        qaUrlTextField.backgroundColor = .secondarySystemBackground
        qaUrlTextField.layer.cornerRadius = 8
        qaUrlTextField.layer.borderWidth = 1
        qaUrlTextField.layer.borderColor = UIColor.separator.cgColor
        qaUrlTextField.isHidden = selectedEnvironment != "QA"
        qaUrlTextField.addTarget(self, action: #selector(qaUrlChanged), for: .editingChanged)
        
        // Add text margin/padding
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: qaUrlTextField.frame.height))
        qaUrlTextField.leftView = leftPaddingView
        qaUrlTextField.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: qaUrlTextField.frame.height))
        qaUrlTextField.rightView = rightPaddingView
        qaUrlTextField.rightViewMode = .always
        experienceLabel.text = TextConstants.selectExperience
        experienceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        experienceLabel.textColor = .label
        experienceButton.setTitle(selectedExperience, for: .normal)
        experienceButton.setTitleColor(.label, for: .normal)
        experienceButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        experienceButton.contentHorizontalAlignment = .left
        experienceButton.backgroundColor = .secondarySystemBackground
        experienceButton.layer.cornerRadius = 10
        experienceButton.layer.borderWidth = 1
        experienceButton.layer.borderColor = UIColor.separator.cgColor
        experienceButton.addTarget(self, action: #selector(experienceTapped), for: .touchUpInside)
        let experienceChevron = UIImageView()
        experienceChevron.image = UIImage(systemName: "chevron.down")
        experienceChevron.tintColor = .secondaryLabel
        experienceChevron.translatesAutoresizingMaskIntoConstraints = false
        experienceButton.addSubview(experienceChevron)
        experienceUnderline.backgroundColor = UIColor.separator
        doneButton.setTitle(TextConstants.done, for: .normal)
        doneButton.setTitleColor(.label, for: .normal)
        doneButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        doneButton.backgroundColor = .tertiarySystemFill
        doneButton.layer.cornerRadius = 10
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        gap1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        gap2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        gap3.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 54),
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        // Environment
        environmentLabel.translatesAutoresizingMaskIntoConstraints = false
        environmentButton.translatesAutoresizingMaskIntoConstraints = false
        environmentUnderline.translatesAutoresizingMaskIntoConstraints = false
        qaUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Get the environment chevron from the button
        let environmentChevron = environmentButton.subviews.first { $0 is UIImageView } as? UIImageView
        
        NSLayoutConstraint.activate([
            environmentLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            environmentLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            environmentLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            environmentButton.topAnchor.constraint(equalTo: environmentLabel.bottomAnchor, constant: 8),
            environmentButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            environmentButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            environmentButton.heightAnchor.constraint(equalToConstant: 44),
            environmentUnderline.topAnchor.constraint(equalTo: environmentButton.bottomAnchor, constant: 2),
            environmentUnderline.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            environmentUnderline.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            environmentUnderline.heightAnchor.constraint(equalToConstant: 2),
            qaUrlTextField.topAnchor.constraint(equalTo: environmentUnderline.bottomAnchor, constant: 12),
            qaUrlTextField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            qaUrlTextField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            qaUrlTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Position environment chevron on the right
        if let environmentChevron = environmentChevron {
            NSLayoutConstraint.activate([
                environmentChevron.centerYAnchor.constraint(equalTo: environmentButton.centerYAnchor),
                environmentChevron.trailingAnchor.constraint(equalTo: environmentButton.trailingAnchor, constant: -16),
                environmentChevron.widthAnchor.constraint(equalToConstant: 12),
                environmentChevron.heightAnchor.constraint(equalToConstant: 12)
            ])
        }
        // Experience
        experienceLabel.translatesAutoresizingMaskIntoConstraints = false
        experienceButton.translatesAutoresizingMaskIntoConstraints = false
        experienceUnderline.translatesAutoresizingMaskIntoConstraints = false
        
        // Get the experience chevron from the button
        let experienceChevron = experienceButton.subviews.first { $0 is UIImageView } as? UIImageView
        
        // Create constraints for experience label - will be updated based on environment selection
        experienceLabelTopConstraint = experienceLabel.topAnchor.constraint(equalTo: environmentUnderline.bottomAnchor, constant: 20)
        experienceLabelTopConstraintWithGap = experienceLabel.topAnchor.constraint(equalTo: qaUrlTextField.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([
            experienceLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            experienceLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            experienceButton.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 8),
            experienceButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            experienceButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            experienceButton.heightAnchor.constraint(equalToConstant: 44),
            experienceUnderline.topAnchor.constraint(equalTo: experienceButton.bottomAnchor, constant: 2),
            experienceUnderline.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            experienceUnderline.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            experienceUnderline.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        // Set initial constraint based on current environment
        if selectedEnvironment == "QA" {
            experienceLabelTopConstraintWithGap?.isActive = true
        } else {
            experienceLabelTopConstraint?.isActive = true
        }
        
        // Position experience chevron on the right
        if let experienceChevron = experienceChevron {
            NSLayoutConstraint.activate([
                experienceChevron.centerYAnchor.constraint(equalTo: experienceButton.centerYAnchor),
                experienceChevron.trailingAnchor.constraint(equalTo: experienceButton.trailingAnchor, constant: -16),
                experienceChevron.widthAnchor.constraint(equalToConstant: 12),
                experienceChevron.heightAnchor.constraint(equalToConstant: 12)
            ])
        }
        // Done
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: experienceUnderline.bottomAnchor, constant: 20),
            doneButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 48),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32)
        ])
        // Gaps
        gap1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        gap2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        gap3.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    // MARK: - Actions
    @objc func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func environmentTapped() {
        let alert = UIAlertController(title: TextConstants.selectEnvironmentAlert, message: nil, preferredStyle: .actionSheet)
        for environment in environments {
            alert.addAction(UIAlertAction(title: environment, style: .default) { _ in
                self.selectedEnvironment = environment
                self.environmentButton.setTitle(environment, for: .normal)
                UserDefaults.standard.selectedEnvironment = environment
                
                // Update constraint based on environment selection
                if environment == "QA" {
                    self.qaUrlTextField.isHidden = false
                    // Ensure default URL is set if empty
                    if self.qaUrl.isEmpty {
                        self.qaUrl = EnvironmentUrls.qa1
                    }
                    self.qaUrlTextField.text = self.qaUrl
                    self.environmentLabel.isHidden = false // Ensure label is always visible
                    
                    // Switch to constraint with gap
                    self.experienceLabelTopConstraint?.isActive = false
                    self.experienceLabelTopConstraintWithGap?.isActive = true
                } else {
                    self.qaUrlTextField.isHidden = true
                    self.environmentLabel.isHidden = false // Ensure label is always visible
                    
                    // Switch to constraint without gap
                    self.experienceLabelTopConstraintWithGap?.isActive = false
                    self.experienceLabelTopConstraint?.isActive = true
                }
                
                // Animate the layout change
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            })
        }
        alert.addAction(UIAlertAction(title: TextConstants.cancel, style: .cancel))
        present(alert, animated: true)
    }
    @objc func experienceTapped() {
        let alert = UIAlertController(title: TextConstants.selectExperienceAlert, message: nil, preferredStyle: .actionSheet)
        for experience in experiences {
            alert.addAction(UIAlertAction(title: experience, style: .default) { _ in
                self.selectedExperience = experience
                self.experienceButton.setTitle(experience, for: .normal)
                UserDefaults.standard.selectedExperience = experience
            })
        }
        alert.addAction(UIAlertAction(title: TextConstants.cancel, style: .cancel))
        present(alert, animated: true)
    }
    @objc func doneTapped() {
        // Compute the shop base URL from the selected environment.
        let baseUrl: String
        switch selectedEnvironment {
        case Environment.prod.rawValue: baseUrl = EnvironmentUrls.prod
        case Environment.preProd.rawValue: baseUrl = EnvironmentUrls.preProd
        case Environment.qa.rawValue:
            let raw = qaUrlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            baseUrl = raw.isEmpty ? EnvironmentUrls.qa : raw
        default: baseUrl = EnvironmentUrls.prod
        }

        // Persist all preferences.
        UserDefaults.standard.shopBaseUrl = baseUrl
        UserDefaults.standard.qaEnvironmentUrl = qaUrlTextField.text ?? ""
        UserDefaults.standard.sampleAppMode = selectedExperience
        if UserDefaults.standard.debugMenuUnlocked {
            UserDefaults.standard.accessToken =
                (accessTokenField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaults.standard.debugLogsEnabled = sdkDebugLogsSwitch.isOn
        }

        // Propagate to the SDK so the next checkout uses the new env / debug toggle.
        NimbblCheckoutSDK.shared.environmentUrl =
            SampleShopAPIUtils.resolveSdkEnvironmentUrl(configuredBaseUrl: baseUrl)
        NimbblCheckoutSDK.shared.setDebugLoggingEnabled(
            NSNumber(value: UserDefaults.standard.debugLogsEnabled)
        )

        self.dismiss(animated: true, completion: nil)
    }

    @objc func qaUrlChanged() {
        let newUrl = qaUrlTextField.text ?? ""
        if !newUrl.isEmpty {
            qaUrl = newUrl
        } else {
            // Default to qa3 on empty input.
            qaUrl = EnvironmentUrls.qa
            qaUrlTextField.text = qaUrl
        }
    }
}
