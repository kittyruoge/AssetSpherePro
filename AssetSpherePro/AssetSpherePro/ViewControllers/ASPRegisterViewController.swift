//
//  ASPRegisterViewController.swift
//  AssetSpherePro
//
//  Local account creation.
//

import UIKit

final class ASPRegisterViewController: ASPBaseViewController {

    /// Called with the new account's email on successful registration.
    var onRegistered: ((String) -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let usernameField = ASPTextField(icon: "person.fill", placeholder: "Your name", caption: "USERNAME")
    private let emailField = ASPTextField(icon: "envelope.fill", placeholder: "you@example.com", caption: "EMAIL")
    private let passwordField = ASPTextField(icon: "lock.fill", placeholder: "At least 6 characters", caption: "PASSWORD", isSecure: true)
    private let confirmField = ASPTextField(icon: "lock.rotation", placeholder: "Re-enter password", caption: "CONFIRM PASSWORD", isSecure: true)
    private let createButton = ASPPrimaryButton(title: "Create Account")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        navigationItem.largeTitleDisplayMode = .never
        asp_buildUI()
    }

    private func asp_buildUI() {
        let stack = asp_makeScrollingStack(topInset: 16, spacing: 16)

        titleLabel.text = "Create Account"
        titleLabel.font = ASPTheme.Font.title()
        titleLabel.textColor = ASPTheme.Color.textPrimary

        subtitleLabel.text = "Set up your personal asset vault"
        subtitleLabel.font = ASPTheme.Font.body()
        subtitleLabel.textColor = ASPTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0

        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no

        createButton.addTarget(self, action: #selector(asp_createTapped), for: .touchUpInside)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        stack.setCustomSpacing(24, after: subtitleLabel)
        [usernameField, emailField, passwordField, confirmField].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(24, after: confirmField)
        stack.addArrangedSubview(createButton)
    }

    @objc private func asp_createTapped() {
        view.endEditing(true)
        guard passwordField.text == confirmField.text else {
            asp_showAlert(title: "Passwords Don't Match",
                          message: "Please make sure both password fields are identical.")
            return
        }

        createButton.asp_setLoading(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.createButton.asp_setLoading(false)
            let result = ASPUserManager.shared.asp_register(
                username: self.usernameField.text,
                email: self.emailField.text,
                password: self.passwordField.text)
            switch result {
            case .success:
                let email = self.emailField.text.asp_trimmed.lowercased()
                self.navigationController?.popViewController(animated: true)
                self.onRegistered?(email)
            case .emailTaken:
                self.asp_showAlert(title: "Email In Use",
                                   message: "An account with this email already exists. Try signing in instead.")
            case .invalid(let message):
                self.asp_showAlert(title: "Check Your Details", message: message)
            }
        }
    }
}
