//
//  ASPEmptyView.swift
//  AssetSpherePro
//
//  A friendly empty-state placeholder with an icon, title, message, and an
//  optional call-to-action button.
//

import UIKit

final class ASPEmptyView: UIView {

    private let iconContainer = ASPGlassCardView(cornerRadius: 28)
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (() -> Void)?

    init() {
        super.init(frame: .zero)
        asp_setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup() {
        translatesAutoresizingMaskIntoConstraints = false

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainer)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = ASPTheme.Color.accent
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        iconContainer.contentView.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.headline()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = ASPTheme.Font.body()
        messageLabel.textColor = ASPTheme.Color.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = ASPTheme.Font.bodyMedium()
        actionButton.setTitleColor(ASPTheme.Color.accent, for: .normal)
        actionButton.addTarget(self, action: #selector(asp_actionTapped), for: .touchUpInside)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: topAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 88),
            iconContainer.heightAnchor.constraint(equalToConstant: 88),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func asp_configure(icon: String, title: String, message: String,
                       action: String? = nil, handler: (() -> Void)? = nil) {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        messageLabel.text = message
        actionButton.setTitle(action, for: .normal)
        actionButton.isHidden = (action == nil)
        actionHandler = handler
    }

    @objc private func asp_actionTapped() {
        actionHandler?()
    }
}
