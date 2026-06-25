//
//  ASPInfoCardView.swift
//  AssetSpherePro
//
//  A simple key/value info card used on the About and Profile screens. Renders
//  a list of label/value rows inside a glass panel.
//

import UIKit

final class ASPInfoCardView: ASPGlassCardView {

    private let stack = UIStackView()

    init() {
        super.init(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    /// Populates the card with rows. Each tuple is (label, value).
    func asp_configure(rows: [(String, String)]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, row) in rows.enumerated() {
            stack.addArrangedSubview(makeRow(label: row.0, value: row.1))
            if index < rows.count - 1 {
                stack.addArrangedSubview(makeSeparator())
            }
        }
    }

    private func makeRow(label: String, value: String) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = ASPTheme.Font.body()
        labelView.textColor = ASPTheme.Color.textSecondary
        labelView.text = label
        container.addSubview(labelView)

        let valueView = UILabel()
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.font = ASPTheme.Font.bodyMedium()
        valueView.textColor = ASPTheme.Color.textPrimary
        valueView.textAlignment = .right
        valueView.text = value
        valueView.setContentCompressionResistancePriority(.required, for: .horizontal)
        container.addSubview(valueView)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 48),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueView.leadingAnchor.constraint(greaterThanOrEqualTo: labelView.trailingAnchor, constant: 8)
        ])
        return container
    }

    private func makeSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = ASPTheme.Color.glassFillStrong
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}
