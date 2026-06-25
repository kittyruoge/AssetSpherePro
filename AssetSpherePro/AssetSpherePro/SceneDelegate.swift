//
//  SceneDelegate.swift
//  AssetSpherePro
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        self.window = window

        // Restore a remembered session, then show the appropriate interface.
        ASPUserManager.shared.asp_restoreSession()
        ASPRootCoordinator.shared.attach(to: window)

        window.makeKeyAndVisible()
    }
}
