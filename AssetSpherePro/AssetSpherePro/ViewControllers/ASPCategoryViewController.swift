//
//  ASPCategoryViewController.swift
//  AssetSpherePro
//
//  Category management: shows each default category with its asset count and
//  total value, and drills into a filtered asset list.
//

import UIKit

final class ASPCategoryViewController: ASPBaseViewController {

    private var listStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        navigationItem.largeTitleDisplayMode = .never
        listStack = asp_makeScrollingStack(topInset: 12, spacing: 10)
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_reload() {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let header = ASPHeaderView()
        header.asp_configure(title: "All Categories",
                             subtitle: "\(ASPAssetManager.shared.asp_count) assets total")
        listStack.addArrangedSubview(header)
        listStack.setCustomSpacing(14, after: header)

        for category in ASPCategory.all {
            let assets = ASPAssetManager.shared.asp_assets(in: category)
            let total = assets.reduce(0) { $0 + $1.assetValue }
            let card = ASPCategoryCardView()
            card.asp_configure(category: category, count: assets.count, totalValue: total)
//            let tap = ASPTapGesture { [weak self] in self?.asp_openCategory(category) }
//            card.addGestureRecognizer(tap)
            listStack.addArrangedSubview(card)
        }
    }

    private func asp_openCategory(_ category: String) {
        let vc = ASPCategoryDetailViewController(category: category)
        navigationController?.pushViewController(vc, animated: true)
    }
}

/// A filtered list of the assets in a single category.
final class ASPCategoryDetailViewController: ASPBaseViewController {

    private let category: String
    private var listStack: UIStackView!

    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category
        navigationItem.largeTitleDisplayMode = .never
        listStack = asp_makeScrollingStack(topInset: 12, spacing: 10)
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_reload() {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let assets = ASPAssetManager.shared.asp_assets(in: category)

        if assets.isEmpty {
            let empty = ASPEmptyView()
            empty.asp_configure(icon: ASPCategory.symbol(for: category),
                                title: "No \(category) Assets",
                                message: "Assets you file under \(category) will appear here.")
            listStack.addArrangedSubview(empty)
            return
        }

//        for asset in assets {
//            let card = ASPAssetCardView()
//            let image = ASPStorageManager.shared.asp_loadAssetImage(asset.assetImagePath)
//            card.asp_configure(asset: asset, image: image)
//            let tap = ASPTapGesture { [weak self] in
//                let vc = ASPAssetDetailViewController(asset: asset)
//                vc.onChanged = { [weak self] in self?.asp_reload() }
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }
//            card.addGestureRecognizer(tap)
//            listStack.addArrangedSubview(card)
//        }
    }
}
