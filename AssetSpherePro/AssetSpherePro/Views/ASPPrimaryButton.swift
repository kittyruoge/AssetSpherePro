//
//  ASPPrimaryButton.swift
//  AssetSpherePro
//
//  The app's primary call-to-action button: a gradient-filled, rounded button
//  with a press animation. A secondary (glass) style is also provided.
//

import UIKit

final class ASPPrimaryButton: UIControl {

    private let gradientView = ASPGradientView(colors: ASPTheme.Gradient.accent,
                                               start: CGPoint(x: 0, y: 0.5),
                                               end: CGPoint(x: 1, y: 0.5))
    private let glassView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    enum Style { case gradient, glass }
    private let style: Style

    init(title: String, style: Style = .gradient) {
        self.style = style
        super.init(frame: .zero)
        asp_build(title: title)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true

        switch style {
        case .gradient:
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            gradientView.isUserInteractionEnabled = false
            addSubview(gradientView)
            gradientView.asp_pinEdges(to: self)
        case .glass:
            glassView.translatesAutoresizingMaskIntoConstraints = false
            glassView.isUserInteractionEnabled = false
            addSubview(glassView)
            glassView.asp_pinEdges(to: self)
            layer.borderWidth = 1
            layer.borderColor = ASPTheme.Color.glassBorder.cgColor
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = ASPTheme.Font.bodyMedium()
        titleLabel.textColor = .white
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: ASPTheme.Layout.buttonHeight),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addTarget(self, action: #selector(asp_down), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(asp_up), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
    }

    func asp_setTitle(_ title: String) { titleLabel.text = title }

    /// Tints the button for a destructive action: red label and border.
    /// Intended for use with the `.glass` style.
    func asp_setDestructive() {
        titleLabel.textColor = ASPTheme.Color.negative
        layer.borderColor = ASPTheme.Color.negative.withAlphaComponent(0.6).cgColor
    }

    func asp_setLoading(_ loading: Bool) {
        isEnabled = !loading
        titleLabel.isHidden = loading
        if loading { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.5 }
    }

    @objc private func asp_down() {
        UIView.animate(withDuration: 0.08) { self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }
    }

    @objc private func asp_up() {
        UIView.animate(withDuration: 0.12) { self.transform = .identity }
    }
}
