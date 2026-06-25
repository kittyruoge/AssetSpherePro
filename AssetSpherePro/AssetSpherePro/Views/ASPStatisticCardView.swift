//
//  ASPStatisticCardView.swift
//  AssetSpherePro
//
//  A compact glass tile showing a single statistic: an icon, an animated value,
//  and a caption. Used in grids on the home and analytics screens.
//

import UIKit

final class ASPStatisticCardView: ASPGlassCardView {

    private let iconView = UIImageView()
    private let valueLabel = ASPAnimatedNumberLabel()
    private let titleLabel = UILabel()
    private let accentDot = ASPGradientView(colors: ASPTheme.Gradient.accent)

    init() {
        super.init(cornerRadius: 22)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        accentDot.translatesAutoresizingMaskIntoConstraints = false
        accentDot.layer.cornerRadius = 18
        accentDot.clipsToBounds = true
        contentView.addSubview(accentDot)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        accentDot.addSubview(iconView)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = ASPTheme.Font.mono(24)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        contentView.addSubview(valueLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.caption()
        titleLabel.textColor = ASPTheme.Color.textSecondary
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            accentDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            accentDot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            accentDot.widthAnchor.constraint(equalToConstant: 36),
            accentDot.heightAnchor.constraint(equalToConstant: 36),
            iconView.centerXAnchor.constraint(equalTo: accentDot.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: accentDot.centerYAnchor),

            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.topAnchor.constraint(equalTo: accentDot.bottomAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    /// Configures the card and animates the value in.
    func asp_configure(icon: String, value: Double, title: String,
                       isCurrency: Bool, gradient: [CGColor] = ASPTheme.Gradient.accent) {
        iconView.image = UIImage(systemName: icon)
        accentDot.asp_setColors(gradient)
        valueLabel.isCurrency = isCurrency
        valueLabel.textColor = ASPTheme.Color.textPrimary
        titleLabel.text = title
        valueLabel.asp_animate(to: value)
    }

    /// Configures the card with a plain text value (no animation).
    func asp_configure(icon: String, text: String, title: String,
                       gradient: [CGColor] = ASPTheme.Gradient.accent) {
        iconView.image = UIImage(systemName: icon)
        accentDot.asp_setColors(gradient)
        valueLabel.asp_set(0)
        valueLabel.text = text
        valueLabel.textColor = ASPTheme.Color.textPrimary
        titleLabel.text = title
    }
}
