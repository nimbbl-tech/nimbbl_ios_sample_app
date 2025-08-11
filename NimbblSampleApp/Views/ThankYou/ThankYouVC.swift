/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/

import UIKit

class ThankYouVC: UIViewController {
    // Remove @IBOutlet
    private let statusIconView = UIImageView()
    private let lblStatus = UILabel()
    private let lblOrderId = UILabel()
    private let lblTrxId = UILabel()
    private let doneButton = UIButton(type: .system)
    private let statusContainerView = UIView()
    
    var orderid = ""
    var trxId = ""
    var isSuccess: Bool = true
    var errorMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Set up navigation bar appearance
        self.title = isSuccess ? TextConstants.orderSuccess : "Payment Status"
        if let navBar = self.navigationController?.navigationBar {
            navBar.barTintColor = .black
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
            navBar.tintColor = .white
        } else {
            // If not in navigation controller, add a custom top bar
            let topBar = UIView()
            topBar.backgroundColor = .black
            topBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topBar)
            NSLayoutConstraint.activate([
                topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topBar.heightAnchor.constraint(equalToConstant: 44)
            ])
            let titleLabel = UILabel()
            titleLabel.text = isSuccess ? TextConstants.orderSuccess : "Payment Status"
            titleLabel.textColor = .white
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            topBar.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
            ])
        }
        view.backgroundColor = .white
        
        // Status container with icon and label
        statusContainerView.backgroundColor = isSuccess ? UIColor.systemGreen.withAlphaComponent(0.1) : UIColor.systemRed.withAlphaComponent(0.1)
        statusContainerView.layer.cornerRadius = 12
        statusContainerView.layer.borderWidth = 2
        statusContainerView.layer.borderColor = isSuccess ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
        statusContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusContainerView)
        
        // Status icon
        statusIconView.image = UIImage(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
        statusIconView.tintColor = isSuccess ? .systemGreen : .systemRed
        statusIconView.contentMode = .scaleAspectFit
        statusIconView.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(statusIconView)
        
        // Status label
        lblStatus.text = isSuccess ? "Payment Successful!" : "Payment Failed"
        lblStatus.textColor = isSuccess ? .systemGreen : .systemRed
        lblStatus.font = UIFont.boldSystemFont(ofSize: 20)
        lblStatus.textAlignment = .center
        lblStatus.translatesAutoresizingMaskIntoConstraints = false
        statusContainerView.addSubview(lblStatus)
        
        // Order ID label
        lblOrderId.text = TextConstants.orderIdPrefix + orderid
        lblOrderId.textColor = .black
        lblOrderId.font = UIFont.boldSystemFont(ofSize: 16)
        lblOrderId.textAlignment = .center
        lblOrderId.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblOrderId)
        
        // Transaction ID or Error Message
        if isSuccess {
        lblTrxId.text = TextConstants.statusSuccessPrefix + trxId
        lblTrxId.textColor = .black
        } else {
            lblTrxId.text = "Error: " + errorMessage
            lblTrxId.textColor = .systemRed
        }
        lblTrxId.font = UIFont.boldSystemFont(ofSize: 16)
        lblTrxId.textAlignment = .center
        lblTrxId.numberOfLines = 0
        lblTrxId.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblTrxId)
        
        doneButton.setTitle(TextConstants.done, for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = isSuccess ? .systemGreen : .systemRed
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.layer.cornerRadius = 10
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(onBtnDoneAction), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            // Status container constraints
            statusContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            statusContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Status icon constraints
            statusIconView.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor, constant: 20),
            statusIconView.centerYAnchor.constraint(equalTo: statusContainerView.centerYAnchor),
            statusIconView.widthAnchor.constraint(equalToConstant: 40),
            statusIconView.heightAnchor.constraint(equalToConstant: 40),
            
            // Status label constraints
            lblStatus.leadingAnchor.constraint(equalTo: statusIconView.trailingAnchor, constant: 15),
            lblStatus.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor, constant: -20),
            lblStatus.centerYAnchor.constraint(equalTo: statusContainerView.centerYAnchor),
            
            // Order ID constraints
            lblOrderId.topAnchor.constraint(equalTo: statusContainerView.bottomAnchor, constant: 30),
            lblOrderId.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblOrderId.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Transaction ID constraints
            lblTrxId.topAnchor.constraint(equalTo: lblOrderId.bottomAnchor, constant: 24),
            lblTrxId.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lblTrxId.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Done button constraints
            doneButton.topAnchor.constraint(equalTo: lblTrxId.bottomAnchor, constant: 40),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 120),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func onBtnDoneAction() {
        print("ThankYouVC: Done button tapped")
        
        // Since ThankYouVC is presented modally, simply dismiss it
        // This will return to the root ViewController
        self.dismiss(animated: true) {
            print("ThankYouVC: Dismissed successfully, returned to root ViewController")
        }
    }
}
