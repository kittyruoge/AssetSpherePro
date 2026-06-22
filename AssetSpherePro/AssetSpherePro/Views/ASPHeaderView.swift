//
//  ASPHeaderView.swift
//  AssetSpherePro
//
//  A large section header with a title and optional subtitle/trailing action.
//

import UIKit

final class ASPHeaderView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (() -> Void)?

    init() {
        super.init(frame: .zero)
        asp_setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup() {
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.headline()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = ASPTheme.Font.caption()
        subtitleLabel.textColor = ASPTheme.Color.textSecondary
        addSubview(subtitleLabel)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = ASPTheme.Font.captionMedium()
        actionButton.setTitleColor(ASPTheme.Color.accent, for: .normal)
        actionButton.addTarget(self, action: #selector(asp_actionTapped), for: .touchUpInside)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }

    func asp_configure(title: String, subtitle: String? = nil, action: String? = nil, handler: (() -> Void)? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil)
        actionButton.setTitle(action, for: .normal)
        actionButton.isHidden = (action == nil)
        actionHandler = handler
    }

    @objc private func asp_actionTapped() {
        actionHandler?()
    }
}
