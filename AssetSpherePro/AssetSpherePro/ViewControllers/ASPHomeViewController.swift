//
//  ASPHomeViewController.swift
//  AssetSpherePro
//
//  The dashboard. Vertically scrolling with 8+ modules when signed in:
//  1 Welcome Banner, 2 Profile Summary, 3 Asset Overview, 4 Quick Actions,
//  5 Recent Assets, 6 Statistics Preview, 7 Recent Activities, 8 Storage.
//
//  When the session is not authenticated it shows a guided sign-in entry point
//  instead, producing a clear visual difference between the two states.
//

import UIKit

final class ASPHomeViewController: ASPBaseViewController {

    /// Invoked when the user requests sign-out so the app can swap to auth.
    var onRequestSignOut: (() -> Void)?
    /// Invoked to switch tabs (passes the target tab index).
    var onSelectTab: ((Int) -> Void)?

    private var contentStack: UIStackView!

    // Live references for refresh.
    private let overviewAssetsCard = ASPStatisticCardView()
    private let overviewValueCard = ASPStatisticCardView()
    private let overviewCategoriesCard = ASPStatisticCardView()
    private let storageCard = ASPStorageCardView()
    private var recentAssetsCarousel: UIStackView?
    private var activitiesStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        asp_rebuild()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_rebuild()
    }

    // MARK: - Build

    private func asp_rebuild() {
        // Clear any previous content.
        view.subviews.filter { $0 is UIScrollView }.forEach { $0.removeFromSuperview() }
        contentStack = asp_makeScrollingStack(topInset: 12, spacing: ASPTheme.Layout.cardSpacing)

        if ASPUserManager.shared.asp_isLoggedIn {
            asp_buildDashboard()
        } else {
            asp_buildGuestState()
        }
    }

    // MARK: - Guest (logged-out) state

    private func asp_buildGuestState() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let logo = UIImageView(image: UIImage(systemName: "circle.hexagongrid.fill"))
        logo.tintColor = ASPTheme.Color.accent
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold)

        let title = UILabel()
        title.text = "AssetSphere Pro"
        title.font = ASPTheme.Font.largeTitle()
        title.textColor = ASPTheme.Color.textPrimary
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let welcome = UILabel()
        welcome.text = "Welcome. Track everything you own in one private, on-device vault."
        welcome.font = ASPTheme.Font.body()
        welcome.textColor = ASPTheme.Color.textSecondary
        welcome.textAlignment = .center
        welcome.numberOfLines = 0
        welcome.translatesAutoresizingMaskIntoConstraints = false

        let signIn = ASPPrimaryButton(title: "Sign In")
        signIn.addTarget(self, action: #selector(asp_signInTapped), for: .touchUpInside)

        let createAccount = ASPPrimaryButton(title: "Create Account", style: .glass)
        createAccount.addTarget(self, action: #selector(asp_createAccountTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [logo, title, welcome])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        let buttonStack = UIStackView(arrangedSubviews: [signIn, createAccount])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            logo.heightAnchor.constraint(equalToConstant: 80),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 60),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            buttonStack.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 40),
            buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        contentStack.addArrangedSubview(container)
    }

    // MARK: - Dashboard (logged-in) state

    private func asp_buildDashboard() {
        asp_addWelcomeBanner()        // Module 1
        asp_addProfileSummary()       // Module 2
        asp_addAssetOverview()        // Module 3
        asp_addQuickActions()         // Module 4
        asp_addRecentAssets()         // Module 5
        asp_addStatisticsPreview()    // Module 6
        asp_addRecentActivities()     // Module 7
        asp_addStorageOverview()      // Module 8
    }

    // Module 1 — Welcome Banner
    private func asp_addWelcomeBanner() {
        let banner = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        banner.translatesAutoresizingMaskIntoConstraints = false

        let accent = ASPGradientView(colors: ASPTheme.Gradient.accent,
                                     start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.alpha = 0.22
        banner.contentView.addSubview(accent)
        accent.asp_pinEdges(to: banner.contentView)

        let greeting = UILabel()
        greeting.text = asp_greetingText()
        greeting.font = ASPTheme.Font.caption()
        greeting.textColor = ASPTheme.Color.textSecondary
        greeting.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel()
        name.text = ASPUserManager.shared.currentUser?.username ?? "Welcome"
        name.font = ASPTheme.Font.title()
        name.textColor = ASPTheme.Color.textPrimary
        name.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Here's your portfolio at a glance."
        sub.font = ASPTheme.Font.body()
        sub.textColor = ASPTheme.Color.textSecondary
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        [greeting, name, sub].forEach { banner.contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            greeting.topAnchor.constraint(equalTo: banner.contentView.topAnchor, constant: 20),
            greeting.leadingAnchor.constraint(equalTo: banner.contentView.leadingAnchor, constant: 20),
            name.topAnchor.constraint(equalTo: greeting.bottomAnchor, constant: 4),
            name.leadingAnchor.constraint(equalTo: banner.contentView.leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(lessThanOrEqualTo: banner.contentView.trailingAnchor, constant: -20),
            sub.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 6),
            sub.leadingAnchor.constraint(equalTo: banner.contentView.leadingAnchor, constant: 20),
            sub.trailingAnchor.constraint(equalTo: banner.contentView.trailingAnchor, constant: -20),
            sub.bottomAnchor.constraint(equalTo: banner.contentView.bottomAnchor, constant: -20)
        ])
        contentStack.addArrangedSubview(banner)
    }

    // Module 2 — Profile Summary
    private func asp_addProfileSummary() {
        guard let user = ASPUserManager.shared.currentUser else { return }
        let card = ASPProfileCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let image = ASPStorageManager.shared.asp_loadAssetImage(user.avatar)
        let storage = ASPFormat.bytes(ASPStorageManager.shared.asp_totalStorageBytes())
        card.asp_configure(user: user, assetCount: ASPAssetManager.shared.asp_count,
                           storage: storage, image: image)
        contentStack.addArrangedSubview(card)
    }

    // Module 3 — Asset Overview
    private func asp_addAssetOverview() {
        let header = ASPHeaderView()
        header.asp_configure(title: "Asset Overview")
        contentStack.addArrangedSubview(header)

        let row = UIStackView(arrangedSubviews: [overviewAssetsCard, overviewValueCard, overviewCategoriesCard])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 120).isActive = true

        overviewAssetsCard.asp_configure(icon: "shippingbox.fill",
                                         value: Double(ASPStatisticsManager.shared.asp_totalAssets),
                                         title: "Total Assets", isCurrency: false)
        overviewValueCard.asp_configure(icon: "dollarsign.circle.fill",
                                        value: ASPStatisticsManager.shared.asp_totalValue,
                                        title: "Total Value", isCurrency: true,
                                        gradient: ASPTheme.Gradient.positive)
        overviewCategoriesCard.asp_configure(icon: "square.grid.2x2.fill",
                                             value: Double(ASPStatisticsManager.shared.asp_categoriesUsed),
                                             title: "Categories", isCurrency: false,
                                             gradient: ASPTheme.Gradient.warm)
        contentStack.addArrangedSubview(row)
    }

    // Module 4 — Quick Actions
    private func asp_addQuickActions() {
        let header = ASPHeaderView()
        header.asp_configure(title: "Quick Actions")
        contentStack.addArrangedSubview(header)

        let add = ASPQuickActionView()
        add.asp_configure(icon: "plus", title: "Add Asset", gradient: ASPTheme.Gradient.accent) { [weak self] in
            self?.asp_presentAddAsset()
        }
        let docs = ASPQuickActionView()
        docs.asp_configure(icon: "doc.text.fill", title: "Documents", gradient: ASPTheme.Gradient.positive) { [weak self] in
            self?.navigationController?.pushViewController(ASPDocumentCenterViewController(), animated: true)
        }
        let photos = ASPQuickActionView()
        photos.asp_configure(icon: "photo.fill", title: "Photos", gradient: ASPTheme.Gradient.warm) { [weak self] in
            self?.onSelectTab?(3)
        }
        let analytics = ASPQuickActionView()
        analytics.asp_configure(icon: "chart.bar.fill", title: "Analytics",
                                gradient: [ASPTheme.Color.accentSecondary.cgColor, ASPTheme.Color.accent.cgColor]) { [weak self] in
            self?.onSelectTab?(2)
        }

        let row = UIStackView(arrangedSubviews: [add, docs, photos, analytics])
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 104).isActive = true
        contentStack.addArrangedSubview(row)
    }

    // Module 5 — Recent Assets
    private func asp_addRecentAssets() {
        let header = ASPHeaderView()
        header.asp_configure(title: "Recent Assets", action: "View All") { [weak self] in
            self?.onSelectTab?(1)
        }
        contentStack.addArrangedSubview(header)

        let recents = ASPAssetManager.shared.asp_recent(limit: 6)
        if recents.isEmpty {
            contentStack.addArrangedSubview(asp_inlineEmpty(text: "No assets yet. Add your first one."))
            return
        }

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.heightAnchor.constraint(equalToConstant: 132).isActive = true

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(row)
        row.asp_pinEdges(to: scroll)
        row.heightAnchor.constraint(equalTo: scroll.heightAnchor).isActive = true

        for asset in recents {
            let tile = ASPRecentAssetView()
            tile.widthAnchor.constraint(equalToConstant: 140).isActive = true
            let image = ASPStorageManager.shared.asp_loadAssetImage(asset.assetImagePath)
            tile.asp_configure(asset: asset, image: image) { [weak self] in
                self?.asp_presentDetail(asset)
            }
            row.addArrangedSubview(tile)
        }
        recentAssetsCarousel = row
        contentStack.addArrangedSubview(scroll)
    }

    // Module 6 — Statistics Preview
    private func asp_addStatisticsPreview() {
        let header = ASPHeaderView()
        header.asp_configure(title: "Statistics Preview", action: "Details") { [weak self] in
            self?.onSelectTab?(2)
        }
        contentStack.addArrangedSubview(header)

        let card = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        card.translatesAutoresizingMaskIntoConstraints = false

        let chart = ASPChartView()
        let trend = ASPStatisticsManager.shared.asp_monthlyTrend(months: 6)
        chart.asp_configure(values: trend.map { $0.total }, labels: trend.map { $0.label })
        card.contentView.addSubview(chart)

        let caption = UILabel()
        caption.text = "Portfolio value trend (last 6 months)"
        caption.font = ASPTheme.Font.caption()
        caption.textColor = ASPTheme.Color.textSecondary
        caption.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(caption)

        NSLayoutConstraint.activate([
            caption.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 16),
            caption.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 18),
            chart.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 12),
            chart.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 18),
            chart.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -18),
            chart.heightAnchor.constraint(equalToConstant: 140),
            chart.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -18)
        ])
        contentStack.addArrangedSubview(card)
    }

    // Module 7 — Recent Activities
    private func asp_addRecentActivities() {
        let header = ASPHeaderView()
        header.asp_configure(title: "Recent Activities", action: "Timeline") { [weak self] in
            self?.navigationController?.pushViewController(ASPTimelineViewController(), animated: true)
        }
        contentStack.addArrangedSubview(header)

        let activities = ASPActivityManager.shared.asp_allActivities(limit: 4)
        if activities.isEmpty {
            contentStack.addArrangedSubview(asp_inlineEmpty(text: "No activity recorded yet."))
            return
        }
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        for activity in activities {
            let card = ASPActivityCardView()
            card.asp_configure(activity: activity)
            stack.addArrangedSubview(card)
        }
        activitiesStack = stack
        contentStack.addArrangedSubview(stack)
    }

    // Module 8 — Storage Overview
    private func asp_addStorageOverview() {
        storageCard.translatesAutoresizingMaskIntoConstraints = false
        storageCard.asp_configure(
            totalBytes: ASPStorageManager.shared.asp_totalStorageBytes(),
            assetImages: ASPAssetManager.shared.asp_all().filter { $0.assetImagePath != nil }.count,
            documents: ASPStorageManager.shared.asp_documentCount,
            photos: ASPStorageManager.shared.asp_photoCount)
        contentStack.addArrangedSubview(storageCard)
    }

    // MARK: - Helpers

    private func asp_inlineEmpty(text: String) -> UIView {
        let card = ASPGlassCardView(cornerRadius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = text
        label.font = ASPTheme.Font.body()
        label.textColor = ASPTheme.Color.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 22),
            label.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -22),
            label.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -18)
        ])
        return card
    }

    private func asp_greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<22: return "GOOD EVENING"
        default:      return "WELCOME BACK"
        }
    }

    private func asp_presentAddAsset() {
//        let vc = ASPAddAssetViewController()
//        vc.onSaved = { [weak self] in self?.asp_rebuild() }
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
    }

    private func asp_presentDetail(_ asset: ASPAssetModel) {
//        let vc = ASPAssetDetailViewController(asset: asset)
//        vc.onChanged = { [weak self] in self?.asp_rebuild() }
//        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions

    @objc private func asp_signInTapped() { onRequestSignOut?() }

    @objc private func asp_createAccountTapped() { onRequestSignOut?() }
}
