//
//  ASPProfileCardView.swift
//  AssetSpherePro
//
//  Dashboard module: a glass card summarizing the user's profile — avatar,
//  username, asset count, storage usage, and last login.
//

import UIKit

final class ASPProfileCardView: ASPGlassCardView {

    private let avatarView = ASPAvatarView(diameter: 56)
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statsStack = UIStackView()

    init() {
        super.init(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        let topStack = UIStackView()
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.axis = .horizontal
        topStack.spacing = 14
        topStack.alignment = .center

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        nameLabel.font = ASPTheme.Font.headline()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        emailLabel.font = ASPTheme.Font.caption()
        emailLabel.textColor = ASPTheme.Color.textSecondary

        topStack.addArrangedSubview(avatarView)
        topStack.addArrangedSubview(nameStack)
        contentView.addSubview(topStack)

        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 8
        contentView.addSubview(statsStack)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),

            statsStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 18),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    func asp_configure(user: ASPUserModel, assetCount: Int, storage: String, image: UIImage?) {
        avatarView.asp_configure(username: user.username, image: image)
        nameLabel.text = user.username
        emailLabel.text = user.email

        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let lastLogin = user.lastLoginDate.map(ASPFormat.dateTime) ?? "—"
        statsStack.addArrangedSubview(Self.statBlock(value: "\(assetCount)", title: "Assets"))
        statsStack.addArrangedSubview(Self.statBlock(value: storage, title: "Storage"))
        statsStack.addArrangedSubview(Self.statBlock(value: lastLogin, title: "Last Login"))
    }

    private static func statBlock(value: String, title: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.font = ASPTheme.Font.captionMedium()
        valueLabel.textColor = ASPTheme.Color.textPrimary
        valueLabel.text = value
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        titleLabel.textColor = ASPTheme.Color.textTertiary
        titleLabel.text = title

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }
}
