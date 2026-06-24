//
//  ASPAssetFormViewController.swift
//  AssetSpherePro
//
//  Shared form used for both adding and editing an asset. Subclasses configure
//  the title, initial values, and the save behavior.
//

import UIKit
import PhotosUI

class ASPAssetFormViewController: ASPBaseViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Editable state

    /// The working model being edited. Subclasses seed this.
    var workingAsset = ASPAssetModel()
    /// A freshly picked image not yet persisted.
    private var pickedImage: UIImage?

    // MARK: - UI

    private let imageButton = UIButton(type: .system)
    private let imageView = UIImageView()
    private let imageGlyph = UIImageView()
    private let nameField = ASPTextField(icon: "tag.fill", placeholder: "Asset name", caption: "NAME")
    private let valueField = ASPTextField(icon: "dollarsign.circle.fill", placeholder: "0", caption: "VALUE (USD)")
    private let categoryButton = UIButton(type: .system)
    private let favoriteToggleRow = ASPSettingItemView()
    private let noteView = UITextView()
    private let saveButton = ASPPrimaryButton(title: "Save")
    private var isFavorite = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(asp_cancelTapped))
        asp_buildUI()
        asp_populate()
    }

    /// Subclasses override to perform the persistence and return whether it
    /// succeeded.
    func asp_commit(_ asset: ASPAssetModel) -> Bool { false }

    // MARK: - UI

    private func asp_buildUI() {
        let stack = asp_makeScrollingStack(topInset: 12, spacing: 16)

        // Image picker card.
        let imageCard = ASPGlassCardView(cornerRadius: 22)
        imageCard.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        imageCard.contentView.addSubview(imageView)

        imageGlyph.image = UIImage(systemName: "camera.fill")
        imageGlyph.tintColor = ASPTheme.Color.accent
        imageGlyph.contentMode = .scaleAspectFit
        imageGlyph.translatesAutoresizingMaskIntoConstraints = false
        imageGlyph.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        imageCard.contentView.addSubview(imageGlyph)

        let glyphCaption = UILabel()
        glyphCaption.text = "Add Photo"
        glyphCaption.font = ASPTheme.Font.caption()
        glyphCaption.textColor = ASPTheme.Color.textSecondary
        glyphCaption.translatesAutoresizingMaskIntoConstraints = false
        imageCard.contentView.addSubview(glyphCaption)

        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.addTarget(self, action: #selector(asp_pickImage), for: .touchUpInside)
        imageCard.contentView.addSubview(imageButton)

        imageView.asp_pinEdges(to: imageCard.contentView)
        imageButton.asp_pinEdges(to: imageCard.contentView)
        NSLayoutConstraint.activate([
            imageCard.heightAnchor.constraint(equalToConstant: 160),
            imageGlyph.centerXAnchor.constraint(equalTo: imageCard.contentView.centerXAnchor),
            imageGlyph.centerYAnchor.constraint(equalTo: imageCard.contentView.centerYAnchor, constant: -8),
            glyphCaption.topAnchor.constraint(equalTo: imageGlyph.bottomAnchor, constant: 6),
            glyphCaption.centerXAnchor.constraint(equalTo: imageCard.contentView.centerXAnchor)
        ])
        stack.addArrangedSubview(imageCard)

        // Fields.
        valueField.textField.keyboardType = .decimalPad
        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(valueField)

        // Category selector (menu).
        asp_styleSelector(categoryButton, title: "CATEGORY")
        categoryButton.addTarget(self, action: #selector(asp_pickCategory), for: .touchUpInside)
        stack.addArrangedSubview(asp_wrapSelector(categoryButton, caption: "CATEGORY"))

        // Favorite toggle.
        let favCard = ASPGlassCardView(cornerRadius: 16)
        favCard.translatesAutoresizingMaskIntoConstraints = false
        favoriteToggleRow.translatesAutoresizingMaskIntoConstraints = false
        favoriteToggleRow.asp_configureToggle(icon: "star.fill", iconColor: ASPTheme.Color.warning,
                                              title: "Mark as Favorite", isOn: isFavorite) { [weak self] on in
            self?.isFavorite = on
        }
        favCard.contentView.addSubview(favoriteToggleRow)
        favoriteToggleRow.asp_pinEdges(to: favCard.contentView)
        stack.addArrangedSubview(favCard)

        // Note.
        let noteCaption = UILabel()
        noteCaption.text = "NOTE"
        noteCaption.font = ASPTheme.Font.captionMedium()
        noteCaption.textColor = ASPTheme.Color.textSecondary
        stack.addArrangedSubview(noteCaption)
        stack.setCustomSpacing(6, after: noteCaption)

        let noteCard = ASPGlassCardView(cornerRadius: 14)
        noteCard.translatesAutoresizingMaskIntoConstraints = false
        noteView.backgroundColor = .clear
        noteView.font = ASPTheme.Font.body()
        noteView.textColor = ASPTheme.Color.textPrimary
        noteView.tintColor = ASPTheme.Color.accent
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteCard.contentView.addSubview(noteView)
        noteView.asp_pinEdges(to: noteCard.contentView, inset: 10)
        noteCard.heightAnchor.constraint(equalToConstant: 110).isActive = true
        stack.addArrangedSubview(noteCard)

        saveButton.addTarget(self, action: #selector(asp_saveTapped), for: .touchUpInside)
        stack.setCustomSpacing(24, after: noteCard)
        stack.addArrangedSubview(saveButton)
    }

    private func asp_styleSelector(_ button: UIButton, title: String) {
        button.contentHorizontalAlignment = .leading
        button.setTitleColor(ASPTheme.Color.textPrimary, for: .normal)
        button.titleLabel?.font = ASPTheme.Font.body()
    }

    private func asp_wrapSelector(_ button: UIButton, caption: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = ASPTheme.Font.captionMedium()
        captionLabel.textColor = ASPTheme.Color.textSecondary
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(captionLabel)

        let card = ASPGlassCardView(cornerRadius: 14)
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        chevron.tintColor = ASPTheme.Color.textTertiary
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)

        button.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(button)
        card.contentView.addSubview(chevron)

        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: container.topAnchor),
            captionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),

            card.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            card.heightAnchor.constraint(equalToConstant: ASPTheme.Layout.fieldHeight),

            button.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 16),
            button.centerYAnchor.constraint(equalTo: card.contentView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),

            chevron.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.contentView.centerYAnchor)
        ])
        return container
    }

    private func asp_populate() {
        nameField.textField.text = workingAsset.assetName
        if workingAsset.assetValue > 0 {
            valueField.textField.text = String(format: "%g", workingAsset.assetValue)
        }
        categoryButton.setTitle(workingAsset.assetCategory, for: .normal)
        noteView.text = workingAsset.assetNote
        isFavorite = workingAsset.isFavorite
        favoriteToggleRow.asp_configureToggle(icon: "star.fill", iconColor: ASPTheme.Color.warning,
                                              title: "Mark as Favorite", isOn: isFavorite) { [weak self] on in
            self?.isFavorite = on
        }
        if let image = ASPStorageManager.shared.asp_loadAssetImage(workingAsset.assetImagePath) {
            pickedImage = image
            imageView.image = image
            imageView.isHidden = false
        }
    }

    // MARK: - Category picker

    @objc private func asp_pickCategory() {
        let sheet = UIAlertController(title: "Category", message: nil, preferredStyle: .actionSheet)
        for category in ASPCategory.all {
            sheet.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.workingAsset.assetCategory = category
                self?.categoryButton.setTitle(category, for: .normal)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = categoryButton
        present(sheet, animated: true)
    }

    // MARK: - Image picking

    @objc private func asp_pickImage() {
        let sheet = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.asp_presentCamera()
            })
        }
        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.asp_presentLibrary()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.sourceView = imageButton
        present(sheet, animated: true)
    }

    private func asp_presentLibrary() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func asp_presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async { self?.asp_applyPicked(image) }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage { asp_applyPicked(image) }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func asp_applyPicked(_ image: UIImage) {
        pickedImage = image
        imageView.image = image
        imageView.isHidden = false
    }

    // MARK: - Save / cancel

    @objc private func asp_saveTapped() {
        view.endEditing(true)
        let name = nameField.text.asp_trimmed
        guard !name.isEmpty else {
            asp_showAlert(title: "Name Required", message: "Please enter a name for this asset.")
            return
        }
        let value = Double(valueField.text.asp_trimmed) ?? 0

        var asset = workingAsset
        asset.assetName = name
        asset.assetValue = value
        asset.assetNote = noteView.text ?? ""
        asset.isFavorite = isFavorite

        // Persist a newly picked image if it changed.
        if let picked = pickedImage,
           let savedName = ASPStorageManager.shared.asp_saveAssetImage(picked) {
            asset.assetImagePath = savedName
        }

        if asp_commit(asset) {
            dismiss(animated: true)
            navigationController?.popViewController(animated: true)
        } else {
            asp_showAlert(title: "Save Failed", message: "Something went wrong saving this asset.")
        }
    }

    @objc private func asp_cancelTapped() {
        view.endEditing(true)
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
