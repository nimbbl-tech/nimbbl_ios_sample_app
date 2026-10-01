/*
Created by Sandeep Y. on 15/05/26.
Copyright (c) 2026 Bigital Technologies Pvt. Ltd. All rights reserved.

Live log viewer for the sample app.
App bar matches `SettingsViewController` (black header, back chevron, title).
*/

import UIKit

final class DebugLogsViewController: UIViewController {

    // MARK: - Header (matches SettingsViewController)
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()

    // MARK: - Toolbar + content
    private let toolsBar = UIView()
    private let textView = UITextView()
    private let searchBar = UISearchBar()
    private let pauseButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let copyButton = UIButton(type: .system)
    private let searchPrevButton = UIButton(type: .system)
    private let searchNextButton = UIButton(type: .system)

    // MARK: - State
    private var matchRanges: [NSRange] = []
    private var currentMatchIndex: Int = -1
    private var autoScroll: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if !AppLogStream.isXcodeDebugSession {
            AppLogStream.shared.install()
        }
        view.backgroundColor = .systemBackground
        AppLogStream.shared.isPaused = false
        setupUI()
        setupConstraints()
        updatePauseButtonTitle()
        refreshLogText()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onLogAppended(_:)),
            name: AppLogStream.didAppendNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if !AppLogStream.isXcodeDebugSession {
            AppLogStream.shared.install()
        }
        refreshLogText()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        headerView.backgroundColor = .black
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        headerView.addSubview(backButton)

        titleLabel.text = TextConstants.debugLogsTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        headerView.addSubview(titleLabel)

        updatePauseButtonTitle()
        pauseButton.setTitleColor(.systemBlue, for: .normal)
        pauseButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        pauseButton.addTarget(self, action: #selector(onPauseToggle), for: .touchUpInside)

        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        clearButton.addTarget(self, action: #selector(onClear), for: .touchUpInside)

        copyButton.setTitle("Copy", for: .normal)
        copyButton.setTitleColor(.systemBlue, for: .normal)
        copyButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        copyButton.addTarget(self, action: #selector(onCopy), for: .touchUpInside)

        toolsBar.backgroundColor = .systemBackground
        [pauseButton, clearButton, copyButton].forEach { toolsBar.addSubview($0) }

        searchBar.placeholder = "Search logs"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal

        searchPrevButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        searchPrevButton.addTarget(self, action: #selector(onSearchPrev), for: .touchUpInside)
        searchPrevButton.isEnabled = false
        searchNextButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        searchNextButton.addTarget(self, action: #selector(onSearchNext), for: .touchUpInside)
        searchNextButton.isEnabled = false

        textView.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .secondarySystemBackground
        textView.textColor = .label
        textView.delegate = self
        textView.layer.cornerRadius = 6

        [headerView, toolsBar, searchBar, searchPrevButton, searchNextButton, textView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        let g = view.safeAreaLayoutGuide
        let margin: CGFloat = 14

        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: g.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 54),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            toolsBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            toolsBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolsBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolsBar.heightAnchor.constraint(equalToConstant: 44),

            pauseButton.leadingAnchor.constraint(equalTo: toolsBar.leadingAnchor, constant: margin),
            pauseButton.centerYAnchor.constraint(equalTo: toolsBar.centerYAnchor),

            clearButton.leadingAnchor.constraint(equalTo: pauseButton.trailingAnchor, constant: 16),
            clearButton.centerYAnchor.constraint(equalTo: toolsBar.centerYAnchor),

            copyButton.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 16),
            copyButton.centerYAnchor.constraint(equalTo: toolsBar.centerYAnchor),

            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin - 6),
            searchBar.trailingAnchor.constraint(equalTo: searchPrevButton.leadingAnchor, constant: -4),
            searchBar.topAnchor.constraint(equalTo: toolsBar.bottomAnchor, constant: 4),
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            searchPrevButton.trailingAnchor.constraint(equalTo: searchNextButton.leadingAnchor, constant: -8),
            searchPrevButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchPrevButton.widthAnchor.constraint(equalToConstant: 32),
            searchPrevButton.heightAnchor.constraint(equalToConstant: 32),

            searchNextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            searchNextButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchNextButton.widthAnchor.constraint(equalToConstant: 32),
            searchNextButton.heightAnchor.constraint(equalToConstant: 32),

            textView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            textView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Actions

    @objc private func onBack() {
        if let navigationController, navigationController.viewControllers.first != self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func onPauseToggle() {
        AppLogStream.shared.isPaused.toggle()
        updatePauseButtonTitle()
    }

    private func updatePauseButtonTitle() {
        let title = AppLogStream.shared.isPaused ? "Resume" : "Pause"
        pauseButton.setTitle(title, for: .normal)
    }

    @objc private func onClear() {
        AppLogStream.shared.clear()
        textView.text = ""
        matchRanges = []
        currentMatchIndex = -1
        updateMatchButtons()
    }

    @objc private func onCopy() {
        UIPasteboard.general.string = textView.text
    }

    @objc private func onSearchNext() {
        guard !matchRanges.isEmpty else { return }
        currentMatchIndex = (currentMatchIndex + 1) % matchRanges.count
        highlightAndScrollToCurrentMatch()
    }

    @objc private func onSearchPrev() {
        guard !matchRanges.isEmpty else { return }
        currentMatchIndex = (currentMatchIndex - 1 + matchRanges.count) % matchRanges.count
        highlightAndScrollToCurrentMatch()
    }

    private func updateMatchButtons() {
        let hasMatches = !matchRanges.isEmpty
        searchPrevButton.isEnabled = hasMatches
        searchNextButton.isEnabled = hasMatches
    }

    // MARK: - Search highlighting

    private func performSearch(_ query: String) {
        let text = textView.text ?? ""
        matchRanges.removeAll()
        currentMatchIndex = -1
        defer { updateMatchButtons() }
        guard !query.isEmpty, !text.isEmpty else {
            applyAttributes(highlightedRange: nil)
            return
        }

        var searchRange = NSRange(location: 0, length: (text as NSString).length)
        let nsText = text as NSString
        while searchRange.location < nsText.length {
            let found = nsText.range(of: query, options: .caseInsensitive, range: searchRange)
            if found.location == NSNotFound { break }
            matchRanges.append(found)
            let nextStart = found.location + found.length
            searchRange = NSRange(location: nextStart, length: nsText.length - nextStart)
        }

        if !matchRanges.isEmpty {
            currentMatchIndex = 0
            highlightAndScrollToCurrentMatch()
        } else {
            applyAttributes(highlightedRange: nil)
        }
    }

    private func highlightAndScrollToCurrentMatch() {
        guard currentMatchIndex >= 0, currentMatchIndex < matchRanges.count else { return }
        let range = matchRanges[currentMatchIndex]
        applyAttributes(highlightedRange: range)
        textView.scrollRangeToVisible(range)
    }

    private func applyAttributes(highlightedRange: NSRange?) {
        let text = textView.text ?? ""
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor.label
            ]
        )
        for r in matchRanges {
            attributed.addAttribute(.backgroundColor, value: UIColor.systemYellow.withAlphaComponent(0.4), range: r)
        }
        if let r = highlightedRange {
            attributed.addAttribute(.backgroundColor, value: UIColor.systemOrange, range: r)
        }
        textView.attributedText = attributed
    }

    // MARK: - Log display

    private func refreshLogText() {
        let snapshot = AppLogStream.shared.snapshot()
        if snapshot.isEmpty {
            let hint = AppLogStream.isXcodeDebugSession
                ? "No in-app logs yet.\n\nSample-app lines logged via DebugLog.log appear here.\nSDK print output is in the Xcode debug console only (pipe capture is disabled under the debugger to avoid crashes)."
                : "No logs captured yet.\n\nInteract with the app and output will stream here. Tap Pause to freeze the view."
            textView.text = hint
        } else {
            textView.text = snapshot
        }
        scrollToBottom()
    }

    // MARK: - Auto-scroll

    private func scrollToBottom() {
        guard autoScroll else { return }
        let length = (textView.text as NSString?)?.length ?? 0
        guard length > 0 else { return }
        textView.scrollRangeToVisible(NSRange(location: length - 1, length: 1))
    }

    @objc private func onLogAppended(_ note: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshLogText()
            if let q = self.searchBar.text, !q.isEmpty {
                self.performSearch(q)
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension DebugLogsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        onSearchNext()
    }
}

// MARK: - UITextViewDelegate

extension DebugLogsViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let viewportHeight = scrollView.bounds.height
        let bottomOffset = contentHeight - scrollView.contentOffset.y - viewportHeight
        autoScroll = bottomOffset < 40
    }
}
