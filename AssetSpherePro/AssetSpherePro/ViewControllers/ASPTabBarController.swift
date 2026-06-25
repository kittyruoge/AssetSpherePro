//
//  ASPTabBarController.swift
//  AssetSpherePro
//
//  The main interface: 5 tabs — Home, Assets, Analytics, Vault, Settings.
//  Styled with a translucent dark appearance to match the glass aesthetic.
//

import UIKit

final class ASPTabBarController: UITabBarController {

    /// Invoked when the user signs out from the Settings tab.
    var onSignOut: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        asp_setupAppearance()
        asp_setupTabs()
    }

    private func asp_setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = ASPTheme.Color.backgroundBottom.withAlphaComponent(0.4)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = ASPTheme.Color.textTertiary
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: ASPTheme.Color.textTertiary]
        itemAppearance.selected.iconColor = ASPTheme.Color.accent
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: ASPTheme.Color.accent]
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = ASPTheme.Color.accent
    }

    private func asp_setupTabs() {
        let home = ASPHomeViewController()
        home.onRequestSignOut = { [weak self] in self?.onSignOut?() }
        home.onSelectTab = { [weak self] index in self?.selectedIndex = index }

        let assets = ASPAssetListViewController()
        let analytics = ASPAnalyticsViewController()
        let vault = ASPPhotoVaultViewController()

        let settings = ASPSettingsViewController()
        settings.onSignOut = { [weak self] in self?.onSignOut?() }

        viewControllers = [
            asp_wrap(home, title: "Home", icon: "house.fill"),
            asp_wrap(assets, title: "Assets", icon: "shippingbox.fill"),
            asp_wrap(analytics, title: "Analytics", icon: "chart.bar.fill"),
            asp_wrap(vault, title: "Vault", icon: "lock.shield.fill"),
            asp_wrap(settings, title: "Settings", icon: "gearshape.fill")
        ]
    }

    private func asp_wrap(_ vc: UIViewController, title: String, icon: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: nil)
        vc.title = title

        // Match the navigation bar to the dark glass aesthetic.
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        navAppearance.titleTextAttributes = [.foregroundColor: ASPTheme.Color.textPrimary]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: ASPTheme.Color.textPrimary]
        nav.navigationBar.standardAppearance = navAppearance
        nav.navigationBar.scrollEdgeAppearance = navAppearance
        nav.navigationBar.tintColor = ASPTheme.Color.accent
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
}
