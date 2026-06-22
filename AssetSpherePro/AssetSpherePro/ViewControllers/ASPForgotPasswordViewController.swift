//
//  ASPForgotPasswordViewController.swift
//  AssetSpherePro
//
//  Local password reset simulation — no real email is sent. The user enters
//  their account email and a new password, which overwrites the Keychain value.
//

import UIKit

final class ASPForgotPasswordViewController: ASPBaseViewController {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailField = ASPTextField(icon: "envelope.fill", placeholder: "you@example.com", caption: "ACCOUNT EMAIL")
    private let passwordField = ASPTextField(icon: "lock.fill", placeholder: "At least 6 characters", caption: "NEW PASSWORD", isSecure: true)
    private let confirmField = ASPTextField(icon: "lock.rotation", placeholder: "Re-enter password", caption: "CONFIRM PASSWORD", isSecure: true)
    private let resetButton = ASPPrimaryButton(title: "Reset Password")
    private let noteLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reset Password"
        navigationItem.largeTitleDisplayMode = .never
        asp_buildUI()
    }

    private func asp_buildUI() {
        let stack = asp_makeScrollingStack(topInset: 16, spacing: 16)

        titleLabel.text = "Forgot Password"
        titleLabel.font = ASPTheme.Font.title()
        titleLabel.textColor = ASPTheme.Color.textPrimary

        subtitleLabel.text = "Reset your password locally on this device."
        subtitleLabel.font = ASPTheme.Font.body()
        subtitleLabel.textColor = ASPTheme.Color.textSecondary
        subtitleLabel.numberOfLines = 0

        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no

        resetButton.addTarget(self, action: #selector(asp_resetTapped), for: .touchUpInside)

        noteLabel.text = "No email will be sent. Your new password is stored securely in the device Keychain."
        noteLabel.font = ASPTheme.Font.caption()
        noteLabel.textColor = ASPTheme.Color.textTertiary
        noteLabel.numberOfLines = 0
        noteLabel.textAlignment = .center

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        stack.setCustomSpacing(24, after: subtitleLabel)
        [emailField, passwordField, confirmField].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(24, after: confirmField)
        stack.addArrangedSubview(resetButton)
        stack.addArrangedSubview(noteLabel)
    }

    @objc private func asp_resetTapped() {
        view.endEditing(true)
        guard passwordField.text == confirmField.text else {
            asp_showAlert(title: "Passwords Don't Match",
                          message: "Please make sure both password fields are identical.")
            return
        }

        resetButton.asp_setLoading(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.resetButton.asp_setLoading(false)
            let result = ASPUserManager.shared.asp_resetPassword(
                email: self.emailField.text, newPassword: self.passwordField.text)
            switch result {
            case .success:
                self.asp_showAlert(title: "Password Reset",
                                   message: "Your password has been updated. You can now sign in.") {
                    self.navigationController?.popViewController(animated: true)
                }
            case .notFound:
                self.asp_showAlert(title: "Account Not Found",
                                   message: "We couldn't find an account with that email.")
            case .invalid(let message):
                self.asp_showAlert(title: "Check Your Details", message: message)
            }
        }
    }
}
