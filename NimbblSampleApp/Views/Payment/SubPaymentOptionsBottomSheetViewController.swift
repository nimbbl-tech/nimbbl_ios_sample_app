/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/
import UIKit

class SubPaymentOptionsBottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let options: [ImageWithName]
    private let selectedOption: String?
    private let completion: (ImageWithName) -> Void
    
    private let tableView = UITableView()
    
    init(options: [ImageWithName], selectedOption: String?, completion: @escaping (ImageWithName) -> Void) {
        self.options = options
        self.selectedOption = selectedOption
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubPaymentOptionCell.self, forCellReuseIdentifier: TextConstants.subPaymentOptionCell)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextConstants.subPaymentOptionCell, for: indexPath) as! SubPaymentOptionCell
        let option = options[indexPath.row]
        cell.iconView.image = UIImage(named: option.imageName)
        cell.titleLabel.text = PaymentManager.shared.displayName(for: SubPaymentOption(imageName: option.imageName, name: option.name, code: option.name))
        cell.accessoryType = (option.name == selectedOption) ? .checkmark : .none
        cell.tintColor = (option.name == selectedOption) ? .black : .gray
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.completion(self.options[indexPath.row])
        }
    }
}

class SubPaymentOptionCell: UITableViewCell {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Gordita-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        self.backgroundColor = .white
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 