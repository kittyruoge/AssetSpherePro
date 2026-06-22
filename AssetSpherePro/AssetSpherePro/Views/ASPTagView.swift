//
//  ASPTagView.swift
//  AssetSpherePro
//
//  A small pill-shaped tag used to display a category with its color.
//

import UIKit

final class ASPTagView: UIView {

    private let iconView = UIImageView()
    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        asp_setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 13
        layer.cornerCurve = .continuous
        clipsToBounds = true

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        addSubview(iconView)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ASPTheme.Font.captionMedium()
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 26),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 12),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Configures the tag for a category name.
    func asp_configure(category: String) {
        let color = ASPTheme.Color.category(category)
        iconView.image = UIImage(systemName: ASPCategory.symbol(for: category))
        iconView.tintColor = color
        label.text = category
        label.textColor = color
        backgroundColor = color.withAlphaComponent(0.16)
    }

    /// Configures the tag with arbitrary text and color.
    func asp_configure(text: String, color: UIColor, symbol: String? = nil) {
        if let symbol = symbol {
            iconView.image = UIImage(systemName: symbol)
            iconView.tintColor = color
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }
        label.text = text
        label.textColor = color
        backgroundColor = color.withAlphaComponent(0.16)
    }
}
