//
//  ASPLoginViewController.swift
//  AssetSpherePro
//
//  Local sign-in. Validates against the Core Data user store and Keychain.
//

import UIKit

final class ASPLoginViewController: ASPBaseViewController {

    /// Called after a successful login so the app can swap to the main interface.
    var onAuthenticated: (() -> Void)?

    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailField = ASPTextField(icon: "envelope.fill", placeholder: "you@example.com", caption: "EMAIL")
    private let passwordField = ASPTextField(icon: "lock.fill", placeholder: "Your password", caption: "PASSWORD", isSecure: true)
    private let rememberToggle = UISwitch()
    private let rememberLabel = UILabel()
    private let loginButton = ASPPrimaryButton(title: "Login")
    private let registerButton = UIButton(type: .system)
    private let forgotButton = UIButton(type: .system)
    private let guestButton = ASPPrimaryButton(title: "Continue as Guest", style: .glass)
    private let privacyButton = UIButton(type: .system)

    private enum Keys { static let rememberedEmail = "asp_remembered_email" }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Skip", style: .plain, target: self, action: #selector(asp_guestTapped))
        navigationItem.rightBarButtonItem?.tintColor = ASPTheme.Color.textSecondary
        asp_buildUI()
        asp_prefillReviewHint()
    }

    private func asp_buildUI() {
        let stack = asp_makeScrollingStack(topInset: 40, spacing: 16)

        logoView.image = UIImage(systemName: "circle.hexagongrid.fill")
        logoView.tintColor = ASPTheme.Color.accent
        logoView.contentMode = .scaleAspectFit
        logoView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 56, weight: .bold)
        logoView.heightAnchor.constraint(equalToConstant: 72).isActive = true

        titleLabel.text = "Welcome Back"
        titleLabel.font = ASPTheme.Font.largeTitle()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Sign in to your AssetSphere"
        subtitleLabel.font = ASPTheme.Font.body()
        subtitleLabel.textColor = ASPTheme.Color.textSecondary
        subtitleLabel.textAlignment = .center

        emailField.textField.keyboardType = .emailAddress
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no

        // Remember-me row.
        rememberLabel.text = "Remember Me"
        rememberLabel.font = ASPTheme.Font.body()
        rememberLabel.textColor = ASPTheme.Color.textSecondary
        rememberToggle.onTintColor = ASPTheme.Color.accent
        rememberToggle.isOn = true
        let rememberRow = UIStackView(arrangedSubviews: [rememberLabel, UIView(), rememberToggle])
        rememberRow.axis = .horizontal
        rememberRow.alignment = .center

        loginButton.addTarget(self, action: #selector(asp_loginTapped), for: .touchUpInside)

        registerButton.setTitle("Create Account", for: .normal)
        registerButton.setTitleColor(ASPTheme.Color.accent, for: .normal)
        registerButton.titleLabel?.font = ASPTheme.Font.bodyMedium()
        registerButton.addTarget(self, action: #selector(asp_registerTapped), for: .touchUpInside)

        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.setTitleColor(ASPTheme.Color.textSecondary, for: .normal)
        forgotButton.titleLabel?.font = ASPTheme.Font.caption()
        forgotButton.addTarget(self, action: #selector(asp_forgotTapped), for: .touchUpInside)

        guestButton.addTarget(self, action: #selector(asp_guestTapped), for: .touchUpInside)

        // Privacy footer: consent line + tappable Privacy Policy link.
        let consentLabel = UILabel()
        consentLabel.text = "By continuing you acknowledge that you have read and understood our"
        consentLabel.font = ASPTheme.Font.caption()
        consentLabel.textColor = ASPTheme.Color.textTertiary
        consentLabel.textAlignment = .center
        consentLabel.numberOfLines = 0

        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(ASPTheme.Color.accent, for: .normal)
        privacyButton.titleLabel?.font = ASPTheme.Font.captionMedium()
        privacyButton.addTarget(self, action: #selector(asp_privacyTapped), for: .touchUpInside)

        [logoView, titleLabel, subtitleLabel].forEach { stack.addArrangedSubview($0) }
        stack.setCustomSpacing(28, after: subtitleLabel)
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.addArrangedSubview(rememberRow)
        stack.setCustomSpacing(24, after: rememberRow)
        stack.addArrangedSubview(loginButton)
        stack.addArrangedSubview(forgotButton)

        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.backgroundColor = ASPTheme.Color.glassFillStrong
        stack.addArrangedSubview(divider)
        stack.setCustomSpacing(20, after: divider)
        stack.addArrangedSubview(registerButton)
        stack.setCustomSpacing(12, after: registerButton)
        stack.addArrangedSubview(guestButton)

        // Privacy footer pinned below the actions.
        stack.setCustomSpacing(28, after: guestButton)
        stack.addArrangedSubview(consentLabel)
        stack.setCustomSpacing(2, after: consentLabel)
        stack.addArrangedSubview(privacyButton)
    }

    private func asp_prefillReviewHint() {
        // Pre-fill the remembered email if present for convenience.
        if let saved = UserDefaults.standard.string(forKey: Keys.rememberedEmail) {
            emailField.textField.text = saved
        }
    }

    // MARK: - Actions

    @objc private func asp_loginTapped() {
        view.endEditing(true)
        let email = emailField.text
        let password = passwordField.text

        loginButton.asp_setLoading(true)
        // Brief delay so the loading state is visible; logic is fully local.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.loginButton.asp_setLoading(false)
            let result = ASPUserManager.shared.asp_login(
                email: email, password: password, rememberMe: self.rememberToggle.isOn)
            switch result {
            case .success:
                if self.rememberToggle.isOn {
                    UserDefaults.standard.set(email.lowercased().asp_trimmed, forKey: Keys.rememberedEmail)
                }
                self.onAuthenticated?()
            case .wrongCredentials:
                self.asp_showAlert(title: "Sign In Failed",
                                   message: "The email or password is incorrect. Please try again.")
            case .invalid(let message):
                self.asp_showAlert(title: "Check Your Details", message: message)
            }
        }
    }

    @objc private func asp_registerTapped() {
        let vc = ASPRegisterViewController()
        vc.onRegistered = { [weak self] email in
            self?.emailField.textField.text = email
            self?.asp_showAlert(title: "Account Created",
                                message: "Your account is ready. Sign in to continue.")
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func asp_forgotTapped() {
        navigationController?.pushViewController(ASPForgotPasswordViewController(), animated: true)
    }

    @objc private func asp_guestTapped() {
        view.endEditing(true)
        ASPUserManager.shared.asp_continueAsGuest()
        onAuthenticated?()
    }

    @objc private func asp_privacyTapped() {
        navigationController?.pushViewController(ASPPrivacyPolicyViewController(), animated: true)
    }
}
