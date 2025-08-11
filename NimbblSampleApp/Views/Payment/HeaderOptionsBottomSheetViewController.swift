/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/
import UIKit

class HeaderOptionsBottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let options: [String]
    private let colorIndicators: [UIColor]
    private let selectedOption: String?
    private let completion: (String) -> Void
    
    private let tableView = UITableView()
    
    init(options: [String], colorIndicators: [UIColor], selectedOption: String?, completion: @escaping (String) -> Void) {
        self.options = options
        self.colorIndicators = colorIndicators
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
        tableView.register(HeaderOptionCell.self, forCellReuseIdentifier: TextConstants.headerOptionCell)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.rowHeight = 44
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TextConstants.headerOptionCell, for: indexPath) as! HeaderOptionCell
        let option = options[indexPath.row]
        cell.titleLabel.text = option
        cell.titleLabel.font = UIFont(name: FontNames.gorditaMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        // Set indicator color to match button logic
        if option == TextConstants.brandNameAndLogo {
            cell.indicatorView.backgroundColor = UIColor(red: 0.13, green: 0.15, blue: 0.30, alpha: 1) // #22274C
        } else if option == TextConstants.brandLogo {
            cell.indicatorView.backgroundColor = UIColor(red: 0.20, green: 0.23, blue: 0.44, alpha: 1) // #343B70
        } else {
            cell.indicatorView.backgroundColor = UIColor(red: 0.984, green: 0.22, blue: 0.114, alpha: 1) // #FB381D
        }
        cell.accessoryType = (option == selectedOption) ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        // Set checkmark color to black if selected, else default
        cell.tintColor = (option == selectedOption) ? UIColor.black : UIColor.gray
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        if DebugConfig.debugPrintEnabled {
            print("[DEBUG] BottomSheet header option selected: \(selectedOption)")
        }
        dismiss(animated: true) {
            self.completion(selectedOption)
        }
    }
}

class HeaderOptionCell: UITableViewCell {
    let indicatorView = UIView()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.layer.cornerRadius = 8
        indicatorView.clipsToBounds = true
        contentView.addSubview(indicatorView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: FontNames.gorditaMedium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            indicatorView.widthAnchor.constraint(equalToConstant: 16),
            indicatorView.heightAnchor.constraint(equalToConstant: 16),
            indicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 12),
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