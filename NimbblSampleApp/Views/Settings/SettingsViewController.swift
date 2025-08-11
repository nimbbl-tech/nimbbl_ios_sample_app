/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

class SettingsViewController: UIViewController {
    // MARK: - State
    let environments = ["Prod", "Pre-Prod", "QA"]
    let experiences = Experience.allCases.map { $0.rawValue }
    var selectedEnvironment: String = UserDefaults.standard.selectedEnvironment
    var selectedExperience: String = UserDefaults.standard.selectedExperience
    var qaUrl: String {
        get {
            return UserDefaults.standard.string(forKey: "qaEnvironmentUrl") ?? EnvironmentUrls.qa1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "qaEnvironmentUrl")
        }
    }
    let qaUrlTextField = UITextField()
    
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
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
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
        environmentLabel.textColor = .black
        environmentLabel.isHidden = false
        environmentButton.setTitle(selectedEnvironment, for: .normal)
        environmentButton.setTitleColor(.black, for: .normal)
        environmentButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        environmentButton.contentHorizontalAlignment = .left
        environmentButton.backgroundColor = .white
        environmentButton.layer.cornerRadius = 10
        environmentButton.layer.borderWidth = 0
        environmentButton.addTarget(self, action: #selector(environmentTapped), for: .touchUpInside)
        let environmentChevron = UIImageView()
        environmentChevron.image = UIImage(systemName: "chevron.down")
        environmentChevron.tintColor = .gray
        environmentChevron.translatesAutoresizingMaskIntoConstraints = false
        environmentButton.addSubview(environmentChevron)
        environmentUnderline.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        qaUrlTextField.placeholder = "Enter QA environment URL"
        qaUrlTextField.text = qaUrl
        qaUrlTextField.font = UIFont.preferredFont(forTextStyle: .body)
        qaUrlTextField.textColor = .black
        qaUrlTextField.backgroundColor = .white
        qaUrlTextField.layer.cornerRadius = 8
        qaUrlTextField.layer.borderWidth = 1
        qaUrlTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
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
        experienceLabel.textColor = .black
        experienceButton.setTitle(selectedExperience, for: .normal)
        experienceButton.setTitleColor(.black, for: .normal)
        experienceButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        experienceButton.contentHorizontalAlignment = .left
        experienceButton.backgroundColor = .white
        experienceButton.layer.cornerRadius = 10
        experienceButton.layer.borderWidth = 0
        experienceButton.addTarget(self, action: #selector(experienceTapped), for: .touchUpInside)
        let experienceChevron = UIImageView()
        experienceChevron.image = UIImage(systemName: "chevron.down")
        experienceChevron.tintColor = .gray
        experienceChevron.translatesAutoresizingMaskIntoConstraints = false
        experienceButton.addSubview(experienceChevron)
        experienceUnderline.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        doneButton.setTitle(TextConstants.done, for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        doneButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
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
        // Save selections to UserDefaults (already done in selection handlers)
        self.dismiss(animated: true, completion: nil)
    }
    @objc func qaUrlChanged() {
        let newUrl = qaUrlTextField.text ?? ""
        if !newUrl.isEmpty {
            qaUrl = newUrl
        } else {
            // If user clears the text field, set default URL
            qaUrl = EnvironmentUrls.qa1
            qaUrlTextField.text = qaUrl
        }
    }
}
