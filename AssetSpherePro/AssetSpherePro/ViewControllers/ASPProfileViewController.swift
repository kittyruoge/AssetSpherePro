//
//  ASPProfileViewController.swift
//  AssetSpherePro
//
//  Shows the signed-in user's profile: avatar, username, email, register date,
//  asset count, and last login. Allows changing the avatar and username.
//

import UIKit
import PhotosUI

final class ASPProfileViewController: ASPBaseViewController,
    PHPickerViewControllerDelegate {

    private var contentStack: UIStackView!
    private let avatarView = ASPAvatarView(diameter: 96)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit", style: .plain, target: self, action: #selector(asp_editName))
        contentStack = asp_makeScrollingStack(topInset: 16, spacing: 16)
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let user = ASPUserManager.shared.currentUser else { return }

        // Avatar + name header.
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false

        let avatarImage = ASPStorageManager.shared.asp_loadAssetImage(user.avatar)
        avatarView.asp_configure(username: user.username, image: avatarImage)

        let editAvatarButton = UIButton(type: .system)
        editAvatarButton.setTitle("Change Photo", for: .normal)
        editAvatarButton.setTitleColor(ASPTheme.Color.accent, for: .normal)
        editAvatarButton.titleLabel?.font = ASPTheme.Font.caption()
        editAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        editAvatarButton.addTarget(self, action: #selector(asp_changeAvatar), for: .touchUpInside)

        let nameLabel = UILabel()
        nameLabel.text = user.username
        nameLabel.font = ASPTheme.Font.title()
        nameLabel.textColor = ASPTheme.Color.textPrimary
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        headerContainer.addSubview(avatarView)
        headerContainer.addSubview(editAvatarButton)
        headerContainer.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 8),
            avatarView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            editAvatarButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            editAvatarButton.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            editAvatarButton.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
        contentStack.addArrangedSubview(headerContainer)

        // Info card.
        let infoCard = ASPInfoCardView()
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        infoCard.asp_configure(rows: [
            ("Email", user.email),
            ("Member Since", ASPFormat.date(user.registerDate)),
            ("Assets", "\(ASPAssetManager.shared.asp_count)"),
            ("Last Login", user.lastLoginDate.map(ASPFormat.dateTime) ?? "—")
        ])
        contentStack.addArrangedSubview(infoCard)

        // Quick links.
        let linksCard = ASPGlassCardView(cornerRadius: ASPTheme.Layout.cardCornerRadius)
        linksCard.translatesAutoresizingMaskIntoConstraints = false
        let linksStack = UIStackView()
        linksStack.axis = .vertical
        linksStack.spacing = 4
        linksStack.translatesAutoresizingMaskIntoConstraints = false
        linksCard.contentView.addSubview(linksStack)
        linksStack.asp_pinEdges(to: linksCard.contentView, inset: 6)

        let timelineItem = ASPSettingItemView()
        timelineItem.asp_configure(icon: "clock.fill", iconColor: ASPTheme.Color.accent, title: "Activity Timeline") { [weak self] in
            self?.navigationController?.pushViewController(ASPTimelineViewController(), animated: true)
        }
        let categoryItem = ASPSettingItemView()
        categoryItem.asp_configure(icon: "square.grid.2x2.fill", iconColor: ASPTheme.Color.accentSecondary, title: "Categories") { [weak self] in
            self?.navigationController?.pushViewController(ASPCategoryViewController(), animated: true)
        }
        linksStack.addArrangedSubview(timelineItem)
        linksStack.addArrangedSubview(categoryItem)
        contentStack.addArrangedSubview(linksCard)
    }

    // MARK: - Actions

    @objc private func asp_editName() {
        let alert = UIAlertController(title: "Edit Username", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = ASPUserManager.shared.currentUser?.username
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let name = alert?.textFields?.first?.text else { return }
            ASPUserManager.shared.asp_updateUsername(name)
            self?.asp_reload()
        })
        present(alert, animated: true)
    }

    @objc private func asp_changeAvatar() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
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
                if let name = ASPStorageManager.shared.asp_saveAssetImage(image) {
                    ASPUserManager.shared.asp_updateAvatar(name)
                    self?.asp_reload()
                }
            }
        }
    }
}
