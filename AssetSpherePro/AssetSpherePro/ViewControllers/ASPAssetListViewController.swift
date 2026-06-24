//
//  ASPAssetListViewController.swift
//  AssetSpherePro
//
//  Lists all assets with search and a favorites filter. Supports tapping into
//  detail, swipe-free delete via detail, and an add button.
//

import UIKit

final class ASPAssetListViewController: ASPBaseViewController {

    private let searchField = ASPTextField(icon: "magnifyingglass", placeholder: "Search assets", caption: "SEARCH")
    private let segment = UISegmentedControl(items: ["All", "Favorites"])
    private var listStack: UIStackView!
    private var scrollView: UIScrollView!
    private let emptyView = ASPEmptyView()

    private var assets: [ASPAssetModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(asp_addTapped))
        asp_buildUI()
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_buildUI() {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.textField.addTarget(self, action: #selector(asp_searchChanged), for: .editingChanged)
        searchField.textField.returnKeyType = .search
        view.addSubview(searchField)

        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        segment.selectedSegmentTintColor = ASPTheme.Color.accent
        segment.setTitleTextAttributes([.foregroundColor: ASPTheme.Color.textSecondary], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(asp_filterChanged), for: .valueChanged)
        view.addSubview(segment)

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 10
        listStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(listStack)

        emptyView.isHidden = true
        emptyView.asp_configure(icon: "shippingbox", title: "No Assets",
                                message: "Add your first asset to start building your portfolio.",
                                action: "Add Asset") { [weak self] in self?.asp_addTapped() }
        view.addSubview(emptyView)

        let inset = ASPTheme.Layout.screenInset
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),

            segment.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 14),
            segment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            segment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),

            scrollView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            listStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: inset),
            listStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -inset),
            listStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset)
        ])
    }

    // MARK: - Data

    private func asp_reload() {
        let query = searchField.text
        var result = query.asp_trimmed.isEmpty
            ? ASPAssetManager.shared.asp_all()
            : ASPAssetManager.shared.asp_search(query)
        if segment.selectedSegmentIndex == 1 {
            result = result.filter { $0.isFavorite }
        }
        assets = result
        asp_render()
    }

    private func asp_render() {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if assets.isEmpty {
            emptyView.isHidden = false
            scrollView.isHidden = true
            return
        }
        emptyView.isHidden = true
        scrollView.isHidden = false

        for asset in assets {
            let card = ASPAssetCardView()
            let image = ASPStorageManager.shared.asp_loadAssetImage(asset.assetImagePath)
            card.asp_configure(asset: asset, image: image)
            let tap = ASPTapGesture { [weak self] in self?.asp_openDetail(asset) }
            card.addGestureRecognizer(tap)
            listStack.addArrangedSubview(card)
        }
    }

    private func asp_openDetail(_ asset: ASPAssetModel) {
        let vc = ASPAssetDetailViewController(asset: asset)
        vc.onChanged = { [weak self] in self?.asp_reload() }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions

    @objc private func asp_addTapped() {
        let vc = ASPAddAssetViewController()
        vc.onSaved = { [weak self] in self?.asp_reload() }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func asp_searchChanged() { asp_reload() }

    @objc private func asp_filterChanged() { asp_reload() }
}

/// A small closure-based tap gesture used by list cards.
final class ASPTapGesture: UITapGestureRecognizer {
    private let handler: () -> Void
    init(handler: @escaping () -> Void) {
        self.handler = handler
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(asp_fire))
    }
    @objc private func asp_fire() { handler() }
}
