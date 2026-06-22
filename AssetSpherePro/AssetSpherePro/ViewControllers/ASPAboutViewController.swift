//
//  ASPAboutViewController.swift
//  AssetSpherePro
//
//  About screen: app/build version, storage usage, and database info.
//

import UIKit

final class ASPAboutViewController: ASPBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        navigationItem.largeTitleDisplayMode = .never
        asp_build()
    }

    private func asp_build() {
        let stack = asp_makeScrollingStack(topInset: 24, spacing: 16)

        // Logo + name.
        let logo = UIImageView(image: UIImage(systemName: "circle.hexagongrid.fill"))
        logo.tintColor = ASPTheme.Color.accent
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold)
        logo.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let name = UILabel()
        name.text = "AssetSphere Pro"
        name.font = ASPTheme.Font.title()
        name.textColor = ASPTheme.Color.textPrimary
        name.textAlignment = .center

        let tagline = UILabel()
        tagline.text = "Your private, on-device asset manager."
        tagline.font = ASPTheme.Font.body()
        tagline.textColor = ASPTheme.Color.textSecondary
        tagline.textAlignment = .center
        tagline.numberOfLines = 0

        stack.addArrangedSubview(logo)
        stack.addArrangedSubview(name)
        stack.addArrangedSubview(tagline)
        stack.setCustomSpacing(28, after: tagline)

        // Version info.
        let versionCard = ASPInfoCardView()
        versionCard.translatesAutoresizingMaskIntoConstraints = false
        versionCard.asp_configure(rows: [
            ("App Version", Self.appVersion),
            ("Build", Self.buildVersion),
            ("Platform", "iOS \(UIDevice.current.systemVersion)")
        ])
        stack.addArrangedSubview(versionCard)

        // Storage / database info.
        let dbHeader = ASPHeaderView()
        dbHeader.asp_configure(title: "Database")
        stack.addArrangedSubview(dbHeader)

        let dbCard = ASPInfoCardView()
        dbCard.translatesAutoresizingMaskIntoConstraints = false
        dbCard.asp_configure(rows: [
            ("Storage Used", ASPFormat.bytes(ASPStorageManager.shared.asp_totalStorageBytes())),
            ("Assets", "\(ASPAssetManager.shared.asp_count)"),
            ("Documents", "\(ASPStorageManager.shared.asp_documentCount)"),
            ("Photos", "\(ASPStorageManager.shared.asp_photoCount)"),
            ("Activities", "\(ASPActivityManager.shared.asp_count)"),
            ("Engine", "Core Data")
        ])
        stack.addArrangedSubview(dbCard)

        // Privacy Policy link.
        let privacyButton = ASPPrimaryButton(title: "Privacy Policy", style: .glass)
        privacyButton.addTarget(self, action: #selector(asp_privacyTapped), for: .touchUpInside)
        stack.setCustomSpacing(24, after: dbCard)
        stack.addArrangedSubview(privacyButton)

        // Footer.
        let footer = UILabel()
        footer.text = "All data is stored locally on this device.\nNo account data leaves your iPhone."
        footer.font = ASPTheme.Font.caption()
        footer.textColor = ASPTheme.Color.textTertiary
        footer.textAlignment = .center
        footer.numberOfLines = 0
        stack.setCustomSpacing(28, after: privacyButton)
        stack.addArrangedSubview(footer)
    }

    @objc private func asp_privacyTapped() {
        navigationController?.pushViewController(ASPPrivacyPolicyViewController(), animated: true)
    }

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private static var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
