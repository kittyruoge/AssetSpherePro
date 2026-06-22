//
//  ASPCategoryCardView.swift
//  AssetSpherePro
//
//  A row representing a category in the category-management screen: icon,
//  name, asset count, and total value.
//

import UIKit

final class ASPCategoryCardView: ASPGlassCardView {

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView()

    init() {
        super.init(cornerRadius: 20)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.cornerRadius = 20
        iconBackground.clipsToBounds = true
        contentView.addSubview(iconBackground)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconBackground.addSubview(iconView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = ASPTheme.Font.bodyMedium()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        contentView.addSubview(nameLabel)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = ASPTheme.Font.caption()
        countLabel.textColor = ASPTheme.Color.textSecondary
        contentView.addSubview(countLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = ASPTheme.Font.mono(16)
        valueLabel.textColor = ASPTheme.Color.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(valueLabel)

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = ASPTheme.Color.textTertiary
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        contentView.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 40),
            iconBackground.heightAnchor.constraint(equalToConstant: 40),
            iconBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: iconBackground.topAnchor, constant: 1),

            countLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            chevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8)
        ])
    }

    func asp_configure(category: String, count: Int, totalValue: Double) {
        let color = ASPTheme.Color.category(category)
        iconBackground.backgroundColor = color
        iconView.image = UIImage(systemName: ASPCategory.symbol(for: category))
        nameLabel.text = category
        countLabel.text = count == 1 ? "1 asset" : "\(count) assets"
        valueLabel.text = ASPFormat.currency(totalValue)
    }
}
