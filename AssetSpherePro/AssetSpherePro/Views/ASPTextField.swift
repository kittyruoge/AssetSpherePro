//
//  ASPTextField.swift
//  AssetSpherePro
//
//  A glassmorphism text field with a leading icon and floating-style caption.
//

import UIKit

final class ASPTextField: UIView {

    let textField = UITextField()
    private let iconView = UIImageView()
    private let captionLabel = UILabel()
    private let fieldBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let eyeButton = UIButton(type: .system)

    init(icon: String, placeholder: String, caption: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        asp_build(icon: icon, placeholder: placeholder, caption: caption, isSecure: isSecure)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build(icon: String, placeholder: String, caption: String, isSecure: Bool) {
        translatesAutoresizingMaskIntoConstraints = false

        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = ASPTheme.Font.captionMedium()
        captionLabel.textColor = ASPTheme.Color.textSecondary
        captionLabel.text = caption
        addSubview(captionLabel)

        fieldBackground.translatesAutoresizingMaskIntoConstraints = false
        fieldBackground.layer.cornerRadius = 14
        fieldBackground.layer.cornerCurve = .continuous
        fieldBackground.clipsToBounds = true
        fieldBackground.layer.borderWidth = 1
        fieldBackground.layer.borderColor = ASPTheme.Color.glassBorder.cgColor
        addSubview(fieldBackground)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = ASPTheme.Color.accent
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        fieldBackground.contentView.addSubview(iconView)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = ASPTheme.Font.body()
        textField.textColor = ASPTheme.Color.textPrimary
        textField.tintColor = ASPTheme.Color.accent
        textField.isSecureTextEntry = isSecure
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: ASPTheme.Color.textTertiary])
        fieldBackground.contentView.addSubview(textField)

        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.tintColor = ASPTheme.Color.textTertiary
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.isHidden = !isSecure
        eyeButton.addTarget(self, action: #selector(asp_toggleSecure), for: .touchUpInside)
        fieldBackground.contentView.addSubview(eyeButton)

        // The text field's trailing edge depends on whether the eye toggle is
        // present, so secure fields leave room for a full-size tap target while
        // plain fields use the normal inset.
        let textFieldTrailing: NSLayoutConstraint = isSecure
            ? textField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -4)
            : textField.trailingAnchor.constraint(equalTo: fieldBackground.contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            captionLabel.topAnchor.constraint(equalTo: topAnchor),

            fieldBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            fieldBackground.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 6),
            fieldBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldBackground.heightAnchor.constraint(equalToConstant: ASPTheme.Layout.fieldHeight),

            iconView.leadingAnchor.constraint(equalTo: fieldBackground.contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: fieldBackground.contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: fieldBackground.contentView.centerYAnchor),
            textFieldTrailing,

            // 44×44pt minimum tap target (Apple HIG). The eye glyph stays
            // visually centered inside the larger touch area.
            eyeButton.trailingAnchor.constraint(equalTo: fieldBackground.contentView.trailingAnchor, constant: -2),
            eyeButton.centerYAnchor.constraint(equalTo: fieldBackground.contentView.centerYAnchor),
            eyeButton.widthAnchor.constraint(equalToConstant: 44),
            eyeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    var text: String { textField.text ?? "" }

    @objc private func asp_toggleSecure() {
        textField.isSecureTextEntry.toggle()
        let symbol = textField.isSecureTextEntry ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: symbol), for: .normal)
    }
}
