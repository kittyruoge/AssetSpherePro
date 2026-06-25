//
//  ASPAvatarView.swift
//  AssetSpherePro
//
//  A circular avatar that shows a stored image or a gradient monogram fallback.
//

import UIKit

final class ASPAvatarView: UIView {

    private let gradientView = ASPGradientView(colors: ASPTheme.Gradient.accent)
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()

    init(diameter: CGFloat = 64) {
        super.init(frame: .zero)
        asp_setup(diameter: diameter)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_setup(diameter: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = diameter / 2
        layer.cornerCurve = .continuous
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = ASPTheme.Color.glassBorder.cgColor

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = ASPTheme.Font.rounded(diameter * 0.4, .bold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        addSubview(initialsLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        addSubview(imageView)

        gradientView.asp_pinEdges(to: self)
        imageView.asp_pinEdges(to: self)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
            initialsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Shows initials derived from a username when no avatar image is set.
    func asp_configure(username: String, image: UIImage? = nil) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            initialsLabel.isHidden = true
        } else {
            imageView.isHidden = true
            initialsLabel.isHidden = false
            initialsLabel.text = Self.initials(from: username)
        }
    }

    private static func initials(from name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }
}
