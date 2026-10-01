/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Bottom-sheet picker for UPI intent apps (gpay / phonepe / paytm).
Shown when Payment=UPI + Sub=Intent.

UX: presents a single-column list using the same cell style as
`SubPaymentOptionsBottomSheetViewController`. Returns the picked
`SubPaymentOption` so the caller can store it on `PaymentManager.selectedUpiApp`.
*/

import UIKit

final class UpiAppPickerBottomSheetViewController: UIViewController,
                                                   UITableViewDelegate,
                                                   UITableViewDataSource {

    private let options: [SubPaymentOption]
    private let selectedCode: String?
    private let completion: (SubPaymentOption) -> Void

    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let reuseId = "UpiAppCell"

    init(
        options: [SubPaymentOption],
        selectedCode: String?,
        completion: @escaping (SubPaymentOption) -> Void
    ) {
        self.options = options
        self.selectedCode = selectedCode
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *), let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        titleLabel.text = TextConstants.upiAppTitle
        titleLabel.font = UIFont(name: "Gordita-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        let option = options[indexPath.row]

        // Resolve brand icon with graceful fallback to the generic UPI icon.
        // Brand logos are rendered in their original colors (NOT template-tinted)
        // so gpay's blue, phonepe's purple, paytm's blue stay correct.
        let brandImage = UIImage(named: option.imageName)?.withRenderingMode(.alwaysOriginal)
        let fallbackImage = UIImage(named: "upiImg")?.withRenderingMode(.alwaysOriginal)
        let resolvedImage = brandImage ?? fallbackImage

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = option.name
            if let img = resolvedImage {
                content.image = img
                content.imageProperties.maximumSize = CGSize(width: 28, height: 28)
                content.imageProperties.reservedLayoutSize = CGSize(width: 28, height: 28)
                content.imageToTextPadding = 12
            }
            content.textProperties.font = UIFont(name: "Gordita-Medium", size: 14)
                ?? UIFont.systemFont(ofSize: 14, weight: .medium)
            cell.contentConfiguration = content
        } else {
            // Fallback for iOS 13 and earlier
            cell.textLabel?.text = option.name
            cell.textLabel?.font = UIFont(name: "Gordita-Medium", size: 14)
                ?? UIFont.systemFont(ofSize: 14, weight: .medium)
            cell.imageView?.image = resolvedImage
            // Preserve brand colors on iOS 13 too.
            cell.imageView?.tintColor = nil
            cell.imageView?.contentMode = .scaleAspectFit
        }

        cell.accessoryType = (option.code == selectedCode) ? .checkmark : .none
        cell.backgroundColor = .systemBackground
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picked = options[indexPath.row]
        dismiss(animated: true) {
            self.completion(picked)
        }
    }
}

