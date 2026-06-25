//
//  ASPStorageCardView.swift
//  AssetSpherePro
//
//  Dashboard module summarizing storage usage with a progress bar and a
//  breakdown of asset images, documents, and photos.
//

import UIKit

final class ASPStorageCardView: ASPGlassCardView {

    private let titleLabel = UILabel()
    private let usageLabel = UILabel()
    private let progress = ASPProgressView()
    private let breakdownStack = UIStackView()

    init() {
        super.init(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        asp_build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func asp_build() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ASPTheme.Font.captionMedium()
        titleLabel.textColor = ASPTheme.Color.textSecondary
        titleLabel.text = "STORAGE OVERVIEW"
        contentView.addSubview(titleLabel)

        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        usageLabel.font = ASPTheme.Font.mono(26)
        usageLabel.textColor = ASPTheme.Color.textPrimary
        contentView.addSubview(usageLabel)

        contentView.addSubview(progress)

        breakdownStack.translatesAutoresizingMaskIntoConstraints = false
        breakdownStack.axis = .horizontal
        breakdownStack.distribution = .fillEqually
        breakdownStack.spacing = 8
        contentView.addSubview(breakdownStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            usageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            usageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            progress.topAnchor.constraint(equalTo: usageLabel.bottomAnchor, constant: 14),
            progress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            breakdownStack.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 16),
            breakdownStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            breakdownStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            breakdownStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    /// Configures with current usage. `fraction` is used purely for the bar's
    /// visual fill (relative to a nominal 1 GB reference).
    func asp_configure(totalBytes: Int64, assetImages: Int, documents: Int, photos: Int) {
        usageLabel.text = ASPFormat.bytes(totalBytes)
        // Reference 1 GB for the bar; clamp so small usage still shows a sliver.
        let reference: Double = 1_073_741_824
        let fraction = max(0.04, min(1, Double(totalBytes) / reference))
        progress.asp_setProgress(CGFloat(fraction))

        breakdownStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        breakdownStack.addArrangedSubview(Self.block(count: assetImages, title: "Images", color: ASPTheme.Color.accent))
        breakdownStack.addArrangedSubview(Self.block(count: documents, title: "Docs", color: ASPTheme.Color.accentSecondary))
        breakdownStack.addArrangedSubview(Self.block(count: photos, title: "Photos", color: ASPTheme.Color.accentPink))
    }

    private static func block(count: Int, title: String, color: UIColor) -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8)
        ])

        let countLabel = UILabel()
        countLabel.font = ASPTheme.Font.bodyMedium()
        countLabel.textColor = ASPTheme.Color.textPrimary
        countLabel.text = "\(count)"

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textColor = ASPTheme.Color.textTertiary
        titleLabel.text = title

        let topRow = UIStackView(arrangedSubviews: [dot, countLabel])
        topRow.axis = .horizontal
        topRow.spacing = 6
        topRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [topRow, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }
}
