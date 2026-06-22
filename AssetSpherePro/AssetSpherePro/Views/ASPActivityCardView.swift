//
//  ASPActivityCardView.swift
//  AssetSpherePro
//
//  A row representing a single timeline activity — typed icon, title, and
//  relative timestamp. Optionally draws a connector line for timeline layout.
//

import UIKit

final class ASPActivityCardView: ASPGlassCardView {

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()

    init() {
        super.init(cornerRadius: 18)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.cornerRadius = 18
        iconBackground.clipsToBounds = true
        contentView.addSubview(iconBackground)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconBackground.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.bodyMedium()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        contentView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = ASPTheme.Font.caption()
        subtitleLabel.textColor = ASPTheme.Color.textSecondary
        contentView.addSubview(subtitleLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = ASPTheme.Font.caption()
        dateLabel.textColor = ASPTheme.Color.textTertiary
        dateLabel.textAlignment = .right
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 36),
            iconBackground.heightAnchor.constraint(equalToConstant: 36),
            iconBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: iconBackground.topAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func asp_configure(activity: ASPActivityModel) {
        let type = activity.activityType ?? .createAsset
        iconView.image = UIImage(systemName: type.symbol)
        titleLabel.text = type.rawValue
        subtitleLabel.text = activity.title
        dateLabel.text = ASPFormat.dateTime(activity.date)

        let color = Self.color(for: type)
        iconView.tintColor = color
        iconBackground.backgroundColor = color.withAlphaComponent(0.18)
    }

    private static func color(for type: ASPActivityType) -> UIColor {
        switch type {
        case .createAsset:    return ASPTheme.Color.positive
        case .editAsset:      return ASPTheme.Color.accent
        case .deleteAsset:    return ASPTheme.Color.negative
        case .importDocument: return ASPTheme.Color.accentSecondary
        case .importPhoto:    return ASPTheme.Color.accentPink
        case .login:          return ASPTheme.Color.warning
        }
    }
}
