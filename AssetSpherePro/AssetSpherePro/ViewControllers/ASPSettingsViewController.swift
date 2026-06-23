//
//  ASPSettingsViewController.swift
//  AssetSpherePro
//
//  App settings: profile entry, preferences (stored in UserDefaults), data
//  management, and sign-out.
//

import UIKit

final class ASPSettingsViewController: ASPBaseViewController {

    /// Called when the user signs out.
    var onSignOut: (() -> Void)?

    private var contentStack: UIStackView!

    private enum Keys {
        static let hapticsEnabled = "asp_haptics_enabled"
        static let animationsEnabled = "asp_animations_enabled"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        contentStack = asp_makeScrollingStack(topInset: 12, spacing: ASPTheme.Layout.cardSpacing)
        asp_build()
    }

    private func asp_build() {
        // Account section.
        asp_sectionHeader("ACCOUNT")
        let accountCard = asp_card()
        let accountStack = asp_stack(in: accountCard)

        if ASPUserManager.shared.isGuest {
            // Guest session: invite the user to sign in or register instead of
            // showing a profile entry.
            let signInItem = ASPSettingItemView()
            signInItem.asp_configure(icon: "person.crop.circle.badge.plus", iconColor: ASPTheme.Color.accent,
                                     title: "Sign In or Register", value: "Guest") { [weak self] in
                self?.asp_promptSignIn()
            }
            accountStack.addArrangedSubview(signInItem)
        } else if let user = ASPUserManager.shared.currentUser {
            let profileItem = ASPSettingItemView()
            profileItem.asp_configure(icon: "person.crop.circle.fill", iconColor: ASPTheme.Color.accent,
                                      title: user.username, value: "Profile") { [weak self] in
                let profile = ASPProfileViewController()
                profile.onAccountDeleted = { [weak self] in self?.onSignOut?() }
                self?.navigationController?.pushViewController(profile, animated: true)
            }
            accountStack.addArrangedSubview(profileItem)
        }
        contentStack.addArrangedSubview(accountCard)

        // Preferences section.
        asp_sectionHeader("PREFERENCES")
        let prefsCard = asp_card()
        let prefsStack = asp_stack(in: prefsCard)

        let haptics = ASPSettingItemView()
        haptics.asp_configureToggle(icon: "iphone.radiowaves.left.and.right", iconColor: ASPTheme.Color.accentSecondary,
                                    title: "Haptic Feedback",
                                    isOn: UserDefaults.standard.object(forKey: Keys.hapticsEnabled) as? Bool ?? true) { on in
            UserDefaults.standard.set(on, forKey: Keys.hapticsEnabled)
            if on { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        }
        let animations = ASPSettingItemView()
        animations.asp_configureToggle(icon: "sparkles", iconColor: ASPTheme.Color.accentPink,
                                       title: "Number Animations",
                                       isOn: UserDefaults.standard.object(forKey: Keys.animationsEnabled) as? Bool ?? true) { on in
            UserDefaults.standard.set(on, forKey: Keys.animationsEnabled)
        }
        prefsStack.addArrangedSubview(haptics)
        prefsStack.addArrangedSubview(asp_separator())
        prefsStack.addArrangedSubview(animations)
        contentStack.addArrangedSubview(prefsCard)

        // Data section.
        asp_sectionHeader("DATA")
        let dataCard = asp_card()
        let dataStack = asp_stack(in: dataCard)

        let categories = ASPSettingItemView()
        categories.asp_configure(icon: "square.grid.2x2.fill", iconColor: ASPTheme.Color.accent,
                                 title: "Manage Categories") { [weak self] in
            self?.navigationController?.pushViewController(ASPCategoryViewController(), animated: true)
        }
        let documents = ASPSettingItemView()
        documents.asp_configure(icon: "doc.text.fill", iconColor: ASPTheme.Color.positive,
                                title: "Documents") { [weak self] in
            self?.navigationController?.pushViewController(ASPDocumentCenterViewController(), animated: true)
        }
        let storage = ASPSettingItemView()
        storage.asp_configure(icon: "internaldrive.fill", iconColor: ASPTheme.Color.warning,
                              title: "Storage Used",
                              value: ASPFormat.bytes(ASPStorageManager.shared.asp_totalStorageBytes()))
        dataStack.addArrangedSubview(categories)
        dataStack.addArrangedSubview(asp_separator())
        dataStack.addArrangedSubview(documents)
        dataStack.addArrangedSubview(asp_separator())
        dataStack.addArrangedSubview(storage)
        contentStack.addArrangedSubview(dataCard)

        // About section.
        asp_sectionHeader("ABOUT")
        let aboutCard = asp_card()
        let aboutStack = asp_stack(in: aboutCard)
        let about = ASPSettingItemView()
        about.asp_configure(icon: "info.circle.fill", iconColor: ASPTheme.Color.accentSecondary,
                            title: "About AssetSphere Pro") { [weak self] in
            self?.navigationController?.pushViewController(ASPAboutViewController(), animated: true)
        }
        let privacy = ASPSettingItemView()
        privacy.asp_configure(icon: "hand.raised.fill", iconColor: ASPTheme.Color.accent,
                              title: "Privacy Policy") { [weak self] in
            self?.navigationController?.pushViewController(ASPPrivacyPolicyViewController(), animated: true)
        }
        aboutStack.addArrangedSubview(about)
        aboutStack.addArrangedSubview(asp_separator())
        aboutStack.addArrangedSubview(privacy)
        contentStack.addArrangedSubview(aboutCard)

        // Sign out / exit guest mode.
        let isGuest = ASPUserManager.shared.isGuest
        let signOut = ASPPrimaryButton(title: isGuest ? "Exit Guest Mode" : "Sign Out", style: .glass)
        signOut.addTarget(self, action: #selector(asp_signOutTapped), for: .touchUpInside)
        contentStack.setCustomSpacing(28, after: aboutCard)
        contentStack.addArrangedSubview(signOut)
    }

    // MARK: - Builders

    private func asp_sectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = ASPTheme.Font.captionMedium()
        label.textColor = ASPTheme.Color.textTertiary
        contentStack.addArrangedSubview(label)
        contentStack.setCustomSpacing(6, after: label)
    }

    private func asp_card() -> ASPGlassCardView {
        let card = ASPGlassCardView(cornerRadius: 18)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    private func asp_stack(in card: ASPGlassCardView) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        stack.asp_pinEdges(to: card.contentView, inset: 6)
        return stack
    }

    private func asp_separator() -> UIView {
        let line = UIView()
        line.backgroundColor = ASPTheme.Color.glassFillStrong
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    @objc private func asp_signOutTapped() {
        let isGuest = ASPUserManager.shared.isGuest
        let title = isGuest ? "Exit Guest Mode" : "Sign Out"
        let message = isGuest
            ? "Leave guest mode and return to the sign-in screen?"
            : "Are you sure you want to sign out?"
        asp_showConfirm(title: title, message: message, confirmTitle: title) { [weak self] in
            ASPUserManager.shared.asp_logout()
            self?.onSignOut?()
        }
    }

    /// Leaves guest mode and returns to the sign-in screen so the user can
    /// sign in or register.
    private func asp_promptSignIn() {
        asp_showConfirm(title: "Sign In or Register",
                        message: "Leave guest mode and go to the sign-in screen?",
                        confirmTitle: "Continue") { [weak self] in
            ASPUserManager.shared.asp_logout()
            self?.onSignOut?()
        }
    }
}
