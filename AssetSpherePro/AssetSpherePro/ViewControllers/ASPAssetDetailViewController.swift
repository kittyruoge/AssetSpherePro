//
//  ASPAssetDetailViewController.swift
//  AssetSpherePro
//
//  Shows the full detail of an asset with edit, favorite, and delete actions.
//

import UIKit

final class ASPAssetDetailViewController: ASPBaseViewController {

    /// Called when the asset is edited or deleted so callers can refresh.
    var onChanged: (() -> Void)?

    private var asset: ASPAssetModel

    private let heroCard = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
    private let heroImage = UIImageView()
    private let heroGlyphBackground = ASPGradientView(colors: ASPTheme.Gradient.accent)
    private let heroGlyph = UIImageView()
    private let nameLabel = UILabel()
    private let valueLabel = ASPAnimatedNumberLabel()
    private let tagView = ASPTagView()
    private let favoriteButton = UIButton(type: .system)

    init(asset: ASPAssetModel) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"), style: .plain,
            target: self, action: #selector(asp_editTapped))
        asp_buildUI()
        asp_render()
    }

    private func asp_buildUI() {
        let stack = asp_makeScrollingStack(topInset: 12, spacing: 16)

        // Hero image / glyph.
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroGlyphBackground.translatesAutoresizingMaskIntoConstraints = false
        heroCard.contentView.addSubview(heroGlyphBackground)
        heroGlyphBackground.asp_pinEdges(to: heroCard.contentView)

        heroGlyph.translatesAutoresizingMaskIntoConstraints = false
        heroGlyph.tintColor = .white
        heroGlyph.contentMode = .scaleAspectFit
        heroGlyph.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 56, weight: .semibold)
        heroGlyphBackground.addSubview(heroGlyph)

        heroImage.translatesAutoresizingMaskIntoConstraints = false
        heroImage.contentMode = .scaleAspectFill
        heroImage.clipsToBounds = true
        heroImage.isHidden = true
        heroCard.contentView.addSubview(heroImage)
        heroImage.asp_pinEdges(to: heroCard.contentView)

        NSLayoutConstraint.activate([
            heroCard.heightAnchor.constraint(equalToConstant: 200),
            heroGlyph.centerXAnchor.constraint(equalTo: heroGlyphBackground.centerXAnchor),
            heroGlyph.centerYAnchor.constraint(equalTo: heroGlyphBackground.centerYAnchor)
        ])
        stack.addArrangedSubview(heroCard)

        // Name + value + tag card.
        let infoCard = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        infoCard.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = ASPTheme.Font.title()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = ASPTheme.Font.mono(32)
        valueLabel.isCurrency = true
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        tagView.translatesAutoresizingMaskIntoConstraints = false

        [nameLabel, valueLabel, tagView].forEach { infoCard.contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: infoCard.contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: infoCard.contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: infoCard.contentView.trailingAnchor, constant: -20),

            tagView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            tagView.leadingAnchor.constraint(equalTo: infoCard.contentView.leadingAnchor, constant: 20),

            valueLabel.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 14),
            valueLabel.leadingAnchor.constraint(equalTo: infoCard.contentView.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: infoCard.contentView.trailingAnchor, constant: -20),
            valueLabel.bottomAnchor.constraint(equalTo: infoCard.contentView.bottomAnchor, constant: -20)
        ])
        stack.addArrangedSubview(infoCard)

        // Meta info card (date, favorite).
        let metaCard = ASPInfoCardView()
        metaCard.translatesAutoresizingMaskIntoConstraints = false
        metaCard.asp_configure(rows: [
            ("Category", asset.assetCategory),
            ("Acquired", ASPFormat.date(asset.assetDate)),
            ("Favorite", asset.isFavorite ? "Yes" : "No")
        ])
        stack.addArrangedSubview(metaCard)

        // Note card (only when present).
        if !asset.assetNote.asp_trimmed.isEmpty {
            let noteHeader = ASPHeaderView()
            noteHeader.asp_configure(title: "Note")
            stack.addArrangedSubview(noteHeader)

            let noteCard = ASPGlassCardView(cornerRadius: 18)
            noteCard.translatesAutoresizingMaskIntoConstraints = false
            let noteLabel = UILabel()
            noteLabel.text = asset.assetNote
            noteLabel.font = ASPTheme.Font.body()
            noteLabel.textColor = ASPTheme.Color.textSecondary
            noteLabel.numberOfLines = 0
            noteLabel.translatesAutoresizingMaskIntoConstraints = false
            noteCard.contentView.addSubview(noteLabel)
            noteLabel.asp_pinEdges(to: noteCard.contentView, inset: 18)
            stack.addArrangedSubview(noteCard)
        }

        // Favorite + delete buttons.
        favoriteButton.titleLabel?.font = ASPTheme.Font.bodyMedium()
        favoriteButton.tintColor = ASPTheme.Color.warning
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(asp_favoriteTapped), for: .touchUpInside)
        let favWrap = ASPGlassCardView(cornerRadius: 16)
        favWrap.translatesAutoresizingMaskIntoConstraints = false
        favWrap.contentView.addSubview(favoriteButton)
        favoriteButton.asp_pinEdges(to: favWrap.contentView)
        favWrap.heightAnchor.constraint(equalToConstant: 52).isActive = true
        stack.setCustomSpacing(24, after: stack.arrangedSubviews.last ?? favWrap)
        stack.addArrangedSubview(favWrap)

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Asset", for: .normal)
        deleteButton.setTitleColor(ASPTheme.Color.negative, for: .normal)
        deleteButton.titleLabel?.font = ASPTheme.Font.bodyMedium()
        deleteButton.addTarget(self, action: #selector(asp_deleteTapped), for: .touchUpInside)
        stack.addArrangedSubview(deleteButton)
    }

    private func asp_render() {
        nameLabel.text = asset.assetName
        tagView.asp_configure(category: asset.assetCategory)
        valueLabel.asp_animate(to: asset.assetValue)

        let color = ASPTheme.Color.category(asset.assetCategory)
        heroGlyphBackground.asp_setColors([color.cgColor, color.withAlphaComponent(0.55).cgColor])
        heroGlyph.image = UIImage(systemName: ASPCategory.symbol(for: asset.assetCategory))

        if let image = ASPStorageManager.shared.asp_loadAssetImage(asset.assetImagePath) {
            heroImage.image = image
            heroImage.isHidden = false
        } else {
            heroImage.isHidden = true
        }

        let favTitle = asset.isFavorite ? "★  Remove from Favorites" : "☆  Add to Favorites"
        favoriteButton.setTitle(favTitle, for: .normal)
    }

    // MARK: - Actions

    @objc private func asp_editTapped() {
        let vc = ASPEditAssetViewController(asset: asset)
        vc.onSaved = { [weak self] in
            guard let self = self else { return }
            if let refreshed = ASPAssetManager.shared.asp_asset(id: self.asset.assetId) {
                self.asset = refreshed
            }
            self.asp_refreshUI()
            self.onChanged?()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func asp_favoriteTapped() {
        ASPAssetManager.shared.asp_toggleFavorite(id: asset.assetId)
        if let refreshed = ASPAssetManager.shared.asp_asset(id: asset.assetId) {
            asset = refreshed
        }
        asp_render()
        onChanged?()
    }

    @objc private func asp_deleteTapped() {
        asp_showConfirm(title: "Delete Asset",
                        message: "Are you sure you want to delete \"\(asset.assetName)\"? This can't be undone.") { [weak self] in
            guard let self = self else { return }
            ASPAssetManager.shared.asp_delete(id: self.asset.assetId)
            self.onChanged?()
            self.navigationController?.popViewController(animated: true)
        }
    }

    /// Rebuilds the scrolling content after an edit (note visibility may change).
    private func asp_refreshUI() {
        view.subviews.filter { $0 is UIScrollView }.forEach { $0.removeFromSuperview() }
        asp_buildUI()
        asp_render()
    }
}
