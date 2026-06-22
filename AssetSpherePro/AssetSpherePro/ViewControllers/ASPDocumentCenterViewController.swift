//
//  ASPDocumentCenterViewController.swift
//  AssetSpherePro
//
//  Local document management: import PDF/DOC/DOCX/TXT files, preview them via
//  QuickLook, and delete them.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook

final class ASPDocumentCenterViewController: ASPBaseViewController,
    UIDocumentPickerDelegate, QLPreviewControllerDataSource {

    private var listStack: UIStackView!
    private let emptyView = ASPEmptyView()
    private var scrollView: UIScrollView!
    private var previewURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documents"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(asp_importTapped))
        asp_buildUI()
        asp_reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        asp_reload()
    }

    private func asp_buildUI() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 10
        listStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(listStack)

        emptyView.isHidden = true
        emptyView.asp_configure(icon: "doc.text", title: "No Documents",
                                message: "Import PDFs, Word files, or text documents to keep them with your assets.",
                                action: "Import Document") { [weak self] in self?.asp_importTapped() }
        view.addSubview(emptyView)

        let inset = ASPTheme.Layout.screenInset
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            listStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: inset),
            listStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -inset),
            listStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset)
        ])
    }

    private func asp_reload() {
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let documents = ASPStorageManager.shared.asp_allDocuments()

        if documents.isEmpty {
            emptyView.isHidden = false
            scrollView.isHidden = true
            return
        }
        emptyView.isHidden = true
        scrollView.isHidden = false

        for document in documents {
            let card = ASPDocumentCardView()
            card.asp_configure(document: document)
//            let tap = ASPTapGesture { [weak self] in self?.asp_preview(document) }
//            card.addGestureRecognizer(tap)

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(asp_longPress(_:)))
            card.addGestureRecognizer(longPress)
            card.accessibilityHint = document.documentId   // stash id for delete lookup

            listStack.addArrangedSubview(card)
        }
    }

    // MARK: - Import

    @objc private func asp_importTapped() {
        let types: [UTType] = [.pdf, .plainText, UTType("com.microsoft.word.doc") ?? .data,
                               UTType("org.openxmlformats.wordprocessingml.document") ?? .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        if ASPStorageManager.shared.asp_importDocument(from: url) != nil {
            asp_reload()
        } else {
            asp_showAlert(title: "Import Failed", message: "That document couldn't be imported.")
        }
    }

    // MARK: - Preview

    private func asp_preview(_ document: ASPDocumentModel) {
        let url = ASPStorageManager.shared.asp_documentURL(document.documentPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            asp_showAlert(title: "File Missing", message: "This document could not be found on disk.")
            return
        }
        previewURL = url
        let preview = QLPreviewController()
        preview.dataSource = self
        present(preview, animated: true)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewURL == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        (previewURL ?? URL(fileURLWithPath: "")) as QLPreviewItem
    }

    // MARK: - Delete

    @objc private func asp_longPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let card = gesture.view,
              let id = card.accessibilityHint else { return }
        asp_showConfirm(title: "Delete Document",
                        message: "Remove this document from your library?") { [weak self] in
            ASPStorageManager.shared.asp_deleteDocument(id: id)
            self?.asp_reload()
        }
    }
}
