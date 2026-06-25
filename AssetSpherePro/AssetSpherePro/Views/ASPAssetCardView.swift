//
//  ASPAssetCardView.swift
//  AssetSpherePro
//
//  A glass card representing a single asset in the asset list — thumbnail or
//  category glyph, name, category tag, value, and a favorite indicator.
//

import UIKit

final class ASPAssetCardView: ASPGlassCardView {

    private let thumbBackground = ASPGradientView(colors: ASPTheme.Gradient.accent)
    private let thumbImageView = UIImageView()
    private let glyphView = UIImageView()
    private let nameLabel = UILabel()
    private let tagView = ASPTagView()
    private let valueLabel = UILabel()
    private let favoriteView = UIImageView()

    init() {
        super.init(cornerRadius: 22)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        thumbBackground.translatesAutoresizingMaskIntoConstraints = false
        thumbBackground.layer.cornerRadius = 16
        thumbBackground.clipsToBounds = true
        contentView.addSubview(thumbBackground)

        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 16
        thumbImageView.isHidden = true
        contentView.addSubview(thumbImageView)

        glyphView.translatesAutoresizingMaskIntoConstraints = false
        glyphView.contentMode = .scaleAspectFit
        glyphView.tintColor = .white
        glyphView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        thumbBackground.addSubview(glyphView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = ASPTheme.Font.bodyMedium()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)

        contentView.addSubview(tagView)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = ASPTheme.Font.mono(18)
        valueLabel.textColor = ASPTheme.Color.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(valueLabel)

        favoriteView.translatesAutoresizingMaskIntoConstraints = false
        favoriteView.image = UIImage(systemName: "star.fill")
        favoriteView.tintColor = ASPTheme.Color.warning
        favoriteView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        contentView.addSubview(favoriteView)

        NSLayoutConstraint.activate([
            thumbBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            thumbBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbBackground.widthAnchor.constraint(equalToConstant: 52),
            thumbBackground.heightAnchor.constraint(equalToConstant: 52),
            thumbBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            thumbBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            thumbImageView.leadingAnchor.constraint(equalTo: thumbBackground.leadingAnchor),
            thumbImageView.trailingAnchor.constraint(equalTo: thumbBackground.trailingAnchor),
            thumbImageView.topAnchor.constraint(equalTo: thumbBackground.topAnchor),
            thumbImageView.bottomAnchor.constraint(equalTo: thumbBackground.bottomAnchor),

            glyphView.centerXAnchor.constraint(equalTo: thumbBackground.centerXAnchor),
            glyphView.centerYAnchor.constraint(equalTo: thumbBackground.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: thumbBackground.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: thumbBackground.topAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),

            favoriteView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6),
            favoriteView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            tagView.leadingAnchor.constraint(equalTo: thumbBackground.trailingAnchor, constant: 12),
            tagView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),

            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func asp_configure(asset: ASPAssetModel, image: UIImage?) {
        nameLabel.text = asset.assetName
        tagView.asp_configure(category: asset.assetCategory)
        valueLabel.text = ASPFormat.currency(asset.assetValue)
        favoriteView.isHidden = !asset.isFavorite

        let color = ASPTheme.Color.category(asset.assetCategory)
        thumbBackground.asp_setColors([color.cgColor, color.withAlphaComponent(0.6).cgColor])
        glyphView.image = UIImage(systemName: ASPCategory.symbol(for: asset.assetCategory))

        if let image = image {
            thumbImageView.image = image
            thumbImageView.isHidden = false
            glyphView.isHidden = true
        } else {
            thumbImageView.isHidden = true
            glyphView.isHidden = false
        }
    }
}
