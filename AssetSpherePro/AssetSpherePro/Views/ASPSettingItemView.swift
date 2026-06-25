//
//  ASPSettingItemView.swift
//  AssetSpherePro
//
//  A tappable settings row with an icon, title, optional trailing value, and a
//  chevron. Supports a toggle variant for boolean settings.
//

import UIKit

final class ASPSettingItemView: UIView {

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView()
    private let toggle = UISwitch()

    private var tapHandler: (() -> Void)?
    private var toggleHandler: ((Bool) -> Void)?

    init() {
        super.init(frame: .zero)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        translatesAutoresizingMaskIntoConstraints = false

        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.layer.cornerRadius = 9
        iconBackground.clipsToBounds = true
        addSubview(iconBackground)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconBackground.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.body()
        titleLabel.textColor = ASPTheme.Color.textPrimary
        addSubview(titleLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = ASPTheme.Font.caption()
        valueLabel.textColor = ASPTheme.Color.textSecondary
        valueLabel.textAlignment = .right
        addSubview(valueLabel)

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = ASPTheme.Color.textTertiary
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        addSubview(chevron)

        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = ASPTheme.Color.accent
        toggle.isHidden = true
        toggle.addTarget(self, action: #selector(asp_toggleChanged), for: .valueChanged)
        addSubview(toggle)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),

            iconBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 30),
            iconBackground.heightAnchor.constraint(equalToConstant: 30),
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),

            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(asp_tapped)))
    }

    /// Configures a navigational row.
    func asp_configure(icon: String, iconColor: UIColor, title: String,
                       value: String? = nil, handler: (() -> Void)? = nil) {
        iconBackground.backgroundColor = iconColor
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        valueLabel.text = value
        tapHandler = handler
        toggle.isHidden = true
        chevron.isHidden = false
    }

    /// Configures a toggle row.
    func asp_configureToggle(icon: String, iconColor: UIColor, title: String,
                             isOn: Bool, handler: @escaping (Bool) -> Void) {
        iconBackground.backgroundColor = iconColor
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        toggle.isOn = isOn
        toggleHandler = handler
        toggle.isHidden = false
        chevron.isHidden = true
        valueLabel.isHidden = true
    }

    @objc private func asp_tapped() { tapHandler?() }

    @objc private func asp_toggleChanged() { toggleHandler?(toggle.isOn) }
}
