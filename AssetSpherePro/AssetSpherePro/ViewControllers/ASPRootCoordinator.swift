//
//  ASPRootCoordinator.swift
//  AssetSpherePro
//
//  Owns the window's root view controller and transitions between the
//  authentication flow and the main tab bar based on session state.
//

import UIKit

final class ASPRootCoordinator {

    static let shared = ASPRootCoordinator()

    private init() {}

    private weak var window: UIWindow?

    /// Attaches to the window and shows the correct initial interface.
    func attach(to window: UIWindow) {
        self.window = window
        if ASPUserManager.shared.asp_isLoggedIn {
            window.rootViewController = asp_makeMain()
        } else {
            window.rootViewController = asp_makeAuth()
        }
    }

    /// Switches to the main tab bar (after a successful login).
    func asp_showMain() {
        asp_transition(to: asp_makeMain())
    }

    /// Switches to the auth flow (after sign-out or from a guest entry point).
    func asp_showAuth() {
        asp_transition(to: asp_makeAuth())
    }

    // MARK: - Builders

    private func asp_makeMain() -> UIViewController {
        let tabBar = ASPTabBarController()
        tabBar.onSignOut = { [weak self] in self?.asp_showAuth() }
        return tabBar
    }

    private func asp_makeAuth() -> UIViewController {
        let login = ASPLoginViewController()
        login.onAuthenticated = { [weak self] in self?.asp_showMain() }

        let nav = UINavigationController(rootViewController: login)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: ASPTheme.Color.textPrimary]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = ASPTheme.Color.accent
        return nav
    }

    // MARK: - Transition

    private func asp_transition(to viewController: UIViewController) {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
            window.rootViewController = viewController
        }
    }
}
