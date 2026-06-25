//
//  ASPPhotoVaultViewController.swift
//  AssetSpherePro
//
//  Image center: capture photos or import from the library, preview them in a
//  grid, and delete. Photos are stored locally in the app's documents folder.
//

import UIKit
import PhotosUI

final class ASPPhotoVaultViewController: ASPBaseViewController,
    PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var collectionView: UICollectionView!
    private let emptyView = ASPEmptyView()
    private var photos: [ASPPhotoModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vault"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(asp_addTapped))
        asp_buildUI()
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_buildUI() {
        let layout = UICollectionViewFlowLayout()
        let inset = ASPTheme.Layout.screenInset
        let spacing: CGFloat = 12
        let columns: CGFloat = 2
        let available = view.bounds.width - inset * 2 - spacing * (columns - 1)
        let side = floor(available / columns)
        layout.itemSize = CGSize(width: side, height: side)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 8, left: inset, bottom: 24, right: inset)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ASPPhotoCell.self, forCellWithReuseIdentifier: ASPPhotoCell.reuseID)
        view.addSubview(collectionView)

        emptyView.isHidden = true
        emptyView.asp_configure(icon: "photo.on.rectangle.angled", title: "Empty Vault",
                                message: "Capture or import photos of receipts, items, and documents.",
                                action: "Add Photo") { [weak self] in self?.asp_addTapped() }
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset)
        ])
    }

    private func asp_reload() {
        photos = ASPStorageManager.shared.asp_allPhotos()
        emptyView.isHidden = !photos.isEmpty
        collectionView.isHidden = photos.isEmpty
        collectionView.reloadData()
    }

    // MARK: - Add

    @objc private func asp_addTapped() {
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
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
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
            DispatchQueue.main.async {
                ASPStorageManager.shared.asp_savePhoto(image)
                self?.asp_reload()
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            ASPStorageManager.shared.asp_savePhoto(image)
            asp_reload()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Collection data source / delegate

extension ASPPhotoVaultViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ASPPhotoCell.reuseID, for: indexPath) as! ASPPhotoCell
        let photo = photos[indexPath.item]
        let image = ASPStorageManager.shared.asp_loadPhoto(photo.photoPath)
        cell.configure(image: image, date: photo.createDate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        let image = ASPStorageManager.shared.asp_loadPhoto(photo.photoPath)
        asp_presentPreview(image: image, photoId: photo.photoId)
    }

    private func asp_presentPreview(image: UIImage?, photoId: String) {
        let previewVC = ASPPhotoPreviewViewController(image: image)
        previewVC.onDelete = { [weak self] in
            ASPStorageManager.shared.asp_deletePhoto(id: photoId)
            self?.asp_reload()
        }
        previewVC.modalPresentationStyle = .overFullScreen
        previewVC.modalTransitionStyle = .crossDissolve
        present(previewVC, animated: true)
    }
}

// MARK: - Photo cell

final class ASPPhotoCell: UICollectionViewCell {
    static let reuseID = "ASPPhotoCell"
    private let card = ASPPhotoCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        card.asp_pinEdges(to: contentView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(image: UIImage?, date: Date) {
        card.asp_configure(image: image, date: date)
    }
}
