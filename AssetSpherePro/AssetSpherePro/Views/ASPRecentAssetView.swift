//
//  ASPRecentAssetView.swift
//  AssetSpherePro
//
//  A compact vertical tile for the home "Recent Assets" horizontal carousel.
//

import UIKit

final class ASPRecentAssetView: ASPGlassCardView {

    private let glyphBackground = ASPGradientView(colors: ASPTheme.Gradient.accent)
    private let glyphView = UIImageView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    private var tapHandler: (() -> Void)?

    init() {
        super.init(cornerRadius: 20)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        glyphBackground.translatesAutoresizingMaskIntoConstraints = false
        glyphBackground.layer.cornerRadius = 16
        glyphBackground.clipsToBounds = true
        contentView.addSubview(glyphBackground)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.isHidden = true
        contentView.addSubview(imageView)

        glyphView.translatesAutoresizingMaskIntoConstraints = false
        glyphView.contentMode = .scaleAspectFit
        glyphView.tintColor = .white
        glyphView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        glyphBackground.addSubview(glyphView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = ASPTheme.Font.captionMedium()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = ASPTheme.Font.mono(15)
        valueLabel.textColor = ASPTheme.Color.accent
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            glyphBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            glyphBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            glyphBackground.widthAnchor.constraint(equalToConstant: 56),
            glyphBackground.heightAnchor.constraint(equalToConstant: 56),
            imageView.leadingAnchor.constraint(equalTo: glyphBackground.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: glyphBackground.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: glyphBackground.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: glyphBackground.bottomAnchor),
            glyphView.centerXAnchor.constraint(equalTo: glyphBackground.centerXAnchor),
            glyphView.centerYAnchor.constraint(equalTo: glyphBackground.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            nameLabel.topAnchor.constraint(equalTo: glyphBackground.bottomAnchor, constant: 12),

            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            valueLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(asp_tapped)))
    }

    func asp_configure(asset: ASPAssetModel, image: UIImage?, handler: @escaping () -> Void) {
        nameLabel.text = asset.assetName
        valueLabel.text = ASPFormat.currency(asset.assetValue)
        tapHandler = handler

        let color = ASPTheme.Color.category(asset.assetCategory)
        glyphBackground.asp_setColors([color.cgColor, color.withAlphaComponent(0.6).cgColor])
        glyphView.image = UIImage(systemName: ASPCategory.symbol(for: asset.assetCategory))

        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            glyphView.isHidden = true
        } else {
            imageView.isHidden = true
            glyphView.isHidden = false
        }
    }

    @objc private func asp_tapped() { tapHandler?() }
}
