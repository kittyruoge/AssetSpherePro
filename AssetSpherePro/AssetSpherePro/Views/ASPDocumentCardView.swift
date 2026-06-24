//
//  ASPDocumentCardView.swift
//  AssetSpherePro
//
//  A row representing an imported document — file-type glyph, name, and date.
//

import UIKit

final class ASPDocumentCardView: ASPGlassCardView {

    private let iconBackground = UIView()
    private let extLabel = UILabel()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()

    init() {
        super.init(cornerRadius: 18)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.cornerRadius = 12
        iconBackground.clipsToBounds = true
        contentView.addSubview(iconBackground)

        extLabel.translatesAutoresizingMaskIntoConstraints = false
        extLabel.font = ASPTheme.Font.rounded(11, .bold)
        extLabel.textColor = .white
        extLabel.textAlignment = .center
        iconBackground.addSubview(extLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = ASPTheme.Font.bodyMedium()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = ASPTheme.Font.caption()
        dateLabel.textColor = ASPTheme.Color.textSecondary
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 44),
            iconBackground.heightAnchor.constraint(equalToConstant: 44),
            iconBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            extLabel.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            extLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            extLabel.leadingAnchor.constraint(greaterThanOrEqualTo: iconBackground.leadingAnchor, constant: 2),
            extLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconBackground.trailingAnchor, constant: -2),

            nameLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            nameLabel.topAnchor.constraint(equalTo: iconBackground.topAnchor, constant: 2),

            dateLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -14)
        ])
    }

    func asp_configure(document: ASPDocumentModel) {
        nameLabel.text = document.documentName
        dateLabel.text = ASPFormat.date(document.createDate)
        let ext = document.fileExtension.isEmpty ? "FILE" : document.fileExtension.uppercased()
        extLabel.text = ext
        iconBackground.backgroundColor = Self.color(for: document.fileExtension)
    }

    private static func color(for ext: String) -> UIColor {
        switch ext {
        case "pdf":           return ASPTheme.Color.negative
        case "doc", "docx":   return ASPTheme.Color.accentSecondary
        case "txt":           return ASPTheme.Color.warning
        default:              return ASPTheme.Color.accent
        }
    }
}
