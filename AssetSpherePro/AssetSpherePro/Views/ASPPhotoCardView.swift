//
//  ASPPhotoCardView.swift
//  AssetSpherePro
//
//  A square photo tile for the vault collection-style grid.
//

import UIKit

final class ASPPhotoCardView: UIView {

    private let imageView = UIImageView()
    private let overlay = ASPGradientView(
        colors: [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor])
    private let dateLabel = UILabel()

    init() {
        super.init(frame: .zero)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = ASPTheme.Color.glassBorder.cgColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)

        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dateLabel.textColor = .white
        addSubview(dateLabel)

        imageView.asp_pinEdges(to: self)
        overlay.asp_pinEdges(to: self)

        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func asp_configure(image: UIImage?, date: Date) {
        imageView.image = image
        dateLabel.text = ASPFormat.date(date)
    }
}
