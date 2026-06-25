//
//  ASPPrivacyPolicyViewController.swift
//  AssetSpherePro
//
//  Renders the app's privacy policy as styled sections inside the shared
//  glass/dark layout. Reachable from the login screen, Settings, and About.
//

import UIKit

final class ASPPrivacyPolicyViewController: ASPBaseViewController {

    /// A single rendered block of the policy document.
    private enum Block {
        case title(String)
        case meta(String)
        case heading(String)
        case body(String)
        case bullet(String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy Policy"
        navigationItem.largeTitleDisplayMode = .never
        asp_build()
    }

    private func asp_build() {
        let stack = asp_makeScrollingStack(topInset: 12, spacing: 0)

        for block in Self.content {
            let view = makeView(for: block)
            stack.addArrangedSubview(view)
            // Per-block spacing so headings breathe and bullets stay tight.
            switch block {
            case .title:   stack.setCustomSpacing(2, after: view)
            case .meta:    stack.setCustomSpacing(22, after: view)
            case .heading: stack.setCustomSpacing(8, after: view)
            case .body:    stack.setCustomSpacing(14, after: view)
            case .bullet:  stack.setCustomSpacing(6, after: view)
            }
        }
    }

    // MARK: - Block rendering

    private func makeView(for block: Block) -> UIView {
        switch block {
        case .title(let text):
            return label(text, font: ASPTheme.Font.title(), color: ASPTheme.Color.textPrimary)
        case .meta(let text):
            return label(text, font: ASPTheme.Font.caption(), color: ASPTheme.Color.textTertiary)
        case .heading(let text):
            return label(text, font: ASPTheme.Font.headline(), color: ASPTheme.Color.textPrimary)
        case .body(let text):
            return label(text, font: ASPTheme.Font.body(), color: ASPTheme.Color.textSecondary)
        case .bullet(let text):
            return bulletRow(text)
        }
    }

    private func label(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func bulletRow(_ text: String) -> UIView {
        let container = UIView()

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = ASPTheme.Color.accent
        dot.layer.cornerRadius = 3
        container.addSubview(dot)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = ASPTheme.Font.body()
        label.textColor = ASPTheme.Color.textSecondary
        label.numberOfLines = 0
        container.addSubview(label)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            dot.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    // MARK: - Content

    private static let content: [Block] = [
        .title("Privacy Policy"),
        .meta("Last Updated: June 2026"),
        .body("AssetSphere Pro (\"the App\") respects your privacy and is committed to protecting your personal information."),

        .heading("Information We Collect"),
        .body("AssetSphere Pro is designed to operate primarily on your device."),
        .body("The App may store information that you voluntarily create, including:"),
        .bullet("Asset records"),
        .bullet("Notes"),
        .bullet("Photos"),
        .bullet("Documents"),
        .bullet("Account information created within the App"),
        .body("All such information is stored locally on your device."),

        .heading("Local Storage"),
        .body("AssetSphere Pro uses local device storage to save your information."),
        .body("This may include:"),
        .bullet("Core Data"),
        .bullet("UserDefaults"),
        .bullet("Keychain"),
        .body("Your information is not automatically transmitted to any external server."),

        .heading("No Account Verification"),
        .body("The App does not require online account verification."),
        .body("Any account created within the App is stored locally on your device and is used only for application functionality."),

        .heading("No Data Sharing"),
        .body("AssetSphere Pro does not sell, rent, trade, or share your personal information with third parties."),

        .heading("No Advertising"),
        .body("The App does not include third-party advertising services."),
        .body("The App does not use advertising identifiers for tracking purposes."),

        .heading("No Analytics Tracking"),
        .body("AssetSphere Pro does not use third-party analytics platforms to collect personal usage data."),

        .heading("Photos and Documents"),
        .body("If you choose to import photos or documents into the App, those files remain under your control and are stored locally on your device."),

        .heading("Data Security"),
        .body("Reasonable measures are used to protect information stored within the App."),
        .body("However, no storage method can be guaranteed to be completely secure."),
        .body("Users are responsible for maintaining the security of their devices."),

        .heading("Children's Privacy"),
        .body("AssetSphere Pro is not directed toward children under the age of 13."),
        .body("The App does not knowingly collect personal information from children."),

        .heading("Changes to This Policy"),
        .body("This Privacy Policy may be updated from time to time."),
        .body("Any changes will be reflected within the App."),

        .heading("Contact"),
        .body("If you have questions regarding this Privacy Policy, please contact the developer through the contact information provided in the App Store listing."),

        .heading("Consent"),
        .body("By using AssetSphere Pro, you acknowledge that you have read and understood this Privacy Policy.")
    ]
}
