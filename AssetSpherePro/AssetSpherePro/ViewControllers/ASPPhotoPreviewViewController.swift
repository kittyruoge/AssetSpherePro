//
//  ASPPhotoPreviewViewController.swift
//  AssetSpherePro
//
//  A full-screen overlay that previews a vault photo with a delete and close
//  control. Presented over the vault grid.
//

import UIKit

final class ASPPhotoPreviewViewController: UIViewController {

    /// Called when the user confirms deletion.
    var onDelete: (() -> Void)?

    private let image: UIImage?
    private let imageView = UIImageView()

    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.92)

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill",
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)),
                             for: .normal)
        closeButton.tintColor = ASPTheme.Color.textPrimary
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(asp_close), for: .touchUpInside)
        view.addSubview(closeButton)

        let deleteButton = ASPPrimaryButton(title: "Delete Photo", style: .glass)
        deleteButton.addTarget(self, action: #selector(asp_delete), for: .touchUpInside)
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),

            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ASPTheme.Layout.screenInset),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ASPTheme.Layout.screenInset),
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func asp_close() { dismiss(animated: true) }

    @objc private func asp_delete() {
        asp_showConfirm(title: "Delete Photo", message: "Remove this photo from your vault?") { [weak self] in
            self?.dismiss(animated: true) { self?.onDelete?() }
        }
    }
}
