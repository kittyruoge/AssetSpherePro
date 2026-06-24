//
//  ASPQuickActionView.swift
//  AssetSpherePro
//
//  A tappable glass tile representing a quick action (Add, Documents, Photos,
//  Analytics) on the home dashboard.
//

import UIKit

final class ASPQuickActionView: ASPGlassCardView {

    private let iconBackground = ASPGradientView(colors: ASPTheme.Gradient.accent)
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private var tapHandler: (() -> Void)?

    init() {
        super.init(cornerRadius: 22)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.cornerRadius = 22
        iconBackground.clipsToBounds = true
        contentView.addSubview(iconBackground)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconBackground.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.captionMedium()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconBackground.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 44),
            iconBackground.heightAnchor.constraint(equalToConstant: 44),
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(asp_tapped))
        addGestureRecognizer(tap)
    }

    func asp_configure(icon: String, title: String, gradient: [CGColor], handler: @escaping () -> Void) {
        iconView.image = UIImage(systemName: icon)
        iconBackground.asp_setColors(gradient)
        titleLabel.text = title
        tapHandler = handler
    }

    @objc private func asp_tapped() {
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.transform = .identity }
        }
        tapHandler?()
    }
}
